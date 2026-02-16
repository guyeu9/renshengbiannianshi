import 'dart:ui';

import 'package:flutter/material.dart';

class TravelPage extends StatefulWidget {
  const TravelPage({super.key});

  @override
  State<TravelPage> createState() => _TravelPageState();
}

enum _TravelViewMode { wishlist, onTheRoad }

class _TravelPageState extends State<TravelPage> {
  _TravelViewMode _mode = _TravelViewMode.onTheRoad;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2BCDEE),
        foregroundColor: Colors.white,
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TravelCreatePage())),
        child: const Icon(Icons.add, size: 28),
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: _TravelTopBar()),
            const SliverToBoxAdapter(child: _TravelSearchRow()),
            SliverPersistentHeader(
              pinned: true,
              delegate: _PinnedHeaderDelegate(
                height: 56,
                child: _TravelModeSwitch(
                  mode: _mode,
                  onChanged: (m) => setState(() => _mode = m),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
              sliver: SliverToBoxAdapter(
                child: _mode == _TravelViewMode.onTheRoad ? const _TravelOnTheRoadView() : const _TravelWishlistView(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TravelTopBar extends StatelessWidget {
  const _TravelTopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          const SizedBox(width: 48),
          const Expanded(
            child: Text(
              '人生路漫漫',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
            ),
          ),
          SizedBox(
            width: 48,
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2BCDEE),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                child: const Text('解析'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TravelSearchRow extends StatelessWidget {
  const _TravelSearchRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Color(0xFF94A3B8), size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '搜索城市、标签、地理位置...',
                      style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          _SquareIconButton(icon: Icons.tune, onTap: () {}),
        ],
      ),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(width: 44, height: 44, child: Icon(icon, color: const Color(0xFF64748B), size: 22)),
      ),
    );
  }
}

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PinnedHeaderDelegate({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFF6F8F8),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}

class _TravelModeSwitch extends StatelessWidget {
  const _TravelModeSwitch({required this.mode, required this.onChanged});

  final _TravelViewMode mode;
  final ValueChanged<_TravelViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TravelModePill(
              label: '愿望清单',
              selected: mode == _TravelViewMode.wishlist,
              onTap: () => onChanged(_TravelViewMode.wishlist),
            ),
          ),
          Expanded(
            child: _TravelModePill(
              label: '在路上',
              selected: mode == _TravelViewMode.onTheRoad,
              onTap: () => onChanged(_TravelViewMode.onTheRoad),
            ),
          ),
        ],
      ),
    );
  }
}

class _TravelModePill extends StatelessWidget {
  const _TravelModePill({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF2BCDEE) : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}

class _TravelOnTheRoadView extends StatelessWidget {
  const _TravelOnTheRoadView();

