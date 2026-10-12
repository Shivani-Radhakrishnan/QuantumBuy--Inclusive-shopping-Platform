"""Write a short spoken description of every product photo with a small vision-language model.

    pip install torch==2.8.0 transformers==4.57.1 pillow num2words   # only for this script
    python ml/tools/describe_images.py [--limit N]

Runs once, offline; the result (assets/ai_descriptions.json) ships with the app, so the
app needs no model at runtime. Uses HuggingFaceTB/SmolVLM-256M-Instruct (about 500 MB,
natively supported by transformers, no remote code), told which product it is looking
at and asked for its look (colour, material, shape) rather than brand names. Greedy
decoding, so the output is deterministic. ``ml/tools/check_descriptions.py`` then decides
which descriptions are consistent enough with the product to be used.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "ml"))

from quantumbuy_ml.catalog import DART_CATALOG, DESCRIPTIONS, parse_dart  # noqa: E402

MODEL = "HuggingFaceTB/SmolVLM-256M-Instruct"
PROMPT = ("This product photo shows a {name}. In one short sentence for a blind shopper, describe how the "
          "{name} looks: its colour, material and shape. Do not mention brand names or the background.")


def clean(text: str, name: str) -> str:
    """Turn the model's short answer into a sentence that names the product.

    "Black." -> "A black smartphone."   "It is black and silver." -> "The digital camera is black and silver."
    """
    t = text.strip().split("\n")[0]
    t = re.sub(r"^(?:assistant:|answer:)\s*", "", t, flags=re.I).strip()
    t = re.sub(r"\s+", " ", t).strip(" \"'.")
    if not t:
        return ""
    n = name.lower()
    if re.match(r"^(?:it|this|the product|the item)\b", t, re.I):    # "It is black" -> "The toaster is black"
        t = re.sub(r"^(?:it|this|the product|the item)\b", f"The {n}", t, count=1, flags=re.I)
    elif len(t.split()) <= 3 and n not in t.lower():                  # "Black", "Black and white"
        t = f"{'An' if t[0].lower() in 'aeiou' else 'A'} {t.lower()} {n}"
    return t[:1].upper() + t[1:] + "."


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--limit", type=int, default=0)
    args = ap.parse_args()

    import torch
    from PIL import Image
    from transformers import AutoModelForImageTextToText, AutoProcessor

    torch.manual_seed(0)
    processor = AutoProcessor.from_pretrained(MODEL)
    model = AutoModelForImageTextToText.from_pretrained(MODEL, torch_dtype=torch.float32).eval()
    products = parse_dart(DART_CATALOG.read_text(encoding="utf-8"))
    if args.limit:
        products = products[: args.limit]
    out, raw = {}, {}
    for p in products:
        image = Image.open(ROOT / p.image).convert("RGB")
        messages = [{"role": "user", "content": [
            {"type": "image"}, {"type": "text", "text": PROMPT.format(name=p.name.lower())}]}]
        prompt = processor.apply_chat_template(messages, add_generation_prompt=True)
        inputs = processor(text=prompt, images=[image], return_tensors="pt")
        with torch.no_grad():
            ids = model.generate(**inputs, max_new_tokens=48, do_sample=False, no_repeat_ngram_size=3)
        text = processor.batch_decode(ids[:, inputs["input_ids"].shape[1]:], skip_special_tokens=True)[0]
        raw[p.image] = text.strip()
        out[p.image] = clean(text, p.name)
        print(f"{p.name:22s} {out[p.image]}", file=sys.stderr)
    if not args.limit:
        DESCRIPTIONS.write_text(json.dumps({"model": MODEL, "prompt": PROMPT, "descriptions": out, "raw": raw}, indent=1,
                                           ensure_ascii=False) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
