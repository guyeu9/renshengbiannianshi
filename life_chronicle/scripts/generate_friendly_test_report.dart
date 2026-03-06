import 'dart:convert';
import 'dart:io';

void main() {
  final testResultsPath = 'test-results.json';
  final outputPath = 'friendly-test-report.html';

  if (!File(testResultsPath).existsSync()) {
    print('错误: 找不到测试结果文件 $testResultsPath');
    exit(1);
  }

  final testResultsJson = File(testResultsPath).readAsStringSync();
  final testResults = json.decode(testResultsJson);

  final html = generateFriendlyReport(testResults);
  File(outputPath).writeAsStringSync(html);

  print('友好测试报告已生成: $outputPath');
}

String generateFriendlyReport(dynamic testResults) {
  final tests = testResults['tests'] as List? ?? [];
  final totalTests = tests.length;
  final passedTests = tests.where((t) => t['result'] == 'success').length;
  final failedTests = tests.where((t) => t['result'] == 'error' || t['result'] == 'failure').toList();
  final hasProblems = failedTests.isNotEmpty;

  final reportTitle = hasProblems ? '有问题 - Flutter测试报告' : '正常 - Flutter测试报告';
  final statusIcon = hasProblems ? '❌' : '✅';
  final statusText = hasProblems ? '存在问题' : '全部通过';
  final statusColor = hasProblems ? '#dc2626' : '#16a34a';
  final passRate = totalTests > 0 ? ((passedTests / totalTests) * 100).toStringAsFixed(1) : '0';

  final moduleInfo = analyzeModules(tests);

  return '''
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$reportTitle</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif; background: #f3f4f6; padding: 20px; line-height: 1.6; }
    .container { max-width: 900px; margin: 0 auto; background: white; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); overflow: hidden; }
    .header { background: linear-gradient(135deg, #1e40af 0%, #3b82f6 100%); color: white; padding: 30px; text-align: center; }
    .header h1 { font-size: 28px; margin-bottom: 10px; }
    .status-badge { display: inline-block; padding: 12px 30px; border-radius: 50px; font-size: 24px; font-weight: bold; background: $statusColor; margin-top: 15px; }
    .summary { padding: 30px; background: #f9fafb; border-bottom: 1px solid #e5e7eb; }
    .summary-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-top: 20px; }
    .summary-card { background: white; padding: 20px; border-radius: 8px; text-align: center; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
    .summary-card .number { font-size: 36px; font-weight: bold; color: #1f2937; }
    .summary-card .label { font-size: 14px; color: #6b7280; margin-top: 5px; }
    .section { padding: 30px; border-bottom: 1px solid #e5e7eb; }
    .section-title { font-size: 20px; font-weight: bold; color: #1f2937; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; }
    .module-list { list-style: none; display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 12px; }
    .module-item { background: #f0f9ff; padding: 15px; border-radius: 8px; border-left: 4px solid #3b82f6; }
    .module-name { font-weight: bold; color: #1e40af; }
    .module-count { font-size: 14px; color: #6b7280; margin-top: 5px; }
    .test-group { margin-bottom: 30px; }
    .test-group-title { font-size: 18px; font-weight: bold; margin-bottom: 15px; padding: 10px 15px; border-radius: 8px; }
    .test-group-title.passed { background: #dcfce7; color: #166534; }
    .test-group-title.failed { background: #fee2e2; color: #991b1b; }
    .test-item { padding: 15px; border: 1px solid #e5e7eb; border-radius: 8px; margin-bottom: 10px; }
    .test-item.passed { background: #f0fdf4; border-color: #86efac; }
    .test-item.failed { background: #fef2f2; border-color: #fca5a5; }
    .test-header { display: flex; justify-content: space-between; align-items: flex-start; gap: 10px; }
    .test-name { font-weight: bold; color: #1f2937; }
    .test-module { font-size: 12px; color: #6b7280; margin-top: 5px; }
    .error-box { margin-top: 15px; background: #fef2f2; border: 1px solid #fecaca; border-radius: 6px; padding: 15px; }
    .error-title { font-weight: bold; color: #991b1b; margin-bottom: 10px; }
    .error-message { font-family: monospace; font-size: 13px; color: #7f1d1d; white-space: pre-wrap; word-break: break-all; }
    .term-explanation { margin-top: 10px; padding: 10px; background: #fffbeb; border-radius: 6px; font-size: 13px; color: #92400e; }
    .footer { padding: 20px; text-align: center; color: #9ca3af; font-size: 14px; background: #f9fafb; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>$statusIcon $reportTitle</h1>
      <div class="status-badge">$statusText</div>
    </div>

    <div class="summary">
      <h2 class="section-title">📊 测试总结</h2>
      <div class="summary-grid">
        <div class="summary-card">
          <div class="number">$totalTests</div>
          <div class="label">总测试数</div>
        </div>
        <div class="summary-card">
          <div class="number" style="color: #16a34a;">$passedTests</div>
          <div class="label">通过 ✅</div>
        </div>
        <div class="summary-card">
          <div class="number" style="color: #dc2626;">${failedTests.length}</div>
          <div class="label">有问题 ❌</div>
        </div>
        <div class="summary-card">
          <div class="number">$passRate%</div>
          <div class="label">通过率</div>
        </div>
      </div>
    </div>

    <div class="section">
      <h2 class="section-title">📦 测试覆盖模块</h2>
      <ul class="module-list">
        ${moduleInfo.entries.map((entry) => '''
        <li class="module-item">
          <div class="module-name">${entry.key}</div>
          <div class="module-count">${entry.value} 个测试</div>
        </li>
        ''').join()}
      </ul>
    </div>

    ${failedTests.isNotEmpty ? '''
    <div class="section">
      <h2 class="section-title">❌ 有问题的测试项</h2>
      <div class="test-group">
        <div class="test-group-title failed">❌ 失败的测试 (${failedTests.length}个)</div>
        ${failedTests.map((test) => generateTestItem(test, true)).join()}
      </div>
    </div>
    ''' : ''}

    <div class="section">
      <h2 class="section-title">✅ 无问题的测试项</h2>
      <div class="test-group">
        <div class="test-group-title passed">✅ 通过的测试 ($passedTests个)</div>
        ${tests.where((t) => t['result'] == 'success').map((test) => generateTestItem(test, false)).join()}
      </div>
    </div>

    <div class="footer">
      人生编年史 - 测试报告 | 生成时间: ${DateTime.now().toLocal().toString().substring(0, 19)}
    </div>
  </div>
</body>
</html>
''';
}

