"""Generate board-style prompts with Saunders-referenced professional stems."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
from pathlib import Path
from typing import Iterable, List, Tuple

RULE = Tuple[re.Pattern[str], List[str]]

SCENARIO_RULES: List[RULE] = [
    (
        re.compile(r"(blood pressure|hypertension|angiotensin|arterial|hypotension)", re.IGNORECASE),
        [
            "Hypertension follow-up zeroes in on medication safety",
            "BP med check flags cough, potassium, and dizziness cues",
            "Cardiovascular round reminds nurses to trend hypotension warnings",
        ],
    ),
    (
        re.compile(r"(myocardial|contractility|tachycardia|telemetry|angina|beta blocker)", re.IGNORECASE),
        [
            "Telemetry briefing concentrates on rhythm control",
            "Cardiac safety scan keeps rate and contractility limits in view",
            "Step-down huddle pairs beta-blocker timing with symptom tracking",
        ],
    ),
    (
        re.compile(r"(edema|renal|kidney|potassium|creatinine|diuretic|nephro)", re.IGNORECASE),
        [
            "Renal rounds highlight potassium and creatinine trends",
            "Diuretic check focuses on volume status and cramps",
            "Kidney consult keeps electrolyte sparing strategies in scope",
        ],
    ),
    (
        re.compile(r"(insulin|glucose|diabetes|hypoglycemia)", re.IGNORECASE),
        [
            "Endocrine clinic visit stresses glucose timing",
            "Diabetes coaching links meals with pharmacology cues",
            "Glycemic review focuses on hypoglycemia readiness",
        ],
    ),
    (
        re.compile(r"(thyroid|levothyroxine|hyperthyroid|hypothyroid)", re.IGNORECASE),
        [
            "Thyroid check-in covers dosing consistency",
            "Hormone replacement briefing emphasizes pulse and heat intolerance",
            "Endocrine consult links postpartum fatigue with lab follow-up",
        ],
    ),
    (
        re.compile(r"(anticoag|warfarin|heparin|clot|throm|platelet|bleed)", re.IGNORECASE),
        [
            "Anticoagulation huddle keeps bleeding precautions front and center",
            "Coagulation review stresses INR or aPTT targets",
            "Thrombosis prevention note pairs labs with safety teaching",
        ],
    ),
    (
        re.compile(r"(benzodiazepine|anxiety|mental|psych|serotonin|lithium|mood)", re.IGNORECASE),
        [
            "Behavioral-health coaching underscores coping plans",
            "Psych safety pause reinforces fall and withdrawal watch",
            "Therapeutic communication reminder spotlights clear limits",
        ],
    ),
    (
        re.compile(r"(opioid|analgesic|morphine|naloxone|pain|antiemetic|chemotherapy)", re.IGNORECASE),
        [
            "Pain service review balances relief with respiratory checks",
            "Chemo pre-brief keeps rescue meds ready",
            "Opioid safety moment covers sedation and reversal prep",
        ],
    ),
    (
        re.compile(r"(infection|antibiotic|vancomycin|gentamicin|vre)", re.IGNORECASE),
        [
            "Infection-control tracing reaffirms culture and isolation timing",
            "Sepsis drill reminder pairs vitals with early antibiotics",
            "Antimicrobial stewardship note checks troughs and organ function",
        ],
    ),
    (
        re.compile(r"(magnesium|sodium|electrolyte|hyperkalemia|hyponatremia)", re.IGNORECASE),
        [
            "Electrolyte rounds focus on neuromuscular signs",
            "Critical care briefing tracks replacement protocols",
            "Lab safety review highlights rhythm and seizure watch",
        ],
    ),
    (
        re.compile(r"(ligament|gluteus|biceps|deltoid|hamstring|piriformis|diaphragm|meniscus|tendon|muscle|rotator)", re.IGNORECASE),
        [
            "Mobility huddle reinforces joint protection",
            "Ortho coaching revisits muscle origin and function",
            "Rehab briefing covers gait and strengthening cues",
        ],
    ),
]

DEFAULT_CONTENT_PREFIXES = [
    "Shift huddle spotlights the immediate cue",
    "Clinical coach recaps the safety trigger",
    "Bedside review keeps the priority outcome in scope",
    "Professor note highlights what to watch first",
    "Unit briefing links assessment to the next step",
    "Practice exam vignette echoes this teaching point",
]

DIFFICULTY_PREFIXES = {
    "easy": [
        "steady med-surg follow-up",
        "fundamental safety recap",
        "introductory skill check",
        "calm coaching scenario",
    ],
    "medium": [
        "telemetry unit briefing",
        "progressive-care huddle",
        "step-down decision point",
        "mixed-acuity shift focus",
    ],
    "hard": [
        "high-acuity change-in-condition",
        "rapid response review",
        "complex comorbidity consult",
        "time-sensitive escalation",
    ],
    "rnworthy": [
        "board-style escalation drill",
        "critical leadership consult",
        "senior practicum scenario",
        "expert-level prioritization cue",
    ],
}

REFERENCE_PHRASES = [
    "trend the most unstable vital sign first",
    "link the assessment to a direct nursing action",
    "keep one rescue plan ready before giving meds",
    "match the symptom to the most likely complication",
    "scan labs before titrating therapy",
    "center teaching on the clearest safety phrase",
    "use focused language so the patient trusts the plan",
    "root every answer in the primary physiologic change",
    "protect airway, breathing, and circulation before anything routine",
    "pair every intervention with the simple why",
]

QUESTION_OPENERS = [
    "Which nursing action",
    "What intervention",
    "Which strategy",
    "How should the nurse respond to",
    "Which clinical choice",
    "What assessment focus",
    "Which immediate action",
    "What is the priority",
    "Which measure best",
    "What would the nurse do first",
    "Which sign should prompt",
]

QUESTION_START_PATTERN = re.compile(
    r"(which|what|when|why|how|select|identify|name|state)\b",
    re.IGNORECASE,
)


def stable_choice(options: List[str], key: str) -> str:
    digest = hashlib.sha1(key.encode('utf-8')).digest()
    idx = int.from_bytes(digest[:4], 'big') % len(options)
    return options[idx]


def infer_difficulty(question_id: str) -> str:
    suffix = question_id.lower()
    for level in ("easy", "medium", "hard", "rnworthy"):
        if suffix.endswith(f"-{level}") or f"-{level}-" in suffix:
            return level
    return "medium"


def pick_content_prefix(text: str, key: str) -> str:
    lower = text.lower()
    for pattern, options in SCENARIO_RULES:
        if pattern.search(lower):
            return stable_choice(options, key)
    return stable_choice(DEFAULT_CONTENT_PREFIXES, key)


def ensure_sentence(text: str) -> str:
    cleaned = text.strip()
    if not cleaned:
        return ""
    if cleaned[-1] in ".!?":
        return cleaned
    return f"{cleaned}."


def sentence_case(text: str) -> str:
    stripped = text.strip()
    if not stripped:
        return stripped
    return stripped[0].upper() + stripped[1:]


def build_case_tag(question_id: str) -> str:
    digest = hashlib.sha1(question_id.encode('utf-8')).digest()
    number = 100 + (int.from_bytes(digest[:2], 'big') % 900)
    return f"Case {number}"


def extract_core_prompt(text: str) -> str:
    cleaned = re.sub(r"\s+", " ", text).strip()
    if not cleaned:
        return ""
    q_idx = cleaned.rfind('?')
    if q_idx != -1:
        start_period = cleaned.rfind('.', 0, q_idx)
        start_colon = cleaned.rfind(':', 0, q_idx)
        start = max(start_period, start_colon)
        snippet = cleaned[start + 1 : q_idx + 1].strip()
        if len(snippet.split()) >= 5:
            return snippet
    match = QUESTION_START_PATTERN.search(cleaned)
    if match:
        return cleaned[match.start():].strip()
    return cleaned


def format_question_body(text: str, question_id: str) -> str:
    stripped = re.sub(r"\s+", " ", text.strip())
    if not stripped:
        return stripped
    match = re.match(r"^(which|what|when|why|how)\b(.*)", stripped, re.IGNORECASE)
    if match:
        rest = match.group(2).lstrip()
        opener = stable_choice(QUESTION_OPENERS, f"{question_id}:open")
        stripped = f"{opener} {rest}".strip()
    stripped = stripped.rstrip(" ")
    stripped = stripped.rstrip(". ")
    if not stripped.endswith('?'):
        stripped = f"{stripped}?"
    if stripped and not stripped[0].isupper():
        stripped = stripped[0].upper() + stripped[1:]
    return stripped


VARIANTS_PER_QUESTION = 10


def enhance_prompt(question: dict, variant_index: int = 0) -> str:
    original = question.get('text', '')
    question_id = question.get('id', original)
    difficulty = infer_difficulty(question_id)
    diff_options = DIFFICULTY_PREFIXES.get(difficulty, DIFFICULTY_PREFIXES['medium'])
    # Build a multi-fragment context for greater unique combinations per question id
    key_suffix = f":v{variant_index}"
    base_prompt = extract_core_prompt(original)
    prompt_source = base_prompt if base_prompt else original
    diff_prefix = sentence_case(stable_choice(diff_options, f"{question_id}:diff{key_suffix}"))
    content_prefix = pick_content_prefix(prompt_source, f"{question_id}:content{key_suffix}")
    reference = ensure_sentence(
        f"Saunders cue: {stable_choice(REFERENCE_PHRASES, f'{question_id}:ref{key_suffix}')}."
    )
    case_label = ensure_sentence(f"{build_case_tag(f'{question_id}{key_suffix}')}.")

    scenario_line = content_prefix or diff_prefix
    if scenario_line:
        scenario_line = ensure_sentence(sentence_case(scenario_line))

    fragments = [case_label]
    if scenario_line:
        fragments.append(scenario_line)
    fragments.append(reference)

    context = " ".join(fr for fr in fragments if fr)
    body_source = prompt_source
    body = format_question_body(body_source, question_id)
    if not body:
        return original
    # final composed stem
    return f"{context} {body}"


def iter_questions(payload: dict) -> Iterable[dict]:
    if 'topics' in payload:
        for topic in payload.get('topics', []):
            for quiz in topic.get('quizzes', []):
                for question in quiz.get('questions', []):
                    yield question
    elif 'quizzes' in payload:
        for quiz in payload.get('quizzes', []):
            for question in quiz.get('questions', []):
                yield question
    else:
        raise ValueError('Unsupported quiz JSON structure; expected topics or quizzes key.')


def process_file(path: Path) -> int:
    data = json.loads(path.read_text(encoding='utf-8'))
    updates = 0
    for question in iter_questions(data):
        # generate multiple deterministic variants for each question
        variants = []
        for i in range(VARIANTS_PER_QUESTION):
            variants.append(enhance_prompt(question, i))
        # ensure uniqueness
        unique_vars = []
        seen = set()
        for v in variants:
            if v not in seen:
                unique_vars.append(v)
                seen.add(v)
        if unique_vars:
            # set the first variant as the main text for backward compatibility
            if question.get('text') != unique_vars[0]:
                updates += 1
            question['variants'] = unique_vars
            question['text'] = unique_vars[0]
    if updates:
        path.write_text(json.dumps(data, indent=2) + '\n', encoding='utf-8')
    return updates


def main() -> None:
    parser = argparse.ArgumentParser(description='Apply Saunders-referenced clinical context to quiz questions.')
    parser.add_argument('files', nargs='*', help='Quiz JSON files to update. Defaults to core assets.')
    args = parser.parse_args()

    if args.files:
        targets = [Path(p) for p in args.files]
    else:
        targets = [
            Path('assets/data/anatomy_quiz.json'),
            Path('assets/data/nursing_quizzes.json'),
            Path('assets/data/pharmacology_quiz.json'),
        ]

    total_updates = 0
    for target in targets:
        if not target.exists():
            print(f"Skipping missing file: {target}")
            continue
        updated = process_file(target)
        total_updates += updated
        print(f"Updated {updated:>3} questions in {target}")

    if total_updates == 0:
        print('No question prompts required updates.')


if __name__ == '__main__':
    main()
