// Generates assets/alarm.wav — مميز للتطبيق: 3 نغمات صاعدة (E5-G5-C6)
const fs = require('fs');
const SR = 44100;
const notes = [
  { f: 659.25, t: 0.0, d: 0.30 },  // E5
  { f: 783.99, t: 0.28, d: 0.30 }, // G5
  { f: 1046.5, t: 0.56, d: 0.55 }, // C6
];
const total = 1.3;
const n = Math.floor(SR * total);
const data = Buffer.alloc(n * 2);
for (let i = 0; i < n; i++) {
  const t = i / SR;
  let s = 0;
  for (const nt of notes) {
    if (t >= nt.t && t <= nt.t + nt.d) {
      const lt = t - nt.t;
      const env = Math.exp(-4 * lt / nt.d);
      s += Math.sin(2 * Math.PI * nt.f * lt) * env * 0.5;
      s += Math.sin(2 * Math.PI * nt.f * 2 * lt) * env * 0.12;
    }
  }
  s = Math.max(-1, Math.min(1, s));
  data.writeInt16LE(Math.round(s * 30000), i * 2);
}
const hdr = Buffer.alloc(44);
hdr.write('RIFF', 0); hdr.writeUInt32LE(36 + data.length, 4);
hdr.write('WAVE', 8); hdr.write('fmt ', 12);
hdr.writeUInt32LE(16, 16); hdr.writeUInt16LE(1, 20); hdr.writeUInt16LE(1, 22);
hdr.writeUInt32LE(SR, 24); hdr.writeUInt32LE(SR * 2, 28);
hdr.writeUInt16LE(2, 32); hdr.writeUInt16LE(16, 34);
hdr.write('data', 36); hdr.writeUInt32LE(data.length, 40);
fs.mkdirSync('assets', { recursive: true });
fs.writeFileSync('assets/alarm.wav', Buffer.concat([hdr, data]));
console.log('alarm bytes: ' + (44 + data.length));
