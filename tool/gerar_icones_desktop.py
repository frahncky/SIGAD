import sys
from PIL import Image, ImageDraw, ImageFilter
# Uso: python3 tool/gerar_icones_desktop.py [raiz_do_projeto]
# Gera os ícones de macOS e Windows a partir de assets/images/app_icon_full.png.
root = sys.argv[1] if len(sys.argv) > 1 else "."
src = Image.open(f"{root}/assets/images/app_icon_full.png").convert("RGBA")
N = 1024

def rounded(img, size, radius):
    img = img.resize((size, size), Image.LANCZOS)
    mask = Image.new("L", (size * 4, size * 4), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, size * 4 - 1, size * 4 - 1), radius * 4, fill=255)
    mask = mask.resize((size, size), Image.LANCZOS)
    out = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    out.paste(img, (0, 0), mask)
    return out

# macOS: grade de 1024 com corpo de 824 px, cantos de ~185 px e sombra suave (Apple HIG).
body = 824
off = (N - body) // 2
canvas = Image.new("RGBA", (N, N), (0, 0, 0, 0))
shadow = Image.new("L", (N, N), 0)
ImageDraw.Draw(shadow).rounded_rectangle((off, off + 12, off + body, off + body + 12), 185, fill=90)
shadow = shadow.filter(ImageFilter.GaussianBlur(14))
canvas.paste(Image.new("RGBA", (N, N), (0, 0, 0, 255)), (0, 0), shadow)
icon = rounded(src, body, 185)
canvas.alpha_composite(icon, (off, off))
d = f"{root}/macos/Runner/Assets.xcassets/AppIcon.appiconset"
for s in (16, 32, 64, 128, 256, 512, 1024):
    canvas.resize((s, s), Image.LANCZOS).save(f"{d}/app_icon_{s}.png", optimize=True)

# Windows: quadrado com cantos arredondados, sem margem.
win = rounded(src, 256, 40)
win.save(f"{root}/windows/runner/resources/app_icon.ico",
         sizes=[(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)])
