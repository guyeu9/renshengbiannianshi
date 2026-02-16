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
