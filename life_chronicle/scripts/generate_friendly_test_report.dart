import 'dart:convert';
import 'dart:io';

void main() {
  final testResultsPath = 'test-results.json';

  if (!File(testResultsPath).existsSync()) {
    stderr.writeln('警告: 找不到测试结果文件 $testResultsPath，生成空报告');
    generateEmptyReport();
    return;
  }

  final testResultsJson = File(testResultsPath).readAsStringSync();
  
  if (testResultsJson.trim().isEmpty) {
    stderr.writeln('警告: 测试结果文件为空，生成空报告');
    generateEmptyReport();
    return;
  }

  final tests = <Map<String, dynamic>>[];
  int totalTests = 0;
  int passedTests = 0;
  int failedTests = 0;
  int skippedTests = 0;
  final failedTestList = <Map<String, dynamic>>[];
  final skippedTestList = <Map<String, dynamic>>[];

  final lines = testResultsJson.split('\n');
  for (final line in lines) {
    if (line.trim().isEmpty) continue;
    
    try {
      final jsonLine = json.decode(line);
      if (jsonLine is Map<String, dynamic>) {
        if (jsonLine.containsKey('test')) {
          final test = jsonLine['test'] as Map<String, dynamic>;
          tests.add(test);
          totalTests++;
          final result = test['result'] as String?;
          if (result == 'success') {
            passedTests++;
          } else if (result == 'error' || result == 'failure') {
            failedTests++;
            failedTestList.add(test);
          } else if (result == 'skipped') {
            skippedTests++;
            skippedTestList.add(test);
          }
        } else if (jsonLine.containsKey('success')) {
          final success = jsonLine['success'] as bool?;
          if (success == false && jsonLine.containsKey('error')) {
            final error = jsonLine['error'] as String?;
            stderr.writeln('测试运行错误: $error');
          }
        }
      }
    } catch (e) {
      stderr.writeln('解析JSON行失败: $line');
    }
  }

  final hasProblems = failedTests > 0;
  final passRate = totalTests > 0 ? ((passedTests / totalTests) * 100).toStringAsFixed(1) : '0';
  final timestamp = DateTime.now().toLocal().toString().replaceAll(':', '-').replaceAll(' ', '_').substring(0, 19);
  
  final statusText = hasProblems ? '有问题' : '正常';
  final fileName = '检测报告_${statusText}_通过${passedTests}_失败${failedTests}_跳过${skippedTests}_$timestamp.html';

  final reportTitle = hasProblems ? '❌ 检测报告 - 有问题' : '✅ 检测报告 - 正常';
  final statusIcon = hasProblems ? '❌' : '✅';
  final statusBadgeText = hasProblems ? '发现问题' : '全部通过';
  final statusColor = hasProblems ? '#dc2626' : '#16a34a';

  final moduleInfo = analyzeModules(tests);

  final html = generateFriendlyReport(
    tests: tests,
    totalTests: totalTests,
    passedTests: passedTests,
    failedTests: failedTests,
    skippedTests: skippedTests,
    failedTestList: failedTestList,
    skippedTestList: skippedTestList,
    reportTitle: reportTitle,
    statusIcon: statusIcon,
    statusBadgeText: statusBadgeText,
    statusColor: statusColor,
    passRate: passRate,
    moduleInfo: moduleInfo,
    timestamp: timestamp,
    hasProblems: hasProblems,
  );

  File(fileName).writeAsStringSync(html);
  File('检测报告-latest.html').writeAsStringSync(html);

  final markdown = generateMarkdownSummary(
    tests: tests,
    totalTests: totalTests,
    passedTests: passedTests,
    failedTests: failedTests,
    skippedTests: skippedTests,
    failedTestList: failedTestList,
    skippedTestList: skippedTestList,
    reportTitle: reportTitle,
    statusIcon: statusIcon,
    statusBadgeText: statusBadgeText,
    passRate: passRate,
    moduleInfo: moduleInfo,
    timestamp: timestamp,
    hasProblems: hasProblems,
  );
  File('检测报告_summary.md').writeAsStringSync(markdown);

  stdout.writeln('========================================');
  stdout.writeln('检测报告已生成');
  stdout.writeln('========================================');
  stdout.writeln('文件名: $fileName');
  stdout.writeln('----------------------------------------');
  stdout.writeln('检测统计:');
  stdout.writeln('  总检测数: $totalTests');
  stdout.writeln('  ✅ 通过: $passedTests');
  stdout.writeln('  ❌ 有问题: $failedTests');
  stdout.writeln('  ⏭️  跳过: $skippedTests');
  stdout.writeln('  📊 通过率: $passRate%');
  stdout.writeln('----------------------------------------');
  stdout.writeln('检测结果: ${hasProblems ? "有问题" : "正常"}');
  stdout.writeln('========================================');
}