  static const _entries = <_TravelOnTheRoadEntry>[
    _TravelOnTheRoadEntry(
      year: 2023,
      dateRange: '10月12日 - 20日',
      durationDays: 8,
      place: '圣托里尼，希腊',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAiYeR0YcCn1tfLzR2C2qW7pWwiTIIzX5y9HcELMdQlsNCZvTqnJ41-B1ywijjoYzk_kaGbsMNndOTvAGoPUk9OIdsfsainDuqObiaIAJ1ggBT2W_sadXiE3WlCdjh5JHOSptSe6uIHLP9jUHWc1LU6_TIwZcj6Qz14mI7QoVIrSDXJUMfVfMU0rGHzPTzcMJRaZBBLmmGcbMzlO2zr5R5SveBseZ7IY2suW8zTiFnU1s_9_fH1swq0ZImopSmXI3-V_iTjIqb-uT3m',
      companions: [
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDheb26Erh0AoCNYUAzET6_o8v9xUPTMWh6Q9SGAFRPh5HFsel2frUzRgzn48nFaBr7PEW-7Kl2ZyjGyhT6kDi9lRHpO1eKfzAkcY9hPDqcDzhRNf3ztVNFQCzZVg830hNXqqczCFl68ofVW-h6HvhlBm8Gn1Vj58A-_vaMjQSR2e1RYf58WTBWmiZEcsPEUf9kkPPaLaTBx8E8bXdIkXInXI59qk9YFmGjux7vyNd93fG3tGaYnw57l61XWl3rs1H_iVjkumddEf8D',
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCCxSAYevaHZ7JD7Vr88wgLQ586JK1FVk8irLktZlZGU64GlbD4ReClmeF_I7xrFp1GhUDOk8vKriMhjGtAyotUDE8aaiCWewP2UQXAEiO5U8srBg5Wbqgn4_PortiR1thtfHH0GNXdACchU-NFrQtR-YcJI7rdbI97kftf5TN4_GIZv57LwWjpgXVFpLd8Rc0zfbUvHwQzAdc7Y-k_EgkBICQFS7Ec0dB5cEqByYyKziJzfXE_1PUxc_hePIvm7ge0VDhlEp9xvHcY',
      ],
      item: TravelItem(
        date: '2023年10月12日',
        title: '圣托里尼之旅',
        subtitle: '海风 · 白墙蓝顶 · 日落',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAiYeR0YcCn1tfLzR2C2qW7pWwiTIIzX5y9HcELMdQlsNCZvTqnJ41-B1ywijjoYzk_kaGbsMNndOTvAGoPUk9OIdsfsainDuqObiaIAJ1ggBT2W_sadXiE3WlCdjh5JHOSptSe6uIHLP9jUHWc1LU6_TIwZcj6Qz14mI7QoVIrSDXJUMfVfMU0rGHzPTzcMJRaZBBLmmGcbMzlO2zr5R5SveBseZ7IY2suW8zTiFnU1s_9_fH1swq0ZImopSmXI3-V_iTjIqb-uT3m',
      ),
    ),
    _TravelOnTheRoadEntry(
      year: 2023,
      dateRange: '6月05日 - 15日',
      durationDays: 10,
      place: '京都，日本',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuArjODPnhetd9mNC97Lhyyqrqsau8zb2mpHZIUajs_y80A4ktyrbZdDW3aWe7YbHT6D80VUeRr-NAuvPHauC8Dg2fdZ5vPeKcHPC8zwEXC7b38nqgcHpHHJfcHIO8ZvXsb_71H0ZjFXXtutdVPzOQ4y-smnWPuVutfwhttAEPWMW-b5u774LkHpWlfpa3-IUGorIG5AVqKV38wB5_7apJTYX8IwButUW2sZkX8RfRe412n0XRr2clKf-HALs50dk5x75Knr98dA1_2X',
      companions: [
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCfJm-B09qhEbr3vJn2M3vUPot7kay2p8neQCm92azpcqsnHkR7JnBfCP5vk0HXEJB62jQ1iameH0ufpMWMlYHzdDQHJlfhSXFvZc-Irzu6lgJn1zijr95QFrwnsB4CpAPmWWnhnoDengr_FyFpQ3soqu8bZI_m58E7dJ8sBEx__UIHIR_r1qSx3FfLDILNZEIPA53dCknUoqHrrG7ODojjBdw8N8wAXue95OJOMvAfa6H8jZF2pqq9XQpaNUosJduEKNFh73tNC6fa',
      ],
      item: TravelItem(
        date: '2023年6月05日',
        title: '京都之旅',
        subtitle: '清水寺 · 伏见稻荷 · 岚山',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuArjODPnhetd9mNC97Lhyyqrqsau8zb2mpHZIUajs_y80A4ktyrbZdDW3aWe7YbHT6D80VUeRr-NAuvPHauC8Dg2fdZ5vPeKcHPC8zwEXC7b38nqgcHpHHJfcHIO8ZvXsb_71H0ZjFXXtutdVPzOQ4y-smnWPuVutfwhttAEPWMW-b5u774LkHpWlfpa3-IUGorIG5AVqKV38wB5_7apJTYX8IwButUW2sZkX8RfRe412n0XRr2clKf-HALs50dk5x75Knr98dA1_2X',
      ),
    ),
    _TravelOnTheRoadEntry(
      year: 2022,
      dateRange: '12月20日 - 1月02日',
      durationDays: 14,
      place: '纽约，美国',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCIwfpW5Tw0aDH8j4GZsg6k8FIlBRSJUtHA4f7L6yrfWBpRLCDTOhZgzzrAKFJ3J9FIskGAxsxAdu-x9YQKnDLlgp3LoSxHMZwn5DGjM5fxSH7kzTJFHm0JBX5TFA9tT-vFLjiymDxURBRk-FVsNeqO8kxGN1XruPsskE9ifqfleFfLdyYuHUymhXxWwa6rsuZZ_vJ0WBopAwdMZ0CfzOODrQ_bxIDAgeBu0XUGvPsL2y77MghcQGM-3AwN-BZFeIezMTC07H0vywMH',
      companions: [
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDZMMw16OOA9fm8LwncB97oR_-QJZWtJH-IOCdVyI90IlfGWUEgqwPaa9v_kr1Fi9tpOYsfheaiqN1HcrwM7qGT8F66SyDZ3U5gXhqlaKH4kjiDYUAwqIFJG37P2T6LzpdYESLfTcV3TYL-GagWJGvyepFGppyamqycMv9oSvyitfrGexYXsAv6e2tupUPRdSHlnsMtxvyzYoX71MCcJKGjXvy87-GVBGZgWYgVp6uLcP_C0cZwVSHmejagxyVQ381CJONzCAuulPfS',
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAD673M_-uyjr4Qk4esD99qxnHgR6uH_hcUpUiZVpfb6P2mG-OQOtU13LuH6zY6Uy_pW5jgCFu66ol_AKjvG8S2icbnyrRbaatZLv7InpY_qlZJ0rBv5JIzqVkWVjwANAFpwoM2ePl0YgsONFeH63QtYAIXLkj-9NQeLp4hkcPAKdK869h9SS26NYwwBGm58fTWeyyfnSk2eGE_c3QFM1QHDEp-HRPOtQNE-RzYsC72_WD6DEOwtObn_3TPxfTQpD4D-VIzUi6WIUyt',
      ],
      item: TravelItem(
        date: '2022年12月20日',
        title: '纽约跨年',
        subtitle: '摩天大楼 · 冬夜 · 人潮',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCIwfpW5Tw0aDH8j4GZsg6k8FIlBRSJUtHA4f7L6yrfWBpRLCDTOhZgzzrAKFJ3J9FIskGAxsxAdu-x9YQKnDLlgp3LoSxHMZwn5DGjM5fxSH7kzTJFHm0JBX5TFA9tT-vFLjiymDxURBRk-FVsNeqO8kxGN1XruPsskE9ifqfleFfLdyYuHUymhXxWwa6rsuZZ_vJ0WBopAwdMZ0CfzOODrQ_bxIDAgeBu0XUGvPsL2y77MghcQGM-3AwN-BZFeIezMTC07H0vywMH',
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TravelFootprintCard(onTap: () {}),
        const SizedBox(height: 18),
        _TravelOnTheRoadTimeline(entries: _entries),
      ],
    );
  }
}

class _TravelOnTheRoadEntry {
  const _TravelOnTheRoadEntry({
    required this.year,
    required this.dateRange,
    required this.durationDays,
    required this.place,
    required this.imageUrl,
    required this.companions,
    required this.item,
  });

