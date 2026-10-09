const fs = require('fs');
const file = process.argv[2];
let t = fs.readFileSync(file, 'utf8');
t = t.replace(/\/\*[\s\S]*?\*\//g, '').replace(/\/\/[^\n]*/g, '');
let str = false, esc = false, q = '', line = 1;
const stack = [];
const pairs = { '}': '{', ')': '(', ']': '[' };
for (const ch of t) {
  if (ch === '\n') line++;
  if (str) {
    if (esc) esc = false;
    else if (ch === '\\') esc = true;
    else if (ch === q) str = false;
    continue;
  }
  if (ch === "'" || ch === '"') { str = true; q = ch; continue; }
  if (ch === '{' || ch === '(' || ch === '[') stack.push({ ch, line });
  else if (pairs[ch]) {
    const top = stack.pop();
    if (!top || top.ch !== pairs[ch]) {
      console.log(`MISMATCH line ${line}: got '${ch}' expected close for '${top ? top.ch : 'empty'}' (opened line ${top ? top.line : '?'})`);
    }
  }
}
console.log('UNCLOSED: ' + stack.map(s => `${s.ch}@${s.line}`).join(' '));
