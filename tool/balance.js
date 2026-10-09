const fs = require('fs');
const path = require('path');
function walk(d) {
  for (const f of fs.readdirSync(d)) {
    const p = path.join(d, f);
    const s = fs.statSync(p);
    if (s.isDirectory()) walk(p);
    else if (f.endsWith('.dart')) check(p);
  }
}
function check(p) {
  let t = fs.readFileSync(p, 'utf8');
  t = t.replace(/\/\*[\s\S]*?\*\//g, '').replace(/\/\/[^\n]*/g, '');
  let str = false, esc = false, q = '';
  const st = { '{': 0, '}': 0, '(': 0, ')': 0, '[': 0, ']': 0 };
  for (const ch of t) {
    if (str) {
      if (esc) esc = false;
      else if (ch === '\\') esc = true;
      else if (ch === q) str = false;
      continue;
    }
    if (ch === "'" || ch === '"') { str = true; q = ch; continue; }
    if (st[ch] !== undefined) st[ch]++;
  }
  const ok = st['{'] === st['}'] && st['('] === st[')'] && st['['] === st[']'];
  console.log((ok ? 'OK  ' : 'BAD ') + p + ' ' + JSON.stringify(st));
}
walk('lib');
