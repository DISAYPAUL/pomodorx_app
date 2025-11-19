import json
import re
from pathlib import Path

TARGET_FILES = [
    Path("assets/data/anatomy_quiz.json"),
    Path("assets/data/pharmacology_quiz.json"),
    Path("assets/data/nursing_quizzes.json"),
]


def extract_core_question(text: str) -> str:
    if not text or not isinstance(text, str):
        return text
    # Start with original text
    cleaned = text
    # Remove all 'Case ###.' occurrences anywhere
    cleaned = re.sub(r'Case\s*\d+\.?\s*', '', cleaned)
    # Remove 'Saunders cue: ...' up to the next sentence terminator (., !, or ?)
    cleaned = re.sub(r'Saunders\s*cue:\s*[^.?!]*[.?!]\s*', '', cleaned, flags=re.IGNORECASE)
    # Also remove any leftover 'Saunders cue:' tokens
    cleaned = re.sub(r'Saunders\s*cue:\s*', '', cleaned, flags=re.IGNORECASE)
    cleaned = cleaned.strip()

    # Split into sentences and prefer the last sentence that contains a question mark
    sentences = re.split(r'(?<=[.!?])\s+', cleaned)
    for s in reversed(sentences):
        if '?' in s:
            return s.strip()

    # If no question-mark sentence found, return the cleaned string without case/saunders fragments
    return cleaned


def clean_file(path: Path) -> None:
    if not path.exists():
        print(f"Skipping missing file: {path}")
        return

    data = json.loads(path.read_text(encoding="utf-8"))
    modified = False

    # Support both top-level 'quizzes' and nested 'topics' structures
    if isinstance(data.get("quizzes"), list):
        quiz_containers = data["quizzes"]
    else:
        quiz_containers = []

    if isinstance(data.get("topics"), list):
        for t in data.get("topics", []):
            if isinstance(t, dict) and isinstance(t.get("quizzes"), list):
                quiz_containers.extend(t.get("quizzes", []))

    for quiz in quiz_containers:
        questions = quiz.get("questions", [])
        for q in questions:
            orig = q.get("text", "")
            new = extract_core_question(orig)
            if new != orig:
                q["text"] = new
                modified = True

            # Clean variants to only include the core question or empty list
            if "variants" in q and isinstance(q["variants"], list):
                q["variants"] = [new] if new else []
                modified = True

    if modified:
        path.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")
        print(f"Cleaned: {path}")
    else:
        print(f"No changes needed: {path}")


def main():
    for p in TARGET_FILES:
        clean_file(p)


if __name__ == "__main__":
    main()