void generateEmptyReport() {
  final timestamp = DateTime.now().toLocal().toString().replaceAll(':', '-').replaceAll(' ', '_').substring(0, 19);
  final fileName = '检测报告_未知_无检测数据_$timestamp.html';
  
  final html = generateFriendlyReport(
    tests: [],
    totalTests: 0,
    passedTests: 0,
    failedTests: 0,
    skippedTests: 0,
    failedTestList: [],
    skippedTestList: [],
    reportTitle: '⚠️ 检测报告 - 无数据',
    statusIcon: '⚠️',
    statusBadgeText: '无检测结果',
    statusColor: '#f59e0b',
    passRate: '0',
    moduleInfo: {},
    timestamp: timestamp,
    hasProblems: false,
  );

  File(fileName).writeAsStringSync(html);
  File('检测报告-latest.html').writeAsStringSync(html);
  
  final markdown = generateMarkdownSummary(
    tests: [],
    totalTests: 0,
    passedTests: 0,
    failedTests: 0,
    skippedTests: 0,
    failedTestList: [],
    skippedTestList: [],
    reportTitle: '⚠️ 检测报告 - 无数据',
    statusIcon: '⚠️',
    statusBadgeText: '无检测结果',
    passRate: '0',
    moduleInfo: {},
    timestamp: timestamp,
    hasProblems: false,
  );
  File('检测报告_summary.md').writeAsStringSync(markdown);
  
  stdout.writeln('检测报告已生成: $fileName');
}

