# CI测试报告优化任务分解

## 任务列表

### 任务1：创建友好测试报告生成脚本
**优先级**：高
**验证方法**：
- 脚本能成功读取 test-results.json
- 能生成有效的HTML文件
- 运行 `dart run scripts/generate_friendly_test_report.dart` 无错误

**具体步骤**：
1.1 创建 `life_chronicle/scripts/generate_friendly_test_report.dart` 文件
1.2 实现测试结果JSON解析功能
1.3 实现模块分类功能（根据测试文件路径识别模块）
1.4 实现HTML生成功能，包含：
    - 报告标题（带"有问题"标识）
    - 总结性结论区域
    - 测试模块清单
    - 测试结果分类展示
    - 问题描述友好化转换
    - 颜色编码和图标
1.5 实现错误信息简化和术语解释功能

---

### 任务2：更新CI工作流配置
**优先级**：高
**验证方法**：
- 查看 `.github/workflows/android-apk.yml` 包含新增步骤
- 新增步骤使用 `if: always()` 确保不影响主流程
- 包含上传友好报告作为工件的步骤

**具体步骤**：
2.1 在 "Upload Test Results" 步骤后添加新步骤
2.2 新增 "Generate Friendly Test Report" 步骤，运行Dart脚本
2.3 新增 "Upload Friendly Test Report" 步骤，上传HTML报告
2.4 确保所有新增步骤都使用 `continue-on-error: true` 和 `if: always()`

---

### 任务3：本地测试验证
**优先级**：高
**验证方法**：
- 运行 `flutter test --coverage --file-reporter json:test-results.json` 生成测试数据
- 运行报告生成脚本
- 在浏览器中打开生成的HTML报告
- 验证所有功能正常：
  ✅ 报告标题正确标识"有问题"/"正常"
  ✅ 总结区域清晰展示通过率
  ✅ 模块清单完整列出
  ✅ 测试结果分类展示正确
  ✅ 颜色编码正确（红/绿）
  ✅ 问题描述通俗易懂

**具体步骤**：
3.1 运行现有测试生成测试结果
3.2 运行报告生成脚本
3.3 检查生成的HTML文件
3.4 手动验证各项功能

---

### 任务4：更新开发设计文档和更新日志
**优先级**：中
**验证方法**：
- 检查更新日志.md包含新增条目
- 检查开发设计文档包含版本变更记录

**具体步骤**：
4.1 在根目录更新日志中追加CI优化相关条目
4.2 在开发设计文档的"版本变更记录"表中新增一行
