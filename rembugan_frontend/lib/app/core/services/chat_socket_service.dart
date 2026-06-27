import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/api_config.dart';
import 'api_client.dart';

class ChatSocketService extends GetxService {
  final _api = Get.find<ApiClient>();

  final Map<String, WebSocketChannel> _channels = {};
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _notificationController = StreamController<Map<String, dynamic>>.broadcast();
  final _feedController = StreamController<Map<String, dynamic>>.broadcast();
  final connectionStatus = false.obs;

  Stream<Map<String, dynamic>> get onMessage => _messageController.stream;
  Stream<Map<String, dynamic>> get onNotification => _notificationController.stream;
  Stream<Map<String, dynamic>> get onFeed => _feedController.stream;

  String? _token;
  Timer? _reconnectTimer;
  final Set<String> _joinedRooms = {};

  WebSocketChannel? _feedChannel;
  bool _feedConnected = false;

  @override
  void onInit() {
    super.onInit();
    _initToken().then((_) => connectFeed());
  }

  Future<void> _initToken() async {
    _token = await _api.getToken();
  }

  String _wsBaseUrl() {
    final httpBase = ApiConfig.baseUrl;
    return httpBase.replaceFirst('http://', 'ws://').replaceFirst('https://', 'wss://');
  }

  Future<void> connect(String roomId) async {
    if (_token == null) await _initToken();
    if (_token == null || _token!.isEmpty) return;
    if (_channels.containsKey(roomId)) return;

    try {
      final uri = Uri.parse('${_wsBaseUrl()}/chat/ws/$roomId?token=$_token');
      final channel = WebSocketChannel.connect(uri);
      _channels[roomId] = channel;
      _joinedRooms.add(roomId);
      connectionStatus.value = true;

      channel.stream.listen(
        (data) {
          try {
                final parsed = jsonDecode(data as String) as Map<String, dynamic>;
                parsed['_room_id'] = roomId;
                if (parsed['event'] != 'new_notification') {
                  _messageController.add(parsed);
                }
          } catch (_) {
            _messageController.add({'text': data.toString(), 'type': 'text'});
          }
        },
        onDone: () {
          _channels.remove(roomId);
          _joinedRooms.remove(roomId);
          connectionStatus.value = _channels.isNotEmpty || _feedConnected;
          _scheduleReconnect(roomId);
        },
        onError: (_) {
          _channels.remove(roomId);
          _joinedRooms.remove(roomId);
          connectionStatus.value = _channels.isNotEmpty || _feedConnected;
          _scheduleReconnect(roomId);
        },
      );
    } catch (e) {
      debugPrint('ChatSocketService.connect error: $e');
      _scheduleReconnect(roomId);
    }
  }

  Future<void> connectFeed() async {
    if (_token == null) await _initToken();
    if (_token == null || _token!.isEmpty) return;
    if (_feedConnected) return;

    try {
      final uri = Uri.parse('${_wsBaseUrl()}/chat/ws/feed?token=$_token');
      final channel = WebSocketChannel.connect(uri);
      _feedChannel = channel;
      _feedConnected = true;
      connectionStatus.value = true;

      channel.stream.listen(
        (data) {
          try {
            final parsed = jsonDecode(data as String) as Map<String, dynamic>;
            if (parsed['event'] == 'new_notification') {
              _notificationController.add(parsed['data'] as Map<String, dynamic>);
            } else if (parsed['event'] == 'feed_message') {
              _feedController.add(parsed);
            }
          } catch (_) {}
        },
        onDone: () {
          _feedConnected = false;
          connectionStatus.value = _channels.isNotEmpty || _feedConnected;
          _scheduleFeedReconnect();
        },
        onError: (_) {
          _feedConnected = false;
          connectionStatus.value = _channels.isNotEmpty || _feedConnected;
          _scheduleFeedReconnect();
        },
      );
    } catch (e) {
      debugPrint('ChatSocketService.connectFeed error: $e');
      _scheduleFeedReconnect();
    }
  }

  void disconnectFeed() {
    _feedConnected = false;
    _feedChannel?.sink.close();
    _feedChannel = null;
    connectionStatus.value = _channels.isNotEmpty;
  }

  void _scheduleFeedReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_feedConnected) connectFeed();
    });
  }

  void _scheduleReconnect(String roomId) {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_joinedRooms.contains(roomId)) return;
      connect(roomId);
    });
  }

  void send(String roomId, String text, {String type = 'text', String? attachmentUrl, String? attachmentName, int? attachmentSize, int? replyToId}) {
    final channel = _channels[roomId];
    if (channel == null) return;
    final payload = <String, dynamic>{
      'text': text,
      'type': type,
    };
    if (attachmentUrl != null) payload['attachment_url'] = attachmentUrl;
    if (attachmentName != null) payload['attachment_name'] = attachmentName;
    if (attachmentSize != null) payload['attachment_size'] = attachmentSize;
    if (replyToId != null) payload['reply_to_id'] = replyToId;
    channel.sink.add(jsonEncode(payload));
  }

  void disconnect(String roomId) {
    _joinedRooms.remove(roomId);
    final channel = _channels.remove(roomId);
    channel?.sink.close();
    if (_channels.isEmpty && !_feedConnected) connectionStatus.value = false;
  }

  void disconnectAll() {
    for (final channel in _channels.values) {
      channel.sink.close();
    }
    _channels.clear();
    _joinedRooms.clear();
    disconnectFeed();
    _reconnectTimer?.cancel();
    _token = null;
    connectionStatus.value = false;
  }

  @override
  void onClose() {
    disconnectAll();
    _messageController.close();
    _notificationController.close();
    _feedController.close();
    _reconnectTimer?.cancel();
    super.onClose();
  }
}
