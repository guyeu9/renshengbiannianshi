import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drift/drift.dart' show OrderingMode, OrderingTerm;

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const _background = Color(0xFFF2F4F6);
  static const _primary = Color(0xFF8AB4F8);
  static const _accent = Color(0xFFE2F0FD);
  static const _softRed = Color(0xFFFFEBEE);
  static const _softBlue = Color(0xFFE3F2FD);
  static const _softPurple = Color(0xFFF3E5F5);
  static const _iconRed = Color(0xFFEF5350);
  static const _iconBlue = Color(0xFF42A5F5);
  static const _iconPurple = Color(0xFFAB47BC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _FrostedCircleButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  Row(
                    children: [
                      _FrostedCircleButton(icon: Icons.share, onTap: () {}),
                      const SizedBox(width: 12),
                      _FrostedCircleButton(icon: Icons.notifications, onTap: () {}),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(bottom: 40 + MediaQuery.paddingOf(context).bottom),
                children: [
                  const _Header(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ChronicleCard(
                          onGenerate: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ChronicleGenerateConfigPage()),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const _SectionTitle(title: '功能管理'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _LargeTile(
                                icon: Icons.collections_bookmark,
                                iconBg: _softPurple,
                                iconColor: _iconPurple,
                                title: '收藏中心',
                                subtitle: '美食 · 旅行 · 小确幸',
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const FavoritesCenterPage()),
                                ),
                                trailingIcon: Icons.ios_share,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _SmallTile(
                                icon: Icons.history_toggle_off,
                                iconBg: _accent,
                                iconColor: const Color(0xFF5D8CC0),
                                title: '编年史管理',
                                subtitle: '查看历史版本',
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const ChronicleManagePage()),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SmallTile(
                                icon: Icons.analytics,
                                iconBg: _softRed,
                                iconColor: _iconRed,
                                title: '年度报告',
                                subtitle: '回顾过往精彩',
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const YearReportPage()),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _SmallTile(
                                icon: Icons.cloud_upload,
                                iconBg: _softBlue,
                                iconColor: _iconBlue,
                                title: '数据备份',
                                subtitle: '云端安全存储',
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const DataManagementPage()),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SmallTile(
                                icon: Icons.dashboard_customize,
                                iconBg: _accent,
                                iconColor: const Color(0xFF5D8CC0),
                                title: '模块管理',
                                subtitle: '个性化主页',
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const ModuleManagementPage()),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _ListGroup(
                          items: [
                            _ListItem(
                              icon: Icons.hub,
                              iconColor: const Color(0xFF4CAF50),
                              title: '万物互联',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const UniversalLinkPage()),
                              ),
                            ),
                            _ListItem(
                              icon: Icons.notifications_active,
                              iconColor: Colors.black,
                              title: '提醒设置',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const ReminderSettingsPage()),
                              ),
                            ),
                            _ListItem(
                              icon: Icons.lock,
                              iconColor: Colors.black,
                              title: '隐私与安全',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const PrivacySecurityPage()),
                              ),
                            ),
                            _ListItem(
                              icon: Icons.help,
                              iconColor: Colors.black,
                              title: '帮助与反馈',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const HelpFeedbackPage()),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                            foregroundColor: const Color(0xFF9CA3AF),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ).copyWith(
                            backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
                          ),
                          onPressed: () {},
                          child: const Text('退出登录', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8EAED), Color(0xFFF8F9FA)],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          const SizedBox(
            width: 96,
            height: 96,
            child: ClipOval(
              child: Image(
                image: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBbKe_aCd46pUms7LLAFzD6OXtQ8lCfAXJOsCrBecRIq0Rsb6hG4jY_titPPL6OX4UEolhRaXIm5q1CN8mgX1sDnDEpjIu6VsAPEPXD_TgVO70SfpWy3Ip2I0CsCyMuTYopG68o1H3zfeCTGnhMwcli29GRkYeNRSh_bne4ffgw7Lym8TRcy9xvfIRJ7re4r_AZ6HYWFXuNljbmovvrN8K3yGjv8iiZ5MCKo2rG0vQcYlScRiJTep-ftfRgTq7kF_pycqvsKRxWyfNh',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Alex Chen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1F2937))),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFDCFCE7)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history_edu, size: 16, color: Color(0xFF15803D)),
                SizedBox(width: 8),
                Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 12, color: Color(0xFF166534), fontWeight: FontWeight.w800),
                    children: [
                      TextSpan(text: '已记录人生 '),
                      TextSpan(text: '1,240', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                      TextSpan(text: ' 天'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '我频繁的记录着，我热烈的分享着',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1152D4)),
          ),
          const SizedBox(height: 6),
          const Text(
            '你要知道诗人的一生也可能非常普通',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1152D4)),
          ),
        ],
      ),
    );
  }
}

