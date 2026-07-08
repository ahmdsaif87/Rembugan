import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/chat_socket_service.dart';
import '../data/repositories/workspace_repository.dart';

class WorkspaceMember {
  final String id;
  final String name;
  final String initials;
  final String role;
  final bool isOnline;
  final String? photoUrl;
  const WorkspaceMember({
    required this.id,
    required this.name,
    required this.role,
    this.initials = '',
    this.isOnline = false,
    this.photoUrl,
  });
}

class WorkspaceModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final String userRole;
  final int totalTasks;
  final int doneTasks;
  final int memberCount;
  final List<WorkspaceMember> members;
  final String lastActivity;
  final bool isOwned;
  final int applicants;
  final int unreadCount;
  final String? activityCue;
  final String? urgency;

  const WorkspaceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.userRole,
    required this.totalTasks,
    required this.doneTasks,
    required this.memberCount,
    required this.members,
    required this.lastActivity,
    this.isOwned = false,
    this.applicants = 0,
    this.unreadCount = 0,
    this.activityCue,
    this.urgency,
  });

  double get progress => totalTasks > 0 ? doneTasks / totalTasks : 0;

  WorkspaceModel copyWith({
    int? totalTasks,
    int? doneTasks,
    int? memberCount,
    List<WorkspaceMember>? members,
    int? applicants,
    int? unreadCount,
    String? activityCue,
    String? urgency,
  }) {
    return WorkspaceModel(
      id: id,
      name: name,
      category: category,
      description: description,
      userRole: userRole,
      totalTasks: totalTasks ?? this.totalTasks,
      doneTasks: doneTasks ?? this.doneTasks,
      memberCount: memberCount ?? this.memberCount,
      members: members ?? this.members,
      lastActivity: lastActivity,
      isOwned: isOwned,
      applicants: applicants ?? this.applicants,
      unreadCount: unreadCount ?? this.unreadCount,
      activityCue: activityCue ?? this.activityCue,
      urgency: urgency ?? this.urgency,
    );
  }
}

class WorkspaceApplicant {
  final String id;
  final String workspaceId;
  final String name;
  final String role;
  final String note;
  final List<String> skills;

  const WorkspaceApplicant({
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.role,
    required this.note,
    required this.skills,
  });
}

class WorkspaceHistory {
  final String name;
  final String role;
  final int members;
  final String finishedAt;
  final String summary;

  const WorkspaceHistory({
    required this.name,
    required this.role,
    required this.members,
    required this.finishedAt,
    required this.summary,
  });
}

class RecentActivity {
  final String text;
  final String time;
  final String workspace;
  final String type;
  const RecentActivity({
    required this.text,
    required this.time,
    required this.workspace,
    this.type = 'activity',
  });
}

class DiscussionMessage {
  final String sender;
  final String? senderPhotoUrl;
  final String body;
  final String type;
  final String time;
  final bool isMe;
  final bool isSystem;
  final String? replyTo;
  final AttachmentData? attachment;
  const DiscussionMessage({
    required this.sender,
    required this.body,
    required this.time,
    this.senderPhotoUrl,
    this.type = 'text',
    this.isMe = false,
    this.isSystem = false,
    this.replyTo,
    this.attachment,
  });
}

class AttachmentData {
  final String url;
  final String? name;
  final int? size;
  const AttachmentData({required this.url, this.name, this.size});
}

class WorkspaceTask {
  final int id;
  final String title;
  final List<String> assigneeNames;
  final List<String> assigneeIds;
  final String deadline;
  final String status;
  final bool isDone;
  const WorkspaceTask({
    this.id = 0,
    required this.title,
    this.assigneeNames = const [],
    this.assigneeIds = const [],
    required this.deadline,
    required this.status,
    this.isDone = false,
  });
}

class WorkspaceFile {
  final int id;
  final String name;
  final String uploader;
  final String date;
  final String size;
  final String type;
  final String url;
  const WorkspaceFile({
    this.id = 0,
    required this.name,
    required this.uploader,
    required this.date,
    required this.size,
    required this.type,
    this.url = '',
  });
}

class TeamController extends GetxController {
  final WorkspaceRepository _repo = WorkspaceRepository();
  StreamSubscription? _wsSub;

  var detailTabIndex = 0.obs;
  var workspaceFilter = 0.obs; // 0=all, 1=owned, 2=joined
  final isLoading = true.obs;
  final selectedWorkspace = Rxn<WorkspaceModel>();

  final attachedGroupFileName = RxnString();
  final attachedGroupFileSize = RxnString();
  final isUploading = false.obs;

  void attachGroupFile(String name, String size) {
    attachedGroupFileName.value = name;
    attachedGroupFileSize.value = size;
  }

  void removeGroupAttachment() {
    attachedGroupFileName.value = null;
    attachedGroupFileSize.value = null;
  }