String generateMarkdownSummary({
  required List<Map<String, dynamic>> tests,
  required int totalTests,
  required int passedTests,
  required int failedTests,
  required int skippedTests,
  required List<Map<String, dynamic>> failedTestList,
  required List<Map<String, dynamic>> skippedTestList,
  required String reportTitle,
  required String statusIcon,
  required String statusBadgeText,
  required String passRate,
  required Map<String, int> moduleInfo,
  required String timestamp,
  required bool hasProblems,
}) {
  final buffer = StringBuffer();
  
  buffer.writeln('# $statusIcon $reportTitle');
  buffer.writeln('');
  buffer.writeln('> 生成时间: ${timestamp.replaceAll('_', ' ')}');
  buffer.writeln('');
  
  buffer.writeln('## 📊 检测结果概览');
  buffer.writeln('');
  buffer.writeln('| 指标 | 数量 |');
  buffer.writeln('|------|------|');
  buffer.writeln('| 总检测数 | **$totalTests** |');
  buffer.writeln('| ✅ 通过 | **$passedTests** |');
  buffer.writeln('| ❌ 有问题 | **$failedTests** |');
  buffer.writeln('| ⏭️ 跳过 | **$skippedTests** |');
  buffer.writeln('| 📊 通过率 | **$passRate%** |');
  buffer.writeln('');
  
  if (totalTests > 0) {
    buffer.writeln('### 通过率进度');
    buffer.writeln('');
    buffer.writeln('```');
    final passedBar = '█' * (passedTests * 20 ~/ totalTests);
    final failedBar = '░' * (failedTests * 20 ~/ totalTests);
    final skippedBar = '▒' * (skippedTests * 20 ~/ totalTests);
    buffer.writeln('$passedBar$failedBar$skippedBar $passRate%');
    buffer.writeln('```');
    buffer.writeln('');
    buffer.writeln('- 🟢 通过: $passedTests');
    buffer.writeln('- 🔴 有问题: $failedTests');
    buffer.writeln('- 🟡 跳过: $skippedTests');
    buffer.writeln('');
  }
  
  if (moduleInfo.isNotEmpty) {
    buffer.writeln('## 📦 检测覆盖模块');
    buffer.writeln('');
    for (final entry in moduleInfo.entries) {
      buffer.writeln('- **${entry.key}**: ${entry.value} 个检测');
    }
    buffer.writeln('');
  }
  
  if (failedTestList.isNotEmpty) {
    buffer.writeln('## ❌ 有问题的检测');
    buffer.writeln('');
    buffer.writeln('> 🔴 请重点关注以下有问题的检测项');
    buffer.writeln('');
    for (final test in failedTestList) {
      final name = test['name'] as String? ?? '未知检测';
      final path = test['path'] as String? ?? '';
      final module = getModuleName(path);
      final error = test['error'] as String? ?? '';
      final friendlyError = makeErrorFriendly(error);
      
      buffer.writeln('### ❌ $name');
      buffer.writeln('');
      buffer.writeln('- **模块**: $module');
      buffer.writeln('- **问题**: ${friendlyError['message']}');
      if ((friendlyError['explanation'] ?? '').isNotEmpty) {
        buffer.writeln('- **💡 小提示**: ${friendlyError['explanation']}');
      }
      buffer.writeln('');
    }
  }
  
  if (skippedTestList.isNotEmpty) {
    buffer.writeln('## ⏭️ 跳过的检测');
    buffer.writeln('');
    for (final test in skippedTestList) {
      final name = test['name'] as String? ?? '未知检测';
      final skipReason = test['skipReason'] as String? ?? '未指定跳过原因';
      buffer.writeln('- ⏭️ **$name**: $skipReason');
    }
    buffer.writeln('');
  }
  
  if (passedTests > 0 && failedTests == 0) {
    buffer.writeln('## ✅ 全部通过！');
    buffer.writeln('');
    buffer.writeln('> 🎉 恭喜！所有检测都通过了！');
    buffer.writeln('');
  }
  
  buffer.writeln('---');
  buffer.writeln('');
  buffer.writeln('*人生编年史 - 检测报告*');
  
  return buffer.toString();
}

