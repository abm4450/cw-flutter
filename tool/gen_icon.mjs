import { readFileSync, writeFileSync } from "fs";
import { dirname, join } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = join(__dirname, "..");
const svgPath = join(root, "assets", "logo.svg");
const outPath = join(root, "assets", "icon_app.png");
const BG = "#0098C4";
const SIZE = 1024;
const VB_W = 85.48, VB_H = 85.17;
const scale = Math.min(SIZE / VB_W, SIZE / VB_H);
const dx = (SIZE - VB_W * scale) / 2;
const dy = (SIZE - VB_H * scale) / 2;

const svg = readFileSync(svgPath, "utf8");
const inner = svg
  .replace(/^<\?xml[^>]*>\s*/, "")
  .replace(/<!DOCTYPE[^>]*>\s*/, "")
  .replace(/<svg[^>]*>/, "")
  .replace(/<\/svg>\s*$/, "");

const wrapped = `<svg xmlns="http://www.w3.org/2000/svg" width="${SIZE}" height="${SIZE}" viewBox="0 0 ${SIZE} ${SIZE}">
  <rect width="100%" height="100%" fill="${BG}"/>
  <g transform="translate(${dx}, ${dy}) scale(${scale})">
    ${inner}
  </g>
</svg>`;

const sharp = (await import("sharp")).default;
await sharp(Buffer.from(wrapped))
  .png()
  .toFile(outPath);

console.log(`Generated ${outPath} (${SIZE}x${SIZE})`);
