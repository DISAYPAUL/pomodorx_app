"""Utility to generate nursing quiz JSON from the curated question bank."""

from __future__ import annotations

import ast
import json
from collections import defaultdict
from datetime import UTC, datetime
from pathlib import Path
from typing import DefaultDict, Dict, List

BASE_DIR = Path(__file__).resolve().parents[1]
SOURCE_PATH = BASE_DIR / "tools" / "question_bank_source.py"
OUTPUT_PATH = BASE_DIR / "assets" / "data" / "nursing_quizzes.json"
CREATED_AT = "2025-01-10T00:00:00.000Z"
ICON_PATH = "assets/icons/logo.png"

DIFFICULTY_TITLES = {
    "easy": "Easy",
    "medium": "Medium",
    "hard": "Hard",
    "rnworthy": "RN Worthy",
}

DIFFICULTY_DURATION = {
    "easy": 12,
    "medium": 18,
    "hard": 22,
    "rnworthy": 25,
}

TOPIC_DEFS = {
    "pharm": {
        "id": "topic-pharm",
        "name": "Pharmacology",
        "description": "Medication safety, adverse effects, and priority monitoring cues from Saunders",
        "slug": "pharmacology",
        "icon": ICON_PATH,
        "order": 1,
    },
    "med-surg": {
        "id": "topic-med-surg",
        "name": "Medical-Surgical",
        "description": "Systems-based adult health priorities across cardiovascular, respiratory, and endocrine cases",
        "slug": "medical-surgical",
        "icon": ICON_PATH,
        "order": 2,
    },
    "peds": {
        "id": "topic-pediatrics",
        "name": "Pediatrics",
        "description": "Growth, development, and acute pediatric safety cues from Saunders",
        "slug": "pediatrics",
        "icon": ICON_PATH,
        "order": 3,
    },
    "mat": {
        "id": "topic-maternal",
        "name": "Maternal-Newborn",
        "description": "Antepartum, intrapartum, and postpartum priorities grounded in Saunders references",
        "slug": "maternal-newborn",
        "icon": ICON_PATH,
        "order": 4,
    },
    "mental": {
        "id": "topic-mental",
        "name": "Mental Health",
        "description": "Psychiatric safety, therapeutic communication, and crisis management scenarios",
        "slug": "mental-health",
        "icon": ICON_PATH,
        "order": 5,
    },
    "fundamentals": {
        "id": "topic-fundamentals",
        "name": "Fundamentals",
        "description": "Core nursing foundations: delegation, infection control, and safety",
        "slug": "fundamentals",
        "icon": ICON_PATH,
        "order": 6,
    },
}


def normalize_text(value: str) -> str:
    """Fix mojibake such as â€¢ that crept into the raw source."""

    try:
        return value.encode("latin-1").decode("utf-8")
    except (UnicodeEncodeError, UnicodeDecodeError):
        return value


def q(
    cat: str,
    diff: str,
    suffix: str,
    text: str,
    options: List[str],
    correct: int,
    explanation: str,
) -> dict:
    return {
        "id": f"{cat}-{diff}-{suffix}",
        "text": text,
        "options": options,
        "correctIndex": correct,
        "explanation": explanation,
        "type": "mcq",
    }


def topic(meta: Dict[str, str]) -> Dict[str, str]:
    return {
        "id": meta["id"],
        "name": meta["name"],
        "description": meta["description"],
        "icon": meta.get("icon", ICON_PATH),
        "slug": meta["slug"],
        "createdAt": CREATED_AT,
    }


def quiz(quiz_id: str, title: str, topic_id: str, difficulty: str, questions: List[dict]) -> dict:
    return {
        "id": quiz_id,
        "title": title,
        "durationMinutes": DIFFICULTY_DURATION.get(difficulty, 15),
        "createdAt": CREATED_AT,
        "isOffline": True,
        "questions": questions,
    }


def parse_question_bank(source_path: Path) -> Dict[str, Dict[str, List[dict]]]:
    question_map: DefaultDict[str, DefaultDict[str, List[dict]]] = defaultdict(
        lambda: defaultdict(list)
    )

    lines = source_path.read_text(encoding="utf-8").splitlines()
    current_cat: str | None = None
    i = 0

    while i < len(lines):
        stripped = lines[i].strip()

        if stripped.startswith("cat") and "=" in stripped:
            rhs = stripped.split("=", 1)[1].strip()
            try:
                current_cat = ast.literal_eval(rhs)
            except (SyntaxError, ValueError):
                current_cat = rhs.strip('"')
            i += 1
            continue

        if stripped.startswith("q("):
            block: List[str] = []
            i += 1
            while i < len(lines):
                inner = lines[i]
                if inner.strip().startswith("),"):
                    break
                block.append(inner)
                i += 1
            else:
                raise ValueError("Unterminated question block")

            i += 1  # skip the closing line

            if not block:
                continue

            first_line = block[0]
            if first_line.strip().startswith("cat"):
                if current_cat is None:
                    raise ValueError("Encountered 'cat' before assignment")
                leading = first_line[: len(first_line) - len(first_line.lstrip())]
                block[0] = f'{leading}"{current_cat}",'  # preserve indentation

            args_text = "\n".join(block)
            tuple_literal = f"({args_text})"
            try:
                (
                    cat_value,
                    diff,
                    suffix,
                    prompt,
                    options,
                    correct_idx,
                    rationale,
                ) = ast.literal_eval(tuple_literal)
            except Exception as exc:
                raise ValueError(f"Failed to parse question near line {i}") from exc

            cat_key = normalize_text(cat_value)
            normalized_options = [normalize_text(opt) for opt in options]

            question = q(
                cat_key,
                diff,
                suffix,
                normalize_text(prompt),
                normalized_options,
                correct_idx,
                normalize_text(rationale),
            )
            question_map[cat_key][diff].append(question)
            continue

        i += 1

    return question_map


def build_topics(question_bank: Dict[str, Dict[str, List[dict]]]) -> List[dict]:
    topics: List[dict] = []
    for cat, meta in sorted(TOPIC_DEFS.items(), key=lambda item: item[1]["order"]):
        cat_questions = question_bank.get(cat, {})
        quizzes: List[dict] = []
        for diff in ("easy", "medium", "hard", "rnworthy"):
            questions = cat_questions.get(diff)
            if not questions:
                continue
            quiz_id = f"quiz-{cat}-{diff}"
            title = f"{meta['name']} - {DIFFICULTY_TITLES.get(diff, diff.title())}"
            quizzes.append(quiz(quiz_id, title, meta["id"], diff, questions))

        if not quizzes:
            continue

        topic_meta = topic(meta)
        topics.append({"topic": topic_meta, "quizzes": quizzes})

    return topics


def main() -> None:
    if not SOURCE_PATH.exists():
        raise FileNotFoundError(
            f"Question bank source not found: {SOURCE_PATH}"  # pragma: no cover
        )

    question_bank = parse_question_bank(SOURCE_PATH)
    topics = build_topics(question_bank)
    generated_at = datetime.now(UTC).isoformat(timespec="seconds").replace("+00:00", "Z")
    payload = {
        "generatedAt": generated_at,
        "topics": topics,
    }

    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_PATH.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    total_questions = sum(len(quiz["questions"]) for topic in topics for quiz in topic["quizzes"])
    print(f"Wrote {total_questions} questions to {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
