import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/bond/presentation/bond_page.dart';
import '../features/food/presentation/food_page.dart';
import '../features/goal/presentation/goal_page.dart';
import '../features/home_schedule/presentation/home_schedule_page.dart';
import '../features/moment/presentation/moment_page.dart';
import '../features/travel/presentation/travel_page.dart';

final appTabIndexProvider = StateProvider<int>((ref) => 0);

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  static const _tabs = <Widget>[
    HomeSchedulePage(),
    FoodPage(),
    MomentPage(),
    TravelPage(),
    GoalPage(),
    BondPage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(appTabIndexProvider);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: index,
        children: _tabs,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        heroTag: 'app_shell_quick_create',
        backgroundColor: const Color(0xFF2BCDEE),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () => _showQuickCreateSheet(context, ref),
        child: const Icon(Icons.add, size: 28),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xF2FFFFFF),
          border: Border(top: BorderSide(color: Color(0xFFF3F4F6), width: 1)),
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: BottomNavigationBar(
                  currentIndex: index,
                  onTap: (next) => ref.read(appTabIndexProvider.notifier).state = next,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.calendar_today),
                      label: '日程',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.restaurant),
                      label: '美食',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.auto_awesome),
                      label: '小确幸',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.airplanemode_active),
                      label: '旅行',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.outlined_flag),
                      label: '目标',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.group),
                      label: '羁绊',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void _showQuickCreateSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(20, 10, 20, 18 + MediaQuery.paddingOf(sheetContext).bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 14),
              const Text('添加新记录', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 18.0;
                  final itemWidth = (constraints.maxWidth - spacing * 2) / 3;
                  return Wrap(
                    alignment: WrapAlignment.center,
                    spacing: spacing,
                    runSpacing: 22,
                    children: [
                      _QuickCreateEntry(
                        width: itemWidth,
                        label: '美食',
                        icon: Icons.restaurant,
                        color: Color(0xFFF97316),
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FoodCreatePage()));
                        },
                      ),
                      _QuickCreateEntry(
                        width: itemWidth,
                        label: '小确幸',
                        icon: Icons.auto_awesome,
                        color: Color(0xFFFBBF24),
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MomentCreatePage()));
                        },
                      ),
                      _QuickCreateEntry(
                        width: itemWidth,
                        label: '旅行',
                        icon: Icons.airplanemode_active,
                        color: Color(0xFF3B82F6),
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TravelCreatePage()));
                        },
                      ),
                      _QuickCreateEntry(
                        width: itemWidth,
                        label: '目标',
                        icon: Icons.outlined_flag,
                        color: Color(0xFFA855F7),
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GoalCreatePage()));
                        },
                      ),
                      _QuickCreateEntry(
                        width: itemWidth,
                        label: '添加朋友',
                        icon: Icons.person_add,
                        color: Color(0xFFEC4899),
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          ref.read(appTabIndexProvider.notifier).state = 5;
                          final navigator = Navigator.of(context);
                          Future.microtask(() {
                            navigator.push(MaterialPageRoute(builder: (_) => const FriendCreatePage()));
                          });
                        },
                      ),
                      _QuickCreateEntry(
                        width: itemWidth,
                        label: '相遇',
                        icon: Icons.emoji_people,
                        color: Color(0xFF14B8A6),
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EncounterCreatePage()));
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      );
    },
  );
}

class _QuickCreateEntry extends StatelessWidget {
  const _QuickCreateEntry({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.width = 86,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
          ],
        ),
      ),
    );
  }
}
