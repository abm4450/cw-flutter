"""Generate icon_app.png from logo.svg (1024x1024, #0098C4 background)."""
import cairosvg
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SVG = ROOT / "assets" / "logo.svg"
OUT = ROOT / "assets" / "icon_app.png"
BG = "#0098C4"
SIZE = 1024

if not SVG.exists():
    raise SystemExit(f"ERROR: {SVG} not found")

cairosvg.svg2png(
    url=str(SVG),
    write_to=str(OUT),
    output_width=SIZE,
    output_height=SIZE,
    background_color=BG,
)
print(f"Generated {OUT} ({SIZE}x{SIZE})")
