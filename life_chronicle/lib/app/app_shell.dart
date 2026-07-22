import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/config/module_management_config.dart';
import '../core/providers/vector_search_provider.dart';
import '../core/router/app_router.dart';
import '../core/utils/icon_utils.dart';

class AppShell extends ConsumerStatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(vectorIndexManagerInitializerProvider.future);
    });
  }

  /// 构建当前可用的底部 Tab 配置列表（首页 + 已启用模块）
  List<_BottomTabEntry> _buildTabEntries(ModuleManagementConfig config) {
    final entries = <_BottomTabEntry>[
      _BottomTabEntry(
        route: AppRoutes.home,
        label: '日程',
        iconName: 'calendar_today',
      ),
    ];
    // 按固定顺序追加已启用（showOnCalendar）的模块
    const moduleOrder = ['food', 'moment', 'travel', 'goal', 'bond'];
    const routeByKey = <String, String>{
      'food': AppRoutes.food,
      'moment': AppRoutes.moment,
      'travel': AppRoutes.travel,
      'goal': AppRoutes.goal,
      'bond': AppRoutes.bond,
    };
    for (final key in moduleOrder) {
      final module = config.modules[key];
      if (module == null) continue;
      if (!module.showOnCalendar) continue;
      entries.add(_BottomTabEntry(
        route: routeByKey[key] ?? AppRoutes.home,
        label: module.title,
        iconName: module.iconName,
      ));
    }
    return entries;
  }

  int _getTabIndexFromLocation(String location, List<_BottomTabEntry> entries) {
    for (int i = entries.length - 1; i >= 1; i--) {
      if (location.startsWith(entries[i].route)) return i;
    }
    return 0;
  }

  void _onTabTapped(int index, List<_BottomTabEntry> entries) {
    context.go(entries[index].route);
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final configAsync = ref.watch(moduleManagementConfigProvider);
    final config = configAsync.maybeWhen(
      data: (c) => c,
      orElse: () => ModuleManagementConfig.defaults(),
    );
    final entries = _buildTabEntries(config);
    final index = _getTabIndexFromLocation(location, entries).clamp(0, entries.length - 1);

    return Scaffold(
      extendBody: true,
      body: widget.child,
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
                  onTap: (i) => _onTabTapped(i, entries),
                  type: BottomNavigationBarType.fixed,
                  items: [
                    for (final entry in entries)
                      BottomNavigationBarItem(
                        icon: Icon(IconUtils.fromName(entry.iconName)),
                        label: entry.label,
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

/// 底部 Tab 配置项
class _BottomTabEntry {
  const _BottomTabEntry({
    required this.route,
    required this.label,
    required this.iconName,
  });

  final String route;
  final String label;
  final String iconName;
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
                builder: (layoutContext, constraints) {
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
                        color: const Color(0xFFF97316),
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          context.go('${AppRoutes.food}/create');
                        },
                      ),
                      _QuickCreateEntry(
                        width: itemWidth,
                        label: '小确幸',
                        icon: Icons.auto_awesome,
                        color: const Color(0xFFFBBF24),
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          context.go('${AppRoutes.moment}/create');
                        },
                      ),
                      _QuickCreateEntry(
                        width: itemWidth,
                        label: '旅行',
                        icon: Icons.airplanemode_active,
                        color: const Color(0xFF3B82F6),
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          context.go('${AppRoutes.travel}/create');
                        },
                      ),
                      _QuickCreateEntry(
                        width: itemWidth,
                        label: '目标',
                        icon: Icons.outlined_flag,
                        color: const Color(0xFFA855F7),
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          context.go('${AppRoutes.goal}/create');
                        },
                      ),
                      _QuickCreateEntry(
                        width: itemWidth,
                        label: '添加朋友',
                        icon: Icons.person_add,
                        color: const Color(0xFFEC4899),
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          context.go(AppRoutes.friendCreate);
                        },
                      ),
                      _QuickCreateEntry(
                        width: itemWidth,
                        label: '相遇',
                        icon: Icons.emoji_people,
                        color: const Color(0xFF14B8A6),
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          context.go(AppRoutes.encounterCreate);
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
