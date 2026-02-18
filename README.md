

# 生命年鉴 (Chronicle of Life)

一个帮助你记录和管理生活中点点滴滴的跨平台应用。使用Flutter开发，支持Android、iOS、Web和Windows平台。

## 功能特性

### 📸 瞬间记录 (Moment)
随时记录生活中的美好瞬间，留住珍贵回忆。

### 👥 人际关系 (Bond)
管理与朋友、家人的联系，记录重要的人际交往。

### 🍽️ 饮食记录 (Food)
追踪您的饮食习惯，了解健康状况。

### 🎯 目标管理 (Goal)
设定并追踪您的人生目标，见证成长历程。

### 📅 日程安排 (Home Schedule)
管理日常生活和工作日程，提高时间利用效率。

### ✈️ 旅行记录 (Travel)
记录您的旅行足迹，珍藏每一段旅程。

### 🤖 AI 史料官 (AI Historian)
借助AI能力，智能分析您的生活记录，提供洞察和建议。

## 技术架构

### 核心框架
- **Flutter** - 跨平台UI框架
- **Dart** - 编程语言

### 数据存储
- **Drift** - 轻量级SQLite数据库
- **DAO模式** - 数据访问对象设计模式

### 状态管理
- **Provider/Riverpod** - 状态管理解决方案

### 支持平台
- Android
- iOS
- Web
- Windows

## 项目结构

```
life_chronicle/
├── lib/
│   ├── app/                    # 应用核心配置
│   │   ├── app.dart           # 应用入口
│   │   ├── app_shell.dart     # 应用外壳
│   │   └── app_theme.dart     # 主题配置
│   ├── core/                   # 核心功能层
│   │   └── database/          # 数据库层
│   │       ├── app_database.dart
│   │       ├── daos/          # 数据访问对象
│   │       └── migration_steps.dart
│   ├── features/              # 功能模块
│   │   ├── ai_historian/     # AI史料官
│   │   ├── bond/             # 人际关系
│   │   ├── food/             # 饮食记录
│   │   ├── goal/             # 目标管理
│   │   ├── home_schedule/    # 日程安排
│   │   ├── moment/           # 瞬间记录
│   │   ├── profile/          # 个人资料
│   │   └── travel/           # 旅行记录
│   └── main.dart             # 程序入口
├── android/                   # Android平台配置
├── web/                      # Web平台配置
└── windows_bak/             # Windows平台配置
```

## 开始使用

### 环境要求
- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio / VS Code

### 安装步骤

1. **克隆项目**
```bash
git clone https://gitee.com/suliu-here/chronicle-of-life.git
cd chronicle-of-life/life_chronicle
```

2. **获取依赖**
```bash
flutter pub get
```

3. **运行项目**
```bash
flutter run
```

### 构建APK (Android)
```bash
flutter build apk --release
```

## 贡献指南

欢迎提交Issue和Pull Request来帮助改进这个项目。

## 许可证

本项目采用 [MIT License](LICENSE) 开源协议。