Map<String, int> analyzeModules(List<dynamic> tests) {
  final modules = <String, int>{};
  
  for (final test in tests) {
    final path = test['path'] as String? ?? '';
    final moduleName = getModuleName(path);
    modules[moduleName] = (modules[moduleName] ?? 0) + 1;
  }
  
  return modules;
}

String getModuleName(String path) {
  if (path.contains('daos/')) return '数据访问层 (DAO)';
  if (path.contains('services/')) return '业务逻辑服务';
  if (path.contains('providers/')) return '状态管理Provider';
  if (path.contains('utils/')) return '工具类';
  if (path.contains('integration/')) return '集成测试';
  if (path.contains('backup/')) return '备份服务';
  if (path.contains('widget_test')) return 'Widget测试';
  return '其他测试';
}

String generateTestItem(dynamic test, bool isFailed) {
  final name = test['name'] as String? ?? '未知测试';
  final path = test['path'] as String? ?? '';
  final module = getModuleName(path);
  final result = test['result'] as String? ?? '';
  final error = test['error'] as String? ?? '';
  
  String errorHtml = '';
  if (isFailed && error.isNotEmpty) {
    final friendlyError = makeErrorFriendly(error);
    final explanation = friendlyError['explanation'] ?? '';
    errorHtml = '''
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
  }
  
  return '''
  <div class="test-item ${isFailed ? 'failed' : 'passed'}">
    <div class="test-header">
      <div>
        <div class="test-name">${isFailed ? '❌' : '✅'} ${htmlEscape(name)}</div>
        <div class="test-module">📁 $module</div>
      </div>
    </div>
    $errorHtml
  </div>
  ''';
}

Map<String, String> makeErrorFriendly(String error) {
  String message = error;
  String? explanation;
  
  if (error.contains('Expected:') && error.contains('Actual:')) {
    explanation = '断言失败：预期结果和实际结果不一致，请检查代码逻辑是否正确。';
  } else if (error.contains('NoSuchMethodError')) {
    explanation = '调用了不存在的方法：可能是某个对象为空或者方法名写错了。';
  } else if (error.contains('TimeoutException')) {
    explanation = '超时错误：测试运行时间太长，可能是代码中有死循环或者性能问题。';
  } else if (error.contains('TestFailedException')) {
    explanation = '测试失败：这是一个一般性的测试失败，请查看详细信息。';
  } else if (error.contains('Null check operator used on a null value')) {
    explanation = '空值错误：代码中使用了一个空对象，请确保对象在使用前已正确初始化。';
  }
  
  message = message.split('\n').take(10).join('\n');
  
  return {
    'message': message,
    'explanation': explanation ?? ''
  };
}

String htmlEscape(String text) {
  return text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#039;');
}