class _ChronicleCard extends StatelessWidget {
  const _ChronicleCard({required this.onGenerate});

  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)]),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 30, offset: const Offset(0, 8))],
        border: Border.all(color: const Color(0x331E40AF)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: -24,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), shape: BoxShape.circle),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Row(
                            children: [
                              Icon(Icons.auto_stories, color: Color(0xFFFCD34D), size: 20),
                              SizedBox(width: 8),
                              Text('人生传记', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(
                            '128条美食、45次旅行、53个小确幸',
                            style: TextStyle(fontSize: 12, color: Color(0xFFDBEAFE), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                      ),
                      child: const Icon(Icons.workspace_premium, color: Color(0xFFFCD34D), size: 28),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    SizedBox(
                      height: 32,
                      child: Stack(
                        children: const [
                          _StackAvatar(
                            left: 0,
                            image:
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuBH6ehj1x0eGgr0VT06HQYlUaq4fxkuUqmW_4FW1gikA4nxmI22lrL1sVhFIaaXEu4_sdXwyQzkzCt-Dnrf67biay7YI5oTrsxWpfXYiDoEZ8XgUQuJKSYkju8t7BU-1oC6Pe41HZgsfEJ-8oBiL-EoEHYjkIMGCg8b9eEaanMop_7hkQD5mnnsAE5St7AICaTl30tf6PViJCwsyVOz4DzZpvGdGZKHVVXJacED7BYrhu8umPQo5a8feO9c8Je6Tu0hBrX-Qa6IqdPz',
                          ),
                          _StackAvatar(
                            left: 20,
                            image:
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuAxXDOLwhNbt-UVPJcW_LvKDBPIFu2hX7FsNBdXVv1wiYEXyaNi06egGSt711Y68tkgK5bmiHGEArNPbXPlUqI3hvoopLb4Q1Wp1u1HsKCs87W5BCKa4qIfvOl4VitjkOYUCI9PkDmdEWe2WxS5GcFcwiE9yOGssBuuM3V81VxKHBzmc0ClvZ1UQ0ljfW0DdCs5zGmFoBnUpVeqJFFTy_uZ0uzkCnheIB8Z_TdXj23jlr2fS_cAzwrHvlTJ9KFxYr5zTudW71WrxMRa',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 30),
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E40AF),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFF1E3A8A), width: 2),
                      ),
                      child: const Text('+3', style: TextStyle(fontSize: 10, color: Color(0xFFDBEAFE), fontWeight: FontWeight.w800)),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: onGenerate,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_fix_high, size: 16),
                          SizedBox(width: 6),
                          Text('生成编年史'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StackAvatar extends StatelessWidget {
  const _StackAvatar({required this.left, required this.image});

  final double left;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: 0,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF1E3A8A), width: 2),
          image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 16, decoration: BoxDecoration(color: ProfilePage._primary, borderRadius: BorderRadius.circular(99))),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
      ],
    );
  }
}