String generateFriendlyReport({
  required List<Map<String, dynamic>> tests,
  required int totalTests,
  required int passedTests,
  required int failedTests,
  required int skippedTests,
  required List<Map<String, dynamic>> failedTestList,
  required List<Map<String, dynamic>> skippedTestList,
  required String reportTitle,
  required String statusIcon,
  required String statusBadgeText,
  required String statusColor,
  required String passRate,
  required Map<String, int> moduleInfo,
  required String timestamp,
  required bool hasProblems,
}) {
  return '''
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$reportTitle</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif; background: #f3f4f6; padding: 20px; line-height: 1.8; }
    .container { max-width: 1000px; margin: 0 auto; background: white; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); overflow: hidden; }
    .header { background: ${hasProblems ? 'linear-gradient(135deg, #dc2626 0%, #ef4444 100%)' : 'linear-gradient(135deg, #1e40af 0%, #3b82f6 100%)'}; color: white; padding: 40px 30px; text-align: center; }
    .header h1 { font-size: 32px; margin-bottom: 10px; }
    .header .timestamp { font-size: 14px; opacity: 0.9; margin-top: 5px; }
    .status-badge { display: inline-block; padding: 15px 40px; border-radius: 50px; font-size: 28px; font-weight: bold; background: white; color: $statusColor; margin-top: 20px; box-shadow: 0 4px 6px rgba(0,0,0,0.2); }
    .summary { padding: 30px; background: #f9fafb; border-bottom: 1px solid #e5e7eb; }
    .summary-grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: 15px; margin-top: 20px; }
    .summary-card { background: white; padding: 25px 15px; border-radius: 10px; text-align: center; box-shadow: 0 2px 4px rgba(0,0,0,0.08); border: 2px solid transparent; transition: transform 0.2s; }
    .summary-card:hover { transform: translateY(-2px); box-shadow: 0 4px 8px rgba(0,0,0,0.12); }
    .summary-card .number { font-size: 40px; font-weight: bold; line-height: 1.2; }
    .summary-card .label { font-size: 15px; color: #6b7280; margin-top: 8px; font-weight: 500; }
    .summary-card.total { border-color: #d1d5db; }
    .summary-card.total .number { color: #1f2937; }
    .summary-card.passed { border-color: #86efac; background: #f0fdf4; }
    .summary-card.passed .number { color: #16a34a; }
    .summary-card.failed { border-color: #fca5a5; background: #fef2f2; }
    .summary-card.failed .number { color: #dc2626; }
    .summary-card.skipped { border-color: #fcd34d; background: #fffbeb; }
    .summary-card.skipped .number { color: #d97706; }
    .summary-card.rate { border-color: #93c5fd; background: #eff6ff; }
    .summary-card.rate .number { color: #2563eb; }
    .progress-bar { margin-top: 30px; height: 28px; background: #e5e7eb; border-radius: 14px; overflow: hidden; display: flex; box-shadow: inset 0 2px 4px rgba(0,0,0,0.1); }
    .progress-passed { background: #16a34a; height: 100%; display: flex; align-items: center; justify-content: center; color: white; font-weight: bold; font-size: 12px; min-width: 40px; }
    .progress-failed { background: #dc2626; height: 100%; display: flex; align-items: center; justify-content: center; color: white; font-weight: bold; font-size: 12px; min-width: 40px; }
    .progress-skipped { background: #f59e0b; height: 100%; display: flex; align-items: center; justify-content: center; color: white; font-weight: bold; font-size: 12px; min-width: 40px; }
    .section { padding: 35px 30px; border-bottom: 1px solid #e5e7eb; }
    .section-title { font-size: 22px; font-weight: bold; color: #1f2937; margin-bottom: 25px; display: flex; align-items: center; gap: 12px; }
    .section-title .count { font-size: 14px; background: #e5e7eb; padding: 4px 12px; border-radius: 20px; font-weight: normal; }
    .module-list { list-style: none; display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 15px; }
    .module-item { background: #f0f9ff; padding: 20px; border-radius: 10px; border-left: 5px solid #3b82f6; transition: transform 0.2s; }
    .module-item:hover { transform: translateX(5px); }
    .module-name { font-weight: bold; color: #1e40af; font-size: 16px; }
    .module-count { font-size: 14px; color: #6b7280; margin-top: 8px; }
    .test-group { margin-bottom: 25px; }
    .test-group-title { font-size: 17px; font-weight: bold; margin-bottom: 18px; padding: 12px 18px; border-radius: 10px; display: flex; justify-content: space-between; align-items: center; }
    .test-group-title.passed { background: #dcfce7; color: #166534; }
    .test-group-title.failed { background: #fee2e2; color: #991b1b; }
    .test-group-title.skipped { background: #fef3c7; color: #92400e; }
    .test-item { padding: 18px; border: 2px solid #e5e7eb; border-radius: 10px; margin-bottom: 12px; transition: all 0.2s; }
    .test-item:hover { border-color: #d1d5db; box-shadow: 0 2px 8px rgba(0,0,0,0.06); }
    .test-item.passed { background: #f0fdf4; border-color: #86efac; }
    .test-item.failed { background: #fef2f2; border-color: #fca5a5; animation: pulse 2s infinite; }
    .test-item.skipped { background: #fffbeb; border-color: #fcd34d; }
    @keyframes pulse {
      0%, 100% { box-shadow: 0 0 0 0 rgba(220, 38, 38, 0.2); }
      50% { box-shadow: 0 0 0 8px rgba(220, 38, 38, 0); }
    }
    .test-header { display: flex; justify-content: space-between; align-items: flex-start; gap: 15px; }
    .test-name { font-weight: bold; color: #1f2937; font-size: 16px; }
    .test-module { font-size: 13px; color: #6b7280; margin-top: 6px; }
    .error-box { margin-top: 18px; background: #fef2f2; border: 2px solid #fecaca; border-radius: 8px; padding: 18px; }
    .error-title { font-weight: bold; color: #991b1b; margin-bottom: 12px; font-size: 16px; display: flex; align-items: center; gap: 8px; }
    .error-message { font-family: 'Courier New', monospace; font-size: 13px; color: #7f1d1d; white-space: pre-wrap; word-break: break-all; max-height: 300px; overflow-y: auto; background: #fef2f2; padding: 12px; border-radius: 6px; border: 1px solid #fecaca; }
    .term-explanation { margin-top: 15px; padding: 15px; background: #fffbeb; border-radius: 8px; font-size: 14px; color: #92400e; border-left: 4px solid #f59e0b; }
    .skip-reason { margin-top: 15px; padding: 15px; background: #fef3c7; border-radius: 8px; font-size: 14px; color: #92400e; border-left: 4px solid #f59e0b; }
    .footer { padding: 25px; text-align: center; color: #9ca3af; font-size: 14px; background: #f9fafb; }
    .no-tests { padding: 60px 40px; text-align: center; color: #6b7280; }
    .no-tests-icon { font-size: 64px; margin-bottom: 25px; }
    .no-tests h3 { font-size: 22px; margin-bottom: 10px; color: #374151; }
    .no-tests p { font-size: 15px; }
    .legend { display: flex; justify-content: center; gap: 30px; margin-top: 20px; font-size: 14px; flex-wrap: wrap; }
    .legend-item { display: flex; align-items: center; gap: 8px; padding: 8px 16px; background: white; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
    .legend-color { width: 20px; height: 20px; border-radius: 6px; }
    .legend-color.passed { background: #16a34a; }
    .legend-color.failed { background: #dc2626; }
    .legend-color.skipped { background: #f59e0b; }
    .collapse-btn { background: none; border: none; color: inherit; cursor: pointer; font-size: 14px; padding: 8px 16px; border-radius: 6px; font-weight: 500; }
    .collapse-btn:hover { background: rgba(0,0,0,0.08); }
    .test-list { max-height: 600px; overflow-y: auto; padding-right: 10px; }
    .test-list::-webkit-scrollbar { width: 8px; }
    .test-list::-webkit-scrollbar-track { background: #f3f4f6; border-radius: 4px; }
    .test-list::-webkit-scrollbar-thumb { background: #d1d5db; border-radius: 4px; }
    .test-list::-webkit-scrollbar-thumb:hover { background: #9ca3af; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>$statusIcon $reportTitle</h1>
      <div class="timestamp">生成时间: ${timestamp.replaceAll('_', ' ')}</div>
      <div class="status-badge">$statusBadgeText</div>
    </div>

    <div class="summary">
      <h2 class="section-title">📊 检测结果概览</h2>
      <div class="summary-grid">
        <div class="summary-card total">
          <div class="number">$totalTests</div>
          <div class="label">总检测数</div>
        </div>
        <div class="summary-card passed">
          <div class="number">$passedTests</div>
          <div class="label">✅ 通过</div>
        </div>
        <div class="summary-card failed">
          <div class="number">$failedTests</div>
          <div class="label">❌ 有问题</div>
        </div>
        <div class="summary-card skipped">
          <div class="number">$skippedTests</div>
          <div class="label">⏭️ 跳过</div>
        </div>
        <div class="summary-card rate">
          <div class="number">$passRate%</div>
          <div class="label">📊 通过率</div>
        </div>
      </div>
      
      ${totalTests > 0 ? '''
      <div class="progress-bar">
        <div class="progress-passed" style="width: ${(passedTests / totalTests * 100).toStringAsFixed(1)}%;" title="通过: $passedTests">${passedTests > 0 ? '$passedTests' : ''}</div>
        <div class="progress-failed" style="width: ${(failedTests / totalTests * 100).toStringAsFixed(1)}%;" title="有问题: $failedTests">${failedTests > 0 ? '$failedTests' : ''}</div>
        <div class="progress-skipped" style="width: ${(skippedTests / totalTests * 100).toStringAsFixed(1)}%;" title="跳过: $skippedTests">${skippedTests > 0 ? '$skippedTests' : ''}</div>
      </div>
      <div class="legend">
        <div class="legend-item"><div class="legend-color passed"></div> 通过 ($passedTests)</div>
        <div class="legend-item"><div class="legend-color failed"></div> 有问题 ($failedTests)</div>
        <div class="legend-item"><div class="legend-color skipped"></div> 跳过 ($skippedTests)</div>
      </div>
      ''' : ''}
    </div>

    ${moduleInfo.isNotEmpty ? '''
    <div class="section">
      <h2 class="section-title">📦 检测覆盖模块 <span class="count">${moduleInfo.length} 个模块</span></h2>
      <ul class="module-list">
        ${moduleInfo.entries.map((entry) => '''
        <li class="module-item">
          <div class="module-name">${entry.key}</div>
          <div class="module-count">${entry.value} 个检测</div>
        </li>
        ''').join()}
      </ul>
    </div>
    ''' : ''}

    ${failedTestList.isNotEmpty ? '''
    <div class="section">
      <h2 class="section-title">❌ 有问题的检测 <span class="count">${failedTestList.length} 个</span></h2>
      <div class="test-group">
        <div class="test-group-title failed">
          <span>🔴 请重点关注这些有问题的检测</span>
        </div>
        <div class="test-list">
        ${failedTestList.map((test) => generateTestItem(test, 'failed')).join()}
        </div>
      </div>
    </div>
    ''' : ''}

    ${skippedTestList.isNotEmpty ? '''
    <div class="section">
      <h2 class="section-title">⏭️ 跳过的检测 <span class="count">${skippedTestList.length} 个</span></h2>
      <div class="test-group">
        <div class="test-group-title skipped">
          <span>🟡 这些检测被跳过了（可能需要特定环境）</span>
        </div>
        <div class="test-list">
        ${skippedTestList.map((test) => generateTestItem(test, 'skipped')).join()}
        </div>
      </div>
    </div>
    ''' : ''}

    ${passedTests > 0 ? '''
    <div class="section">
      <h2 class="section-title">✅ 通过的检测 <span class="count">$passedTests 个</span></h2>
      <div class="test-group">
        <div class="test-group-title passed">
          <span>🟢 这些检测全部通过</span>
        </div>
        <div class="test-list">
        ${tests.where((t) => t['result'] == 'success').map((test) => generateTestItem(test, 'passed')).join()}
        </div>
      </div>
    </div>
    ''' : ''}

    ${tests.isEmpty ? '''
    <div class="section">
      <div class="no-tests">
        <div class="no-tests-icon">⚠️</div>
        <h3>没有找到检测结果</h3>
        <p style="margin-top: 15px;">可能是检测未运行或检测结果文件为空</p>
      </div>
    </div>
    ''' : ''}

    <div class="footer">
      <strong>人生编年史 - 检测报告</strong> | 
      总检测: $totalTests | 
      通过: $passedTests | 
      有问题: $failedTests | 
      跳过: $skippedTests | 
      通过率: $passRate%
    </div>
  </div>
</body>
</html>
''';
}

