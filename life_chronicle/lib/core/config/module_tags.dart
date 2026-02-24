class ModuleTags {
  ModuleTags._();

  static const food = [
    '必吃榜',
    '周末探店',
    '辣',
    '火锅',
    '烤肉',
    '日料',
    '甜品',
    '咖啡',
  ];

  static const moment = [
    '读书',
    '搬家',
    '桌面布置',
    '电影',
  ];

  static const bond = [
    '家人',
    '同学',
    '同事',
    '闺蜜',
    '饭搭子',
    '旅行搭子',
    '球友',
    '靠谱',
    '有趣',
    '温柔',
    '爱运动',
    '爱拍照',
  ];

  static const goal = [
    '职业发展',
    '身心健康',
    '环球旅行',
  ];

  static const travel = [
    '国内游',
    '露营',
    '海岛',
    '城市漫游',
  ];

  static List<String> forModule(String moduleKey) {
    switch (moduleKey) {
      case 'food':
        return food;
      case 'moment':
        return moment;
      case 'bond':
        return bond;
      case 'goal':
        return goal;
      case 'travel':
        return travel;
      default:
        return const [];
    }
  }
}
