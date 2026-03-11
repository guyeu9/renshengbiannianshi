import 'package:flutter/material.dart';
import 'package:life_chronicle/features/ai_historian/models/module_config.dart';
import 'package:life_chronicle/features/ai_historian/models/quick_action_config.dart';
import 'friend_configs.dart';

const String _systemPrompt = '''
你是人生编年史APP的AI史官，也是用户的"人生数据分析师"。

你的任务不是简单总结，而是通过用户的人生记录数据：
- 发现行为模式
- 识别隐藏规律
- 解释用户的生活方式
- 给出改善建议

你的回答需要：
- 温暖：像一个真正了解用户的朋友
- 有洞察：发现用户可能没有意识到的模式
- 有数据支撑：用统计数据支持你的结论
- 可执行：给出具体可操作的建议

输出结构必须包含：
【核心洞察】
【数据支撑】
【行为模式】
【专属建议】

如涉及推荐记录，请在回复末尾输出推荐卡片JSON。
''';

const String _foodModulePrompt = '''
当前分析模块：美食模块

你的职责是通过用户的美食记录数据，分析用户的：
- 饮食习惯
- 口味偏好
- 消费模式
- 社交场景

分析重点：
1. 口味偏好识别：从评分、标签、描述中识别用户的口味DNA
2. 消费习惯分析：分析人均消费分布、高频消费地点
3. 地理分布洞察：分析美食记录的城市分布、区域偏好
4. 时间规律发现：发现用餐时间规律、季节性偏好
5. 社交属性分析：分析独自用餐vs聚餐的比例和场景
6. 收藏价值评估：分析收藏记录的共同特征
''';

const String _travelModulePrompt = '''
当前分析模块：旅行模块

你的职责是通过用户的旅行记录数据，分析用户的：
- 旅行人格
- 目的地偏好
- 花费结构
- 旅行模式

分析重点：
1. 足迹可视化：帮助用户可视化旅行足迹分布
2. 花费结构分析：分析交通、住宿、餐饮、景点等花费占比
3. 旅行模式识别：识别周末游、长假游、商务出行等模式
4. 同伴关系分析：分析同行伙伴与旅行体验的关系
5. 目的地偏好：分析用户对目的地类型的偏好
6. 季节规律：发现旅行季节偏好和最佳出行时间
''';

const String _momentModulePrompt = '''
当前分析模块：小确幸模块

你的职责是通过用户的小确幸记录数据，分析用户的：
- 幸福触发器
- 心情模式
- 场景偏好
- 情绪规律

分析重点：
1. 情绪波动追踪：追踪心情变化趋势和触发因素
2. 幸福来源识别：识别什么类型的事情最容易带来幸福感
3. 场景偏好分析：分析居家、户外、读书等不同场景的记录分布
4. 时间规律发现：发现一天中、一周内的幸福时刻分布
5. 内容深度挖掘：从简短记录中挖掘深层情感
6. 正向反馈循环：帮助用户发现如何创造更多小确幸
''';

const String _goalModulePrompt = '''
当前分析模块：目标模块

你的职责是通过用户的目标记录数据，分析用户的：
- 目标执行力
- 完成模式
- 延期原因
- 目标平衡

分析重点：
1. 进度可视化：清晰展示各目标完成进度
2. 完成率计算：计算分类完成率和整体完成率
3. 延期原因分析：分析目标顺延的原因和模式
4. 目标平衡评估：评估目标在各类别间的分布合理性
5. 执行障碍识别：识别阻碍目标完成的常见因素
6. 可行性建议：基于历史数据给出切实可行的改进建议
''';

const String _bondModulePrompt = '''
当前分析模块：羁绊模块

你的职责是通过用户的社交记录数据，分析用户的：
- 社交网络
- 关系健康度
- 见面模式
- 重要关系

分析重点：
1. 社交网络分析：分析社交关系的广度和深度
2. 亲密度评估：基于见面频率评估关系亲密度
3. 维护提醒：识别需要维护的疏远关系
4. 共同记忆挖掘：挖掘与特定朋友的重要共同经历
5. 分组特征分析：分析不同朋友群体的特征
6. 关系发展建议：给出关系维护和深化的建议
''';

