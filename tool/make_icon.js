// Generates assets/icon.png (1024x1024) with pure Node (no deps).
// Design: deep-blue full-bleed background + white abstract "service" mark
// (ring + diagonal bar = wrench/technician), amber accent dot.
const fs = require('fs');
const zlib = require('zlib');

const S = 1024;
const buf = Buffer.alloc(S * S * 4);

function lerp(a, b, t) { return a + (b - a) * t; }

for (let y = 0; y < S; y++) {
  for (let x = 0; x < S; x++) {
    const i = (y * S + x) * 4;
    // background: vertical gradient deep blue
    const t = y / (S - 1);
    let r = lerp(13, 21, t), g = lerp(71, 101, t), b = lerp(161, 192, t);
    // subtle radial light in center
    const dx = x - S / 2, dy = y - S / 2;
    const d = Math.sqrt(dx * dx + dy * dy) / (S / 2);
    const glow = Math.max(0, 1 - d) * 22;
    r += glow; g += glow; b += glow;

    // foreground mark: ring (outer R=300, thickness 64) centered slightly up
    const cx = S / 2, cy = S / 2 - 40;
    const px = x - cx, py = y - cy;
    const dist = Math.sqrt(px * px + py * py);
    const inRing = Math.abs(dist - 300) < 34;
    // diagonal bar: rotate coords by -35deg, bar half-width 62, length 640
    const ang = -35 * Math.PI / 180;
    const rx = px * Math.cos(ang) - py * Math.sin(ang);
    const ry = px * Math.sin(ang) + py * Math.cos(ang);
    const inBar = Math.abs(ry) < 62 && Math.abs(rx) < 330;
    // round bar ends
    const endL = Math.hypot(rx + 330, ry), endR = Math.hypot(rx - 330, ry);
    const inBarRound = inBar || endL < 62 || endR < 62;
    // amber dot at bar lower end
    const dotC = { x: 300 * Math.cos(ang), y: 300 * Math.sin(ang) };
    const inDot = Math.hypot(px - dotC.x, py - dotC.y) < 78;

    if (inDot) { r = 245; g = 166; b = 35; }
    else if (inRing || inBarRound) { r = 255; g = 255; b = 255; }

    buf[i] = Math.min(255, r); buf[i + 1] = Math.min(255, g);
    buf[i + 2] = Math.min(255, b); buf[i + 3] = 255;
  }
}

// minimal PNG encoder
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
ihdr.writeUInt32BE(S, 0); ihdr.writeUInt32BE(S, 4);
ihdr[8] = 8; ihdr[9] = 6; ihdr[10] = 0; ihdr[11] = 0; ihdr[12] = 0;
const raw = Buffer.alloc((S * 4 + 1) * S);
for (let y = 0; y < S; y++) {
  raw[y * (S * 4 + 1)] = 0;
  buf.copy(raw, y * (S * 4 + 1) + 1, y * S * 4, (y + 1) * S * 4);
}
const png = Buffer.concat([
  Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
  chunk('IHDR', ihdr),
  chunk('IDAT', zlib.deflateSync(raw)),
  chunk('IEND', Buffer.alloc(0)),
]);
fs.mkdirSync('assets', { recursive: true });
fs.writeFileSync('assets/icon.png', png);
console.log('icon bytes: ' + png.length);