  final int year;
  final String dateRange;
  final int durationDays;
  final String place;
  final String imageUrl;
  final List<String> companions;
  final TravelItem item;
}

class _TravelFootprintCard extends StatelessWidget {
  const _TravelFootprintCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            boxShadow: [BoxShadow(color: const Color(0xFF2BCDEE).withValues(alpha: 0.10), blurRadius: 20, offset: const Offset(0, 12))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                SizedBox(
                  height: 132,
                  width: double.infinity,
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDcni2LwtmaarwLbusdF4hZ0n64Ccbqcro_mNlE1JoQ2W7xan2Np-aL-NR0r1mERCSWD-VrgAjgPTreKg7rOJG9pEmzgkxybMW6FiEQsie94nkXwMeYNfqLdMypoYLsM_gxZuODk_-9XmCjo5SikmTNZtEUM48dwCkfdgO8YzEGhUBCwW5EEGncwjnEUcgtdljEfYCFtXRijdDC1xfkzgrno5ctBJDtBD9oohKBGaO_DSbSe1M87lySWl4_APrOOnE5Bw4-EAcJO1jc',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 14,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '我的足迹',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xE6FFFFFF)),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '12 个国家，45 座城市',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(color: Color(0xFF2BCDEE), shape: BoxShape.circle),
                        child: const Icon(Icons.map, color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TravelOnTheRoadTimeline extends StatelessWidget {
  const _TravelOnTheRoadTimeline({required this.entries});

  final List<_TravelOnTheRoadEntry> entries;

  @override
  Widget build(BuildContext context) {
    final byYear = <int, List<_TravelOnTheRoadEntry>>{};
    for (final e in entries) {
      byYear.putIfAbsent(e.year, () => []).add(e);
    }
    final years = byYear.keys.toList()..sort((a, b) => b.compareTo(a));

    return _TimelineColumn(
      children: [
        for (final year in years) ...[
          _TimelineYearHeader(year: year),
          for (final entry in byYear[year]!) _TimelineTripEntry(entry: entry),
        ],
      ],
    );
  }
}

class _TimelineColumn extends StatelessWidget {
  const _TimelineColumn({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _TimelineLinePainter(),
      child: Padding(
        padding: const EdgeInsets.only(left: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}

class _TimelineLinePainter extends CustomPainter {
  const _TimelineLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()..color = const Color(0xFFE5E7EB)..strokeWidth = 2..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(14, 0), Offset(14, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _TimelineLinePainter oldDelegate) => false;
}

class _TimelineYearHeader extends StatelessWidget {
  const _TimelineYearHeader({required this.year});

  final int year;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Transform.translate(
            offset: const Offset(-24, 0),
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF2BCDEE),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF6F8F8), width: 2),
              ),
            ),
          ),
          Text(
            '$year',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
          ),
        ],
      ),
    );
  }
}

class _TimelineTripEntry extends StatelessWidget {
  const _TimelineTripEntry({required this.entry});

  final _TravelOnTheRoadEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Stack(
        children: [
          Positioned(
            left: -21,
            top: 26,
            child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFD1D5DB), shape: BoxShape.circle)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry.dateRange,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF2BCDEE)),
              ),
              const SizedBox(height: 10),
              _TravelOnRoadCard(entry: entry),
            ],
          ),
        ],
      ),
    );
  }
}

class _TravelOnRoadCard extends StatelessWidget {
  const _TravelOnRoadCard({required this.entry});

  final _TravelOnTheRoadEntry entry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TravelDetailPage(item: entry.item))),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 14, offset: const Offset(0, 6))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: SizedBox(
                  height: 160,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(entry.imageUrl, fit: BoxFit.cover),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.flight_takeoff, size: 14, color: Colors.white),
                              const SizedBox(width: 6),
                              Text('${entry.durationDays} 天', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.place, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (entry.companions.isNotEmpty)
                          SizedBox(
                            width: entry.companions.length > 2
                                ? 52
                                : (entry.companions.length == 2 ? 38 : 24),
                            height: 24,
                            child: Stack(
                              children: [
                                for (var i = 0; i < entry.companions.length && i < 2; i++)
                                  Positioned(
                                    left: i * 14.0,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: ClipOval(child: Image.network(entry.companions[i], fit: BoxFit.cover)),
                                    ),
                                  ),
                                if (entry.companions.length > 2)
                                  Positioned(
                                    left: 28,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE2E8F0),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: Text(
                                        '+${entry.companions.length - 2}',
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        if (entry.companions.isNotEmpty) const SizedBox(width: 14),
                        if (entry.companions.isNotEmpty) Container(width: 1, height: 14, color: const Color(0xFFE2E8F0)),
                        if (entry.companions.isNotEmpty) const SizedBox(width: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2BCDEE).withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.restaurant, size: 14, color: Color(0xFF2BCDEE)),
                              SizedBox(width: 6),
                              Text('美食', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF4B5563))),
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
        ),
      ),
    );
  }
}

class _TravelWishlistView extends StatelessWidget {
  const _TravelWishlistView();

  static const _items = <TravelItem>[
    TravelItem(
      date: '计划：2026年4月',
      title: '冰岛追极光',
      subtitle: '雷克雅未克 · 蓝湖 · 黑沙滩',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBfQmXlW4U0l2F2s7p5c1Y',
    ),
    TravelItem(
      date: '计划：2026年6月',
      title: '新疆伊犁',
      subtitle: '草原 · 花海 · 日落',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA0l2F2s7p5c1Yq9',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final item in _items) ...[
          _TravelWishlistCard(item: item),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _TravelWishlistCard extends StatelessWidget {
  const _TravelWishlistCard({required this.item});

  final TravelItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TravelDetailPage(item: item))),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
                child: SizedBox(width: 110, height: 110, child: Image.network(item.imageUrl, fit: BoxFit.cover)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.date, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF2BCDEE))),
                      const SizedBox(height: 6),
                      Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                      const SizedBox(height: 6),
                      Text(item.subtitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6B7280))),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TravelItem {
  const TravelItem({required this.date, required this.title, required this.subtitle, required this.imageUrl});

  final String date;
  final String title;
  final String subtitle;
  final String imageUrl;
}

class TravelDetailPage extends StatelessWidget {
  const TravelDetailPage({super.key, required this.item});