class _LargeTile extends StatelessWidget {
  const _LargeTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailingIcon,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final IconData trailingIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF3F4F6))),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(999)),
                child: Icon(trailingIcon, size: 18, color: const Color(0xFF9CA3AF)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallTile extends StatelessWidget {
  const _SmallTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF3F4F6))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(999)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListGroup extends StatelessWidget {
  const _ListGroup({required this.items});

  final List<_ListItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF3F4F6))),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _ListRow(item: items[i]),
            if (i != items.length - 1) const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Divider(height: 1, color: Color(0xFFF9FAFB))),
          ],
        ],
      ),
    );
  }
}

class _ListItem {
  const _ListItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
}

class _ListRow extends StatelessWidget {
  const _ListRow({required this.item});

  final _ListItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(item.icon, color: item.iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFD1D5DB)),
          ],
        ),
      ),
    );
  }
}

class _FrostedCircleButton extends StatelessWidget {
  const _FrostedCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.60),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF374151)),
      ),
    );
  }
}

class ChronicleGenerateConfigPage extends StatelessWidget {
  const ChronicleGenerateConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(title: '编年史生成配置');
  }
}

class FavoritesCenterPage extends StatelessWidget {
  const FavoritesCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF2F4F6);
    const primary = Color(0xFF8AB4F8);
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.7),
        title: const Text('收藏中心', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('收藏概览', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _FavoriteSummaryChip(
                        label: '美食',
                        count: '128',
                        color: const Color(0xFFFFEDD5),
                        textColor: const Color(0xFFFB923C),
                      ),
                      const SizedBox(width: 10),
                      _FavoriteSummaryChip(
                        label: '旅行',
                        count: '45',
                        color: const Color(0xFFDBEAFE),
                        textColor: const Color(0xFF3B82F6),
                      ),
                      const SizedBox(width: 10),
                      _FavoriteSummaryChip(
                        label: '小确幸',
                        count: '53',
                        color: const Color(0xFFFCE7F3),
                        textColor: const Color(0xFFEC4899),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Text('最近收藏', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(foregroundColor: primary, textStyle: const TextStyle(fontWeight: FontWeight.w900)),
                  child: const Text('查看全部'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _FavoriteItemCard(
              title: '京都乌冬面专门店',
              subtitle: '美食 · 2024.12.15',
              tag: '晚餐',
              tagColor: const Color(0xFFFFEDD5),
              tagTextColor: const Color(0xFFFB923C),
              imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAKyf0mNiZ0TAc0cDBuDh729VN8zm8R-lF-JlOBczemlVSfDxlTXyG9D-4CqGvj4VGLsjyH_nyxHz36t5YCWIUdFilyoKvFftQ0lxzt6pmOkOgpBI_gvBZAInqTnxhG3lNNaOqRyxJCT-lzLS3lmLEkNBMXJ6LnIbYkBwU51lRvY0DqIG10oPqPfaoC12BgWZPmW74AWxyipq5A_nuiETA3saO846Avvh5KoAF7C0KINcR5Dmp2orHJWlVQTu97pn9w2S1O1IDzigGp',
            ),
            const SizedBox(height: 12),
            _FavoriteItemCard(
              title: '圣托里尼之旅',
              subtitle: '旅行 · 2024.10.12',
              tag: '在路上',
              tagColor: const Color(0xFFDBEAFE),
              tagTextColor: const Color(0xFF3B82F6),
              imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAiYeR0YcCn1tfLzR2C2qW7pWwiTIIzX5y9HcELMdQlsNCZvTqnJ41-B1ywijjoYzk_kaGbsMNndOTvAGoPUk9OIdsfsainDuqObiaIAJ1ggBT2W_sadXiE3WlCdjh5JHOSptSe6uIHLP9jUHWc1LU6_TIwZcj6Qz14mI7QoVIrSDXJUMfVfMU0rGHzPTzcMJRaZBBLmmGcbMzlO2zr5R5SveBseZ7IY2suW8zTiFnU1s_9_fH1swq0ZImopSmXI3-V_iTjIqb-uT3m',
            ),
            const SizedBox(height: 12),
            _FavoriteItemCard(
              title: '雨后河堤散步',
              subtitle: '小确幸 · 2024.09.01',
              tag: '心情',
              tagColor: const Color(0xFFFCE7F3),
              tagTextColor: const Color(0xFFEC4899),
              imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAJXbnLKvlLG_61cAfkgftdbG_VeN-Yd9sRyc_avp_eCsvTCh21uahLpTGC3iI_KDsW2C0C2cjsuhmB5GVqLdN9l5ve6Fzr8QKkE1_-OA5InnsZeKPDhM42i0rzGdClRzvbmqPtTr0VtxyZMXQj6yEkd31OHKG8dPCGea2pMS41BQKPF4Yv2HuvEVgJ83pTUSKVFkHTtmViPfZbWoKYv__IMLWuBD0XSC5s2-UQqiv-PtaOA2zn5wOKrAt4IHLAPkjrP1_S_Fu-YKIv',
            ),
          ],
        ),
      ),
    );
  }
}

