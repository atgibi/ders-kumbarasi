"""Claude Design bileşen şablonlarını (dc) Flutter'ın çizebileceği düz SVG'ye
çevirir: {{d.x}} durumlarını çözer, <use> başvurularını açar, görünmeyen
(display=none) öğeleri ve filtreleri atar."""
import copy, re
import xml.etree.ElementTree as ET

NS = "http://www.w3.org/2000/svg"
ET.register_namespace("", NS)
XL = "{http://www.w3.org/1999/xlink}href"


def render(tpl: str, vals: dict) -> str:
    def sub(m):
        k = m.group(1)
        v = vals
        for part in k.split("."):
            v = v[part]
        return str(v)
    s = re.sub(r"\{\{([\w.]+)\}\}", sub, tpl)
    root = ET.fromstring(s)
    defs = {}
    for d in root.iter(f"{{{NS}}}defs"):
        for el in list(d):
            if el.get("id"):
                defs[el.get("id")] = el
    for d in list(root.iter(f"{{{NS}}}defs")):
        pass

    def walk(parent):
        for i, el in enumerate(list(parent)):
            tag = el.tag.split("}")[-1]
            if tag == "defs":
                parent.remove(el)
                continue
            if el.get("display") == "none":
                parent.remove(el)
                continue
            el.attrib.pop("display", None)
            el.attrib.pop("filter", None)
            if tag == "use":
                ref = (el.get("href") or el.get(XL) or "").lstrip("#")
                src = copy.deepcopy(defs[ref])
                src.attrib.pop("id", None)
                extra = {k: v for k, v in el.attrib.items() if k not in ("href", XL)}
                tr = extra.pop("transform", None)
                for k, v in extra.items():
                    src.set(k, v)
                if tr:
                    g = ET.Element(f"{{{NS}}}g", {"transform": tr})
                    g.append(src)
                    src = g
                idx = list(parent).index(el)
                parent.remove(el)
                parent.insert(idx, src)
                walk_one(src)
                continue
            walk(el)

    def walk_one(el):
        el.attrib.pop("filter", None)
        walk(el)

    walk(root)
    for k in [k for k in root.attrib if k in ("role", "aria-label", "width", "height", "style", "class")]:
        root.attrib.pop(k)
    return ET.tostring(root, encoding="unicode")