  final TravelItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2BCDEE),
        foregroundColor: Colors.white,
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TravelJournalCreatePage())),
        child: const Icon(Icons.add, size: 28),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            pinned: false,
            expandedHeight: 288,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                    child: Image.network(item.imageUrl, fit: BoxFit.cover),
                  ),
                  DecoratedBox(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0x33000000), Color(0x99000000)],
                        stops: [0.35, 0.70, 1.00],
                      ),
                    ),
                  ),
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Row(
                        children: [
                          _FrostedCircleIconButton(
                            icon: Icons.arrow_back,
                            onTap: () => Navigator.of(context).maybePop(),
                          ),
                          const Spacer(),
                          _FrostedCircleIconButton(icon: Icons.bookmark_border, onTap: () {}),
                          const SizedBox(width: 10),
                          _FrostedCircleIconButton(
                            icon: Icons.edit,
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TravelCreatePage())),
                          ),
                          const SizedBox(width: 10),
                          _FrostedCircleIconButton(
                            icon: Icons.add,
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TravelJournalCreatePage())),
                          ),
                          const SizedBox(width: 10),
                          _PrimaryPillButton(
                            icon: Icons.ios_share,
                            label: '一键导出',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.20),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                              ),
                              child: const Text('5 天 4 晚', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.location_on, color: Colors.white70, size: 16),
                            const SizedBox(width: 4),
                            const Text('日本 · 京都', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.title,
                          style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, height: 1.05),
                        ),
                        const SizedBox(height: 6),
                        const Text('2023.10.15 - 2023.10.19', style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
              child: _TravelTimeline(),
            ),
          ),
        ],
      ),
    );
  }
}

class TravelCreatePage extends StatefulWidget {
  const TravelCreatePage({super.key});

  @override
  State<TravelCreatePage> createState() => _TravelCreatePageState();
}

class _TravelCreatePageState extends State<TravelCreatePage> {
  bool _addToWishlist = true;
  bool _checkItem1Done = true;
  bool _checkItem2Done = false;

  final TextEditingController _dateRangeController = TextEditingController(text: '2023年12月24日 - 12月28日');

