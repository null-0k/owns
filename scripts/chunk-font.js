const fs   = require('fs');
const path = require('path');


const SRC_FILE = path.join(__dirname, '..', 'files', 'fonts', 'base64', 'caveat.txt');
const OUT_FILE = path.join(__dirname, 'caveat.json');
const CHUNK_SIZE = 23 * 1024; // 24 KB


const buf = fs.readFileSync(SRC_FILE);

const chunks = [];
let offset = 0;

while (offset < buf.length) {
  let end = Math.min(offset + CHUNK_SIZE, buf.length);
  while (end < buf.length && (buf[end] & 0b1100_0000) === 0b1000_0000) end--;
  chunks.push(buf.slice(offset, end).toString('utf8'));
  offset = end;
}

fs.writeFileSync(OUT_FILE, JSON.stringify(chunks), 'utf8');

console.log(`Done! ${chunks.length} => ${OUT_FILE}`);
