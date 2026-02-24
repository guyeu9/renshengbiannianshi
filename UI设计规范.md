# 人生博物馆 - UI设计规范

## 一、概述

本文档定义了人生博物馆APP的统一UI设计规范，旨在确保所有页面、组件、交互保持一致的视觉风格和用户体验。

### 设计理念
- **整体风格**：现代简约清新风格，搭配轻微新拟物化设计
- **核心理念**：温暖、治愈、贴合"人生博物馆"的定位
- **色彩主调**：淡青色（#2BCDEE）作为主题蓝色

---

## 二、色彩系统

### 2.1 核心色彩

| 色彩名称 | 色值 | 用途 |
|---------|------|------|
| 主色 Primary | #2BCDEE | 主按钮、导航栏、选中状态、重要强调 |
| 主色深 Primary Dark | #209BB3 | 主按钮hover状态、深色背景下的主色 |
| 背景色 Background Light | #F6F8F8 | 页面背景 |
| 背景深色 Background Dark | #101F22 | 深色模式背景 |
| 表面色 Surface | #FFFFFF | 卡片、弹窗背景 |
| 表面深色 Surface Dark | #1A2C30 | 深色模式卡片背景 |
| 文字主色 Text Main | #1F2937 | 正文、标题 |
| 文字辅色 Text Muted | #6B7280 | 辅助文字、占位符 |
| 文字禁用 Text Disabled | #9CA3AF | 禁用状态文字 |

### 2.2 功能色彩

| 功能色彩 | 色值 | 用途 |
|---------|------|------|
| 美食橙 Food Orange | #FF9F43 | 美食模块、美食标签 |
| 开心粉 Joy Pink | #FF87AB | 开心心情、小确幸粉色背景 |
| 平静蓝 Calm Blue | #64B5F6 | 平静心情、小确幸蓝色背景 |
| 治愈绿 Heal Green | #81C784 | 治愈心情、小确幸绿色背景 |
| 焦虑灰 Anxiety Gray | #9E9E9E | 焦虑心情、小确幸灰色背景 |
| 旅行蓝 Travel Blue | #42A5F5 | 旅行模块 |
| 羁绊红 Bond Red | #EF5350 | 羁绊模块 |
| 目标紫 Goal Purple | #AB47BC | 目标模块 |
| 成功绿 Success Green | #4CAF50 | 成功提示、完成状态 |
| 警告黄 Warning Yellow | #FFC107 | 警告提示、待办提醒 |
| 错误红 Error Red | #F44336 | 错误提示、危险操作 |

### 2.3 透明度规范

| 透明度 | 场景 |
|-------|------|
| 100% | 主要文字、实心按钮 |
| 70% | 次要文字、图标 |
| 50% | 占位符文字、禁用状态 |
| 30% | 分割线、边框 |
| 10% | 背景装饰、hover效果 |

---

## 三、按钮规范

### 3.1 AI解析按钮（AI史官样式）

**用途**：所有功能页面顶部的AI解析/AI史官按钮

**样式规范**：
```
样式：圆角胶囊按钮
圆角：9999px (full)
背景色：#EEFCFC (主色10%透明度)
文字色：#2BCDEE (主色)
边框：1px solid #2BCDEE (主色)
内边距：水平16px (px-4)，垂直6px (py-1.5)
字体：粗体 (font-bold)，字号14px (text-sm)
hover状态：背景色变深为 #DEF9F9
```

**HTML示例**：
```html
<button class="px-4 py-1.5 rounded-full bg-[#eefcfc] hover:bg-[#def9f9] transition-colors text-primary text-sm font-bold border border-primary">
  AI史官
</button>
```

### 3.2 主按钮（Primary Button）

**用途**：主要操作，如发布、保存、确认等

**样式规范**：
```
样式：圆角胶囊按钮或圆角矩形按钮
圆角：9999px (胶囊) 或 12px (矩形)
背景色：#2BCDEE (主色)
文字色：#FFFFFF (白色)
内边距：水平24px，垂直12px
字体：粗体 (font-bold)，字号14px
阴影：shadow-md，主色40%透明度
hover状态：背景色变深为 #209BB3，轻微放大 scale-105
active状态：缩小 scale-95
```

