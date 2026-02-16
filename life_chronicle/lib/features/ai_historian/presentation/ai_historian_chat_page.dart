import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';

class AiHistorianChatPage extends StatelessWidget {
  const AiHistorianChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                const _AiChatTopBar(),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      220,
                    ),
                    children: const [
                      _TimestampChip(),
                      SizedBox(height: 18),
                      _AiMessageIntro(),
                      SizedBox(height: 18),
                      _UserMessage(),
                      SizedBox(height: 18),
                      _AiMessageWithCard(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const _AiChatInputBar(),
        ],
      ),
    );
  }
}

class _AiChatTopBar extends StatelessWidget {
  const _AiChatTopBar();

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 80 + MediaQuery.paddingOf(context).top,
          padding: EdgeInsets.fromLTRB(16, MediaQuery.paddingOf(context).top + 8, 16, 12),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.10),
            border: Border(
              bottom: BorderSide(color: AppTheme.primary.withValues(alpha: 0.20), width: 1),
            ),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                borderRadius: BorderRadius.circular(999),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.arrow_back_ios_new, color: Color(0xFF475569), size: 20),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI 史官',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: Color(0xFF4ADE80), shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '在线 · 全量数据已挂载',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.analytics, color: Color(0xFF475569)),
                splashRadius: 22,
                tooltip: '分析报告',
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.delete_sweep, color: Color(0xFF475569)),
                splashRadius: 22,
                tooltip: '清空对话',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiChatInputBar extends StatelessWidget {
  const _AiChatInputBar();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.paddingOf(context).bottom),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05), width: 1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.90),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      border: Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.50)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.dataset_linked, size: 14, color: AppTheme.primary),
                        SizedBox(width: 6),
                        Text(
                          '已接入：美食、旅行、小确幸等全量数据',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const [
                      _SuggestionChip(icon: Icons.mood, iconColor: Color(0xFFA855F7), label: '总结上月心情'),
                      SizedBox(width: 8),
                      _SuggestionChip(icon: Icons.pie_chart, iconColor: Color(0xFF60A5FA), label: '分析年度目标进度'),
                      SizedBox(width: 8),
                      _SuggestionChip(icon: Icons.history, iconColor: Color(0xFFFB923C), label: '那是哪一年？'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.mic, color: Color(0xFF94A3B8)),
                              splashRadius: 20,
                            ),
                            const Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  hintText: '向史官提问，探索你的过去...',
                                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.add_circle_outline, color: Color(0xFF94A3B8)),
                              splashRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.30),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.send, color: Colors.white),
                        splashRadius: 26,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimestampChip extends StatelessWidget {
  const _TimestampChip();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0).withValues(alpha: 0.50),
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Text(
          '上午 10:23',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
        ),
      ),
    );
  }
}

class _AiMessageIntro extends StatelessWidget {
  const _AiMessageIntro();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _AiAvatar(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('AI 史官', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14).copyWith(bottomLeft: const Radius.circular(4)),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
                  ],
                ),
                child: const Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF334155)),
                    children: [
                      TextSpan(text: '你好！我是你的 AI 史官。我已经阅读了你的人生档案，包含 '),
                      TextSpan(
                        text: '12,403',
                        style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: ' 条记录。今天你想回顾哪段记忆？'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UserMessage extends StatelessWidget {
  const _UserMessage();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(14).copyWith(bottomRight: const Radius.circular(4)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.20),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Text(
                  '帮我找一下去年我和张三去吃的那家日料店，好像是在秋天？',
                  style: TextStyle(fontSize: 14, height: 1.5, color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 4),
              const Text('已读', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAvImBnVZUMJXUm6EAOp9EWbAqk41A6v2fN7HNG-zYMB83MZX8JNW_pvqQDBgaVEs1ryBUzvq1Ec95264nMcOKhduTo6UG-oy7LcpE2bKDIYxSpFF9-aepSFQt5DEHyJ7r2-9vdcyT4IbjZ9ZLvCS4kPduSOoBOh5oEeNpuRVclv-ePlgm7F63rBti-T19ApJxgQ7ZpSSR6YH488rS_csuVvBGNNyluzUCRC7mK4Z3RYY6KkDHyYwMI6P9JBbn-qawLoIM6vw33nTjP',
          ),
        ),
      ],
    );
  }
}

class _AiMessageWithCard extends StatelessWidget {
  const _AiMessageWithCard();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _AiAvatar(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('AI 史官', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14).copyWith(bottomLeft: const Radius.circular(4)),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text.rich(
                      TextSpan(
                        style: TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF334155)),
                        children: [
                          TextSpan(text: '找到了。根据你的相册定位和账单记录，'),
                          TextSpan(
                            text: '2023年10月15日',
                            style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                          ),
                          TextSpan(text: '，你和张三在静安区用餐。那天你还记录了一条关于“海胆很新鲜”的心情。'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              children: [
                                Image.network(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBQqMbwNMWnn2jopFcDCk8oxnkxIQTqKVP2MfpUvUKHeJKTnUNBYWeHU5F34m9zAba2xVRu_YfjGMM7v2rnKTddf30EDrOfS9rtdd8cYXz45ncu_RNEUCS1of0orq42LgxwFm8Dod1y73nhIhRgLVSMJrlJWjcS4Kof8p8EXcFi0XYVRFp4sx4RJt_X2U0rsghccxk-q-2AV8sB8SITpT9yHiyQMpMi-tDGJmi9ckpOjtiJYiNSLLBsDAnH71TSlIGJHdQTt5YJPo9r',
                                  width: 84,
                                  height: 84,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [Color(0x99000000), Color(0x00000000)],
                                      ),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.place, size: 10, color: Colors.white),
                                        SizedBox(width: 3),
                                        Text('上海', style: TextStyle(fontSize: 10, color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Row(
                                    children: [
                                      Icon(Icons.restaurant, size: 14, color: Color(0xFFFB923C)),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          '松下·隐泉日式料理',
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '人均 ¥480 · 评分 4.8 \n关联人物：张三',
                                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.3),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: Color(0x1A2BCDEE),
                                          borderRadius: BorderRadius.all(Radius.circular(999)),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          child: Text(
                                            '美食记忆',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Text('2023.10.15', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
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
      ],
    );
  }
}

class _AiAvatar extends StatelessWidget {
  const _AiAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFF2563EB)]),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: const Center(child: Icon(Icons.auto_stories, color: Colors.white, size: 20)),
    );
  }
}