const List<QuickActionConfig> _foodQuickActions = [
  QuickActionConfig(
    id: 'taste_dna',
    label: '口味DNA分析',
    icon: Icons.restaurant_menu,
    iconColor: Color(0xFFF97316),
    analysisType: 'taste_dna',
    queryTemplate: '''请基于我的美食记录数据，深度分析我的"口味DNA"。

不仅要统计喜欢的菜系，还要识别：
1）我真正偏爱的味型（辣/清淡/重油/鲜味等）
2）评分最高的餐厅类型和共性
3）消费价格与满意度之间的关系
4）我更喜欢独自用餐还是社交聚餐
5）是否存在隐藏偏好（如某些菜系评分更高但次数较少）

最后请总结我的美食人格类型，并给出3个符合我口味的探索建议。''',
  ),
  QuickActionConfig(
    id: 'spending_pattern',
    label: '消费模式分析',
    icon: Icons.trending_up,
    iconColor: Color(0xFF3B82F6),
    analysisType: 'spending_pattern',
    queryTemplate: '''请分析我的美食消费模式，重点包括：

1）消费价格区间分布（低/中/高消费）
2）不同价格区间的满意度差异
3）消费地点分布（城市/商圈）
4）是否存在固定美食路线或高频餐厅类型
5）消费时间规律（工作日/周末、午餐/晚餐）

请总结我的消费习惯，并给出更高性价比的美食策略建议。''',
  ),
  QuickActionConfig(
    id: 'happiness_factor',
    label: '高分幸福因子',
    icon: Icons.star,
    iconColor: Color(0xFFF59E0B),
    analysisType: 'happiness_factor',
    queryTemplate: '''请找出我评分最高的美食记录，并分析这些餐厅让我满意的原因。

重点识别：
1）高评分餐厅的共同特征
2）菜系、价格、环境或服务因素
3）是否与朋友聚餐相关
4）是否存在某些"幸福场景"

最后总结：什么样的餐厅最容易让我感到满足。''',
  ),
  QuickActionConfig(
    id: 'city_food_map',
    label: '城市美食版图',
    icon: Icons.map,
    iconColor: Color(0xFF10B981),
    analysisType: 'city_food_map',
    queryTemplate: '''请根据我的美食记录，构建我的"城市美食版图"。

分析内容包括：
1）各城市的美食记录数量
2）不同城市的偏好菜系
3）我最喜欢的美食城市
4）是否存在某些城市评分更高
5）不同城市的消费差异

最后给出一个属于我的"美食旅行建议地图"。''',
  ),
  QuickActionConfig(
    id: 'wishlist_strategy',
    label: '心愿清单策略',
    icon: Icons.favorite_border,
    iconColor: Color(0xFFEC4899),
    analysisType: 'wishlist_strategy',
    queryTemplate: '''请分析我的美食心愿清单（wishlist）。

重点分析：
1）心愿餐厅类型
2）城市分布
3）价格区间
4）与我历史口味的匹配度

请帮我制定一个合理的"美食打卡计划"，包括：
优先打卡顺序 + 推荐搭配路线。''',
  ),
];

const List<QuickActionConfig> _travelQuickActions = [
  QuickActionConfig(
    id: 'travel_personality',
    label: '我的旅行人格',
    icon: Icons.flight_takeoff,
    iconColor: Color(0xFF3B82F6),
    analysisType: 'travel_personality',
    queryTemplate: '''请根据我的旅行记录分析我的"旅行人格"。

重点识别：
1）我是探索型 / 休闲型 / 打卡型 / 文化型旅行者
2）最喜欢的旅行目的地类型
3）旅行时间长度偏好
4）旅行预算风格
5）旅行伙伴模式

最后总结我的旅行风格画像。''',
  ),
  QuickActionConfig(
    id: 'expense_structure',
    label: '花费结构分析',
    icon: Icons.account_balance_wallet,
    iconColor: Color(0xFF10B981),
    analysisType: 'expense_structure',
    queryTemplate: '''请分析我的旅行花费结构。

包括：
- 交通 / 住宿 / 餐饮 / 景点 / 购物占比
- 不同旅行类型花费差异
- 高满意度旅行的花费结构

最后给出预算优化建议。''',
  ),
  QuickActionConfig(
    id: 'happiest_trip',
    label: '最幸福的旅行',
    icon: Icons.mood,
    iconColor: Color(0xFFF59E0B),
    analysisType: 'happiest_trip',
    queryTemplate: '''找出评分最高或心情最好的旅行。

分析为什么这次旅行让我如此开心：
- 旅行伙伴
- 行程安排
- 目的地类型
- 花费结构''',
  ),
  QuickActionConfig(
    id: 'seasonal_pattern',
    label: '旅行季节规律',
    icon: Icons.calendar_month,
    iconColor: Color(0xFF8B5CF6),
    analysisType: 'seasonal_pattern',
    queryTemplate: '''分析我一年中最常旅行的时间。

识别：
- 最佳旅行季节
- 高满意度旅行月份
- 可能适合我的未来旅行时间''',
  ),
  QuickActionConfig(
    id: 'wishlist_recommend',
    label: '愿望目的地推荐',
    icon: Icons.location_on,
    iconColor: Color(0xFFEC4899),
    analysisType: 'wishlist_recommend',
    queryTemplate: '''根据我的历史旅行偏好推荐新的旅行目的地。

匹配：
- 目的地类型
- 旅行预算
- 旅行时间''',
  ),
];

