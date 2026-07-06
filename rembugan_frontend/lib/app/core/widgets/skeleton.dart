import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 6,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: _animation.value),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({super.key, this.radius = 20});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return const Skeleton(
      width: double.infinity,
      height: double.infinity,
      borderRadius: 100,
    );
  }
}

class SkeletonAvatar extends StatelessWidget {
  const SkeletonAvatar({super.key, this.radius = 20});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: const Skeleton(borderRadius: 100),
    );
  }
}

class SkeletonProfile extends StatelessWidget {
  const SkeletonProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(
          height: MediaQuery.of(context).padding.top + 158,
          child: const Skeleton(borderRadius: 0),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 56, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 47),
              const Skeleton(width: 180, height: 22),
              const SizedBox(height: 8),
              const Skeleton(width: 120, height: 14),
              const SizedBox(height: 12),
              const Skeleton(width: double.infinity, height: 44),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  4,
                  (_) => const Column(
                    children: [
                      Skeleton(width: 48, height: 30),
                      SizedBox(height: 6),
                      Skeleton(width: 60, height: 12),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ...List.generate(3, (_) => const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: double.infinity, height: 200),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        SkeletonAvatar(radius: 16),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Skeleton(width: 140, height: 14),
                              SizedBox(height: 4),
                              Skeleton(width: 100, height: 11),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Skeleton(width: double.infinity, height: 14),
                    SizedBox(height: 6),
                    Skeleton(width: double.infinity, height: 14),
                    SizedBox(height: 6),
                    Skeleton(width: 180, height: 14),
                    SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Skeleton(width: 60, height: 16),
                        Skeleton(width: 60, height: 16),
                        Skeleton(width: 60, height: 16),
                      ],
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }
}

class SkeletonShowcaseList extends StatelessWidget {
  const SkeletonShowcaseList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (_) => Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 12),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SkeletonAvatar(radius: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Skeleton(width: 140, height: 14),
                        SizedBox(height: 4),
                        Skeleton(width: 80, height: 11),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14),
              Skeleton(width: double.infinity, height: 14),
              SizedBox(height: 6),
              Skeleton(width: double.infinity, height: 14),
              SizedBox(height: 6),
              Skeleton(width: 120, height: 14),
              SizedBox(height: 16),
              Skeleton(width: double.infinity, height: 200),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Skeleton(width: 50, height: 16),
                  Skeleton(width: 50, height: 16),
                  Skeleton(width: 50, height: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SkeletonChatList extends StatelessWidget {
  const SkeletonChatList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        6,
        (_) => const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              SkeletonAvatar(radius: 24),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Skeleton(width: 120, height: 14)),
                        SizedBox(width: 8),
                        Skeleton(width: 40, height: 11),
                      ],
                    ),
                    SizedBox(height: 6),
                    Skeleton(width: double.infinity, height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SkeletonNotificationList extends StatelessWidget {
  const SkeletonNotificationList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        6,
        (_) => const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonAvatar(radius: 22),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: double.infinity, height: 13),
                    SizedBox(height: 4),
                    Skeleton(width: 100, height: 11),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SkeletonExplore extends StatelessWidget {
  const SkeletonExplore({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: List.generate(
              3,
              (_) => const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Skeleton(height: 32),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: 3,
            itemBuilder: (_, __) => Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SkeletonAvatar(radius: 18),
                      SizedBox(width: 10),
                      Expanded(child: Skeleton(width: 120, height: 14)),
                    ],
                  ),
                  SizedBox(height: 12),
                  Skeleton(width: double.infinity, height: 14),
                  SizedBox(height: 6),
                  Skeleton(width: 200, height: 14),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Skeleton(width: 60, height: 24),
                      SizedBox(width: 8),
                      Skeleton(width: 80, height: 24),
                    ],
                  ),
                  SizedBox(height: 12),
                  Skeleton(width: double.infinity, height: 140),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Skeleton(width: 60, height: 16),
                      Spacer(),
                      Skeleton(width: 40, height: 16),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SkeletonFeed extends StatelessWidget {
  const SkeletonFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (_) => Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Row(
                  children: [
                    SkeletonAvatar(radius: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Skeleton(width: 140, height: 14),
                          SizedBox(height: 4),
                          Skeleton(width: 80, height: 11),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: double.infinity, height: 14),
                    SizedBox(height: 6),
                    Skeleton(width: double.infinity, height: 14),
                    SizedBox(height: 6),
                    Skeleton(width: 180, height: 14),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Skeleton(width: double.infinity, height: 240),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Skeleton(width: 50, height: 16),
                  Skeleton(width: 50, height: 16),
                  Skeleton(width: 50, height: 16),
                ],
              ),
              SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}
