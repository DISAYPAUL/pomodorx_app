#!/usr/bin/env python3
"""Map NCLEX practice bank questions into topic quiz JSON files.

This script loads `assets/data/nclex_practice_bank_new.json`, classifies each question
by simple keyword matching on the question `category` or `text`, and appends the question
to an appropriate topic file under `assets/data/`.

Target topic files:
- `assets/data/anatomy_quiz.json`       <= anatomy-related
- `assets/data/pharmacology_quiz.json` <= pharmacology-related
- `assets/data/nursing_quizzes.json`   <= fundamentals, maternal-newborn, medical-surgical,
                                           medication safety drills, mental health, pediatrics,
                                           and any other categories not matched above

The script will avoid duplicating identical question texts already present.
It also performs a basic validation: ensures `options` or `variants` present and
`correctIndex` is within range.
"""
import json
import re
from pathlib import Path
from collections import defaultdict

ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = ROOT / "assets" / "data"
NCLEX_FILE = DATA_DIR / "nclex_practice_bank_new.json"

TARGET_FILES = {
    "anatomy": DATA_DIR / "anatomy_quiz.json",
    "pharmacology": DATA_DIR / "pharmacology_quiz.json",
    # fallback target for many clinical topics
    "default": DATA_DIR / "nursing_quizzes.json",
}

KEYWORDS = {
    "anatomy": ["anatom", "muscle", "bone", "joint", "nerve", "artery", "vein", "organ", "physio"],
    "pharmacology": ["pharm", "drug", "medication", "dose", "antibiotic", "anticoag", "opioid", "beta-block", "ace inhibitor", "diuretic", "therap"],
    # default catches everything else
}

def load_json(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)

def save_json(path, data):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

def choose_target(qtext, category):
    keytext = (category or "") + " " + (qtext or "")
    kl = keytext.lower()
    for topic, kws in KEYWORDS.items():
        for kw in kws:
            if kw in kl:
                return topic
    return "default"

def normalize_question_dict(q):
    # Keep fields but ensure standard keys exist
    out = dict(q)
    # Some banks use 'options' or 'choices' or 'variants'
    if "options" not in out and "variants" in out:
        out["options"] = out.get("variants")
    if "options" not in out and "choices" in out:
        out["options"] = out.get("choices")
    return out

def get_existing_texts(topic_data):
    texts = set()
    quizzes = topic_data.get("quizzes") or []
    for quiz in quizzes:
        for q in quiz.get("questions", []):
            texts.add((q.get("text") or "").strip())
    return texts

def append_question_to_topic(topic_path, question):
    if not topic_path.exists():
        print(f"Warning: target file {topic_path} not found; creating basic structure")
        # create minimal structure
        data = {"quizzes": [{"title": "Imported", "questions": []}]}
    else:
        data = load_json(topic_path)

    quizzes = data.get("quizzes")
    if not isinstance(quizzes, list) or len(quizzes) == 0:
        quizzes = [{"title": "Imported", "questions": []}]
        data["quizzes"] = quizzes

    existing_texts = get_existing_texts(data)
    qtext = (question.get("text") or "").strip()
    if qtext in existing_texts:
        return False

    # Append to first quiz's questions
    quizzes[0].setdefault("questions", []).append(question)
    save_json(topic_path, data)
    return True

def validate_question(question):
    # Basic checks: options present and correctIndex valid
    q = normalize_question_dict(question)
    options = q.get("options") or []
    if not isinstance(options, list) or len(options) < 2:
        return False, "missing-or-short-options"
    ci = q.get("correctIndex")
    if ci is None:
        return False, "missing-correctIndex"
    try:
        ci = int(ci)
    except Exception:
        return False, "invalid-correctIndex"
    if ci < 0 or ci >= len(options):
        return False, "correctIndex-out-of-range"
    return True, None

def main():
    bank = load_json(NCLEX_FILE)
    # bank may be grouped into quizzes; traverse and collect all questions
    collected = []
    if isinstance(bank.get("quizzes"), list):
        for quiz in bank.get("quizzes", []):
            for q in quiz.get("questions", []):
                collected.append(q)
    elif isinstance(bank.get("questions"), list):
        collected = bank.get("questions", [])
    else:
        # try to find all question-like dicts recursively
        def find_questions(obj):
            found = []
            if isinstance(obj, dict):
                if "text" in obj and ("options" in obj or "variants" in obj or "choices" in obj):
                    found.append(obj)
                for v in obj.values():
                    found.extend(find_questions(v))
            elif isinstance(obj, list):
                for item in obj:
                    found.extend(find_questions(item))
            return found
        collected = find_questions(bank)

    counts = defaultdict(int)
    added = defaultdict(int)
    warnings = defaultdict(int)

    for q in collected:
        qnorm = normalize_question_dict(q)
        category = qnorm.get("category", "")
        qtext = qnorm.get("text", "")
        topic_key = choose_target(qtext, category)
        target_path = TARGET_FILES.get(topic_key, TARGET_FILES["default"])

        valid, reason = validate_question(qnorm)
        counts[topic_key] += 1
        if not valid:
            warnings[reason] += 1
            # still attempt to add, but mark in explanation
            qnorm.setdefault("explanation", "[Imported with validation warning: %s] %s" % (reason, qnorm.get("explanation", "")))

        appended = append_question_to_topic(target_path, qnorm)
        if appended:
            added[topic_key] += 1

    print("Mapping complete")
    print("Scanned counts by topic:")
    for k, v in counts.items():
        print(f" - {k}: {v} scanned, {added.get(k,0)} added")
    if warnings:
        print("Validation warnings:")
        for k, v in warnings.items():
            print(f" - {k}: {v}")

    # Show short samples
    print("\nSample additions per topic (first 3):")
    for topic_key, path in TARGET_FILES.items():
        data = load_json(path) if path.exists() else {"quizzes":[]}
        qs = []
        for quiz in data.get("quizzes", []):
            qs.extend(quiz.get("questions", []))
        print(f"\n== {topic_key} ({path.name}) total questions: {len(qs)} ==")
        for i, q in enumerate(qs[:3]):
            print(f" {i+1}. {q.get('text')}")


if __name__ == "__main__":
    main()