const List<QuickActionConfig> _momentQuickActions = [
  QuickActionConfig(
    id: 'happiness_trigger',
    label: '幸福触发器',
    icon: Icons.auto_awesome,
    iconColor: Color(0xFFA855F7),
    analysisType: 'happiness_trigger',
    queryTemplate: '''请分析什么最容易让我产生幸福感。

识别：
- 场景
- 人物
- 时间
- 关键词
- 心情标签

总结我的"幸福配方"。''',
  ),
  QuickActionConfig(
    id: 'happiness_time',
    label: '幸福时间规律',
    icon: Icons.schedule,
    iconColor: Color(0xFF3B82F6),
    analysisType: 'happiness_time',
    queryTemplate: '''分析一天中、一周中我最容易记录小确幸的时间。

识别：
- 高频时段
- 心情最好的时间
- 建议的幸福时刻''',
  ),
  QuickActionConfig(
    id: 'happiness_recipe',
    label: '我的幸福配方',
    icon: Icons.favorite,
    iconColor: Color(0xFFEC4899),
    analysisType: 'happiness_recipe',
    queryTemplate: '''总结让我最容易快乐的生活组合。

基于我的记录数据，分析：
- 最常出现的幸福场景
- 最常伴随的心情
- 可以复制的幸福模式''',
  ),
  QuickActionConfig(
    id: 'mood_trend',
    label: '心情变化趋势',
    icon: Icons.show_chart,
    iconColor: Color(0xFF10B981),
    analysisType: 'mood_trend',
    queryTemplate: '''分析最近心情变化趋势。

包括：
- 心情分布
- 情绪波动规律
- 影响因素分析''',
  ),
  QuickActionConfig(
    id: 'hidden_gems',
    label: '被忽略的美好',
    icon: Icons.diamond,
    iconColor: Color(0xFFF59E0B),
    analysisType: 'hidden_gems',
    queryTemplate: '''找出被忽略但重复出现的幸福模式。

识别：
- 低频但高幸福感的场景
- 被忽视的规律
- 可以更多尝试的事情''',
  ),
];

const List<QuickActionConfig> _goalQuickActions = [
  QuickActionConfig(
    id: 'execution_pattern',
    label: '目标执行力分析',
    icon: Icons.analytics,
    iconColor: Color(0xFF3B82F6),
    analysisType: 'execution_pattern',
    queryTemplate: '''请分析我的目标执行力模式。

重点识别：
1）完成率最高的目标类型
2）最容易拖延的目标
3）顺延原因模式
4）目标规模是否合理
5）是否符合SMART原则

给出改进建议。''',
  ),
  QuickActionConfig(
    id: 'completion_analysis',
    label: '完成率分析',
    icon: Icons.check_circle,
    iconColor: Color(0xFF10B981),
    analysisType: 'completion_analysis',
    queryTemplate: '''分析我的目标完成率。

包括：
- 各分类完成率
- 年度目标完成情况
- 完成与未完成的特征对比''',
  ),
  QuickActionConfig(
    id: 'postponed_review',
    label: '顺延目标检视',
    icon: Icons.schedule,
    iconColor: Color(0xFFF59E0B),
    analysisType: 'postponed_review',
    queryTemplate: '''检视我被顺延的目标。

分析：
- 顺延原因
- 顺延模式
- 调整建议''',
  ),
  QuickActionConfig(
    id: 'balance_check',
    label: '目标平衡评估',
    icon: Icons.balance,
    iconColor: Color(0xFF8B5CF6),
    analysisType: 'balance_check',
    queryTemplate: '''分析我的目标在职业、健康、学习等分类上的分布是否均衡。

给出平衡建议。''',
  ),
  QuickActionConfig(
    id: 'planning_advice',
    label: '规划建议',
    icon: Icons.event_note,
    iconColor: Color(0xFFEC4899),
    analysisType: 'planning_advice',
    queryTemplate: '''根据当前目标完成情况，给出下季度的目标规划建议。''',
  ),
];