class ChronicleManagePage extends StatelessWidget {
  const ChronicleManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF2F4F6);
    const primary = Color(0xFF8AB4F8);
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.7),
        title: const Text('编年史管理', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(foregroundColor: primary, textStyle: const TextStyle(fontWeight: FontWeight.w900)),
            child: const Text('生成新版本'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('版本说明', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  SizedBox(height: 8),
                  Text('系统会保留每次生成的编年史版本，支持预览、导出与标记为精选。', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B), height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _ChronicleVersionCard(
              title: '2024 年度编年史',
              range: '2024.01.01 - 2024.12.31',
              tags: const ['年度', '精选'],
              primaryAction: '预览',
              secondaryAction: '导出',
            ),
            const SizedBox(height: 12),
            _ChronicleVersionCard(
              title: '2024 上半年精选',
              range: '2024.01.01 - 2024.06.30',
              tags: const ['专题'],
              primaryAction: '预览',
              secondaryAction: '导出',
            ),
            const SizedBox(height: 12),
            _ChronicleVersionCard(
              title: '旅行主题合集',
              range: '2023.05.01 - 2024.03.31',
              tags: const ['旅行', '专题'],
              primaryAction: '预览',
              secondaryAction: '导出',
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteSummaryChip extends StatelessWidget {
  const _FavoriteSummaryChip({
    required this.label,
    required this.count,
    required this.color,
    required this.textColor,
  });

  final String label;
  final String count;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
        child: Column(
          children: [
            Text(count, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: textColor)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: textColor)),
          ],
        ),
      ),
    );
  }
}

class _FavoriteItemCard extends StatelessWidget {
  const _FavoriteItemCard({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.tagColor,
    required this.tagTextColor,
    required this.imageUrl,
  });

  final String title;
  final String subtitle;
  final String tag;
  final Color tagColor;
  final Color tagTextColor;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 72,
              height: 72,
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                const SizedBox(height: 6),
                Text(subtitle, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: tagColor, borderRadius: BorderRadius.circular(999)),
                  child: Text(tag, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: tagTextColor)),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
        ],
      ),
    );
  }
}

class _ChronicleVersionCard extends StatelessWidget {
  const _ChronicleVersionCard({
    required this.title,
    required this.range,
    required this.tags,
    required this.primaryAction,
    required this.secondaryAction,
  });