Map<String, int> analyzeModules(List<Map<String, dynamic>> tests) {
  final modules = <String, int>{};
  
  for (final test in tests) {
    final path = test['path'] as String? ?? '';
    final moduleName = getModuleName(path);
    modules[moduleName] = (modules[moduleName] ?? 0) + 1;
  }
  
  return modules;
}

String getModuleName(String path) {
  if (path.contains('daos/')) return '数据访问层';
  if (path.contains('services/')) return '业务逻辑服务';
  if (path.contains('providers/')) return '状态管理';
  if (path.contains('utils/')) return '工具类';
  if (path.contains('integration/')) return '集成检测';
  if (path.contains('backup/')) return '备份服务';
  if (path.contains('widgets/')) return '界面检测';
  return '其他检测';
}

String generateTestItem(Map<String, dynamic> test, String status) {
  final name = test['name'] as String? ?? '未知检测';
  final path = test['path'] as String? ?? '';
  final module = getModuleName(path);
  final error = test['error'] as String? ?? '';
  final skipReason = test['skipReason'] as String? ?? '';
  
  String statusIcon = status == 'passed' ? '✅' : (status == 'failed' ? '❌' : '⏭️');
  
  String detailHtml = '';
  if (status == 'failed' && error.isNotEmpty) {
    final friendlyError = makeErrorFriendly(error);
    final explanation = friendlyError['explanation'] ?? '';
    detailHtml = '''
    <div class="error-box">
      <div class="error-title">💥 问题详情</div>
      <div class="error-message">${htmlEscape(friendlyError['message'] ?? '')}</div>
      ${explanation.isNotEmpty ? '''
      <div class="term-explanation">
        💡 小提示: $explanation
      </div>
      ''' : ''}
    </div>
    ''';
  } else if (status == 'skipped') {
    detailHtml = '''
    <div class="skip-reason">
      ⏭️ 跳过原因: ${skipReason.isNotEmpty ? htmlEscape(skipReason) : '未指定跳过原因'}
    </div>
    ''';
  }
  
  return '''
  <div class="test-item $status">
    <div class="test-header">
      <div>
        <div class="test-name">$statusIcon ${htmlEscape(name)}</div>
        <div class="test-module">📁 $module</div>
      </div>
    </div>
    $detailHtml
  </div>
''';
}

