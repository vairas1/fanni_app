// Generates assets/bg.png (1080x1920) — خلفية احترافية: تدرج كحلي + دوائر ناعمة
const fs = require('fs');
const zlib = require('zlib');
const W = 540, H = 960; // نصف الدقة لتقليل الحجم (تتمدد بسلاسة)
const buf = Buffer.alloc(W * H * 4);
const lerp = (a, b, t) => a + (b - a) * t;
// دوائر زخرفية ثابتة
const dots = [];
let seed = 7;
const rnd = () => (seed = (seed * 16807) % 2147483647) / 2147483647;
for (let i = 0; i < 22; i++) {
  dots.push({ x: rnd() * W, y: rnd() * H, r: 30 + rnd() * 90, a: 10 + rnd() * 14 });
}
for (let y = 0; y < H; y++) {
  for (let x = 0; x < W; x++) {
    const i = (y * W + x) * 4;
    const t = y / (H - 1);
    let r = lerp(10, 21, t), g = lerp(38, 110, t), b = lerp(94, 200, t);
    for (const d of dots) {
      const dd = Math.hypot(x - d.x, y - d.y);
      if (dd < d.r) r += d.a * (1 - dd / d.r), g += d.a * (1 - dd / d.r), b += d.a * (1 - dd / d.r);
    }
    buf[i] = Math.min(255, r); buf[i + 1] = Math.min(255, g);
    buf[i + 2] = Math.min(255, b); buf[i + 3] = 255;
  }
}
function crc(table, b) {
  let c = 0xFFFFFFFF;
  for (let i = 0; i < b.length; i++) c = table[(c ^ b[i]) & 0xFF] ^ (c >>> 8);
  return (c ^ 0xFFFFFFFF) >>> 0;
}
const table = new Int32Array(256);
for (let n = 0; n < 256; n++) {
  let c = n;
  for (let k = 0; k < 8; k++) c = (c & 1) ? (0xEDB88320 ^ (c >>> 1)) : (c >>> 1);
  table[n] = c;
}
function chunk(type, data) {
  const len = Buffer.alloc(4); len.writeUInt32BE(data.length);
  const td = Buffer.from(type, 'ascii');
  const cr = Buffer.alloc(4); cr.writeUInt32BE(crc(table, Buffer.concat([td, data])));
  return Buffer.concat([len, td, data, cr]);
}
const ihdr = Buffer.alloc(13);
ihdr.writeUInt32BE(W, 0); ihdr.writeUInt32BE(H, 4);
ihdr[8] = 8; ihdr[9] = 6; ihdr[10] = 0; ihdr[11] = 0; ihdr[12] = 0;
const raw = Buffer.alloc((W * 4 + 1) * H);
for (let y = 0; y < H; y++) {
  raw[y * (W * 4 + 1)] = 0;
  buf.copy(raw, y * (W * 4 + 1) + 1, y * W * 4, (y + 1) * W * 4);
}
const png = Buffer.concat([
  Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
  chunk('IHDR', ihdr), chunk('IDAT', zlib.deflateSync(raw)), chunk('IEND', Buffer.alloc(0)),
]);
fs.mkdirSync('assets', { recursive: true });
fs.writeFileSync('assets/bg.png', png);
console.log('bg bytes: ' + png.length);
