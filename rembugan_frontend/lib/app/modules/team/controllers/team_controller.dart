import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/app_toast.dart';
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

  int get projectId => int.tryParse(id) ?? 0;
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
  final String body;
  final String time;
  final bool isMe;
  final bool isSystem;
  final String? replyTo;
  final String? attachment;
  const DiscussionMessage({
    required this.sender,
    required this.body,
    required this.time,
    this.isMe = false,
    this.isSystem = false,
    this.replyTo,
    this.attachment,
  });
}

class WorkspaceTask {
  final String id;
  final String title;
  final String assignee;
  final String assigneeId;
  final String deadline;
  final String status;
  final bool isDone;
  const WorkspaceTask({
    this.id = '',
    required this.title,
    required this.assignee,
    this.assigneeId = '',
    required this.deadline,
    required this.status,
    this.isDone = false,
  });
}

class WorkspaceFile {
  final String name;
  final String uploader;
  final String date;
  final String size;
  final String type;
  const WorkspaceFile({
    required this.name,
    required this.uploader,
    required this.date,
    required this.size,
    required this.type,
  });
}

class TeamController extends GetxController {
  final WorkspaceRepository _repo = WorkspaceRepository();

  var detailTabIndex = 0.obs;
  var workspaceTabIndex = 0.obs;
  final selectedWorkspace = Rxn<WorkspaceModel>();

  final isLoading = true.obs;
  final hasError = false.obs;

  final attachedGroupFileName = RxnString();
  final attachedGroupFileSize = RxnString();

  void attachGroupFile(String name, String size) {
    attachedGroupFileName.value = name;
    attachedGroupFileSize.value = size;
  }

  void removeGroupAttachment() {
    attachedGroupFileName.value = null;
    attachedGroupFileSize.value = null;
  }

