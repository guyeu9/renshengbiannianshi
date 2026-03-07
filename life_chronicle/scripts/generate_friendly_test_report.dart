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
  
  final statusText = hasProblems ? '失败' : '成功';
  final fileName = '测试报告_${statusText}_通过${passedTests}_失败${failedTests}_跳过${skippedTests}_$timestamp.html';

  final reportTitle = hasProblems ? '❌ 测试失败报告' : '✅ 测试成功报告';
  final statusIcon = hasProblems ? '❌' : '✅';
  final statusBadgeText = hasProblems ? '存在问题' : '全部通过';
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
  );

  File(fileName).writeAsStringSync(html);
  File('test-report-latest.html').writeAsStringSync(html);

  stdout.writeln('========================================');
  stdout.writeln('测试报告已生成');
  stdout.writeln('========================================');
  stdout.writeln('文件名: $fileName');
  stdout.writeln('----------------------------------------');
  stdout.writeln('测试统计:');
  stdout.writeln('  总测试数: $totalTests');
  stdout.writeln('  ✅ 通过: $passedTests');
  stdout.writeln('  ❌ 失败: $failedTests');
  stdout.writeln('  ⏭️  跳过: $skippedTests');
  stdout.writeln('  📊 通过率: $passRate%');
  stdout.writeln('----------------------------------------');
  stdout.writeln('测试结果: ${hasProblems ? "失败" : "成功"}');
  stdout.writeln('========================================');
}

