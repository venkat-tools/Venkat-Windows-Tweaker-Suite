"""
Icon generator for Windows Tweaker Suite.
"""

from PIL import Image, ImageDraw


def generate_tweaker_icon(size=256):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Gradient/Circular Shield background
    margin = size * 0.08
    draw.rounded_rectangle(
        [margin, margin, size - margin, size - margin],
        radius=size * 0.22,
        fill="#0F172A",
        outline="#38BDF8",
        width=int(size * 0.04)
    )

    # Cyan Lightning Bolt / Gear glyph
    cx, cy = size / 2, size / 2
    bolt = [
        (cx + size * 0.05, cy - size * 0.30),
        (cx - size * 0.22, cy + size * 0.02),
        (cx - size * 0.02, cy + size * 0.02),
        (cx - size * 0.08, cy + size * 0.32),
        (cx + size * 0.22, cy - size * 0.02),
        (cx + size * 0.02, cy - size * 0.02),
    ]
    draw.polygon(bolt, fill="#38BDF8")
    draw.polygon(bolt, outline="#FFFFFF", width=int(size * 0.015))

    return img


if __name__ == "__main__":
    icon = generate_tweaker_icon(256)
    icon.save("tweaker_icon.ico", format="ICO", sizes=[(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)])
    print("Saved tweaker_icon.ico!")