  final workspaces = <WorkspaceModel>[].obs;
  final workspaceHistory = <WorkspaceHistory>[].obs;
  final applicants = <WorkspaceApplicant>[].obs;
  final recentActivities = <RecentActivity>[].obs;
  final discussions = <DiscussionMessage>[].obs;
  final tasks = <WorkspaceTask>[].obs;
  final files = <WorkspaceFile>[].obs;
  final channels = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadWorkspaces();
  }

  List<WorkspaceModel> get ownedWorkspaces =>
      workspaces.where((w) => w.isOwned).toList();
  List<WorkspaceModel> get joinedWorkspaces =>
      workspaces.where((w) => !w.isOwned).toList();

  List<WorkspaceApplicant> applicantsFor(String workspaceId) =>
      applicants.where((a) => a.workspaceId == workspaceId).toList();

  void changeDetailTab(int i) => detailTabIndex.value = i;

  void loadWorkspaces() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final result = await _repo.getWorkspaces();
      workspaces.assignAll(result);
      if (result.isNotEmpty) {
        openWorkspace(result.first);
      }
    } catch (e) {
      hasError.value = true;
      debugPrint('loadWorkspaces error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void openWorkspace(WorkspaceModel ws) {
    selectedWorkspace.value = ws;
    detailTabIndex.value = 0;
    _loadWorkspaceDetail(ws.projectId);
  }

  Future<void> _loadWorkspaceDetail(int projectId) async {
    final results = await Future.wait([
      _repo.getDiscussions(projectId),
      _repo.getTasks(projectId),
      _repo.getFiles(projectId),
      _repo.getApplicants(projectId),
    ]);

    discussions.assignAll(results[0] as List<DiscussionMessage>);
    tasks.assignAll(results[1] as List<WorkspaceTask>);
    files.assignAll(results[2] as List<WorkspaceFile>);
    applicants.assignAll(results[3] as List<WorkspaceApplicant>);
  }

  void approveApplicant(WorkspaceApplicant applicant) async {
    final appId = int.tryParse(applicant.id);
    if (appId == null) return;
    final result = await _repo.respondApplication(appId, 'accepted', role: 'Anggota');
    if (result != null) {
      applicants.removeWhere((a) => a.id == applicant.id);
      // Refresh workspace list
      loadWorkspaces();
    }
  }

  void rejectApplicant(WorkspaceApplicant applicant) async {
    final appId = int.tryParse(applicant.id);
    if (appId == null) return;
    final result = await _repo.respondApplication(appId, 'rejected');
    if (result != null) {
      applicants.removeWhere((a) => a.id == applicant.id);
      final ws = selectedWorkspace.value;
      if (ws != null) {
        final idx = workspaces.indexWhere((w) => w.id == ws.id);
        if (idx >= 0) {
          workspaces[idx] = WorkspaceModel(
            id: ws.id,
            name: ws.name,
            category: ws.category,
            description: ws.description,
            userRole: ws.userRole,
            totalTasks: ws.totalTasks,
            doneTasks: ws.doneTasks,
            memberCount: ws.memberCount,
            members: ws.members,
            lastActivity: ws.lastActivity,
            isOwned: ws.isOwned,
            applicants: applicantsFor(ws.id).length,
            unreadCount: ws.unreadCount,
            activityCue: 'Lamaran ${applicant.name} ditolak',
            urgency: ws.urgency,
          );
        }
      }
    }
  }

  void endCollaboration(WorkspaceModel ws) async {
    final ok = await _repo.endCollaboration(ws.projectId);
    if (ok) {
      workspaceHistory.insert(
        0,
        WorkspaceHistory(
          name: ws.name,
          role: ws.userRole,
          members: ws.memberCount,
          finishedAt: 'Selesai hari ini',
          summary: 'Workspace diarsipkan.',
        ),
      );
      applicants.removeWhere((a) => a.workspaceId == ws.id);
      workspaces.removeWhere((w) => w.id == ws.id);
      tasks.clear();
      discussions.clear();
      files.clear();
      selectedWorkspace.value = null;
      detailTabIndex.value = 0;
    }
  }

  void addTask(String title, {String? assigneeId, String? deadline}) async {
    final ws = selectedWorkspace.value;
    if (ws == null) return;
    final result = await _repo.createTask(ws.projectId, title, assigneeId, deadline);
    if (result != null) {
      AppToast.success('Tugas berhasil ditambahkan!');
      _loadWorkspaceDetail(ws.projectId);
    } else {
      AppToast.error('Gagal menambahkan tugas');
    }
  }

  void moveTask(int taskId, String newStatus) async {
    final ok = await _repo.moveTask(taskId, newStatus);
    if (ok) {
      final labels = {'todo': 'To Do', 'doing': 'In Progress', 'done': 'Done'};
      AppToast.success('Berhasil dipindah ke ${labels[newStatus] ?? newStatus}');
      final ws = selectedWorkspace.value;
      if (ws != null) _loadWorkspaceDetail(ws.projectId);
    } else {
      AppToast.error('Gagal memindahkan tugas');
    }
  }

  void updateTask(int taskId, {String? title, String? assigneeId, String? deadline}) async {
    final result = await _repo.updateTask(taskId, title: title, assigneeId: assigneeId, deadline: deadline);
    if (result != null) {
      AppToast.success('Tugas berhasil diedit!');
      final ws = selectedWorkspace.value;
      if (ws != null) _loadWorkspaceDetail(ws.projectId);
    } else {
      AppToast.error('Gagal mengedit tugas');
    }
  }

  void deleteTask(int taskId) async {
    final ok = await _repo.deleteTask(taskId);
    if (ok) {
      AppToast.success('Tugas berhasil dihapus!');
      final ws = selectedWorkspace.value;
      if (ws != null) _loadWorkspaceDetail(ws.projectId);
    } else {
      AppToast.error('Gagal menghapus tugas');
    }
  }

  void kickMember(String userId) async {
    final ws = selectedWorkspace.value;
    if (ws == null) return;
    final name = ws.members.where((m) => m.id == userId).firstOrNull?.name ?? 'Anggota';
    final ok = await _repo.kickMember(ws.projectId, userId);
    if (ok) {
      AppToast.success('$name berhasil dikeluarkan');
      loadWorkspaces();
      _loadWorkspaceDetail(ws.projectId);
    } else {
      AppToast.error('Gagal mengeluarkan anggota');
    }
  }
}