  @override
  void dispose() {
    _dateRangeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8F8).withValues(alpha: 0.92),
                border: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.06))),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF6B7280),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        child: const Text('取消'),
                      ),
                      const Spacer(),
                      const Text('新建旅行行程', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: _PrimaryPillButton(icon: null, label: '创建', onTap: () {}),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 96,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [const Color(0xFF2BCDEE).withValues(alpha: 0.06), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _DashedRRect(
                radius: 20,
                dashColor: const Color(0xFF2BCDEE).withValues(alpha: 0.35),
                dashWidth: 7,
                dashGap: 6,
                strokeWidth: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 200,
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_a_photo, color: Color(0xFF9CA3AF), size: 44),
                        SizedBox(height: 10),
                        Text('上传目的地封面或攻略截图', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF))),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('行程标题', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF))),
                    const SizedBox(height: 8),
                    _RoundedFilledField(
                      hintText: '给这次行程起个标题...',
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                    ),
                    const SizedBox(height: 14),
                    const Text('备注与设想', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF))),
                    const SizedBox(height: 8),
                    _RoundedFilledField(
                      hintText: '记录关于这次行程的备注或初步设想...',
                      minLines: 3,
                      maxLines: 6,
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF334155), height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const _SectionTitle(label: '基本信息'),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.place,
                      label: '目的地',
                      child: const _PlainTextField(hintText: '例如：京都, 日本'),
                    ),
                    Divider(height: 1, color: Colors.black.withValues(alpha: 0.05)),
                    _InfoRow(
                      icon: Icons.calendar_today,
                      label: '计划时间',
                      trailing: const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1), size: 18),
                      child: _PlainTextField(controller: _dateRangeController, readOnly: true, hintText: '选择日期范围'),
                    ),
                    Divider(height: 1, color: Colors.black.withValues(alpha: 0.05)),
                    _InfoRow(
                      icon: Icons.paid,
                      label: '预算金额',
                      child: Row(
                        children: const [
                          Text('¥', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                          SizedBox(width: 6),
                          Expanded(child: _PlainTextField(hintText: '0.00', keyboardType: TextInputType.number)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(child: _SectionTitle(label: '同行者 (羁绊)')),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2BCDEE),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                    child: const Text('管理'),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: const [
                      _CompanionInviteChip(),
                      SizedBox(width: 14),
                      _CompanionAvatarChip(name: 'Alice', imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCplARom1thybC1GgKxC_04lQgbUPjp3U0r0DkcfFdBQFVUstS1aAjlR7ywS28cBBTKY0RdpLhD3gSfiUz6CCz1eeUcTDuJY-bRzWJwmZnkcEyG1sn2aabaC_d0CnuTz10sE70UzOsVCn0xI8Igi2QipyBbgDfTzRrKeScOfP457_GO2BdfAcZrAeKKVG1qAdRq4gT6uBChWQIqyoSAiAr-D_BE3TMBIyBshmDVNjnTtGoRSxqL3MLg5L176BGYaHZOtscWlGluXgpl', showFavorite: true),
                      SizedBox(width: 14),
                      _CompanionAvatarChip(name: 'Bob', imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCQiVIB0_5acJayiUH-UPm3j2qu_CAwxHHR0DTusQGDA06E1QkFb0_uquRTxdkVhDZP4vkpcOgjBXFacMLeYSNR_vjDzXsl0yQuw8-MIXg1nr_wbmWXizb0tHOmmg8NCdL_h-8KZq49uAz4abaafPzCGeOu8_uKkkN8ydMdqSyLKrxR2ruJHALYRhZ0Nd7NgPACeksBkzNU1-KCCYHlAL0wtnmEaVls6UNTwTWOfuo_tHBCi58xOaEZMqmWyOdSj67QKJjkPdZbmsMm'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const _SectionTitle(label: '规划详情'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('加入愿望清单', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF334155))),
                          SizedBox(height: 4),
                          Text('开启后，此行程将同步至愿望清单', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _addToWishlist,
                      activeTrackColor: const Color(0xFF2BCDEE),
                      activeThumbColor: Colors.white,
                      onChanged: (v) => setState(() => _addToWishlist = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 2),
                      child: Text('预订链接', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF9CA3AF))),
                    ),
                    const SizedBox(height: 10),
                    _IconInputRow(icon: Icons.flight, rotateIcon: true, hintText: '粘贴机票/交通预订链接'),
                    const SizedBox(height: 10),
                    _IconInputRow(icon: Icons.hotel, hintText: '粘贴酒店/住宿预订链接'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 2),
                            child: Text('心愿清单 (景点 / 美食)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF9CA3AF))),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: const Color(0xFF2BCDEE).withValues(alpha: 0.10), borderRadius: BorderRadius.circular(999)),
                          child: const Text('2 项', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF2BCDEE))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox.adaptive(
                          value: _checkItem1Done,
                          activeColor: const Color(0xFF2BCDEE),
                          onChanged: (v) => setState(() => _checkItem1Done = v ?? false),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              '清水寺日落',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: _checkItem1Done ? const Color(0xFF94A3B8) : const Color(0xFF334155),
                                decoration: _checkItem1Done ? TextDecoration.lineThrough : TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox.adaptive(
                          value: _checkItem2Done,
                          activeColor: const Color(0xFF2BCDEE),
                          onChanged: (v) => setState(() => _checkItem2Done = v ?? false),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('伏见稻荷大社晨跑', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                                SizedBox(height: 4),
                                Text('记得带运动鞋和水', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(height: 1, color: Colors.black.withValues(alpha: 0.06)),
                    const SizedBox(height: 10),
                    const Row(
                      children: [
                        Icon(Icons.add, color: Color(0xFF94A3B8), size: 18),
                        SizedBox(width: 10),
                        Expanded(child: _PlainTextField(hintText: '添加想去的地方...')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TravelJournalCreatePage extends StatefulWidget {
  const TravelJournalCreatePage({super.key});

  @override
  State<TravelJournalCreatePage> createState() => _TravelJournalCreatePageState();
}

class _TravelJournalCreatePageState extends State<TravelJournalCreatePage> {
  int _selectedMoodIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8F8).withValues(alpha: 0.90),
                border: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.06))),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF6B7280),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        child: const Text('取消'),
                      ),
                      const Spacer(),
                      const Text('新建游记', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: _PrimaryPillButton(icon: null, label: '发布', onTap: () {}),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                _RoundedFilledField(
                  hintText: '给这段游记起个标题...',
                  fillColor: const Color(0xFFF1F5F9),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                ),
                const SizedBox(height: 12),
                _RoundedFilledField(
                  hintText: '此刻有什么想记录的？描述你的见闻与感悟...',
                  fillColor: Colors.transparent,
                  minLines: 5,
                  maxLines: 10,
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF334155), height: 1.6),
                ),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: const [
                    _PhotoGridItem(
                      imageUrl:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuDSiJy4vj3-8R2angY1JfjCncAqBOa2quEtlvEu-dhous2uMskWujq6_nV_uyBKbFQdUGbsn9LMLFfUXUnb93xjTnwyUkIBL2k_igAoKKCbVjWb4l_6Bzu_J_JQDjkC_q4virmec5Zg6uJshfYhdZ73YLp1Y2aJ4-FadDuJVpYP6l8YrR4pBHlCm2qYqcXqYdmrMHOcRO9BESLt1VEvo63DlI3rZlPB9phtt4CrHYWAKXQcpuSvk_FdIIE8sjo5sWyMivQPa7UmvXMv',
                    ),
                    _PhotoGridItem(
                      imageUrl:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuAJXbnLKvlLG_61cAfkgftdbG_VeN-Yd9sRyc_avp_eCsvTCh21uahLpTGC3iI_KDsW2C0C2cjsuhmB5GVqLdN9l5ve6Fzr8QKkE1_-OA5InnsZeKPDhM42i0rzGdClRzvbmqPtTr0VtxyZMXQj6yEkd31OHKG8dPCGea2pMS41BQKPF4Yv2HuvEVgJ83pTUSKVFkHTtmViPfZbWoKYv__IMLWuBD0XSC5s2-UQqiv-PtaOA2zn5wOKrAt4IHLAPkjrP1_S_Fu-YKIv',
                    ),
                    _PhotoAddGridItem(),
                  ],
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Text('已选 2 张', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                    Spacer(),
                    Text('还可以添加 7 张', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                _AssociationRow(
                  iconBg: const Color(0xFF2BCDEE).withValues(alpha: 0.10),
                  iconColor: const Color(0xFF2BCDEE),
                  icon: Icons.place,
                  title: '京都, 清水寺',
                  subtitle: '自动定位中...',
                  trailing: const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
                ),
                Divider(height: 1, color: Colors.black.withValues(alpha: 0.05)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          _MoodIcon(),
                          SizedBox(width: 10),
                          Text('此时心情', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 64,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _moods.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final mood = _moods[index];
                            final isSelected = index == _selectedMoodIndex;
                            return InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => setState(() => _selectedMoodIndex = index),
                              child: SizedBox(
                                width: 58,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Text(mood.emoji, style: TextStyle(fontSize: isSelected ? 26 : 24)),
                                        if (isSelected)
                                          const Positioned(bottom: -2, child: SizedBox(width: 6, height: 6, child: DecoratedBox(decoration: BoxDecoration(color: Color(0xFF2BCDEE), shape: BoxShape.circle)))),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      mood.label,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                        color: isSelected ? const Color(0xFF2BCDEE) : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.black.withValues(alpha: 0.05)),
                _AssociationRow(
                  iconBg: const Color(0xFFA855F7).withValues(alpha: 0.12),
                  iconColor: const Color(0xFFA855F7),
                  icon: Icons.groups,
                  title: '同行朋友',
                  subtitle: null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      _TinyAvatar(url: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCl9nn5TZbEqIM0RhyOIwQgMwpoY7yUPtcRu3jpcF8UPok-9lbm4fbn-Og09ppd8Ancn09tGexDq_ORJzJVdcGY3EyCX9Zq-54wI2yKz7VglOdj16M2Yfqvo1DEHqH9gxIz2glbsmcbr8x0Tdr9MxNMATUjVC9aNjT5aamcmCbwsj2oZXKnaG4aKFxZyiwNOoURdnkC7dh6z5pINcqn1ELEjJxd6nc1YFtGtjO_g6hxQxT9f9fN7UVKXrZdvpMkbSAsZx-kd5UFmXya'),
                      SizedBox(width: 6),
                      _TinyAvatar(url: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBg4HeIqON_KNpEUoHNkGRJOZTcTdMJosl9zwU7xUF9NfHGrdW5R4Gixg2p_Mm2b-XIA2Tm2UBkOtqSnN_ZFK4n673ETjRDiqW11CMkdwHrwTJA0sXsF5UP2uO_RKVI6fOKkwYU6je2Hn3sKpc_xWxph9usJb7n7u5Aq8Za-F_B5JhoztC4ZBU0kAHN-jMwg__p-ijlVncXn22ZcIpw8qMcAZexpMVlWJn_tZQmTgWmXg9vAc43v8j-WQlCDxlk7JPB3KSkOJYu0AJh'),
                      SizedBox(width: 6),
                      _TinyAdd(),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.black.withValues(alpha: 0.05)),
                _AssociationRow(
                  iconBg: const Color(0xFFF43F5E).withValues(alpha: 0.12),
                  iconColor: const Color(0xFFF43F5E),
                  icon: Icons.restaurant,
                  title: '关联美食',
                  subtitle: '选择本次旅行的美食记录',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                        child: const Text('未关联', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.black.withValues(alpha: 0.05)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          _TagIcon(),
                          SizedBox(width: 10),
                          Text('自定义标签', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2BCDEE).withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF2BCDEE).withValues(alpha: 0.20)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('#京都漫步', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF22A4BE))),
                                SizedBox(width: 8),
                                Icon(Icons.close, size: 14, color: Color(0xFF64748B)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('#', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8))),
                                SizedBox(width: 6),
                                Text('输入标签...', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
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
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.60),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 8, height: 8, child: DecoratedBox(decoration: BoxDecoration(color: Color(0xFF2BCDEE), shape: BoxShape.circle))),
                SizedBox(width: 10),
                Text('正在关联行程：', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                Text('关西秋日之旅 (Day 3)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF334155))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const _moods = <_Mood>[
    _Mood('😌', '平静'),
    _Mood('🤩', '惊叹'),
    _Mood('😆', '开心'),
    _Mood('🤔', '思考'),
    _Mood('🥱', '疲惫'),
  ];
}

class _Mood {
  const _Mood(this.emoji, this.label);
  final String emoji;
  final String label;
}

class _FrostedCircleIconButton extends StatelessWidget {
  const _FrostedCircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Material(
          color: Colors.white.withValues(alpha: 0.12),
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(icon, color: Colors.white, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryPillButton extends StatelessWidget {
  const _PrimaryPillButton({required this.label, required this.onTap, this.icon});

  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF2BCDEE).withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 16),
                const SizedBox(width: 6),
              ],
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TravelTimeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 18,
          top: 16,
          bottom: 18,
          child: Container(width: 2, color: const Color(0xFFE5E7EB)),
        ),
        Column(
          children: [
            _TimelineDayBlock(
              dayTitle: '第一天',
              daySubTitle: '10月15日 · 星期五',
              isActive: true,
              items: [
                _TimelineItem.companions,
                _TimelineItem.memory,
                _TimelineItem.food(label: '午间小憩', title: '中村藤吉 · 抹茶甜品', subtitle: '宇治抹茶冰淇淋真的太浓郁了！'),
              ],
            ),
            const SizedBox(height: 22),
            _TimelineDayBlock(
              dayTitle: '第二天',
              daySubTitle: '10月16日 · 星期六',
              isActive: false,
              items: [
                _TimelineItem.gallery,
                _TimelineItem.food(label: '晚餐', title: '京都乌冬面专门店', subtitle: '排队半小时，汤头鲜美。'),
              ],
            ),
            const SizedBox(height: 18),
            const _TimelineEndMarker(),
          ],
        ),
      ],
    );
  }
}

class _TimelineDayBlock extends StatelessWidget {
  const _TimelineDayBlock({required this.dayTitle, required this.daySubTitle, required this.isActive, required this.items});

  final String dayTitle;
  final String daySubTitle;
  final bool isActive;
  final List<_TimelineItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 36,
              child: Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF2BCDEE) : const Color(0xFFCBD5E1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isActive ? const Color(0xFF2BCDEE) : const Color(0xFFCBD5E1)).withValues(alpha: 0.25),
                        blurRadius: 0,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dayTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                const SizedBox(height: 2),
                Text(daySubTitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.only(left: 48),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                items[i].build(context),
                if (i != items.length - 1) const SizedBox(height: 14),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineItem {
  const _TimelineItem._(this._builder);
  final Widget Function(BuildContext context) _builder;

  Widget build(BuildContext context) => _builder(context);

  static const companions = _TimelineItem._(_buildCompanions);
  static const memory = _TimelineItem._(_buildMemory);
  static const gallery = _TimelineItem._(_buildGallery);

  static _TimelineItem food({required String label, required String title, required String subtitle}) {
    return _TimelineItem._((context) => _TimelineFoodCard(label: label, title: title, subtitle: subtitle));
  }

  static Widget _buildCompanions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Stack(
              clipBehavior: Clip.none,
              children: const [
                _TinyAvatar(url: 'https://lh3.googleusercontent.com/aida-public/AB6AXuA1dYnKR7FixUUaLo0ebXhhIT6JnPPsrSurBq2jcEOOMNCyDyv9MGTx6d-xLEw3aVKDglsoUqrio_xhal5AoQQAmoTzYwB50XiAYKGxENWY2IaQuY9pK7b5aSfyN8nXp584y8svO_xumW1hzev3Gmu3RfKmHYFh9fUWQS_il8Jo2bvL3M1aFHmkcU8VzHzCC5V780tBVKfOPpx6gaHnPPq1ExISdUtDUnXmq6a7UCNLoj3w5tfL_WVVE4UbSyBCRLz40FyYCCTiTFZo', size: 32),
                Positioned(left: 18, child: _TinyAvatar(url: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBlUqU-_GWlnZImTO_Kj-jWMOgIMdUhkYNyENgLOvhmA-r-jqzpYS52VgiSarEkJh53H3q7MzzyIJav5LcS0TOVcFHv4eliO_OrARILQiG5KKvGXsSqjCiu58DkP2dVg0z4VEJzmAfL4Huhoq1AbSUCeSWN4-69cbPnzl2yAuJ1sE9HWkj14qViP2rRJZwquIqFTpzycYhXWQBUpcY4WRixTdsLy4wNF_qvIk6ZWiY9WCRO9nZchBm7zpb57c8h1hJ5fcfhNlUFmAhJ', size: 32)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text.rich(
              TextSpan(
                text: '与 ',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                children: [
                  TextSpan(text: '@Alice', style: TextStyle(color: Color(0xFF2BCDEE), fontWeight: FontWeight.w900)),
                  TextSpan(text: ', '),
                  TextSpan(text: '@Ben', style: TextStyle(color: Color(0xFF2BCDEE), fontWeight: FontWeight.w900)),
                  TextSpan(text: ' 同行'),
                ],
              ),
            ),
          ),
          const Icon(Icons.group, color: Color(0xFFCBD5E1), size: 18),
        ],
      ),
    );
  }

  static Widget _buildMemory(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 190,
                width: double.infinity,
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCosUDqvLbtdJUynjkBAeWU1QF2O0jZh2LHLN5F-Q0HoKkPw8Co5PdkkLHU4KgQsh3-E85q9D6rnM6YgMy7C02Efn02q5DIn9kCuTOa3fn4CD5a2TIco8FTkeRI30a4eIT50rHp35uABcuwQXbIlX6qfxLqaVhp5nONYMUhTECl3ohpnzijdMSYD86ij7HL4NC0rk5sh22gKRa-gxm43p_0XxboRN-jgjccl00ZMeezA7-7uQEo07f-QlbXZlRmQ8K48O1Cn36JiXcm',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.50),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time, size: 12, color: Colors.white),
                      SizedBox(width: 6),
                      Text('09:30 AM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('伏见稻荷大社', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                const SizedBox(height: 6),
                const Text(
                  '早起爬山果然是正确的选择！千本鸟居真的太壮观了，光影斑驳下的红色鸟居仿佛通往另一个世界。',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF64748B), height: 1.5),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _TagChip(label: '#神社'),
                    _TagChip(label: '#徒步'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildGallery(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: const Color(0xFF2BCDEE).withValues(alpha: 0.12), shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt, size: 18, color: Color(0xFF2BCDEE)),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('清水寺周边', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                    SizedBox(height: 2),
                    Text('14:20 PM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_horiz, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuAKyf0mNiZ0TAc0cDBuDh729VN8zm8R-lF-JlOBczemlVSfDxlTXyG9D-4CqGvj4VGLsjyH_nyxHz36t5YCWIUdFilyoKvFftQ0lxzt6pmOkOgpBI_gvBZAInqTnxhG3lNNaOqRyxJCT-lzLS3lmLEkNBMXJ6LnIbYkBwU51lRvY0DqIG10oPqPfaoC12BgWZPmW74AWxyipq5A_nuiETA3saO846Avvh5KoAF7C0KINcR5Dmp2orHJWlVQTu97pn9w2S1O1IDzigGp',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuBuT10tYFcn-doux9nf76wexULnaAXe1_2k1m02UsCet0czIwfXMlL4ctiLleAX4asYuPY9ArxyQCQHlN5pcQx9BpEG3CYk0N-yxFknKtVtT84j9C0vhgo6bMG-z-hGn_ep5B9fLZU4hrQqP_6fe5NUi3EPA6k-BtVBFeNO3llR8QYpHkT0eCvEYimxA6gOwpPH9QfqPjVdgErCJIz5GewLRk9fgtTG_yl9mkI-jzPAqZ8tPtzPiFTEVE9wUmC0ay1Lm8AblzlkQfvm',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '穿着和服走在二年坂三年坂，虽然游客很多，但那种古朴的氛围依然让人沉醉。',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF64748B), height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _TimelineFoodCard extends StatelessWidget {
  const _TimelineFoodCard({required this.label, required this.title, required this.subtitle});

  final String label;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 64,
              height: 64,
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCz0ZLYHipBFs6nZU665gOuM-8IrKCKhikLZPpoIC5KEUEj42bpGq4jybIab6WmqkfLIcC0yaUqb4arnRq5J6L_ZdlApupcjl0PxCGko7fUCp60OCprH_B8cL2VZ2mU48YWP8vIVd1iYcoJqM9Ay_UXfAwSA-seowywgtGLGVcp3Rh3zPP0q6M2-pASOh9RZ2gn8_LwMmwJI3mgOPx94gXTirmmtuoewEQfRc13f9SapSMrEjdQfWIWqIKq_IxyHYRlZrbv-Tm_pEq-',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.restaurant, color: Color(0xFF2BCDEE), size: 14),
                    const SizedBox(width: 6),
                    Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF2BCDEE), letterSpacing: 0.4)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                const SizedBox(height: 4),
                Text(subtitle, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineEndMarker extends StatelessWidget {
  const _TimelineEndMarker();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 48),
      child: Row(
        children: const [
          SizedBox(width: 30, height: 1, child: DecoratedBox(decoration: BoxDecoration(color: Color(0xFFCBD5E1)))),
          SizedBox(width: 10),
          Text('旅程未完待续...', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2BCDEE).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF2BCDEE))),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 16, decoration: BoxDecoration(color: const Color(0xFF2BCDEE), borderRadius: BorderRadius.circular(999))),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 0.6)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.child, this.trailing});

  final IconData icon;
  final String label;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: const Color(0xFF2BCDEE).withValues(alpha: 0.10), shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFF2BCDEE), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF))),
                const SizedBox(height: 4),
                child,
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 6),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _PlainTextField extends StatelessWidget {
  const _PlainTextField({this.controller, this.readOnly = false, required this.hintText, this.keyboardType});

  final TextEditingController? controller;
  final bool readOnly;
  final String hintText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFFCBD5E1)),
      ),
    );
  }
}

