#!/usr/bin/env python3
"""Validate recently added NCLEX-imported questions in topic files.

Heuristics to find 'new' questions:
- question text contains keywords like 'NCLEX', 'case', 'case study', 'clinical debrief', 'simulation', 'huddle', 'review'

For each candidate question the validation checks:
- options exist and length >= 2
- correctIndex present and in-range
- whether the explanation contains the correct option text (substring check) — if not, flag as suspected mismatch

The script prints a summary and writes a report file `tools/validation_report.json`.
"""
import json
from pathlib import Path
from collections import defaultdict

ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = ROOT / "assets" / "data"

TARGET_FILES = [
    DATA_DIR / "anatomy_quiz.json",
    DATA_DIR / "pharmacology_quiz.json",
    DATA_DIR / "nursing_quizzes.json",
]

KEY_PHRASES = ["nclex", "case", "case study", "clinical debrief", "simulation", "huddle", "review"]

def load_json(path):
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)

def find_candidates(data):
    candidates = []
    quizzes = data.get('quizzes') or []
    for qi, quiz in enumerate(quizzes):
        for qj, q in enumerate(quiz.get('questions', [])):
            text = (q.get('text') or '').lower()
            if any(kw in text for kw in KEY_PHRASES):
                candidates.append((qi, qj, q))
    return candidates

def normalize_options(q):
    # map variants/choices -> options
    if 'options' in q and isinstance(q['options'], list):
        return q['options']
    if 'variants' in q and isinstance(q['variants'], list):
        return q['variants']
    if 'choices' in q and isinstance(q['choices'], list):
        return q['choices']
    return []

def validate_question(q):
    options = normalize_options(q)
    problems = []
    if not isinstance(options, list) or len(options) < 2:
        problems.append('missing-or-short-options')
    ci = q.get('correctIndex')
    if ci is None:
        problems.append('missing-correctIndex')
    else:
        try:
            ci_i = int(ci)
            if ci_i < 0 or ci_i >= len(options):
                problems.append('correctIndex-out-of-range')
        except Exception:
            problems.append('invalid-correctIndex')

    # check explanation contains correct option text
    if 'explanation' in q and isinstance(q.get('explanation'), str) and ci is not None and isinstance(options, list) and 0 <= int(ci) < len(options):
        correct_text = options[int(ci)]
        expl = q.get('explanation') or ''
        if correct_text.strip() and correct_text.strip().lower() not in expl.lower():
            problems.append('explanation-mismatch-suspected')

    return problems

def main():
    report = { 'files': {} }
    total_candidates = 0
    total_problems = 0

    for path in TARGET_FILES:
        if not path.exists():
            print(f"Warning: {path} not found, skipping")
            continue
        data = load_json(path)
        candidates = find_candidates(data)
        total_candidates += len(candidates)
        file_report = {
            'path': str(path),
            'total_candidates': len(candidates),
            'problems': []
        }
        for qi, qj, q in candidates:
            probs = validate_question(q)
            if probs:
                total_problems += 1
                item = {
                    'quiz_index': qi,
                    'question_index': qj,
                    'text_snippet': (q.get('text') or '')[:200],
                    'problems': probs,
                    'options': normalize_options(q)[:6],
                    'correctIndex': q.get('correctIndex'),
                    'explanation_snippet': ((q.get('explanation') or '')[:200])
                }
                file_report['problems'].append(item)

        report['files'][str(path.name)] = file_report

    report['summary'] = {
        'total_candidates': total_candidates,
        'total_problems': total_problems
    }

    outpath = Path(__file__).resolve().parent / 'validation_report.json'
    with open(outpath, 'w', encoding='utf-8') as f:
        json.dump(report, f, ensure_ascii=False, indent=2)

    print(f"Validation complete. {total_candidates} candidate questions scanned, {total_problems} with potential problems.")
    print(f"Report written to {outpath}")

    # Print a short sample of problems (up to 10 across files)
    printed = 0
    for fname, file_report in report['files'].items():
        if not file_report['problems']:
            continue
        print(f"\nFile: {fname} - {len(file_report['problems'])} problematic items")
        for p in file_report['problems'][:5]:
            print(f" - Q[{p['quiz_index']}][{p['question_index']}]: {p['text_snippet']}")
            print(f"   Problems: {p['problems']}")
            print(f"   CorrectIndex: {p['correctIndex']}, Options: {p['options']}")
            printed += 1
            if printed >= 10:
                break
        if printed >= 10:
            break

if __name__ == '__main__':
    main()
