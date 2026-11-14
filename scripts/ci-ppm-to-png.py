#!/usr/bin/env python3
"""Convert QEMU P6 PPM screenshots into browser-viewable PNGs (stdlib only)."""
from pathlib import Path
import struct
import zlib

def tokens(data):
    pos = 0
    for _ in range(4):
        while pos < len(data) and chr(data[pos]).isspace():
            pos += 1
        while pos < len(data) and data[pos] == 35:
            while pos < len(data) and data[pos] not in (10, 13):
                pos += 1
            while pos < len(data) and chr(data[pos]).isspace():
                pos += 1
        end = pos
        while end < len(data) and not chr(data[end]).isspace():
            end += 1
        yield data[pos:end].decode("ascii")
        pos = end
    if pos >= len(data) or not chr(data[pos]).isspace():
        raise ValueError("Missing PPM pixel separator")
    return pos + 1

def chunk(name, payload):
    return struct.pack(">I", len(payload)) + name + payload + struct.pack(">I", zlib.crc32(name + payload) & 0xffffffff)

def convert(path):
    data = path.read_bytes()
    t = tokens(data)
    magic, width, height, maxval = (next(t) for _ in range(4))
    if magic != "P6" or maxval != "255":
        raise ValueError("Only 8-bit P6 PPM supported")
    # Find the end of the PPM header by reading the four tokens again.
    pos = 0
    for _ in range(4):
        while data[pos] in b" \t\r\n":
            pos += 1
        while data[pos] == 35:
            while data[pos] not in (10, 13):
                pos += 1
            while data[pos] in b" \t\r\n":
                pos += 1
        while data[pos] not in b" \t\r\n":
            pos += 1
    pos += 1
    w, h = int(width), int(height)
    pixels = data[pos:pos + w * h * 3]
    if len(pixels) != w * h * 3:
        raise ValueError("Truncated PPM pixels")
    raw = b"".join(b"\x00" + pixels[y*w*3:(y+1)*w*3] for y in range(h))
    png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0)) + chunk(b"IDAT", zlib.compress(raw, 6)) + chunk(b"IEND", b"")
    target = path.with_suffix(".png")
    target.write_bytes(png)
    print(f"Screenshot: {target} ({w}x{h})")

for path in sorted(Path("out").glob("*.ppm")):
    try:
        convert(path)
    except Exception as exc:
        print(f"Could not convert {path}: {exc}")