### 3.3 次要按钮（Secondary Button）

**用途**：次要操作，如取消、返回等

**样式规范**：
```
样式：圆角胶囊按钮或圆角矩形按钮
圆角：9999px (胶囊) 或 12px (矩形)
背景色：透明 或 #F3F4F6
文字色：#1F2937 (文字主色)
边框：1px solid #E5E7EB
内边距：水平24px，垂直12px
字体：中等 (font-medium)，字号14px
hover状态：背景色变深为 #E5E7EB
```

### 3.4 文字按钮（Text Button）

**用途**：链接性操作，如查看更多、编辑等

**样式规范**：
```
样式：无边框按钮
背景色：透明
文字色：#2BCDEE (主色)
内边距：水平8px，垂直4px
字体：中等 (font-medium)，字号14px
hover状态：文字色变深为 #209BB3，背景色为主色10%透明度
```

### 3.5 图标按钮（Icon Button）

**用途**：工具栏、导航栏中的图标操作

**样式规范**：
```
样式：圆形按钮
圆角：9999px (full)
背景色：透明 或 主色10%透明度
图标色：#6B7280 (文字辅色) 或 #2BCDEE (主色)
尺寸：40x40px 或 36x36px
内边距：8px
hover状态：背景色变为灰色10%透明度，图标色变深
```

### 3.6 浮动操作按钮（FAB）

**用途**：页面主要操作，如添加、发布等

**样式规范**：
```
样式：圆形按钮
圆角：9999px (full)
背景色：#2BCDEE (主色)
图标色：#FFFFFF (白色)
尺寸：56x56px
阴影：shadow-lg，主色40%透明度
位置：fixed bottom-24 right-5 (距离底部导航24px，右侧20px)
hover状态：轻微放大 scale-105
active状态：缩小 scale-95
```

**HTML示例**：
```html
<button class="fixed bottom-24 right-5 w-14 h-14 bg-primary text-white rounded-full shadow-lg shadow-primary/40 flex items-center justify-center z-40 hover:scale-105 transition-transform active:scale-95">
  <span class="material-icons-round text-2xl">add</span>
</button>
```

---

## 四、卡片规范

### 4.1 基础卡片

**样式规范**：
```
背景色：#FFFFFF (表面色)
圆角：12px (rounded-xl)
阴影：shadow-soft (0 4px 20px -2px rgba(43, 205, 238, 0.1), 0 2px 10px -2px rgba(0, 0, 0, 0.02))
边框：可选，1px solid #F3F4F6
内边距：16px
hover状态：阴影变深 shadow-lg，轻微放大 scale-102
```

### 4.2 记录卡片（瀑布流）

**样式规范**：
```
背景色：#FFFFFF (表面色)
圆角：12px (rounded-xl)
阴影：shadow-sm
边框：1px solid #F3F4F6
内边距：12px
图片比例：4:5 或 1:1 或 3:4
图片圆角：12px (与卡片一致)
hover状态：阴影变深 shadow-lg，图片轻微放大 scale-110
```

### 4.3 玻璃态卡片（Glassmorphism）

**样式规范**：
```
背景色：rgba(255, 255, 255, 0.7)
毛玻璃效果：backdrop-filter: blur(12px)
边框：1px solid rgba(255, 255, 255, 0.5)
圆角：12px
```

---

## 五、弹窗规范

### 5.1 底部弹窗（Bottom Sheet）

**用途**：选择器、确认框、操作菜单等

**样式规范**：
```
背景色：#FFFFFF (表面色)
圆角：顶部24px (rounded-t-2xl)
阴影：shadow-xl
高度：最大为屏幕高度的80%
拖拽指示器：顶部中央36x4px的灰色圆角条
关闭方式：点击遮罩、向下滑动、点击关闭按钮
```

**禁用样式**：
- ❌ 禁止使用原生Android弹窗样式
- ❌ 禁止使用系统默认对话框

### 5.2 中央弹窗（Dialog）

**用途**：重要确认、表单填写等