  final workspaces = <WorkspaceModel>[].obs;

  List<WorkspaceModel> get ownedWorkspaces =>
      workspaces.where((w) => w.isOwned).toList();
  List<WorkspaceModel> get joinedWorkspaces =>
      workspaces.where((w) => !w.isOwned).toList();

  List<WorkspaceModel> get filteredWorkspaces {
    switch (workspaceFilter.value) {
      case 1: return ownedWorkspaces;
      case 2: return joinedWorkspaces;
      default: return workspaces;
    }
  }

  final workspaceHistory = <WorkspaceHistory>[].obs;
  final applicants = <WorkspaceApplicant>[].obs;
  final discussions = <DiscussionMessage>[].obs;
  final tasks = <WorkspaceTask>[].obs;
  final files = <WorkspaceFile>[].obs;
  final recentActivities = <RecentActivity>[];
  final channels = ['umum', 'design', 'aset-proyek', 'referensi'];

  @override
  void onInit() {
    super.onInit();
    fetchWorkspaces();
  }

  @override
  void onClose() {
    _disconnectWs();
    _wsSub?.cancel();
    super.onClose();
  }

  void _connectWs() {
    final ws = selectedWorkspace.value;
    if (ws == null) return;
    final roomId = ws.id;
    try {
      final socket = Get.find<ChatSocketService>();
      socket.connect(roomId);
      _wsSub?.cancel();
      _wsSub = socket.onMessage.listen((data) {
        final senderId = data['sender_id'] as String? ?? '';
        final isMe = senderId == _getMyId();
        discussions.add(DiscussionMessage(
          sender: data['sender_name'] as String? ?? (isMe ? 'Saya' : ''),
          body: data['text'] as String? ?? '',
          type: data['type'] as String? ?? 'text',
          time: data['timestamp'] as String? ?? '',
          isMe: isMe,
          isSystem: data['type'] == 'system',
          senderPhotoUrl: data['sender_photo_url'] as String?,
          attachment: data['attachment_url'] != null
              ? AttachmentData(
                  url: data['attachment_url'] as String,
                  name: data['attachment_name'] as String?,
                  size: data['attachment_size'] as int?,
                )
              : null,
        ));
      });
    } catch (_) {}
  }

  void _disconnectWs() {
    final ws = selectedWorkspace.value;
    if (ws == null) return;
    try {
      Get.find<ChatSocketService>().disconnect(ws.id);
    } catch (_) {}
  }

