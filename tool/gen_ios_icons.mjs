/** Generate all iOS AppIcon sizes from assets/icon_app.png */
import sharp from "sharp";
import { mkdirSync, existsSync } from "fs";
import { dirname, join } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = join(__dirname, "..");
const src = join(root, "assets", "icon_app.png");
const outDir = join(root, "ios", "Runner", "Assets.xcassets", "AppIcon.appiconset");

const sizes = [
  { filename: "Icon-App-20x20@1x.png", size: 20 },
  { filename: "Icon-App-20x20@2x.png", size: 40 },
  { filename: "Icon-App-20x20@3x.png", size: 60 },
  { filename: "Icon-App-29x29@1x.png", size: 29 },
  { filename: "Icon-App-29x29@2x.png", size: 58 },
  { filename: "Icon-App-29x29@3x.png", size: 87 },
  { filename: "Icon-App-40x40@1x.png", size: 40 },
  { filename: "Icon-App-40x40@2x.png", size: 80 },
  { filename: "Icon-App-40x40@3x.png", size: 120 },
  { filename: "Icon-App-60x60@2x.png", size: 120 },
  { filename: "Icon-App-60x60@3x.png", size: 180 },
  { filename: "Icon-App-76x76@1x.png", size: 76 },
  { filename: "Icon-App-76x76@2x.png", size: 152 },
  { filename: "Icon-App-83.5x83.5@2x.png", size: 167 },
  { filename: "Icon-App-1024x1024@1x.png", size: 1024 },
];

if (!existsSync(src)) {
  console.error("ERROR: Run tool/gen_icon.mjs first to create assets/icon_app.png");
  process.exit(1);
}

mkdirSync(outDir, { recursive: true });

for (const { filename, size } of sizes) {
  const outPath = join(outDir, filename);
  await sharp(src).resize(size, size).png().toFile(outPath);
  console.log(`  ${filename} (${size}x${size})`);
}

console.log(`\nGenerated ${sizes.length} icons in AppIcon.appiconset`);