Map<String, String> makeErrorFriendly(String error) {
  String message = error;
  String explanation = '';

  if (error.contains('Expected:') && error.contains('Actual:')) {
    message = '预期结果和实际结果不一样';
    explanation = 'Expected 是我们想要的结果，Actual 是实际得到的结果，这两个不一样说明代码逻辑有问题，需要检查一下';
  } else if (error.contains('NoSuchMethodError')) {
    message = '调用了不存在的方法';
    explanation = '可能是某个对象没有正确初始化，或者方法名写错了';
  } else if (error.contains('TimeoutException')) {
    message = '运行时间太长了';
    explanation = '可能是代码中有死循环，或者需要优化一下算法让它跑得更快';
  } else if (error.contains('TestFailedException')) {
    message = '检测失败了';
  } else if (error.contains('Null check operator used on a null value')) {
    message = '空值错误';
    explanation = '代码尝试使用一个不存在的值，请检查数据是否正确加载了';
  } else if (error.contains('RangeError')) {
    message = '范围错误';
    explanation = '数组或列表的索引超出了有效范围，请检查索引值是否正确';
  } else if (error.contains('FormatException')) {
    message = '格式错误';
    explanation = '数据格式不正确，无法解析';
  } else if (error.contains('StateError') || error.contains('Bad state')) {
    message = '状态错误';
    explanation = '组件或对象的状态不正确，请检查状态管理逻辑';
  }

  return {'message': message, 'explanation': explanation};
}

String htmlEscape(String text) {
  return text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#039;');
}