const List<QuickActionConfig> _bondQuickActions = [
  QuickActionConfig(
    id: 'social_network',
    label: '社交关系网络',
    icon: Icons.hub,
    iconColor: Color(0xFF3B82F6),
    analysisType: 'social_network',
    queryTemplate: '''请分析我的社交关系网络。

包括：
- 朋友分布
- 见面频率
- 关系健康度
- 重要关系
- 需要维护的关系''',
  ),
  QuickActionConfig(
    id: 'encounter_frequency',
    label: '见面频率分析',
    icon: Icons.timeline,
    iconColor: Color(0xFF10B981),
    analysisType: 'encounter_frequency',
    queryTemplate: '''分析我与各朋友的见面频率。

识别：
- 高频联系人
- 疏远的关系
- 需要维护的朋友''',
  ),
  QuickActionConfig(
    id: 'shared_memories',
    label: '共同回忆梳理',
    icon: Icons.photo_album,
    iconColor: Color(0xFFF59E0B),
    analysisType: 'shared_memories',
    queryTemplate: '''梳理我与朋友们的重要共同回忆，按时间线呈现。''',
  ),
  QuickActionConfig(
    id: 'contact_reminder',
    label: '联络提醒建议',
    icon: Icons.notifications_active,
    iconColor: Color(0xFFEC4899),
    analysisType: 'contact_reminder',
    queryTemplate: '''根据联络频率设置，提醒我需要联系的朋友。''',
  ),
  QuickActionConfig(
    id: 'group_analysis',
    label: '分组特征分析',
    icon: Icons.groups,
    iconColor: Color(0xFF8B5CF6),
    analysisType: 'group_analysis',
    queryTemplate: '''分析各朋友分组的特征，如家人、同事、闺蜜等群体的共同特点。''',
  ),
];

const foodModuleConfig = ModuleConfig(
  moduleType: 'food',
  moduleName: '美食',
  modulePrompt: _foodModulePrompt,
  analysisTypes: [
    'taste_dna',
    'spending_pattern',
    'happiness_factor',
    'city_food_map',
    'wishlist_strategy',
  ],
  quickActions: _foodQuickActions,
  keyFields: ['rating', 'pricePerPerson', 'tags', 'city', 'mood', 'isFavorite'],
);

const travelModuleConfig = ModuleConfig(
  moduleType: 'travel',
  moduleName: '旅行',
  modulePrompt: _travelModulePrompt,
  analysisTypes: [
    'travel_personality',
    'expense_structure',
    'happiest_trip',
    'seasonal_pattern',
    'wishlist_recommend',
  ],
  quickActions: _travelQuickActions,
  keyFields: ['destination', 'expenseTransport', 'expenseHotel', 'expenseFood', 'mood', 'isFavorite'],
);

const momentModuleConfig = ModuleConfig(
  moduleType: 'moment',
  moduleName: '小确幸',
  modulePrompt: _momentModulePrompt,
  analysisTypes: [
    'happiness_trigger',
    'happiness_time',
    'happiness_recipe',
    'mood_trend',
    'hidden_gems',
  ],
  quickActions: _momentQuickActions,
  keyFields: ['mood', 'moodColor', 'sceneTag', 'city', 'isFavorite'],
);

const goalModuleConfig = ModuleConfig(
  moduleType: 'goal',
  moduleName: '目标',
  modulePrompt: _goalModulePrompt,
  analysisTypes: [
    'execution_pattern',
    'completion_analysis',
    'postponed_review',
    'balance_check',
    'planning_advice',
  ],
  quickActions: _goalQuickActions,
  keyFields: ['level', 'category', 'progress', 'isCompleted', 'isPostponed', 'targetYear'],
);

const bondModuleConfig = ModuleConfig(
  moduleType: 'bond',
  moduleName: '羁绊',
  modulePrompt: _bondModulePrompt,
  analysisTypes: [
    'social_network',
    'encounter_frequency',
    'shared_memories',
    'contact_reminder',
    'group_analysis',
  ],
  quickActions: _bondQuickActions,
  keyFields: ['groupName', 'meetWay', 'contactFrequency', 'lastMeetDate', 'isFavorite'],
);

final Map<String, ModuleConfig> moduleConfigs = {
  'food': foodModuleConfig,
  'travel': travelModuleConfig,
  'moment': momentModuleConfig,
  'goal': goalModuleConfig,
  'bond': bondModuleConfig,
  'friend': friendModuleConfig,
};

ModuleConfig? getModuleConfig(String moduleType) {
  return moduleConfigs[moduleType];
}

String getSystemPrompt() => _systemPrompt;