void generateEmptyReport() {
  final timestamp = DateTime.now().toLocal().toString().replaceAll(':', '-').replaceAll(' ', '_').substring(0, 19);
  final fileName = '测试报告_未知_无测试数据_$timestamp.html';
  
  final html = generateFriendlyReport(
    tests: [],
    totalTests: 0,
    passedTests: 0,
    failedTests: 0,
    skippedTests: 0,
    failedTestList: [],
    skippedTestList: [],
    reportTitle: '⚠️ 无测试数据',
    statusIcon: '⚠️',
    statusBadgeText: '无测试结果',
    statusColor: '#f59e0b',
    passRate: '0',
    moduleInfo: {},
    timestamp: timestamp,
  );

  File(fileName).writeAsStringSync(html);
  File('test-report-latest.html').writeAsStringSync(html);
  
  stdout.writeln('测试报告已生成: $fileName');
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
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif; background: #f3f4f6; padding: 20px; line-height: 1.6; }
    .container { max-width: 1000px; margin: 0 auto; background: white; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); overflow: hidden; }
    .header { background: linear-gradient(135deg, #1e40af 0%, #3b82f6 100%); color: white; padding: 30px; text-align: center; }
    .header h1 { font-size: 28px; margin-bottom: 10px; }
    .header .timestamp { font-size: 14px; opacity: 0.8; margin-top: 5px; }
    .status-badge { display: inline-block; padding: 12px 30px; border-radius: 50px; font-size: 24px; font-weight: bold; background: $statusColor; margin-top: 15px; }
    .summary { padding: 30px; background: #f9fafb; border-bottom: 1px solid #e5e7eb; }
    .summary-grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: 15px; margin-top: 20px; }
    .summary-card { background: white; padding: 20px; border-radius: 8px; text-align: center; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
    .summary-card .number { font-size: 36px; font-weight: bold; }
    .summary-card .label { font-size: 14px; color: #6b7280; margin-top: 5px; }
    .summary-card.total .number { color: #1f2937; }
    .summary-card.passed .number { color: #16a34a; }
    .summary-card.failed .number { color: #dc2626; }
    .summary-card.skipped .number { color: #f59e0b; }
    .summary-card.rate .number { color: #3b82f6; }
    .progress-bar { margin-top: 20px; height: 20px; background: #e5e7eb; border-radius: 10px; overflow: hidden; display: flex; }
    .progress-passed { background: #16a34a; height: 100%; }
    .progress-failed { background: #dc2626; height: 100%; }
    .progress-skipped { background: #f59e0b; height: 100%; }
    .section { padding: 30px; border-bottom: 1px solid #e5e7eb; }
    .section-title { font-size: 20px; font-weight: bold; color: #1f2937; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; }
    .section-title .count { font-size: 14px; background: #e5e7eb; padding: 2px 8px; border-radius: 12px; }
    .module-list { list-style: none; display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 12px; }
    .module-item { background: #f0f9ff; padding: 15px; border-radius: 8px; border-left: 4px solid #3b82f6; }
    .module-name { font-weight: bold; color: #1e40af; }
    .module-count { font-size: 14px; color: #6b7280; margin-top: 5px; }
    .test-group { margin-bottom: 20px; }
    .test-group-title { font-size: 16px; font-weight: bold; margin-bottom: 15px; padding: 10px 15px; border-radius: 8px; display: flex; justify-content: space-between; align-items: center; }
    .test-group-title.passed { background: #dcfce7; color: #166534; }
    .test-group-title.failed { background: #fee2e2; color: #991b1b; }
    .test-group-title.skipped { background: #fef3c7; color: #92400e; }
    .test-item { padding: 15px; border: 1px solid #e5e7eb; border-radius: 8px; margin-bottom: 10px; }
    .test-item.passed { background: #f0fdf4; border-color: #86efac; }
    .test-item.failed { background: #fef2f2; border-color: #fca5a5; }
    .test-item.skipped { background: #fffbeb; border-color: #fcd34d; }
    .test-header { display: flex; justify-content: space-between; align-items: flex-start; gap: 10px; }
    .test-name { font-weight: bold; color: #1f2937; }
    .test-module { font-size: 12px; color: #6b7280; margin-top: 5px; }
    .error-box { margin-top: 15px; background: #fef2f2; border: 1px solid #fecaca; border-radius: 6px; padding: 15px; }
    .error-title { font-weight: bold; color: #991b1b; margin-bottom: 10px; }
    .error-message { font-family: monospace; font-size: 13px; color: #7f1d1d; white-space: pre-wrap; word-break: break-all; max-height: 300px; overflow-y: auto; }
    .term-explanation { margin-top: 10px; padding: 10px; background: #fffbeb; border-radius: 6px; font-size: 13px; color: #92400e; }
    .skip-reason { margin-top: 10px; padding: 10px; background: #fef3c7; border-radius: 6px; font-size: 13px; color: #92400e; }
    .footer { padding: 20px; text-align: center; color: #9ca3af; font-size: 14px; background: #f9fafb; }
    .no-tests { padding: 40px; text-align: center; color: #6b7280; }
    .no-tests-icon { font-size: 48px; margin-bottom: 20px; }
    .legend { display: flex; justify-content: center; gap: 20px; margin-top: 15px; font-size: 14px; }
    .legend-item { display: flex; align-items: center; gap: 5px; }
    .legend-color { width: 16px; height: 16px; border-radius: 4px; }
    .legend-color.passed { background: #16a34a; }
    .legend-color.failed { background: #dc2626; }
    .legend-color.skipped { background: #f59e0b; }
    .collapse-btn { background: none; border: none; color: inherit; cursor: pointer; font-size: 14px; padding: 5px 10px; border-radius: 4px; }
    .collapse-btn:hover { background: rgba(0,0,0,0.1); }
    .test-list { max-height: 500px; overflow-y: auto; }
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
      <h2 class="section-title">📊 测试统计概览</h2>
      <div class="summary-grid">
        <div class="summary-card total">
          <div class="number">$totalTests</div>
          <div class="label">总测试数</div>
        </div>
        <div class="summary-card passed">
          <div class="number">$passedTests</div>
          <div class="label">✅ 通过</div>
        </div>
        <div class="summary-card failed">
          <div class="number">$failedTests</div>
          <div class="label">❌ 失败</div>
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
        <div class="progress-passed" style="width: ${(passedTests / totalTests * 100).toStringAsFixed(1)}%;" title="通过: $passedTests"></div>
        <div class="progress-failed" style="width: ${(failedTests / totalTests * 100).toStringAsFixed(1)}%;" title="失败: $failedTests"></div>
        <div class="progress-skipped" style="width: ${(skippedTests / totalTests * 100).toStringAsFixed(1)}%;" title="跳过: $skippedTests"></div>
      </div>
      <div class="legend">
        <div class="legend-item"><div class="legend-color passed"></div> 通过 ($passedTests)</div>
        <div class="legend-item"><div class="legend-color failed"></div> 失败 ($failedTests)</div>
        <div class="legend-item"><div class="legend-color skipped"></div> 跳过 ($skippedTests)</div>
      </div>
      ''' : ''}
    </div>

    ${moduleInfo.isNotEmpty ? '''
    <div class="section">
      <h2 class="section-title">📦 测试覆盖模块 <span class="count">${moduleInfo.length} 个模块</span></h2>
      <ul class="module-list">
        ${moduleInfo.entries.map((entry) => '''
        <li class="module-item">
          <div class="module-name">${entry.key}</div>
          <div class="module-count">${entry.value} 个测试</div>
        </li>
        ''').join()}
      </ul>
    </div>
    ''' : ''}

    ${failedTestList.isNotEmpty ? '''
    <div class="section">
      <h2 class="section-title">❌ 失败的测试 <span class="count">${failedTestList.length} 个</span></h2>
      <div class="test-group">
        <div class="test-group-title failed">
          <span>需要重点关注的失败测试</span>
        </div>
        <div class="test-list">
        ${failedTestList.map((test) => generateTestItem(test, 'failed')).join()}
        </div>
      </div>
    </div>
    ''' : ''}

    ${skippedTestList.isNotEmpty ? '''
    <div class="section">
      <h2 class="section-title">⏭️ 跳过的测试 <span class="count">${skippedTestList.length} 个</span></h2>
      <div class="test-group">
        <div class="test-group-title skipped">
          <span>被跳过的测试（可能需要特定环境）</span>
        </div>
        <div class="test-list">
        ${skippedTestList.map((test) => generateTestItem(test, 'skipped')).join()}
        </div>
      </div>
    </div>
    ''' : ''}

    ${passedTests > 0 ? '''
    <div class="section">
      <h2 class="section-title">✅ 通过的测试 <span class="count">$passedTests 个</span></h2>
      <div class="test-group">
        <div class="test-group-title passed">
          <span>全部通过的测试</span>
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
        <p>没有找到测试结果</p>
        <p style="margin-top: 10px; font-size: 14px;">可能是测试未运行或测试结果文件为空</p>
      </div>
    </div>
    ''' : ''}

    <div class="footer">
      人生编年史 - 测试报告 | 总测试: $totalTests | 通过: $passedTests | 失败: $failedTests | 跳过: $skippedTests | 通过率: $passRate%
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
  if (path.contains('daos/')) return '数据访问层 (DAO)';
  if (path.contains('services/')) return '业务逻辑服务';
  if (path.contains('providers/')) return '状态管理Provider';
  if (path.contains('utils/')) return '工具类';
  if (path.contains('integration/')) return '集成测试';
  if (path.contains('backup/')) return '备份服务';
  if (path.contains('widgets/')) return 'Widget测试';
  return '其他测试';
}

String generateTestItem(Map<String, dynamic> test, String status) {
  final name = test['name'] as String? ?? '未知测试';
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
    message = '断言失败：预期结果和实际结果不一致，请检查代码逻辑是否正确。';
    explanation = 'Expected 表示期望值，Actual 表示实际值';
  } else if (error.contains('NoSuchMethodError')) {
    message = '调用了不存在的方法：可能是某个对象为空或者方法名写错了。';
    explanation = '请检查对象是否正确初始化，以及方法名是否正确';
  } else if (error.contains('TimeoutException')) {
    message = '超时错误：测试运行时间太长，可能是代码中有死循环或者性能问题。';
    explanation = '检查代码是否有无限循环，或者考虑优化算法';
  } else if (error.contains('TestFailedException')) {
    message = '测试失败：测试框架捕获到了一个失败情况。';
  } else if (error.contains('Null check operator used on a null value')) {
    message = '空值错误：尝试对空值进行操作，请检查数据是否正确加载。';
    explanation = '使用 ?. 或 ?? 操作符可以避免此错误';
  } else if (error.contains('RangeError')) {
    message = '范围错误：数组或列表索引超出范围。';
    explanation = '检查索引值是否在有效范围内';
  } else if (error.contains('FormatException')) {
    message = '格式错误：数据格式不正确，无法解析。';
  } else if (error.contains('StateError') || error.contains('Bad state')) {
    message = '状态错误：组件或对象的状态不正确。';
    explanation = '检查状态管理逻辑是否正确';
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
