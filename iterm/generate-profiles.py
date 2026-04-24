#!/usr/bin/env python3
import json, os

def c(hex_str):
    h = hex_str.lstrip('#')
    return {
        "Red Component":   int(h[0:2], 16) / 255,
        "Green Component": int(h[2:4], 16) / 255,
        "Blue Component":  int(h[4:6], 16) / 255,
    }

# Gruvbox palettes (medium contrast)
dark = {
    "bg":  "#282828", "fg":  "#ebdbb2",
    "a0":  "#282828", "a1":  "#cc241d", "a2":  "#98971a", "a3":  "#d79921",
    "a4":  "#458588", "a5":  "#b16286", "a6":  "#689d6a", "a7":  "#a89984",
    "a8":  "#928374", "a9":  "#fb4934", "a10": "#b8bb26", "a11": "#fabd2f",
    "a12": "#83a598", "a13": "#d3869b", "a14": "#8ec07c", "a15": "#ebdbb2",
    "cursor": "#ebdbb2", "cursor_text": "#282828",
    "selection": "#504945", "selected_text": "#ebdbb2",
    "bold": "#ebdbb2",
}
light = {
    "bg":  "#fbf1c7", "fg":  "#3c3836",
    "a0":  "#fbf1c7", "a1":  "#cc241d", "a2":  "#98971a", "a3":  "#d79921",
    "a4":  "#458588", "a5":  "#b16286", "a6":  "#689d6a", "a7":  "#7c6f64",
    "a8":  "#928374", "a9":  "#9d0006", "a10": "#79740e", "a11": "#b57614",
    "a12": "#076678", "a13": "#8f3f71", "a14": "#427b58", "a15": "#3c3836",
    "cursor": "#3c3836", "cursor_text": "#fbf1c7",
    "selection": "#d5c4a1", "selected_text": "#3c3836",
    "bold": "#3c3836",
}

def build(name, guid, p):
    return {
        "Name": name,
        "Guid": guid,
        "Dynamic Profile Parent Name": "Default",
        "Background Color": c(p["bg"]),
        "Foreground Color": c(p["fg"]),
        "Cursor Color": c(p["cursor"]),
        "Cursor Text Color": c(p["cursor_text"]),
        "Selection Color": c(p["selection"]),
        "Selected Text Color": c(p["selected_text"]),
        "Bold Color": c(p["bold"]),
        **{f"Ansi {i} Color": c(p[f"a{i}"]) for i in range(16)},
    }

profiles = {
    "Profiles": [
        build("Dark",  "A8E7B2C4-1F3D-4A89-9C5E-0DB4F1E8A0D1", dark),
        build("Light", "B9F8C3D5-2A4E-5B9A-8D6F-1EC5A2F9B1E2", light),
    ]
}

out = os.path.expanduser("~/Library/Application Support/iTerm2/DynamicProfiles/gruvbox.json")
with open(out, "w") as f:
    json.dump(profiles, f, indent=2)
print(f"wrote {out}")
