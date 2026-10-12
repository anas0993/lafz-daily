#!/usr/bin/env python3
"""Validate the bundled word lists in lib/data/*.dart.

Checks (mirrors the app's own rules in lib/game/urdu_text.dart and
WordRepository.isValidGuess):
  1. Every entry normalizes to exactly 5 letters (Urdu/Arabic via the app's
     canonicalization; Latin via lowercase alpha).
  2. No exact or post-normalization duplicates inside a list.
  3. Every answer also appears in the guess list (otherwise it could never
     be typed by a player).

Usage: python3 tool/validate_wordlists.py   (run from project root)
Exit code 0 = all clean, 1 = problems found.
"""
import re
import sys
from pathlib import Path

DATA = Path(__file__).resolve().parent.parent / "lib" / "data"


def norm_urdu(s: str) -> str:
    out = []
    for ch in s:
        cp = ord(ch)
        if 0x064B <= cp <= 0x0652:
            continue  # tashkeel
        if cp in (0x0670, 0x0640, 0x0654, 0x0655):
            continue  # superscript alef / tatweel / hamza forms
        if cp == 0x064A:
            out.append(chr(0x06CC)); continue  # ي -> ی
        if cp == 0x0643:
            out.append(chr(0x06A9)); continue  # ك -> ک
        if cp == 0x0647:
            out.append(chr(0x06C1)); continue  # ہ -> ہ
        out.append(ch)
    return "".join(out)


def load(name: str):
    return re.findall(r"'([^']+)'", (DATA / f"{name}.dart").read_text(encoding="utf-8"))


LANGS = {
    "english": ("en", lambda w: w.lower()),
    "spanish": ("es", lambda w: w.lower()),
    "urdu": ("ur", norm_urdu),
    "arabic": ("ar", norm_urdu),  # same canonicalization as the app
}

problems = 0
for lang, (_, norm) in LANGS.items():
    for kind in ("answers", "guesses"):
        name = f"{lang}_{kind}"
        words = load(name)
        bad_len = [w for w in words if len(norm(w)) != 5]
        if bad_len:
            problems += 1
            print(f"FAIL {name}: {len(bad_len)} entries not 5 letters after normalization: {bad_len[:5]}")
        if len(set(words)) != len(words):
            problems += 1
            print(f"FAIL {name}: exact duplicates present")
        if len(set(map(norm, words))) != len(words):
            problems += 1
            print(f"FAIL {name}: duplicates after normalization")
        if kind == "guesses":
            answers = set(map(norm, load(f"{lang}_answers")))
            missing = answers - set(map(norm, words))
            if missing:
                problems += 1
                print(f"FAIL {name}: {len(missing)} answers not guessable: {list(missing)[:5]}")
        print(f"ok {name}: n={len(words)}")

print("ALL CLEAN" if problems == 0 else f"{problems} PROBLEM(S)")
sys.exit(1 if problems else 0)