class _RoundedFilledField extends StatelessWidget {
  const _RoundedFilledField({
    required this.hintText,
    required this.textStyle,
    this.minLines = 1,
    this.maxLines = 1,
    this.fillColor,
  });

  final String hintText;
  final TextStyle textStyle;
  final int minLines;
  final int maxLines;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    return TextField(
      minLines: minLines,
      maxLines: maxLines,
      style: textStyle,
      decoration: InputDecoration(
        filled: true,
        fillColor: fillColor ?? const Color(0xFFF6F8F8),
        hintText: hintText,
        hintStyle: textStyle.copyWith(color: const Color(0xFF94A3B8), fontWeight: FontWeight.w700),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }
}

class _IconInputRow extends StatelessWidget {
  const _IconInputRow({required this.icon, required this.hintText, this.rotateIcon = false});

  final IconData icon;
  final String hintText;
  final bool rotateIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFF6F8F8), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Transform.rotate(
            angle: rotateIcon ? -0.8 : 0,
            child: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanionInviteChip extends StatelessWidget {
  const _CompanionInviteChip();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DashedRRect(
          radius: 999,
          dashColor: const Color(0xFF2BCDEE).withValues(alpha: 0.45),
          dashWidth: 6,
          dashGap: 6,
          strokeWidth: 2,
          child: SizedBox(
            width: 52,
            height: 52,
            child: Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: const Color(0xFF2BCDEE).withValues(alpha: 0.06), shape: BoxShape.circle),
                child: const Icon(Icons.add, color: Color(0xFF2BCDEE)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text('邀请', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
      ],
    );
  }
}

class _CompanionAvatarChip extends StatelessWidget {
  const _CompanionAvatarChip({required this.name, required this.imageUrl, this.showFavorite = false});

  final String name;
  final String imageUrl;
  final bool showFavorite;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipOval(
              child: SizedBox(
                width: 52,
                height: 52,
                child: Image.network(imageUrl, fit: BoxFit.cover),
              ),
            ),
            if (showFavorite)
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(color: const Color(0xFF2BCDEE), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                  child: const Icon(Icons.favorite, size: 10, color: Colors.white),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 64,
          child: Text(name, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF475569))),
        ),
      ],
    );
  }
}

