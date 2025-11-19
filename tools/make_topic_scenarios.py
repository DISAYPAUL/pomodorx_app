import json
import random
import re
from pathlib import Path

FILES = [
    Path("assets/data/anatomy_quiz.json"),
    Path("assets/data/pharmacology_quiz.json"),
    Path("assets/data/nursing_quizzes.json"),
]

AGE_TEMPLATES = [
    "A {age}-year-old {gender} with {condition} in the {setting}.",
    "A {age}-year-old {gender} admitted for {condition} to the {setting}.",
    "A {age}-year-old {gender} presenting to the {setting} with {condition}.",
]

TOPIC_CONDITIONS = {
    "anatomy": ["acute knee injury after pivoting during sports", "shoulder pain after a fall", "elbow pain following a lifting injury"],
    "pharmacology": ["newly diagnosed hypertension", "heart failure with fluid overload", "type 2 diabetes with elevated A1c", "severe bacterial infection requiring antibiotics"],
    "mental": ["major depressive episode with suicidal ideation", "acute mania with agitation", "panic attacks and chest tightness"],
    "pediatrics": ["fever and cough in a 2-year-old", "vomiting and diarrhea for 24 hours in an infant", "lethargy after possible ingestion"],
    "maternal": ["primigravida in active labor", "postpartum hemorrhage on day 1 after vaginal delivery", "pregnant client at 39 weeks with decreased fetal movement"],
    "fundamentals": ["postoperative day 1 after abdominal surgery", "immobile client with pressure injury risk", "client with confusion and new-onset urinary incontinence"],
}


def looks_like_scenario(text: str) -> bool:
    if not text:
        return False
    # common signals of scenario: 'year-old', 'admitted', 'presenting', 'in the', 'with', 'post-op'
    if re.search(r"\b\d{1,2}-year-old\b", text):
        return True
    if any(kw in text.lower() for kw in ["admitted", "presenting", "post-op", "postoperative", "in the emergency", "in the icu", "in the ed", "neonate", "infant", "toddler"]):
        return True
    return False


def make_case_sentence(topic_key: str) -> str:
    age = random.choice(range(1, 90))
    gender = random.choice(["man", "woman", "adult", "patient"])
    setting = random.choice(["emergency department", "medical unit", "outpatient clinic", "surgical ward", "pediatric unit"])
    conditions = TOPIC_CONDITIONS.get(topic_key, TOPIC_CONDITIONS.get("fundamentals"))
    condition = random.choice(conditions)
    template = random.choice(AGE_TEMPLATES)
    return template.format(age=age, gender=gender, condition=condition, setting=setting)


def choose_topic_key_from_path(path: Path) -> str:
    name = path.stem.lower()
    if "anatom" in name:
        return "anatomy"
    if "pharm" in name:
        return "pharmacology"
    if "maternal" in name or "birth" in name:
        return "maternal"
    if "pedi" in name:
        return "pediatrics"
    if "mental" in name or "psych" in name:
        return "mental"
    return "fundamentals"


def process_file(path: Path) -> None:
    if not path.exists():
        print(f"Missing: {path}")
        return
    data = json.loads(path.read_text(encoding="utf-8"))
    modified = False

    # support both formats: top-level 'quizzes' or 'topics' with quizzes
    quizzes_list = []
    if isinstance(data.get("quizzes"), list):
        quizzes_list = data["quizzes"]
    elif isinstance(data.get("topics"), list):
        for t in data["topics"]:
            quizzes_list.extend(t.get("quizzes", []))

    topic_key = choose_topic_key_from_path(path)

    for quiz in quizzes_list:
        for q in quiz.get("questions", []):
            text = q.get("text", "")
            if looks_like_scenario(text):
                continue
            # create a case sentence and prepend it to the existing question stem
            case_sent = make_case_sentence(topic_key)
            new_text = f"{case_sent} {text.strip()}"
            q["text"] = new_text
            # update variants to include same new text
            if "variants" in q:
                q["variants"] = [new_text]
            modified = True

    if modified:
        path.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")
        print(f"Updated scenarios in: {path}")
    else:
        print(f"No scenario updates needed: {path}")


def main():
    random.seed(1)
    for p in FILES:
        process_file(p)


if __name__ == "__main__":
    main()