  String _getMyId() {
    try {
      final auth = Get.find<AuthService>();
      return auth.currentUser.value?.id ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<void> fetchWorkspaces() async {
    isLoading.value = true;
    try {
      workspaces.assignAll(await _repo.getWorkspaces());
    } catch (e) {
      debugPrint('Error fetching workspaces: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<WorkspaceApplicant> applicantsFor(String workspaceId) =>
      applicants.where((a) => a.workspaceId == workspaceId).toList();

  void changeDetailTab(int i) => detailTabIndex.value = i;

  Future<void> openWorkspace(WorkspaceModel ws) async {
    _disconnectWs();
    selectedWorkspace.value = ws;
    detailTabIndex.value = 0;
    final pid = int.tryParse(ws.id) ?? 0;
    if (pid == 0) return;

    final results = await Future.wait([
      _repo.getDiscussions(pid),
      _repo.getTasks(pid),
      _repo.getFiles(pid),
      _repo.getApplicants(pid),
    ]);
    discussions.assignAll(results[0] as List<DiscussionMessage>);
    tasks.assignAll(results[1] as List<WorkspaceTask>);
    files.assignAll(results[2] as List<WorkspaceFile>);
    applicants.assignAll(results[3] as List<WorkspaceApplicant>);
    _connectWs();
  }

  void sendMessage(String text) {
    final ws = selectedWorkspace.value;
    if (ws == null || text.trim().isEmpty) return;
    try {
      Get.find<ChatSocketService>().send(ws.id, text.trim());
    } catch (_) {}
  }

  Future<void> uploadAndSendFile() async {
    final ws = selectedWorkspace.value;
    if (ws == null) return;
    final pid = int.tryParse(ws.id);
    if (pid == null) return;
    isUploading.value = true;
    try {
      await _repo.uploadWorkspaceFile(pid);
      final updatedFiles = await _repo.getFiles(pid);
      files.assignAll(updatedFiles);
    } catch (e) {
      debugPrint('uploadAndSendFile error: $e');
    }
    isUploading.value = false;
  }

  void sendReply(String text, int? replyToId) {
    final ws = selectedWorkspace.value;
    if (ws == null || text.trim().isEmpty) return;
    try {
      Get.find<ChatSocketService>().send(ws.id, text.trim(), replyToId: replyToId);
    } catch (_) {}
  }

  Future<void> approveApplicant(WorkspaceApplicant applicant) async {
    final id = int.tryParse(applicant.id);
    if (id == null) return;
    await _repo.respondApplication(id, 'accepted', role: applicant.role);

    applicants.removeWhere((a) => a.id == applicant.id);
    final index = workspaces.indexWhere((w) => w.id == applicant.workspaceId);
    if (index == -1) return;

    final ws = workspaces[index];
    final updated = ws.copyWith(
      applicants: applicantsFor(ws.id).length,
      memberCount: ws.memberCount + 1,
      members: [
        ...ws.members,
        WorkspaceMember(
          id: applicant.id,
          name: applicant.name,
          initials: applicant.name
              .split(' ')
              .where((part) => part.isNotEmpty)
              .take(2)
              .map((part) => part[0])
              .join()
              .toUpperCase(),
          role: applicant.role,
        ),
      ],
      activityCue: '${applicant.name} diterima ke workspace',
    );
    workspaces[index] = updated;
    selectedWorkspace.value = updated;
  }

  Future<void> rejectApplicant(WorkspaceApplicant applicant) async {
    final id = int.tryParse(applicant.id);
    if (id == null) return;
    await _repo.respondApplication(id, 'rejected');

    applicants.removeWhere((a) => a.id == applicant.id);
    final index = workspaces.indexWhere((w) => w.id == applicant.workspaceId);
    if (index == -1) return;

    final ws = workspaces[index];
    final updated = ws.copyWith(
      applicants: applicantsFor(ws.id).length,
      activityCue: 'Lamaran ${applicant.name} ditolak',
    );
    workspaces[index] = updated;
    selectedWorkspace.value = updated;
  }

  Future<void> endCollaboration(WorkspaceModel ws) async {
    final pid = int.tryParse(ws.id);
    if (pid != null) {
      await _repo.endCollaboration(pid);
    }

    workspaceHistory.insert(
      0,
      WorkspaceHistory(
        name: ws.name,
        role: ws.userRole,
        members: ws.memberCount,
        finishedAt: 'Selesai hari ini',
        summary: 'Workspace diarsipkan. Tugas dan obrolan aktif dibersihkan.',
      ),
    );
    applicants.removeWhere((a) => a.workspaceId == ws.id);
    workspaces.removeWhere((w) => w.id == ws.id);
    tasks.clear();
    discussions.clear();
    selectedWorkspace.value = null;
    detailTabIndex.value = 0;
  }

  Future<void> createTask(String title, List<String> assigneeIds, String? deadline) async {
    final ws = selectedWorkspace.value;
    if (ws == null) return;
    final pid = int.tryParse(ws.id);
    if (pid == null) return;
    await _repo.createTask(pid, title, assigneeIds, deadline);
    tasks.assignAll(await _repo.getTasks(pid));
  }

  Future<void> moveTask(int taskId, String newStatus) async {
    await _repo.moveTask(taskId, newStatus);
    final ws = selectedWorkspace.value;
    if (ws == null) return;
    final pid = int.tryParse(ws.id);
    if (pid == null) return;
    tasks.assignAll(await _repo.getTasks(pid));
  }

  Future<void> updateTask(int taskId, {String? title, List<String>? assigneeIds, String? deadline}) async {
    await _repo.updateTask(taskId, title: title, assigneeIds: assigneeIds, deadline: deadline);
    final ws = selectedWorkspace.value;
    if (ws == null) return;
    final pid = int.tryParse(ws.id);
    if (pid == null) return;
    tasks.assignAll(await _repo.getTasks(pid));
  }

  Future<void> deleteTask(int taskId) async {
    await _repo.deleteTask(taskId);
    final ws = selectedWorkspace.value;
    if (ws == null) return;
    final pid = int.tryParse(ws.id);
    if (pid == null) return;
    tasks.assignAll(await _repo.getTasks(pid));
  }

  Future<bool> createProject({
    required String title,
    required String description,
    required List<String> requiredSkills,
    String? category,
    String? deadline,
    int? totalSlots,
  }) async {
    final result = await _repo.createProject(
      title: title,
      description: description,
      requiredSkills: requiredSkills,
      category: category,
      deadline: deadline,
      totalSlots: totalSlots,
    );
    if (result != null) {
      await fetchWorkspaces();
      return true;
    }
    return false;
  }

  Future<bool> joinProject(String token) async {
    final ok = await _repo.joinProject(token);
    if (ok) {
      await fetchWorkspaces();
      return true;
    }
    return false;
  }

  Future<bool> kickMemberLocal(int projectId, String userId) async {
    final ok = await _repo.kickMember(projectId, userId);
    if (ok) {
      await fetchWorkspaces();
      final ws = selectedWorkspace.value;
      if (ws != null) {
        final updated = await _repo.getWorkspaceDetail(projectId);
        if (updated != null) selectedWorkspace.value = updated;
      }
    }
    return ok;
  }
}
