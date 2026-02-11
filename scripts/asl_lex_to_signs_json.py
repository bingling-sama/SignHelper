#!/usr/bin/env python3
"""
Convert ASL-LEX 2.0 CSV (signdata.csv) into SignHelper signs.json format.

USAGE:
    python scripts/asl_lex_to_signs_json.py \
        --input signdata.csv \
        --output SignHelper/signs.json

Columns used from ASL-LEX CSV:
  - EntryID / LemmaID: gloss identifier
  - SignBankEnglishTranslations: English equivalents for description
  - LexicalClass: Noun, Verb, Adjective
  - CDISemanticCategory: semantic grouping (Animals, Food and Drink, etc.)
"""

import argparse
import csv
import json
import re
from pathlib import Path
from collections import defaultdict

# Category id -> (title, icon)
CATEGORY_MAP = {
    "Animals": ("animals", "Animals", "hare.fill"),
    "Food and Drink": ("food_drink", "Food and Drink", "fork.knife"),
    "Outside Things and Places to Go": ("outside", "Places & Outdoors", "leaf.fill"),
    "Clothing": ("clothing", "Clothing", "tshirt.fill"),
    "Furniture and Rooms": ("furniture", "Furniture & Rooms", "bed.double.fill"),
    "Small Household Items": ("household", "Household Items", "lamp.desk.fill"),
    "People": ("people", "People", "person.2.fill"),
    "Action Signs": ("actions", "Actions", "figure.walk"),
    "Signs About Time": ("time", "Time", "clock.fill"),
    "Attribute": ("attributes", "Attributes", "star.fill"),
    "Event": ("events", "Events", "calendar"),
    "Place": ("places", "Places", "map.fill"),
    "Games and Routines": ("routines", "Greetings & Routines", "hand.wave.fill"),
    "Mental State Terms": ("emotions", "Emotions & Feelings", "face.smiling"),
    "None": ("general", "General", "hand.raised.fill"),
    "-": ("general", "General", "hand.raised.fill"),
}


def normalize_id(raw: str) -> str:
    """Turn EntryID/LemmaID into a stable, matchable id. Strip _1, _2 variants."""
    s = (raw or "").strip().lower()
    s = re.sub(r"_\d+$", "", s)  # candy_1 -> candy
    return s.replace(" ", "_")


def format_title(raw: str) -> str:
    """Format gloss for display: thank_you -> Thank you."""
    s = (raw or "").strip()
    s = re.sub(r"_\d+$", "", s)  # candy_1 -> candy
    parts = s.replace("_", " ").split()
    return " ".join(p.capitalize() for p in parts) if parts else s


# Sign IDs that have demonstration images in Assets.xcassets
DEMO_IMAGES: dict[str, str] = {
    "hello": "SignHello",
    "thank_you": "SignThankYou",
    "help": "SignHelp",
    "dog": "SignDog",
    "tree": "SignTree",
    "happy": "SignHappy",
    "hospital": "SignHospital",
}


def pick_icon(lexical_class: str) -> str:
    if lexical_class == "Noun":
        return "book.fill"
    if lexical_class == "Verb":
        return "figure.walk"
    if lexical_class == "Adjective":
        return "star.fill"
    return "hand.raised.fill"


def main() -> None:
    parser = argparse.ArgumentParser(description="Convert ASL-LEX CSV to SignHelper signs.json")
    parser.add_argument("--input", "-i", type=str, required=True, help="Path to signdata.csv")
    parser.add_argument("--output", "-o", type=str, required=True, help="Path to output signs.json")
    args = parser.parse_args()

    input_path = Path(args.input)
    output_path = Path(args.output)

    if not input_path.exists():
        raise SystemExit(f"Input CSV not found: {input_path}")

    # category_id -> list of sign dicts
    by_category: dict[str, list[dict]] = defaultdict(list)
    seen_ids: set[str] = set()

    with input_path.open("r", encoding="utf-8-sig", newline="", errors="replace") as f:
        reader = csv.DictReader(f)
        cols = reader.fieldnames or []

        if "EntryID" not in cols and "LemmaID" not in cols:
            raise SystemExit(f"CSV must have EntryID or LemmaID. Columns: {cols}")

        gloss_col = "EntryID" if "EntryID" in cols else "LemmaID"
        trans_col = "SignBankEnglishTranslations" if "SignBankEnglishTranslations" in cols else None
        class_col = "LexicalClass" if "LexicalClass" in cols else None
        cat_col = "CDISemanticCategory" if "CDISemanticCategory" in cols else None

        for row in reader:
            gloss = (row.get(gloss_col) or "").strip()
            if not gloss:
                continue

            sign_id = normalize_id(gloss)
            if sign_id in seen_ids:
                continue
            seen_ids.add(sign_id)

            title = format_title(gloss)

            trans = ""
            if trans_col:
                trans = (row.get(trans_col) or "").strip()
            if trans:
                desc = f"ASL sign: {trans}. (Source: ASL-LEX 2.0)"
            else:
                desc = f"ASL sign for '{title}'. (Source: ASL-LEX 2.0)"

            lex_class = (row.get(class_col) or "").strip() if class_col else ""
            cat_raw = (row.get(cat_col) or "").strip() if cat_col else ""
            cat_key = cat_raw if cat_raw and cat_raw != "None" else ("None" if not cat_raw else cat_raw)

            cat_info = CATEGORY_MAP.get(cat_key, ("general", "General", "hand.raised.fill"))
            cat_id = cat_info[0]
            icon = pick_icon(lex_class)
            demo_img = DEMO_IMAGES.get(sign_id)

            sign_entry: dict = {
                "id": sign_id,
                "title": title,
                "description": desc,
                "imageName": icon,
            }
            if demo_img:
                sign_entry["demoImageName"] = demo_img
            by_category[cat_id].append(sign_entry)

    # Build categories list, reuse CATEGORY_MAP for title/icon
    cat_id_to_meta = {t[0]: (t[1], t[2]) for t in CATEGORY_MAP.values()}
    categories = []
    for cid, signs in sorted(by_category.items()):
        title, icon = cat_id_to_meta.get(cid, ("General", "hand.raised.fill"))
        categories.append({
            "id": cid,
            "title": title,
            "icon": icon,
            "difficulty": "Mixed",
            "signs": signs,
        })

    data = {"categories": categories}
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with output_path.open("w", encoding="utf-8") as out_f:
        json.dump(data, out_f, ensure_ascii=False, indent=2)

    total = sum(len(s) for s in by_category.values())
    print(f"Wrote {total} signs in {len(categories)} categories to {output_path}")