**样式规范**：
```
背景色：#FFFFFF (表面色)
圆角：16px (rounded-2xl)
阴影：shadow-2xl
宽度：最大为屏幕宽度的85%，最小300px
内边距：24px
标题：粗体，字号18px，居中或居左
内容：字号14px，文字主色
按钮：底部横向排列，主按钮在右
```

---

## 六、导航规范

### 6.1 顶部导航栏（AppBar）

**样式规范**：
```
背景色：rgba(255, 255, 255, 0.7) (玻璃态)
毛玻璃效果：backdrop-filter: blur(12px)
高度：56px - 64px
内边距：水平20px，垂直16px
标题：字号18px，粗体，文字主色
图标：文字主色或文字辅色
阴影：shadow-sm
固定：sticky top-0
```

### 6.2 底部导航栏（Bottom Navigation）

**样式规范**：
```
背景色：rgba(255, 255, 255, 0.95) (玻璃态)
毛玻璃效果：backdrop-filter: blur(12px)
高度：64px - 72px (含安全区域)
顶部边框：1px solid #F3F4F6
图标尺寸：24px
图标颜色：未选中 #9CA3AF，选中 #2BCDEE
文字字号：10px
文字颜色：未选中 #9CA3AF，选中 #2BCDEE
选中状态：图标填充 (FILL 1)，文字粗体
```

**HTML示例**：
```html
<nav class="fixed bottom-0 left-0 w-full bg-white/95 backdrop-blur-xl border-t border-gray-100 px-2 py-2 pb-6 z-50 flex justify-between items-center text-[10px]">
  <a class="flex flex-col items-center gap-1 w-full text-primary" href="#">
    <span class="material-icons-round text-2xl">calendar_today</span>
    <span class="font-medium">日程</span>
  </a>
  <!-- 更多导航项... -->
</nav>
```

---

## 七、输入框规范

### 7.1 基础输入框

**样式规范**：
```
背景色：#FFFFFF (表面色)
圆角：12px (rounded-xl)
边框：默认透明，focus时主色50%透明度
内边距：水平12px，垂直10px
字号：14px
占位符：文字辅色，70%透明度
focus状态：ring-2，主色10%透明度，边框主色50%透明度
阴影：shadow-sm
```

### 7.2 搜索输入框

**样式规范**：
```
背景色：#FFFFFF (表面色)
圆角：12px (rounded-xl)
左侧图标：搜索图标，文字辅色
右侧操作：筛选、清除等按钮
内边距：左侧40px，右侧40px，垂直10px
占位符："搜索..."
```

**HTML示例**：
```html
<div class="relative mb-4">
  <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
    <span class="material-symbols-outlined text-text-sub-light text-[20px]">search</span>
  </div>
  <input class="block w-full pl-10 pr-3 py-2.5 border-none rounded-xl bg-white dark:bg-card-dark shadow-sm text-sm placeholder-text-sub-light/70 focus:ring-2 focus:ring-primary/50 text-text-main-light" placeholder="搜索店名、标签、地理位置..." type="text"/>
  <div class="absolute inset-y-0 right-0 pr-2 flex items-center">
    <button class="p-1.5 rounded-lg hover:bg-gray-100 text-text-sub-light transition-colors">
      <span class="material-symbols-outlined text-[20px]">tune</span>
    </button>
  </div>
</div>
```

---

## 八、标签规范

### 8.1 模块标签

**样式规范**：
```
圆角：8px (rounded-lg)
内边距：水平8px，垂直4px
字号：10px (text-[10px])
字体：中等 (font-medium)
图标：左侧，14px
```

