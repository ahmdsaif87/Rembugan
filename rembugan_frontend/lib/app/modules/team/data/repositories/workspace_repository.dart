import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/services/api_client.dart';
import '../../controllers/team_controller.dart';

class WorkspaceRepository {
  late final _api = Get.find<ApiClient>();

  Future<List<WorkspaceModel>> getWorkspaces() async {
    try {
      final response = await _api.get('/workspace/');
      final data = response.data as Map<String, dynamic>;
      final items = data['data'] as List<dynamic>? ?? [];
      return items.map((e) => _mapToWorkspace(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('WorkspaceRepository.getWorkspaces error: $e');
      return [];
    }
  }

  Future<WorkspaceModel?> getWorkspaceDetail(int projectId) async {
    try {
      final response = await _api.get('/workspace/$projectId');
      final data = response.data as Map<String, dynamic>;
      final item = data['data'] as Map<String, dynamic>?;
      if (item == null) return null;
      return _mapToWorkspace(item);
    } catch (e) {
      debugPrint('WorkspaceRepository.getWorkspaceDetail error: $e');
      return null;
    }
  }

  Future<List<DiscussionMessage>> getDiscussions(int projectId) async {
    try {
      final response = await _api.get('/workspace/$projectId/discussions');
      final data = response.data as Map<String, dynamic>;
      final items = data['data'] as List<dynamic>? ?? [];
      return items.map((e) {
        final raw = e as Map<String, dynamic>;
        AttachmentData? attachment;
        final attRaw = raw['attachment'] as Map<String, dynamic>?;
        if (attRaw != null && attRaw['url'] != null) {
          attachment = AttachmentData(
            url: attRaw['url'] as String,
            name: attRaw['name'] as String?,
            size: attRaw['size'] as int?,
          );
        }
        return DiscussionMessage(
          sender: raw['sender'] as String? ?? '',
          body: raw['body'] as String? ?? '',
          type: raw['type'] as String? ?? 'text',
          time: raw['time'] as String? ?? '',
          isMe: raw['is_me'] as bool? ?? false,
          isSystem: raw['is_system'] as bool? ?? false,
          replyTo: raw['reply_to'] as String?,
          senderPhotoUrl: raw['sender_photo_url'] as String?,
          attachment: attachment,
        );
      }).toList();
    } catch (e) {
      debugPrint('WorkspaceRepository.getDiscussions error: $e');
      return [];
    }
  }

  Future<List<WorkspaceTask>> getTasks(int projectId) async {
    try {
      final response = await _api.get('/workspace/$projectId/tasks');
      final data = response.data as Map<String, dynamic>;
      final board = data['board'] as Map<String, dynamic>? ?? {};
      final tasks = <WorkspaceTask>[];
      board.forEach((status, items) {
        final list = items as List<dynamic>? ?? [];
        for (final e in list) {
          final raw = e as Map<String, dynamic>;
          final assigneeList = (raw['assignees'] as List<dynamic>?)
                  ?.map((a) => a as Map<String, dynamic>)
                  .toList() ??
              [];
          tasks.add(WorkspaceTask(
            id: raw['id'] as int? ?? 0,
            title: raw['title'] as String? ?? '',
            assigneeNames: assigneeList
                .map((a) => a['name'] as String? ?? '')
                .toList(),
            assigneeIds: assigneeList
                .map((a) => a['id'] as String? ?? '')
                .toList(),
            deadline: raw['deadline'] as String? ?? '',
            status: status,
            isDone: status == 'done',
          ));
        }
      });
      return tasks;
    } catch (e) {
      debugPrint('WorkspaceRepository.getTasks error: $e');
      return [];
    }
  }

  Future<List<WorkspaceFile>> getFiles(int projectId) async {
    try {
      final response = await _api.get('/workspace/$projectId/files');
      final data = response.data as Map<String, dynamic>;
      final items = data['data'] as List<dynamic>? ?? [];
      return items.map((e) {
        final raw = e as Map<String, dynamic>;
        return WorkspaceFile(
          id: raw['id'] as int? ?? 0,
          name: raw['name'] as String? ?? '',
          uploader: raw['uploader'] as String? ?? '',
          date: raw['date'] as String? ?? '',
          size: raw['size'] as String? ?? '',
          type: raw['type'] as String? ?? 'file',
          url: raw['url'] as String? ?? '',
        );
      }).toList();
    } catch (e) {
      debugPrint('WorkspaceRepository.getFiles error: $e');
      return [];
    }
  }

  Future<List<WorkspaceApplicant>> getApplicants(int projectId) async {
    try {
      final response = await _api.get('/workspace/$projectId/applicants');
      final data = response.data as Map<String, dynamic>;
      final items = data['data'] as List<dynamic>? ?? [];
      return items.map((e) {
        final raw = e as Map<String, dynamic>;
        final skills = (raw['skills'] as List<dynamic>?)
                ?.map((s) => s.toString()).toList() ??
            [];
        return WorkspaceApplicant(
          id: raw['id'] as String? ?? '',
          workspaceId: raw['workspace_id'] as String? ?? '',
          name: raw['name'] as String? ?? '',
          role: raw['role'] as String? ?? '',
          note: raw['note'] as String? ?? '',
          skills: skills,
        );
      }).toList();
    } catch (e) {
      debugPrint('WorkspaceRepository.getApplicants error: $e');
      return [];
    }
  }

  Future<void> uploadWorkspaceFile(int projectId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    Uint8List bytes;
    if (file.bytes != null) {
      bytes = file.bytes!;
    } else if (file.path != null) {
      bytes = await File(file.path!).readAsBytes();
    } else {
      return;
    }
    await _api.uploadImageBytes(
      '/workspace/$projectId/files',
      bytes,
      filename: file.name,
    );
  }

  Future<Map<String, dynamic>?> createTask(int projectId, String title, List<String> assigneeIds, String? deadline) async {
    try {
      final response = await _api.post('/workspace/$projectId/tasks', data: {
        'title': title,
        'assignee_ids': assigneeIds,
        if (deadline != null) 'deadline': deadline,
      });
      final data = response.data as Map<String, dynamic>;
      return data;
    } catch (e) {
      debugPrint('WorkspaceRepository.createTask error: $e');
      return null;
    }
  }

  Future<bool> moveTask(int taskId, String newStatus) async {
    try {
      await _api.put('/workspace/tasks/$taskId/move', data: {'status': newStatus});
      return true;
    } catch (e) {
      debugPrint('WorkspaceRepository.moveTask error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> updateTask(int taskId, {String? title, List<String>? assigneeIds, String? deadline}) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (assigneeIds != null) data['assignee_ids'] = assigneeIds;
      if (deadline != null) data['deadline'] = deadline;
      final response = await _api.put('/workspace/tasks/$taskId', data: data);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('WorkspaceRepository.updateTask error: $e');
      return null;
    }
  }

  Future<bool> deleteTask(int taskId) async {
    try {
      await _api.delete('/workspace/tasks/$taskId');
      return true;
    } catch (e) {
      debugPrint('WorkspaceRepository.deleteTask error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> applyToProject(int projectId) async {
    try {
      final response = await _api.post('/collaboration/apply', data: {
        'project_id': projectId,
      });
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('WorkspaceRepository.applyToProject error: $e');
      return null;
    }
  }

  Future<bool> endCollaboration(int projectId) async {
    try {
      await _api.post('/workspace/$projectId/end');
      return true;
    } catch (e) {
      debugPrint('WorkspaceRepository.endCollaboration error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> respondApplication(int applicationId, String status, {String? role}) async {
    try {
      final response = await _api.put('/collaboration/applications/$applicationId/respond', data: {
        'status': status,
        if (role != null) 'role': role,
      });
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('WorkspaceRepository.respondApplication error: $e');
      return null;
    }
  }

  WorkspaceModel _mapToWorkspace(Map<String, dynamic> raw) {
    final membersList = (raw['members'] as List<dynamic>?)
            ?.map((m) {
              final mr = m as Map<String, dynamic>;
               return WorkspaceMember(
                id: mr['user_id'] as String? ?? '',
                name: mr['name'] as String? ?? '',
                role: mr['role'] as String? ?? '',
                initials: mr['initials'] as String? ?? '',
                isOnline: mr['is_online'] as bool? ?? false,
                photoUrl: mr['photo_url'] as String?,
              );
            }).toList() ??
        [];

    final activityCue = raw['activity_cue'] as String?;

    return WorkspaceModel(
      id: raw['id'].toString(),
      name: raw['name'] as String? ?? '',
      category: '',
      description: raw['description'] as String? ?? '',
      userRole: raw['user_role'] as String? ?? '',
      totalTasks: raw['total_tasks'] as int? ?? 0,
      doneTasks: raw['done_tasks'] as int? ?? 0,
      memberCount: raw['member_count'] as int? ?? membersList.length,
      members: membersList,
      lastActivity: raw['last_activity'] as String? ?? '',
      isOwned: raw['is_owned'] as bool? ?? false,
      applicants: raw['applicants'] as int? ?? 0,
      unreadCount: raw['unread_count'] as int? ?? 0,
      activityCue: activityCue,
      urgency: raw['urgency'] as String?,
    );
  }

  Future<bool> kickMember(int projectId, String userId) async {
    try {
      await _api.post('/projects/$projectId/members/$userId/kick');
      return true;
    } catch (e) {
      debugPrint('WorkspaceRepository.kickMember error: $e');
      return false;
    }
  }

}
