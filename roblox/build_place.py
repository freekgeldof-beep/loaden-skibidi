"""Maakt LoadenSkibidi.rbxlx: een Roblox-place die je met een dubbelklik opent in Roblox Studio.

Gebruik:  python3 roblox/build_place.py [uitvoerbestand]
Alle scripts uit roblox/src komen er automatisch op de goede plek in.
(Dit doet hetzelfde als `rojo build`, maar zonder dat je Rojo hoeft te installeren.)
"""
import pathlib
import sys
from xml.sax.saxutils import escape

SRC = pathlib.Path(__file__).parent / "src"

# (map in src, Roblox-plek)
LAYOUT = [
    ("shared", ["ReplicatedStorage"]),
    ("server", ["ServerScriptService"]),
    ("client", ["StarterPlayer", "StarterPlayerScripts"]),
]

_ref = 0


def ref():
    global _ref
    _ref += 1
    return f"RBX{_ref:04d}"


def script_item(path: pathlib.Path) -> str:
    name = path.name
    if name.endswith(".server.luau"):
        cls, name = "Script", name[: -len(".server.luau")]
    elif name.endswith(".client.luau"):
        cls, name = "LocalScript", name[: -len(".client.luau")]
    else:
        cls, name = "ModuleScript", name[: -len(".luau")]
    source = path.read_text(encoding="utf-8")
    assert "]]>" not in source, f"{path} bevat ]]>"
    return (
        f'<Item class="{cls}" referent="{ref()}"><Properties>'
        f'<string name="Name">{escape(name)}</string>'
        f"<ProtectedString name=\"Source\"><![CDATA[{source}]]></ProtectedString>"
        f"</Properties></Item>"
    )


def build() -> str:
    parts = []
    for folder, classes in LAYOUT:
        scripts = "".join(script_item(p) for p in sorted((SRC / folder).glob("*.luau")))
        extra = '<bool name="EnableMouseLockOption">false</bool>' if classes[0] == "StarterPlayer" else ""
        cls = classes[0]
        inner = scripts if len(classes) == 1 else (
            f'<Item class="{classes[1]}" referent="{ref()}"><Properties>'
            f'<string name="Name">{classes[1]}</string></Properties>{scripts}</Item>'
        )
        parts.append(
            f'<Item class="{cls}" referent="{ref()}"><Properties>'
            f'<string name="Name">{cls}</string>{extra}</Properties>{inner}</Item>'
        )
    return (
        '<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" '
        'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
        'xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">'
        + "".join(parts)
        + "</roblox>\n"
    )


if __name__ == "__main__":
    out = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else "LoadenSkibidi.rbxlx")
    out.write_text(build(), encoding="utf-8")
    print(f"Klaar: {out}")
