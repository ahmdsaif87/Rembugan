import 'package:get/get.dart';

class WorkspaceMember {
  final String name;
  final String initials;
  final String role;
  final bool isOnline;
  const WorkspaceMember({
    required this.name,
    required this.role,
    this.initials = '',
    this.isOnline = false,
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
  final String? urgency; // null, 'deadline', 'overdue'

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
  final String type; // 'message', 'file', 'task', 'member', 'mention'
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
  final String title;
  final String assignee;
  final String deadline;
  final String status;
  final bool isDone;
  const WorkspaceTask({
    required this.title,
    required this.assignee,
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
  var detailTabIndex = 0.obs;
  var workspaceTabIndex = 0.obs;
  final selectedWorkspace = Rxn<WorkspaceModel>();

  // Group Chat File Attachment State
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

  final workspaces = <WorkspaceModel>[
    WorkspaceModel(
      id: '1',
      name: 'Rembugan App',
      category: 'Mobile Dev',
      description:
          'Platform kolaborasi berbasis mobile untuk ekosistem kampus.',
      userRole: 'Pemilik',
      totalTasks: 7,
      doneTasks: 5,
      applicants: 2,
      unreadCount: 3,
      activityCue: 'Raka mengirim 2 pesan baru',
      urgency: 'deadline',
      memberCount: 5,
      members: const [
        WorkspaceMember(
          name: 'Dede (Kamu)',
          initials: 'DF',
          role: 'Owner',
          isOnline: true,
        ),
        WorkspaceMember(
          name: 'Raka',
          initials: 'RP',
          role: 'Admin',
          isOnline: true,
        ),
        WorkspaceMember(
          name: 'Cameron',
          initials: 'CW',
          role: 'Member',
          isOnline: false,
        ),
        WorkspaceMember(
          name: 'Marvin',
          initials: 'MM',
          role: 'Member',
          isOnline: true,
        ),
        WorkspaceMember(
          name: 'Aisyah',
          initials: 'AN',
          role: 'Member',
          isOnline: false,
        ),
      ],
      lastActivity: '30 menit lalu',
      isOwned: true,
    ),
    WorkspaceModel(
      id: '2',
      name: 'Hackathon 2026',
      category: 'Kompetisi',
      description: 'Persiapan hackathon nasional. Pitch deck, MVP, dan tugas.',
      userRole: 'Pemilik',
      totalTasks: 8,
      doneTasks: 2,
      activityCue: 'Deadline submission besok',
      urgency: 'overdue',
      memberCount: 4,
      members: const [
        WorkspaceMember(
          name: 'Dede (Kamu)',
          initials: 'DF',
          role: 'Owner',
          isOnline: true,
        ),
        WorkspaceMember(
          name: 'Cameron',
          initials: 'CW',
          role: 'Member',
          isOnline: false,
        ),
        WorkspaceMember(
          name: 'Marvin',
          initials: 'MM',
          role: 'Member',
          isOnline: false,
        ),
        WorkspaceMember(
          name: 'Raka',
          initials: 'RP',
          role: 'Member',
          isOnline: true,
        ),
      ],
      lastActivity: '3 jam lalu',
      isOwned: true,
    ),
    WorkspaceModel(
      id: '3',
      name: 'GEMASTIK Data Mining',
      category: 'ML/AI',
      description: 'Tim untuk GEMASTIK XVII bidang Data Mining.',
      userRole: 'Anggota',
      totalTasks: 5,
      doneTasks: 2,
      activityCue: 'Raka upload dataset_v3.csv',
      memberCount: 3,
      members: const [
        WorkspaceMember(
          name: 'Raka',
          initials: 'RP',
          role: 'Owner',
          isOnline: true,
        ),
        WorkspaceMember(
          name: 'Dede (Kamu)',
          initials: 'DF',
          role: 'Member',
          isOnline: true,
        ),
        WorkspaceMember(
          name: 'Aisyah',
          initials: 'AN',
          role: 'Member',
          isOnline: false,
        ),
      ],
      lastActivity: '2 jam lalu',
      isOwned: false,
    ),
  ].obs;

  List<WorkspaceModel> get ownedWorkspaces =>
      workspaces.where((w) => w.isOwned).toList();
  List<WorkspaceModel> get joinedWorkspaces =>
      workspaces.where((w) => !w.isOwned).toList();

  final workspaceHistory = <WorkspaceHistory>[].obs;

  final applicants = <WorkspaceApplicant>[
    const WorkspaceApplicant(
      id: 'app-1',
      workspaceId: '1',
      name: 'Nabila Putri',
      role: 'UI/UX Designer',
      note: 'Ingin bantu rapihin flow onboarding dan prototype testing.',
      skills: ['Figma', 'UX Research', 'Design System'],
    ),
    const WorkspaceApplicant(
      id: 'app-2',
      workspaceId: '1',
      name: 'Farhan Akbar',
      role: 'Backend Developer',
      note: 'Pernah build API FastAPI dan tertarik bantu auth service.',
      skills: ['FastAPI', 'PostgreSQL', 'REST API'],
    ),
  ].obs;

  List<WorkspaceApplicant> applicantsFor(String workspaceId) =>
      applicants.where((a) => a.workspaceId == workspaceId).toList();

  void changeDetailTab(int i) => detailTabIndex.value = i;
  void openWorkspace(WorkspaceModel ws) {
    selectedWorkspace.value = ws;
    detailTabIndex.value = 0;
  }

  void approveApplicant(WorkspaceApplicant applicant) {
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

  void rejectApplicant(WorkspaceApplicant applicant) {
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

  void endCollaboration(WorkspaceModel ws) {
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

  // Recent activity
  final recentActivities = <RecentActivity>[
    const RecentActivity(
      text: 'Raka mengirim pesan di #umum',
      time: '30m lalu',
      workspace: 'Rembugan App',
      type: 'message',
    ),
    const RecentActivity(
      text: 'wireframe_v2.fig diunggah',
      time: '1j lalu',
      workspace: 'Rembugan App',
      type: 'file',
    ),
    const RecentActivity(
      text: 'Task "Setup CI/CD" selesai',
      time: '2j lalu',
      workspace: 'Hackathon 2026',
      type: 'task',
    ),
    const RecentActivity(
      text: 'Aisyah bergabung ke tim',
      time: '3j lalu',
      workspace: 'GEMASTIK',
      type: 'member',
    ),
  ];

  // ── Detail dummy data ──

  final discussions = <DiscussionMessage>[
    const DiscussionMessage(
      sender: '',
      body: 'Raka menambahkan file wireframe_v2.fig',
      time: '10:20',
      isSystem: true,
    ),
    const DiscussionMessage(
      sender: 'Raka',
      body: 'Wireframe onboarding sudah selesai, bisa dicek di Figma ya!',
      time: '10:24',
    ),
    const DiscussionMessage(
      sender: 'Dede',
      body: 'Sudah lihat, bagus! Kita lanjut ke home screen aja.',
      time: '10:31',
      isMe: true,
    ),
    const DiscussionMessage(
      sender: '',
      body: 'Task "Setup CI/CD" diselesaikan oleh Marvin',
      time: '11:00',
      isSystem: true,
    ),
    const DiscussionMessage(
      sender: 'Cameron',
      body: 'Project Flutter sudah disetup, tinggal integrasi API auth nih.',
      time: '11:05',
    ),
    const DiscussionMessage(
      sender: 'Dede',
      body: 'Siap, nanti aku handle bagian auth-nya.',
      time: '11:08',
      isMe: true,
    ),
    const DiscussionMessage(
      sender: 'Aisyah',
      body: 'Mockup profile page sudah aku upload di tab File.',
      time: '11:15',
      attachment: 'profile_mockup_v2.fig',
    ),
  ].obs;

  final channels = ['umum', 'design', 'aset-proyek', 'referensi'];

  final tasks = <WorkspaceTask>[
    const WorkspaceTask(
      title: 'Slicing UI Onboarding',
      assignee: 'Dede',
      deadline: 'Hari ini',
      status: 'In Progress',
    ),
    const WorkspaceTask(
      title: 'Integrasi API Login',
      assignee: 'Cameron',
      deadline: 'Besok',
      status: 'In Progress',
    ),
    const WorkspaceTask(
      title: 'Review UX Flow Chat',
      assignee: 'Raka',
      deadline: '20 Mei',
      status: 'Todo',
    ),
    const WorkspaceTask(
      title: 'Setup CI/CD Pipeline',
      assignee: 'Marvin',
      deadline: '18 Mei',
      status: 'Done',
      isDone: true,
    ),
    const WorkspaceTask(
      title: 'Design System Docs',
      assignee: 'Aisyah',
      deadline: '22 Mei',
      status: 'Todo',
    ),
  ].obs;

  final files = <WorkspaceFile>[
    const WorkspaceFile(
      name: 'profile_mockup_v2.fig',
      uploader: 'Aisyah',
      date: 'Hari ini',
      size: '2.4 MB',
      type: 'fig',
    ),
    const WorkspaceFile(
      name: 'api_spec_v3.pdf',
      uploader: 'Cameron',
      date: 'Kemarin',
      size: '540 KB',
      type: 'pdf',
    ),
    const WorkspaceFile(
      name: 'meeting_notes.doc',
      uploader: 'Dede',
      date: '15 Mei',
      size: '128 KB',
      type: 'doc',
    ),
    const WorkspaceFile(
      name: 'wireframe_explore.png',
      uploader: 'Raka',
      date: '14 Mei',
      size: '1.8 MB',
      type: 'png',
    ),
  ].obs;
}
