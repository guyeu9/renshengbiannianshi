// 分析 food_page.dart 的损坏模式
// 用法: node analyze_corruption.js
const fs = require('fs');
const path = 'D:\\trae\\chronicle-of-life\\life_chronicle\\lib\\features\\food\\presentation\\food_page.dart';

// 读取文件
const content = fs.readFileSync(path, 'utf8');

// 统计各种转义序列
const patterns = [
  { name: '\\_', regex: /\\_/g },
  { name: '\\[', regex: /\\\[/g },
  { name: '\\]', regex: /\\\]/g },
  { name: '\\*', regex: /\\\*/g },
  { name: '\\+', regex: /\\\+/g },
  { name: '\\?', regex: /\\\?/g },
  { name: '\\(', regex: /\\\(/g },
  { name: '\\)', regex: /\\\)/g },
  { name: '\\{', regex: /\\\{/g },
  { name: '\\}', regex: /\\\}/g },
  { name: '\\<', regex: /\\</g },
  { name: '\\>', regex: /\\>/g },
  { name: '\\.', regex: /\\\./g },
  { name: '\\,', regex: /\\,/g },
  { name: '\\:', regex: /\\:/g },
  { name: '\\;', regex: /\\;/g },
  { name: '\\=', regex: /\\=/g },
  { name: '\\!', regex: /\\!/g },
  { name: '\\/', regex: /\\\//g },
  { name: '\\~', regex: /\\~/g },
  { name: '\\%', regex: /\\%/g },
  { name: '\\&', regex: /\\&/g },
  { name: '\\#', regex: /\\#/g },
  { name: '\\@', regex: /\\@/g },
  { name: '\\$', regex: /\\\$/g },
  { name: '\\^', regex: /\\\^/g },
  { name: '\\|', regex: /\\\|/g },
  { name: '\\-', regex: /\\-/g },
  { name: '\\\\', regex: /\\\\/g },
  { name: '\\\'', regex: /\\'/g },
  { name: '\\"', regex: /\\"/g },
  { name: '\\ ', regex: /\\ /g },
  { name: 'total \\', regex: /\\/g },
];

console.log('=== 损坏分析 ===');
let totalBackslash = 0;
for (const p of patterns) {
  const matches = content.match(p.regex);
  if (matches) {
    console.log(`${p.name}: ${matches.length}`);
    if (p.name !== 'total \\') totalBackslash += matches.length;
  }
}
console.log(`Total backslashes: ${(content.match(/\\/g) || []).length}`);
console.log(`File length: ${content.length}`);