**色彩映射**：
| 模块 | 背景色 | 文字色 | 图标色 |
|------|--------|--------|--------|
| 美食 | 橙色50 (#FFF3E0) | 橙色600 (#FB8C00) | 橙色400 |
| 旅行 | 蓝色50 (#E3F2FD) | 蓝色600 (#1E88E5) | 蓝色400 |
| 小确幸 | 青色50 (#E0F7FA) | 青色600 (#00ACC1) | 青色400 |
| 目标 | 紫色50 (#F3E5F5) | 紫色600 (#8E24AA) | 紫色400 |
| 羁绊 | 红色50 (#FFEBEE) | 红色600 (#E53935) | 红色400 |

**HTML示例**：
```html
<span class="inline-flex items-center gap-1 px-2 py-1 bg-orange-50 rounded-lg text-[10px] text-orange-600 border border-orange-100">
  <span class="material-icons-round text-[10px]">restaurant</span>
  美食
</span>
```

### 8.2 状态标签

**样式规范**：
```
圆角：9999px (rounded-full)
内边距：水平8px，垂直4px
字号：10px (text-[10px])
字体：中等 (font-medium)
```

---

## 九、圆角规范

| 用途 | 圆角值 | Tailwind类 |
|------|--------|-----------|
| 胶囊按钮、圆形按钮 | 9999px | rounded-full |
| 大卡片、弹窗 | 16px | rounded-2xl |
| 基础卡片、输入框 | 12px | rounded-xl |
| 小卡片、标签 | 8px | rounded-lg |
| 微小组件 | 4px | rounded |

---

## 十、阴影规范

| 阴影名称 | 样式 | 用途 |
|---------|------|------|
| shadow-soft | 0 4px 20px -2px rgba(43, 205, 238, 0.1), 0 2px 10px -2px rgba(0, 0, 0, 0.02) | 基础卡片、导航栏 |
| shadow-sm | 0 1px 2px 0 rgba(0, 0, 0, 0.05) | 输入框、小卡片 |
| shadow-md | 0 4px 6px -1px rgba(0, 0, 0, 0.1) | 主按钮 |
| shadow-lg | 0 10px 15px -3px rgba(0, 0, 0, 0.1) | 悬浮按钮、弹窗 |
| shadow-xl | 0 20px 25px -5px rgba(0, 0, 0, 0.1) | 底部弹窗 |
| shadow-glass | 0 8px 32px 0 rgba(31, 38, 135, 0.07) | 玻璃态组件 |

---

## 十一、字体规范

### 11.1 字体族

| 用途 | 字体族 |
|------|--------|
| 标题、展示 | Plus Jakarta Sans, PingFang SC, Microsoft YaHei, sans-serif |
| 正文 | PingFang SC, Microsoft YaHei, sans-serif |

### 11.2 字号规范

| 级别 | 字号 | 字重 | 用途 |
|------|------|------|------|
| Display | 28px | Bold | 页面大标题 |
| H1 | 24px | Bold | 页面标题 |
| H2 | 20px | Bold | 模块标题 |
| H3 | 18px | Bold | 卡片标题 |
| Body Large | 16px | Medium | 正文 |
| Body | 14px | Regular | 正文、按钮 |
| Body Small | 12px | Regular | 辅助文字 |
| Caption | 10px | Medium | 标签、提示文字 |

### 11.3 字重规范

| 字重 | 数值 | 用途 |
|------|------|------|
| Regular | 400 | 正文 |
| Medium | 500 | 次要标题、按钮 |
| SemiBold | 600 | 小标题 |
| Bold | 700 | 主标题 |

---

## 十二、图标规范

### 12.1 图标库

使用 Google Material Icons (Round 风格)

### 12.2 图标尺寸

| 用途 | 尺寸 |
|------|------|
| 导航栏图标 | 24px |
| 按钮图标 | 20px - 24px |
| 标签图标 | 14px - 16px |
| 卡片装饰图标 | 18px - 20px |

### 12.3 图标颜色

| 状态 | 颜色 |
|------|------|
| 主要图标 | #2BCDEE (主色) |
| 次要图标 | #6B7280 (文字辅色) |
| 禁用图标 | #9CA3AF (文字禁用) |

---

## 十三、间距规范

采用 4px 基准的间距系统：

| 间距名称 | 数值 | Tailwind类 |
|---------|------|-----------|
| 2xs | 4px | space-1 |
| xs | 8px | space-2 |
| sm | 12px | space-3 |
| md | 16px | space-4 |
| lg | 20px | space-5 |
| xl | 24px | space-6 |
| 2xl | 32px | space-8 |
| 3xl | 48px | space-12 |

---

## 十四、动效规范

### 14.1 过渡动画

| 用途 | 时长 | 缓动函数 |
|------|------|---------|
| 颜色变化、hover | 150ms - 200ms | ease-out |
| 缩放、位移 | 200ms - 300ms | ease-out |
| 页面切换 | 300ms | ease-in-out |
| 微交互 | 150ms | ease-out |

### 14.2 微交互

- **按钮按下**：scale-95 (缩小5%)
- **按钮hover**：scale-105 (放大5%)
- **卡片hover**：scale-102 (放大2%)
- **图片hover**：scale-110 (放大10%)

---

## 十五、改进建议

### 15.1 立即改进项

1. **统一AI解析按钮样式**
   - ✅ 所有页面顶部的AI解析按钮统一使用"AI史官"样式
   - ✅ 背景色：#EEFCFC，边框：1px solid #2BCDEE，文字色：#2BCDEE
   - ✅ 圆角：9999px (full)

2. **替换原生弹窗**
   - ❌ 禁止使用原生Android弹窗
   - ✅ 全部使用底部弹窗 (Bottom Sheet) 或 中央弹窗 (Dialog)
   - ✅ 底部弹窗样式：顶部圆角24px，带拖拽指示器

3. **统一主题蓝色**
   - ✅ 所有主色统一使用 #2BCDEE
   - ✅ 确保按钮、导航、选中状态颜色一致

### 15.2 中期改进项

1. **完善玻璃态效果**
   - 导航栏、顶部栏统一使用玻璃态效果
   - backdrop-filter: blur(12px)
   - 背景透明度：0.7 - 0.95

2. **统一卡片阴影**
   - 所有卡片使用 shadow-soft 样式
   - 确保阴影颜色包含主色调

3. **完善微交互**
   - 按钮hover/active状态
   - 卡片hover效果
   - 图片缩放动画

### 15.3 长期改进项

1. **深色模式适配**
   - 完善所有组件的深色模式样式
   - 确保文字对比度符合WCAG标准

2. **组件库建设**
   - 提取通用组件为独立组件
   - Button、Card、Dialog、Input等

3. **设计Token化**
   - 将所有设计规范转换为设计Token
   - 便于主题切换和维护

---

## 十六、检查清单

### 16.1 新页面开发检查

- [ ] 色彩使用符合规范
- [ ] 按钮样式统一
- [ ] 弹窗使用Bottom Sheet/Dialog
- [ ] 圆角规范正确
- [ ] 阴影样式统一
- [ ] 字体字号符合规范
- [ ] 间距使用4px基准
- [ ] 图标使用Material Icons Round
- [ ] 动效过渡自然
- [ ] 响应式适配完成

### 16.2 组件复用检查

- [ ] AI解析按钮使用统一样式
- [ ] 主按钮样式一致
- [ ] 卡片样式统一
- [ ] 输入框样式一致
- [ ] 标签样式统一

---

## 附录：完整Tailwind配置

```javascript
tailwind.config = {
  darkMode: "class",
  theme: {
    extend: {
      colors: {
        "primary": "#2bcdee",
        "primary-dark": "#209bb3",
        "background-light": "#f6f8f8",
        "background-dark": "#101f22",
        "neutral-surface": "#ffffff",
        "text-main": "#1f2937",
        "text-muted": "#6b7280",
        "secondary": "#FF9F43",
      },
      fontFamily: {
        "display": ["Plus Jakarta Sans", "PingFang SC", "Microsoft YaHei", "sans-serif"],
        "body": ["PingFang SC", "Microsoft YaHei", "sans-serif"]
      },
      borderRadius: {
        "DEFAULT": "1rem", 
        "lg": "1.5rem", 
        "xl": "2rem", 
        "2xl": "2.5rem",
        "full": "9999px"
      },
      boxShadow: {
        'soft': '0 4px 20px -2px rgba(43, 205, 238, 0.1), 0 2px 10px -2px rgba(0, 0, 0, 0.02)',
        'glass': '0 8px 32px 0 rgba(31, 38, 135, 0.07)',
      }
    },
  },
}
```

---

**文档版本**：v1.0  
**最后更新**：2026-02-24  
**维护者**：设计团队