  final String title;
  final String range;
  final List<String> tags;
  final String primaryAction;
  final String secondaryAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
              ),
              const Icon(Icons.auto_stories, size: 18, color: Color(0xFF8AB4F8)),
            ],
          ),
          const SizedBox(height: 6),
          Text(range, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final tag in tags)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(999)),
                  child: Text(tag, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF3B82F6))),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8AB4F8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  onPressed: () {},
                  child: Text(primaryAction),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  onPressed: () {},
                  child: Text(secondaryAction),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UniversalLinkPage extends ConsumerWidget {
  const UniversalLinkPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);

    final logsQuery = (db.select(db.linkLogs)
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])
      ..limit(50));

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.7),
        title: const Text('个人中心-万物互联', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UniversalLinkAllLogsPage())),
            child: const Text('全部日志'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('说明', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  SizedBox(height: 8),
                  Text('万物互联的底层是 entity_links + link_logs；这里展示最近的关联操作日志，便于校验各模块是否已正确写入关联。', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B), height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Text('最近日志', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UniversalLinkAllLogsPage())),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF2BCDEE), textStyle: const TextStyle(fontWeight: FontWeight.w900)),
                  child: const Text('查看全部'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            StreamBuilder<List<LinkLog>>(
              stream: logsQuery.watch(),
              builder: (context, snapshot) {
                final items = snapshot.data ?? const <LinkLog>[];

                if (snapshot.connectionState == ConnectionState.waiting && items.isEmpty) {
                  return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                }

                if (items.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFF3F4F6))),
                    child: const Text('暂无日志：请在任意新建页发布一条记录并进行关联。', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                  );
                }

                return Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFF3F4F6))),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                    itemBuilder: (context, index) {
                      final log = items[index];
                      return ListTile(
                        dense: true,
                        leading: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: log.action == 'delete' ? const Color(0xFFFFEBEE) : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Icon(log.action == 'delete' ? Icons.link_off : Icons.link, size: 18, color: log.action == 'delete' ? const Color(0xFFEF4444) : const Color(0xFF3B82F6)),
                        ),
                        title: Text(
                          '${_typeLabel(log.sourceType)} → ${_typeLabel(log.targetType)}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                        ),
                        subtitle: Text(
                          '${log.action} · ${log.createdAt.toLocal().toString().substring(0, 19)}\n${log.sourceType}:${log.sourceId}  →  ${log.targetType}:${log.targetId}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B), height: 1.35),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class UniversalLinkAllLogsPage extends ConsumerWidget {
  const UniversalLinkAllLogsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final logsQuery = (db.select(db.linkLogs)
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])
      ..limit(300));

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.7),
        title: const Text('个人中心-万物互联-全部日志', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: StreamBuilder<List<LinkLog>>(
          stream: logsQuery.watch(),
          builder: (context, snapshot) {
            final items = snapshot.data ?? const <LinkLog>[];
            if (snapshot.connectionState == ConnectionState.waiting && items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (items.isEmpty) {
              return const Center(
                child: Text('暂无日志', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final log = items[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFF3F4F6))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: log.action == 'delete' ? const Color(0xFFFFEBEE) : const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(log.action, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: log.action == 'delete' ? const Color(0xFFEF4444) : const Color(0xFF2563EB))),
                          ),
                          const SizedBox(width: 10),
                          Text(_typeLabel(log.sourceType), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                          const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.chevron_right, size: 18, color: Color(0xFFCBD5E1))),
                          Text(_typeLabel(log.targetType), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                          const Spacer(),
                          Text(log.createdAt.toLocal().toString().substring(0, 19), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('${log.sourceType}:${log.sourceId}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                      const SizedBox(height: 6),
                      Text('${log.targetType}:${log.targetId}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

String _typeLabel(String t) {
  switch (t) {
    case 'food':
      return '美食';
    case 'moment':
      return '小确幸';
    case 'friend':
      return '朋友';
    case 'encounter':
      return '相遇';
    case 'travel':
      return '旅行';
    case 'goal':
      return '目标';
    default:
      return t;
  }
}

class DataManagementPage extends StatelessWidget {
  const DataManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(title: '个人中心-数据管理');
  }
}

class ModuleManagementPage extends StatelessWidget {
  const ModuleManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(title: '个人中心-模块管理');
  }
}

class YearReportPage extends StatelessWidget {
  const YearReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(title: '年度报告');
  }
}

class ReminderSettingsPage extends StatelessWidget {
  const ReminderSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(title: '提醒设置');
  }
}

class PrivacySecurityPage extends StatelessWidget {
  const PrivacySecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(title: '隐私与安全');
  }
}

class HelpFeedbackPage extends StatelessWidget {
  const HelpFeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(title: '帮助与反馈');
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.7),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: null,
      ),
      body: const SafeArea(
        child: Center(
          child: Text('界面已搭建（待填充原型细节）', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
        ),
      ),
    );
  }
}