class _DashedRRect extends StatelessWidget {
  const _DashedRRect({
    required this.child,
    required this.radius,
    required this.dashColor,
    required this.dashWidth,
    required this.dashGap,
    required this.strokeWidth,
  });

  final Widget child;
  final double radius;
  final Color dashColor;
  final double dashWidth;
  final double dashGap;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(
        radius: radius,
        dashColor: dashColor,
        dashWidth: dashWidth,
        dashGap: dashGap,
        strokeWidth: strokeWidth,
      ),
      child: child,
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({
    required this.radius,
    required this.dashColor,
    required this.dashWidth,
    required this.dashGap,
    required this.strokeWidth,
  });

  final double radius;
  final Color dashColor;
  final double dashWidth;
  final double dashGap;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dashColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.dashColor != dashColor ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class _PhotoGridItem extends StatelessWidget {
  const _PhotoGridItem({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(imageUrl, fit: BoxFit.cover),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.50), shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoAddGridItem extends StatelessWidget {
  const _PhotoAddGridItem();

  @override
  Widget build(BuildContext context) {
    return _DashedRRect(
      radius: 12,
      dashColor: const Color(0xFFCBD5E1),
      dashWidth: 7,
      dashGap: 6,
      strokeWidth: 2,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: const Color(0xFFF1F5F9),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo, size: 30, color: Color(0xFF2BCDEE)),
              SizedBox(height: 6),
              Text('添加照片', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8))),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssociationRow extends StatelessWidget {
  const _AssociationRow({
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(subtitle!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                ],
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _MoodIcon extends StatelessWidget {
  const _MoodIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(color: const Color(0xFFF97316).withValues(alpha: 0.14), shape: BoxShape.circle),
      child: const Icon(Icons.sentiment_satisfied, size: 18, color: Color(0xFFF97316)),
    );
  }
}

class _TagIcon extends StatelessWidget {
  const _TagIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(color: const Color(0xFF3B82F6).withValues(alpha: 0.14), shape: BoxShape.circle),
      child: const Icon(Icons.label, size: 18, color: Color(0xFF3B82F6)),
    );
  }
}

class _TinyAvatar extends StatelessWidget {
  const _TinyAvatar({required this.url, this.size = 28});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2)),
        child: ClipOval(child: Image.network(url, fit: BoxFit.cover)),
      ),
    );
  }
}

class _TinyAdd extends StatelessWidget {
  const _TinyAdd();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
      child: const Icon(Icons.add, size: 16, color: Color(0xFF94A3B8)),
    );
  }
}
