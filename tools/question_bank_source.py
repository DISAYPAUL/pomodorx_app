import json
from datetime import datetime
from pathlib import Path
from typing import List, Tuple

BASE_DIR = Path(__file__).resolve().parents[1]
OUTPUT_PATH = BASE_DIR / "assets" / "data" / "nursing_quizzes.json"
CREATED_AT = "2025-01-10T00:00:00.000Z"
ICON_PATH = "assets/icons/logo.png"


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


def topic(
  topic_id: str,
  name: str,
  description: str,
  icon: str,
  slug: str,
  created: str = CREATED_AT,
) -> dict:
  return {
      "id": topic_id,
      "name": name,
      "description": description,
      "icon": icon,
      "slug": slug,
      "createdAt": created,
  }


def quiz(
  quiz_id: str,
  title: str,
  topic_id: str,
  difficulty: str,
  questions: List[dict],
) -> dict:
  duration = {
      "easy": 12,
      "medium": 18,
      "hard": 22,
      "rnworthy": 25,
  }.get(difficulty, 15)
  return {
      "id": quiz_id,
      "title": title,
      "durationMinutes": duration,
    "createdAt": CREATED_AT,
      "isOffline": True,
      "questions": questions,
  }


def build_topics() -> List[dict]:
  return [
    build_pharmacology(),
    build_med_surg(),
    build_pediatrics(),
    build_maternal_newborn(),
    build_mental_health(),
    build_fundamentals(),
  ]


def build_pharmacology() -> dict:
  topic_meta = topic(
      "topic-pharmacology",
      "Pharmacology",
      "Medication safety, adverse effects, and priority monitoring cues from Saunders",
      ICON_PATH,
      "pharmacology",
  )
  cat = "pharm"

  def make_quiz(diff: str, label: str, questions: List[dict]) -> dict:
    return quiz(
        f"quiz-{cat}-{diff}",
        f"Pharmacology • {label}",
        topic_meta["id"],
        diff,
        questions,
    )

  easy_questions: List[dict] = [
    q(
      cat,
      "easy",
      "ace-cough",
      "A client has just started captopril for newly diagnosed hypertension. Which finding is most typical of ACE inhibitor therapy and should be reported for documentation?",
      [
        "Persistent dry cough with lightheadedness",
        "Severe constipation on day 1",
        "Metallic taste with every meal",
        "Polyuria with straw-colored urine",
      ],
      0,
      "Saunders Comprehensive Review (11e), p.67 highlights cough, hypotension, and hyperkalemia as hallmark ACE-inhibitor adverse effects that the nurse must monitor early.",
    ),
    q(
      cat,
      "easy",
      "beta-additive",
      "A client uses ophthalmic timolol drops and also takes metoprolol by mouth. What is the nurse's priority assessment for additive beta-blockade?",
      [
        "Trend apical pulse and blood pressure for bradycardia",
        "Compare daily weights for fluid retention",
        "Finger-stick glucose before each meal",
        "Assess for dilated pupils before drop administration",
      ],
      0,
      "Saunders, p.65 notes that ophthalmic beta blockers can potentiate systemic beta blockers, so vigilance for bradycardia and hypotension is required.",
    ),
    q(
      cat,
      "easy",
      "digoxin-early",
      "Which assessment is an early sign of digoxin toxicity that warrants holding the next dose?",
      [
        "New-onset anorexia and nausea",
        "Yellow halos when reading",
        "Apical pulse of 48 beats/min",
        "Occipital headache rated 4/10",
      ],
      0,
      "Saunders, p.53 describes anorexia as one of the earliest manifestations of digoxin toxicity before visual or cardiac changes appear.",
    ),
    q(
      cat,
      "easy",
      "warfarin-pt",
      "Which laboratory value best reflects therapeutic response to warfarin sodium?",
      [
        "Prothrombin time/INR",
        "Serum creatinine",
        "Activated partial thromboplastin time",
        "Erythrocyte sedimentation rate",
      ],
      0,
      "Saunders, p.312 explains that PT/INR is the monitoring parameter for warfarin effectiveness, unlike aPTT which guides heparin dosing.",
    ),
    q(
      cat,
      "easy",
      "glargine-mix",
      "Which insulin administration instruction is specific to insulin glargine?",
      [
        "Do not mix glargine in the same syringe with other insulins",
        "Always draw up glargine before NPH",
        "Hold glargine if the client skips a meal",
        "Massage the site for faster absorption",
      ],
      0,
      "Saunders, p.1454 reminds nurses that glargine is incompatible with other insulin preparations and must be administered separately.",
    ),
    q(
      cat,
      "easy",
      "levothyroxine-admin",
      "A client begins levothyroxine therapy. Which teaching point is correct?",
      [
        "Take it each morning on an empty stomach",
        "Take with a high-fiber breakfast",
        "Skip the dose if resting heart rate exceeds 60",
        "Double the dose if one is missed",
      ],
      0,
      "Saunders, p.459 emphasizes administering levothyroxine on an empty stomach at the same time each morning for consistent absorption.",
    ),
    q(
      cat,
      "easy",
      "naloxone-keep",
      "Why should naloxone be readily available when titrating IV opioid analgesics?",
      [
        "It rapidly reverses opioid-induced respiratory depression",
        "It prolongs the analgesic effect",
        "It prevents opioid-induced constipation",
        "It treats opioid-related itching",
      ],
      0,
      "Saunders, p.309 directs nurses to keep an opioid antagonist such as naloxone at the bedside whenever IV opioids are administered.",
    ),
    q(
      cat,
      "easy",
      "acetylcysteine",
      "Which medication is the antidote for acute acetaminophen overdose?",
      [
        "Acetylcysteine",
        "Protamine sulfate",
        "Vitamin K",
        "Flumazenil",
      ],
      0,
      "According to Saunders, p.307, acetylcysteine is the specific antidote that prevents hepatotoxicity after acetaminophen overdose.",
    ),
    q(
      cat,
      "easy",
      "morphine-abc",
      "A client receiving IV morphine sulfate for cancer pain reports relief. Which nursing action remains the priority?",
      [
        "Monitor respiratory rate and depth",
        "Offer warm liquids for constipation",
        "Assess for urinary retention",
        "Provide passive range-of-motion",
      ],
      0,
      "Saunders, p.96 applies the ABCs framework—airway and breathing take priority because morphine can depress respirations.",
    ),
    q(
      cat,
      "easy",
      "ondansetron-class",
      "Ondansetron given before chemotherapy belongs to which antiemetic class?",
      [
        "Serotonin (5-HT3) receptor antagonist",
        "Anticholinergic antispasmodic",
        "Cannabinoid agonist",
        "Histamine H1 blocker",
      ],
      0,
      "Saunders, Box 49-5 (p.1554) lists ondansetron among the serotonin antagonist antiemetics used for highly emetogenic regimens.",
    ),
  ]

  medium_questions: List[dict] = [
      q(
        cat,
        "medium",
        "lithium-sodium",
        "A client with bipolar disorder takes lithium and now has hyponatremia after days of vomiting. Which teaching point is most important before the next dose?",
        [
          "Maintain prescribed sodium intake and report ongoing GI losses",
          "Restrict sodium to avoid fluid retention",
          "Add over-the-counter diuretics to remove fluid",
          "Skip lithium until weight returns to baseline",
        ],
        0,
        "Saunders, p.248 warns that hyponatremia diminishes lithium excretion and increases toxicity risk, so adequate sodium and hydration are essential.",
      ),
      q(
        cat,
        "medium",
        "aminoglycoside-loop",
        "Which concurrent medication increases the risk for nephrotoxicity and ototoxicity when a client receives IV gentamicin?",
        [
          "Furosemide",
          "Pantoprazole",
          "Sucralfate",
          "Diltiazem",
        ],
        0,
        "Saunders, p.1635 states that aminoglycosides combined with loop diuretics heighten ototoxic and nephrotoxic effects, requiring close monitoring.",
      ),
      q(
        cat,
        "medium",
        "vre-risk",
        "Which hospitalized client is at greatest risk for developing vancomycin-resistant enterococci (VRE)?",
        [
          "The client receiving multiple antibiotics for several weeks",
          "A postoperative client using an incentive spirometer",
          "The client admitted for elective cataract repair",
          "A client taking short-term oral prednisone",
        ],
        0,
        "Saunders, p.421 highlights that prolonged, multi-drug antibiotic therapy creates the highest risk profile for VRE colonization.",
      ),
      q(
        cat,
        "medium",
        "warfarin-high-pt",
        "A client on maintenance warfarin has a PT of 35 seconds. What action should the nurse anticipate?",
        [
          "Hold the next warfarin dose and notify the provider",
          "Administer the dose as scheduled",
          "Add a heparin bolus",
          "Give vitamin K immediately",
        ],
        0,
        "Saunders, p.323 describes holding warfarin when PT/INR rises above the therapeutic window while awaiting further prescriptions.",
      ),
      q(
        cat,
        "medium",
        "furosemide-potassium",
        "A client receives captopril, furosemide, metoprolol, and digoxin for heart failure. Which laboratory value is most important to review before administering the next doses?",
        [
          "Serum potassium",
          "Serum calcium",
          "Blood urea nitrogen",
          "Serum glucose",
        ],
        0,
        "Saunders, p.65 underscores monitoring potassium because loop diuretics predispose to hypokalemia, which increases digoxin toxicity risk.",
      ),
      q(
        cat,
        "medium",
        "heparin-aptt",
        "A continuous heparin infusion is running for a newly diagnosed deep vein thrombosis. The aPTT is 65 seconds. How should the nurse interpret this result?",
        [
          "Therapeutic—continue the infusion per protocol",
          "Subtherapeutic—bolus the client",
          "Critical—stop the infusion immediately",
          "Normal—switch to low-molecular-weight heparin",
        ],
        0,
        "Saunders, clinical vignette on p.324 shows that an aPTT about 1.5 to 2 times control (≈60–80 seconds) indicates therapeutic anticoagulation.",
      ),
      q(
        cat,
        "medium",
        "clopidogrel-bleeding",
        "Which client statement signals a serious adverse effect of clopidogrel therapy?",
        [
          "\"My stools look black and tarry today.\"",
          "\"I occasionally bruise on my arms.\"",
          "\"I take the pill with dinner.\"",
          "\"My gums feel dry in the morning.\"",
        ],
        0,
        "Saunders, p.493 reminds nurses that antiplatelet agents like clopidogrel heighten bleeding risk; tarry stools indicate possible GI hemorrhage.",
      ),
      q(
        cat,
        "medium",
        "magnesium-infusion",
        "A critically ill client with a magnesium level of 0.8 mg/dL is prescribed IV magnesium sulfate. Which outcome reflects a therapeutic response?",
        [
          "Tremors diminish as the level normalizes",
          "Urine output drops below 30 mL/hr",
          "Deep tendon reflexes become absent",
          "Blood pressure spikes sharply",
        ],
        0,
        "Saunders, p.252 explains that IV magnesium sulfate is reserved for severe hypomagnesemia to alleviate neuromuscular irritability, not to cause hypotonia.",
      ),
      q(
        cat,
        "medium",
        "diazepam-sedation",
        "The nurse starts diazepam for muscle spasms. Which adverse effect requires fall precautions during early dosing?",
        [
          "Sedation and ataxia",
          "Dry cough",
          "Diarrhea",
          "Photosensitivity",
        ],
        0,
        "Saunders, p.2071 lists sedation, dizziness, and ataxia as common benzodiazepine effects that mandate safety measures.",
      ),
      q(
        cat,
        "medium",
        "heparinized-syringe",
        "While obtaining an arterial blood gas on a ventilated client, why does the nurse use a heparinized syringe?",
        [
          "To prevent clotting of the blood sample",
          "To buffer the sample pH",
          "To improve oxygenation accuracy",
          "To reduce patient discomfort",
        ],
        0,
        "Saunders, p.280 describes preparing a heparinized syringe for ABG collection to prevent coagulation within the sample.",
      ),
  ]

  hard_questions: List[dict] = [
      q(
        cat,
        "hard",
        "ace-first-dose",
        "A heart-failure client receives the first dose of captopril at bedtime and reports dizziness when standing. What is the nurse's best initial response?",
        [
          "Assist the client to lie supine and recheck blood pressure",
          "Administer 250 mL rapid IV bolus",
          "Hold the next morning dose permanently",
          "Tell the client to continue ambulating to build tolerance",
        ],
        0,
        "Saunders, p.67 notes ACE inhibitors can cause first-dose syncope; safety measures include placing the client supine and reassessing hemodynamics before notifying the provider.",
      ),
      q(
        cat,
        "hard",
        "antacid-digoxin",
        "A hospitalized client takes over-the-counter hydroxyaluminum sodium carbonate for dyspepsia while on digoxin. What action should the nurse take?",
        [
          "Notify the provider because the antacid can elevate digoxin levels",
          "Allow the antacid if taken 1 hour after digoxin",
          "Switch the client to calcium carbonate",
          "Encourage additional doses to control nausea",
        ],
        0,
        "Saunders, p.65 explains that aluminum-containing antacids increase digoxin absorption and warrant provider notification for safer alternatives.",
      ),
      q(
        cat,
        "hard",
        "beta-hypoglycemia",
        "A client with type 2 diabetes is prescribed oral metoprolol after admission. Which education point is most critical?",
        [
          "\"This beta blocker may mask tachycardia during hypoglycemia, so monitor glucose more often.\"",
          "\"Take the medication only if fasting glucose exceeds 140 mg/dL.\"",
          "\"Avoid combining the drug with ACE inhibitors.\"",
          "\"Expect tremors whenever the dose is metabolized.\"",
        ],
        0,
        "Saunders, p.65 alerts the nurse that metoprolol can blunt adrenergic hypoglycemia cues, so intensified monitoring and education are vital.",
      ),
      q(
        cat,
        "hard",
        "ocp-contra",
        "Which element from a client's history makes combined oral contraceptives unsafe?",
        [
          "Previous thromboembolic stroke",
          "History of seasonal allergies",
          "Prior appendectomy",
          "Treated hypothyroidism",
        ],
        0,
        "Saunders, p.60 lists cerebrovascular disease such as prior stroke as an absolute contraindication to estrogen-containing contraceptives.",
      ),
      q(
        cat,
        "hard",
        "insulin-scar",
        "A client rotates insulin sites between an old abdominal scar and the thigh. What should the nurse teach?",
        [
          "Avoid injecting into scar tissue because absorption is unpredictable",
          "Massage the scar after injection to improve uptake",
          "Exercise immediately after scar injections to prevent hypoglycemia",
          "Use only the scar area for bedtime doses",
        ],
        0,
        "Saunders, p.1454 explains that scar tissue delays insulin absorption and should be avoided to maintain glycemic control.",
      ),
      q(
        cat,
        "hard",
        "glargine-activity",
        "Which teaching helps a client prevent hypoglycemia when administering insulin glargine?",
        [
          "Avoid applying heat or vigorous exercise at the injection site",
          "Mix glargine with lispro for bedtime coverage",
          "Inject into the same arm daily for consistency",
          "Massage the site to speed onset",
        ],
        0,
        "Saunders, p.1454 describes that local heat or muscular activity accelerates absorption and can precipitate hypoglycemia with basal insulins like glargine.",
      ),
      q(
        cat,
        "hard",
        "digoxin-visual",
        "A client reports yellow halos after several days of anorexia while taking digoxin. What is the nurse's priority?",
        [
          "Hold the dose and obtain a digoxin level",
          "Administer an antiemetic",
          "Give a potassium supplement",
          "Reassure that the symptom is transient",
        ],
        0,
        "Saunders, p.53 links GI upset followed by visual disturbances to progressive digoxin toxicity; withholding the drug and checking the serum level is critical.",
      ),
      q(
        cat,
        "hard",
        "clopidogrel-surgery",
        "A client on long-term clopidogrel is scheduled for elective surgery in five days. Which action is appropriate?",
        [
          "Collaborate with the provider about discontinuing the drug to reduce bleeding",
          "Continue therapy to prevent perioperative thrombosis",
          "Double the dose the day before surgery",
          "Switch to warfarin immediately",
        ],
        0,
        "Saunders, p.493 emphasizes clopidogrel's platelet inhibition and the need to stop it before procedures to lower bleeding risk.",
      ),
  ]

  rn_questions: List[dict] = [
      q(
        cat,
        "rnworthy",
        "polypharmacy-falls",
        "Victoria is receiving captopril, furosemide, metoprolol, and digoxin along with ophthalmic betaxolol. Which collaborative goal should the nurse prioritize before discharge?",
        [
          "Implement a fall-prevention plan that addresses orthostasis and visual blurring",
          "Eliminate all antihypertensives to prevent hypotension",
          "Discontinue glaucoma drops",
          "Switch to herbal supplements",
        ],
        0,
        "Saunders, p.65 emphasizes aggregated fall risk from polypharmacy (ACE inhibitor, loop diuretic, beta blockers, digoxin) plus visual changes from glaucoma therapy, necessitating coordinated fall-prevention.",
      ),
      q(
        cat,
        "rnworthy",
        "ace-hyperkalemia",
        "A client on lisinopril develops serum potassium of 5.8 mEq/L and peaked T waves. Which provider discussion is the highest priority?",
        [
          "Hold ACE inhibitor doses and evaluate for hyperkalemia management",
          "Decrease oral fluids",
          "Add potassium supplements",
          "Increase dietary bananas",
        ],
        0,
        "Saunders, p.67 cites hyperkalemia as a critical ACE-inhibitor adverse effect; collaboration for immediate management and dose adjustment is required.",
      ),
      q(
        cat,
        "rnworthy",
        "naloxone-dispense",
        "State regulations now require dispensing naloxone with high-dose opioid infusions at home. Which action aligns with best practice?",
        [
          "Provide intranasal naloxone, reinforce its purpose, and document caregiver teaching",
          "Tell the client to pick up naloxone only if symptoms occur",
          "Withhold opioids until naloxone is unavailable",
          "Advise the client to use naloxone daily to prevent tolerance",
        ],
        0,
        "Saunders, p.309 recommends having naloxone readily available and educating support persons when managing potent opioids.",
      ),
      q(
        cat,
        "rnworthy",
        "lithium-crisis",
        "A client on lithium for bipolar disorder arrives with vomiting, tremors, and serum sodium of 128 mEq/L. Which prescription should the nurse question?",
        [
          "Continuing the same lithium dose without addressing sodium loss",
          "Obtaining a stat lithium level",
          "Initiating IV fluids",
          "Adding seizure precautions",
        ],
        0,
        "Saunders, p.248 links hyponatremia to reduced lithium clearance and toxicity; the dose should be withheld pending levels and fluid correction.",
      ),
      q(
        cat,
        "rnworthy",
        "metroprolol-diabetes",
        "Which individualized outcome best evaluates teaching for a diabetic client starting metoprolol?",
        [
          "Client accurately describes non-cardiac signs of hypoglycemia",
          "Client states beta blockers cure diabetes",
          "Client agrees to halve insulin doses",
          "Client will stop checking glucose when asymptomatic",
        ],
        0,
        "Saunders, p.65 highlights that beta blockers mask adrenergic hypoglycemia cues, so recognizing alternate signs (sweating, confusion) validates effective teaching.",
      ),
      q(
        cat,
        "rnworthy",
        "clopidogrel-procedure",
        "A client taking clopidogrel needs an urgent lumbar puncture. Which interprofessional step is most critical?",
        [
          "Clarify the bleeding risk window and potential need to delay the procedure",
          "Proceed without delay to avoid infection",
          "Double the clopidogrel dose to prevent thrombosis",
          "Switch the client to aspirin on the morning of the procedure",
        ],
        0,
        "Saunders, p.493 underscores coordinating invasive procedures around antiplatelet therapy due to hemorrhage risk.",
      ),
    ]

  return {
    "topic": topic_meta,
    "quizzes": [
      make_quiz("easy", "Easy", easy_questions),
      make_quiz("medium", "Medium", medium_questions),
      make_quiz("hard", "Hard", hard_questions),
      make_quiz("rnworthy", "RN Worthy", rn_questions),
    ],
  }


def build_med_surg() -> dict:
  topic_meta = topic(
    "topic-med-surg",
    "Medical-Surgical",
    "Systems-based adult health scenarios spanning cardiovascular, respiratory, neuro, and endocrine priorities",
    ICON_PATH,
    "medical-surgical",
  )

  def make_quiz(diff: str, label: str, questions: List[dict]) -> dict:
    return quiz(
        f"quiz-med-surg-{diff}",
        f"Medical-Surgical • {label}",
        topic_meta["id"],
        diff,
        questions,
    )

    easy_questions = [
      q(
        "med-surg",
        "easy",
        "vfib-defib",
        "Telemetry shows coarse ventricular fibrillation. What is the nurse's priority action?",
        [
          "Activate defibrillation immediately",
          "Administer nitroglycerin sublingually",
          "Start a dopamine infusion",
          "Notify the cardiologist after a full assessment",
        ],
        0,
        "Saunders, p.60 stresses immediate defibrillation for VF before any other interventions to restore an organized rhythm.",
      ),
      q(
        "med-surg",
        "easy",
        "burn-stop",
        "A child sustains a major flame burn. Which intervention comes first?",
        [
          "Stop the burning process and secure the airway",
          "Apply topical antibiotics",
          "Begin enteral feedings",
          "Remove all clothing once in the emergency room",
        ],
        0,
        "Saunders, p.894 (Priority Nursing Actions) lists stopping the burn and assessing airway patency as the first steps.",
      ),
      q(
        "med-surg",
        "easy",
        "appendicitis-perf",
        "Why is appendicitis treated promptly with surgery?",
        [
          "Perforation can rapidly lead to peritonitis and sepsis",
          "The appendix regenerates if not removed",
          "It always causes chronic diarrhea",
          "The pain resolves without intervention",
        ],
        0,
        "Saunders, p.974 explains that inflamed appendices may perforate within hours, triggering peritonitis and septic shock.",
      ),
      q(
        "med-surg",
        "easy",
        "ocp-embolism",
        "A client smokes and takes combined oral contraceptives. Which complication is she at higher risk for?",
        [
          "Pulmonary embolism",
          "Nephrotic syndrome",
          "Cholelithiasis",
          "Appendicitis",
        ],
        0,
        "Saunders, p.60 lists thromboembolic disorders including pulmonary embolism as key contraindications for estrogen therapy.",
      ),
      q(
        "med-surg",
        "easy",
        "diabetes-insipidus",
        "Which condition can cause massive water loss requiring IV fluid replacement?",
        [
          "Diabetes insipidus",
          "Hyperparathyroidism",
          "Peptic ulcer disease",
          "Gout",
        ],
        0,
        "Saunders, p.249 identifies diabetes insipidus as a cause of increased water loss that necessitates aggressive fluid management.",
      ),
    ]

  medium_questions: List[dict] = []
  medium_questions.extend(
          [
            q(
              "fundamentals",
              "medium",
              "sterile-technique",
              "Which action maintains a sterile field during a procedure?",
              [
                "Keep sterile objects above waist level and within view",
                "Turn your back on the field when gathering supplies",
                "Reach across the sterile field",
                "Allow sterile gloves to touch hair",
              ],
              0,
              "Saunders, p.87 reinforces maintaining visual contact and waist-level positioning to preserve sterility.",
            ),
            q(
              "fundamentals",
              "medium",
              "droplet-precautions",
              "Which PPE is required for droplet precautions?",
              [
                "Wear a mask when within 3 feet of the client",
                "Use only gloves",
                "Negative-pressure room",
                "Powered air-purifying respirator",
              ],
              0,
              "Saunders, p.423 specifies surgical masks for droplet illnesses like meningitis or scarlet fever.",
            ),
            q(
              "fundamentals",
              "medium",
              "restraint-rights",
              "Which statement about restraints protects client rights?",
              [
                "Clients have the right not to be subject to unnecessary restraints",
                "Restraints may be applied for staff convenience",
                "Informed consent isn't needed",
                "Restraints can replace observation",
              ],
              0,
              "Saunders, p.174 lists freedom from unnecessary restraints among fundamental patient rights.",
            ),
            q(
              "fundamentals",
              "medium",
              "delegation-priority",
              "Which task is appropriate to delegate to an experienced unlicensed assistive personnel (UAP)?",
              [
                "Assist a stable client with ambulation",
                "Assess lung sounds",
                "Teach insulin injections",
                "Update the plan of care",
              ],
              0,
              "Saunders, Chapter 7 overview (p.5) reviews leadership and delegation principles, reserving assessment/teaching for RNs.",
            ),
            q(
              "fundamentals",
              "medium",
              "triage-safety",
              "During a facility fire, which action follows safety priorities?",
              [
                "Rescue clients in immediate danger before containing the fire",
                "Search the building before removing anyone",
                "Use elevators",
                "Silence alarms first",
              ],
              0,
              "Saunders, p.104 reinforces safety priorities (e.g., RACE) during emergency response planning.",
            ),
          ]
        )
  medium_questions.extend(
          [
            q(
              "mental",
              "medium",
              "schizo-metabolic",
              "Why are clients with schizophrenia monitored for diabetes mellitus?",
              [
                "Atypical antipsychotics contribute to metabolic syndrome",
                "They eat excessive sweets",
                "Schizophrenia directly destroys pancreatic cells",
                "They always have low cortisol",
              ],
              0,
              "Saunders, p.132 reports higher rates of diabetes and metabolic syndrome among clients with schizophrenia due to psychotropic effects.",
            ),
            q(
              "mental",
              "medium",
              "borderline-traits",
              "Which behavior is consistent with borderline personality disorder?",
              [
                "Impulsivity and unstable relationships",
                "Rigid perfectionism",
                "Detachment and coldness",
                "Grandiosity",
              ],
              0,
              "Saunders, p.2271 lists instability, manipulative behavior, and impulsivity as hallmark borderline traits.",
            ),
            q(
              "mental",
              "medium",
              "suicide-precautions",
              "A client verbalizes suicidal intent. Which intervention is essential?",
              [
                "Initiate suicide precautions with q15-minute documentation",
                "Assign roommate",
                "Leave the client unattended",
                "Remove observation",
              ],
              0,
              "Saunders, p.2325 mandates close observation (often every 15 minutes) and documentation for suicidal clients.",
            ),
            q(
              "mental",
              "medium",
              "anorexia-cbt",
              "Which therapy is commonly incorporated into inpatient plans for anorexia nervosa?",
              [
                "Cognitive-behavioral therapy",
                "Electroconvulsive therapy",
                "Psychoanalytic hypnosis",
                "Radiation therapy",
              ],
              0,
              "Saunders, p.2240 references cognitive-behavioral approaches for hospitalized clients with anorexia nervosa.",
            ),
            q(
              "mental",
              "medium",
              "delirium-tremens",
              "Delirium tremens typically peaks how long after alcohol cessation?",
              [
                "48 to 72 hours",
                "6 hours",
                "1 week",
                "Immediately",
              ],
              0,
              "Saunders, p.2303 states DTs usually peak 48–72 hours after stopping alcohol.",
            ),
          ]
        )
  medium_questions.extend(
          [
            q(
              "mat",
              "medium",
              "preeclampsia-protein",
              "During a prenatal visit the urine dipstick shows 3+ protein. Which condition should the nurse suspect?",
              [
                "Preeclampsia",
                "Hyperemesis",
                "Yeast infection",
                "Fetal demise",
              ],
              0,
              "Saunders, p.653 indicates that protein levels of 2+ to 4+ may signal infection or preeclampsia and require follow-up.",
            ),
            q(
              "mat",
              "medium",
              "placenta-previa",
              "A client at 32 weeks has painless vaginal bleeding and is diagnosed with placenta previa. Which intervention is appropriate?",
              [
                "Avoid vaginal examinations and monitor bleeding",
                "Induce labor immediately",
                "Administer uterine stimulants",
                "Insert internal monitors",
              ],
              0,
              "Saunders, p.672 emphasizes minimizing vaginal manipulation and monitoring hemorrhage in placenta previa.",
            ),
            q(
              "mat",
              "medium",
              "abruptio-risk",
              "Which factor increases a pregnant client's risk for abruptio placentae?",
              [
                "History of physical abuse and hypertension",
                "A Rh-negative blood type",
                "Low BMI",
                "Cholelithiasis",
              ],
              0,
              "Saunders, p.649 lists physical abuse and hypertensive disorders as contributors to placental abruption.",
            ),
            q(
              "mat",
              "medium",
              "tocolytics-bleeding",
              "A client with vaginal bleeding and uterine irritability is prescribed tocolytics. What is the goal?",
              [
                "Reduce uterine activity to prevent preterm birth",
                "Increase contractions to deliver",
                "Induce hypertension",
                "Eliminate Rh antibodies",
              ],
              0,
              "Saunders, p.692 notes tocolytics may be ordered with bleeding episodes to suppress contractions while stabilizing the client.",
            ),
            q(
              "mat",
              "medium",
              "apgar-assess",
              "At 1 minute after birth the newborn has a strong cry, flexed extremities, and acrocyanosis. The Apgar score for color is:",
              [
                "1",
                "0",
                "2",
                "3",
              ],
              0,
              "Saunders, p.810 explains that acrocyanosis warrants a color score of 1 on the Apgar assessment.",
            ),
          ]
        )
  medium_questions.extend(
          [
            q(
              "peds",
              "medium",
              "rsv-care",
              "Which intervention helps reduce work of breathing for a toddler hospitalized with RSV bronchiolitis?",
              [
                "Provide cool humidified oxygen and encourage fluids",
                "Administer cough suppressants every 2 hours",
                "Place the child in Trendelenburg position",
                "Restrict all oral intake",
              ],
              0,
              "Saunders, p.1023 recommends humidified oxygen, airway clearance, and hydration for LTB/RSV management.",
            ),
            q(
              "peds",
              "medium",
              "rheumatic-fever",
              "What is a primary nursing focus during the acute phase of rheumatic fever?",
              [
                "Promote bed rest and administer prescribed antibiotics",
                "Encourage team sports",
                "Restrict fluids",
                "Discontinue all analgesics",
              ],
              0,
              "Saunders, p.1071 outlines rest and antibiotic therapy to treat streptococcal infection and reduce cardiac workload.",
            ),
            q(
              "peds",
              "medium",
              "lead-screen",
              "Which child should receive urgent follow-up for lead exposure?",
              [
                "Toddler who still puts chipped-painted toys in the mouth",
                "School-age child who eats leafy greens",
                "Teen with seasonal allergies",
                "Infant on formula",
              ],
              0,
              "Saunders, p.986 highlights mouthing chipped paint as a significant risk for lead poisoning.",
            ),
            q(
              "peds",
              "medium",
              "hip-dysplasia",
              "Which newborn finding warrants follow-up for developmental dysplasia of the hip?",
              [
                "Click felt when thighs are abducted",
                "Symmetric gluteal folds",
                "Strong Moro reflex",
                "Pink skin tone",
              ],
              0,
              "Saunders, p.816 notes that an audible click during the Ortolani maneuver may signify hip dysplasia.",
            ),
            q(
              "peds",
              "medium",
              "epispadias-care",
              "What instruction is appropriate for parents of an infant with epispadias?",
              [
                "Avoid circumcision until surgical repair",
                "Expect spontaneous resolution",
                "Use petroleum gauze at all times",
                "Delay potty training indefinitely",
              ],
              0,
              "Saunders, p.1091 advises deferring circumcision because foreskin tissue may be needed for urethral reconstruction.",
            ),
          ]
        )
  medium_questions.extend(
          [
            q(
              "med-surg",
              "medium",
              "dka-schizo",
              "Why do clients with schizophrenia taking psychotropics have a higher incidence of diabetic ketoacidosis (DKA)?",
              [
                "Atypical antipsychotics contribute to weight gain and insulin resistance",
                "They rarely eat due to hallucinations",
                "Psychotropic drugs cure diabetes",
                "Antipsychotics increase endogenous insulin",
              ],
              0,
              "Saunders, p.132 links metabolic syndrome and DKA to antipsychotic side effects such as weight gain and insulin resistance.",
            ),
            q(
              "med-surg",
              "medium",
              "siadh-oncology",
              "A lung cancer client develops sudden weight gain and hyponatremia. Which complication should the nurse suspect?",
              [
                "Syndrome of inappropriate antidiuretic hormone (SIADH)",
                "Diabetes insipidus",
                "Hyperparathyroidism",
                "Tumor lysis syndrome",
              ],
              0,
              "Saunders, p.1302 describes SIADH as a paraneoplastic complication causing fluid retention and dilutional hyponatremia.",
            ),
            q(
              "med-surg",
              "medium",
              "pancreatitis-calcium",
              "Which laboratory abnormality frequently accompanies acute pancreatitis and requires monitoring?",
              [
                "Hypocalcemia",
                "Hypernatremia",
                "Thrombocytosis",
                "Polycythemia",
              ],
              0,
              "Saunders, p.249 notes that acute pancreatitis can precipitate hypocalcemia by fat saponification.",
            ),
            q(
              "med-surg",
              "medium",
              "cirrhosis-platelets",
              "A cirrhosis client has platelets of 90,000/mm³. What is the best interpretation?",
              [
                "Portal hypertension causes splenic sequestration and thrombocytopenia",
                "The value is normal and expected",
                "Thrombocytosis improves clotting",
                "The client is dehydrated",
              ],
              0,
              "Saunders, p.313 lists cirrhosis as a cause of low platelet counts due to splenic pooling.",
            ),
            q(
              "med-surg",
              "medium",
              "pad-position",
              "How should a client with peripheral arterial disease (PAD) position the legs during rest to relieve pain?",
              [
                "Dangle the legs to promote arterial flow",
                "Elevate legs above the heart",
                "Lie flat and motionless",
                "Place legs under ice packs",
              ],
              0,
              "Saunders, p.512 directs clients with PAD to keep the legs dependent to improve perfusion and relieve ischemic discomfort.",
            ),
          ]
        )
  hard_questions: List[dict] = []
  hard_questions.extend(
          [
            q(
              "fundamentals",
              "hard",
              "nursing-process-priority",
              "A client with cataracts reports concern about losing eyesight. Which step of the nursing process guides prioritizing this problem?",
              [
                "Planning focuses on physiological needs like altered vision",
                "Implementation comes before assessment",
                "Evaluation is first",
                "Diagnosis is skipped",
              ],
              0,
              "Saunders, p.101 example shows planning uses Maslow to prioritize physiological issues over psychosocial concerns when creating care plans.",
            ),
            q(
              "fundamentals",
              "hard",
              "oxygen-sat",
              "A child on pulse oximetry suddenly desaturates. Which action comes first?",
              [
                "Assess airway and ensure the probe is accurately placed",
                "Silence the alarm without assessment",
                "Remove the sensor",
                "Ignore if the child looks fine",
              ],
              0,
              "Saunders, p.58 emphasizes verifying sensor placement while simultaneously addressing airway and breathing cues.",
            ),
            q(
              "fundamentals",
              "hard",
              "pain-nonverbal",
              "Which strategy best assesses pain in a nonverbal adult with dementia?",
              [
                "Use behavioral cues and alternative scales",
                "Assume no pain if silent",
                "Rely on vital signs only",
                "Ask yes/no questions",
              ],
              0,
              "Saunders, p.305 recommends observing nonverbal indicators and selecting appropriate pain tools for clients unable to self-report.",
            ),
            q(
              "fundamentals",
              "hard",
              "ppe-sequence",
              "Which sequence removes PPE safely after droplet isolation care?",
              [
                "Gloves, goggles, gown, mask",
                "Mask, gloves, gown, goggles",
                "Gown, gloves, mask, goggles",
                "Any order",
              ],
              0,
              "Saunders, p.423 implies removing the most contaminated items (gloves) first, ending with the mask.",
            ),
            q(
              "fundamentals",
              "hard",
              "delegation-assess",
              "Which delegated task would require immediate RN follow-up?",
              [
                "UAP reports new onset confusion after ambulation",
                "UAP records intake",
                "UAP provides a bed bath",
                "UAP measures weight",
              ],
              0,
              "Saunders, Chapter 7 (p.5) indicates RNs must investigate assessment findings such as confusion reported by assistive personnel.",
            ),
          ]
        )
  hard_questions.extend(
          [
            q(
              "mental",
              "hard",
              "ect-consent",
              "Before electroconvulsive therapy (ECT), which action is legally required?",
              [
                "Obtain informed consent and explain the procedure",
                "Withhold consent because it is emergent",
                "Skip pre-ECT teaching",
                "Force treatment regardless of wishes",
              ],
              0,
              "Saunders, p.2221 reminds nurses that ECT requires informed consent and ethical review.",
            ),
            q(
              "mental",
              "hard",
              "restraint-policy",
              "Which statement reflects correct use of restraints in mental health care?",
              [
                "Use the least restrictive measure and follow legal protocols",
                "Apply restraints for staff convenience",
                "Leave restrained clients unattended",
                "Tie knots that require tools to release",
              ],
              0,
              "Saunders, p.2221 highlights least-restrictive principles and ongoing monitoring when restraints are unavoidable.",
            ),
            q(
              "mental",
              "hard",
              "borderline-limit",
              "When caring for a client with borderline personality disorder who manipulates staff, which intervention is most effective?",
              [
                "Set clear, consistent limits with all team members",
                "Change the care plan daily",
                "Ignore boundary violations",
                "Promise special favors",
              ],
              0,
              "Saunders, p.2271 recommends firm, consistent limits to address impulsivity and manipulation.",
            ),
            q(
              "mental",
              "hard",
              "panic-coaching",
              "A client in a panic attack hyperventilates and feels out of control. Which action helps first?",
              [
                "Speak calmly, stay with the client, and reduce stimuli",
                "Give complex instructions",
                "Leave until the client calms",
                "Challenge the client's beliefs",
              ],
              0,
              "Saunders, p.2253 underscores remaining with the client, speaking calmly, and decreasing environmental stimuli during panic.",
            ),
            q(
              "mental",
              "hard",
              "alcohol-thiamine",
              "Why is thiamine administered during acute alcohol withdrawal?",
              [
                "To prevent Wernicke's encephalopathy",
                "To induce sleep",
                "To enhance withdrawal symptoms",
                "To control hypertension",
              ],
              0,
              "Saunders, p.2303 states thiamine is given to deter Wernicke's encephalopathy when treating alcohol withdrawal.",
            ),
          ]
        )
  hard_questions.extend(
          [
            q(
              "mat",
              "hard",
              "pph-risk",
              "A client with multifetal gestation and polyhydramnios is in the third stage of labor. Which postpartum complication is she at greatest risk for?",
              [
                "Postpartum hemorrhage",
                "Respiratory alkalosis",
                "Hypoglycemia",
                "Amniotic fluid embolism",
              ],
              0,
              "Saunders, p.691 lists multiple gestation and uterine overdistention as factors that increase the risk of postpartum hemorrhage.",
            ),
            q(
              "mat",
              "hard",
              "rhogam-postpartum",
              "After delivering an Rh-positive newborn, which action is essential for an Rh-negative birthing parent without antibodies?",
              [
                "Administer Rh o (D) immune globulin within 72 hours",
                "Give magnesium sulfate",
                "Begin oxytocin infusion",
                "Start IV antibiotics",
              ],
              0,
              "Saunders, p.651 recommends postpartum Rh o (D) immune globulin to prevent isoimmunization when the infant is Rh positive.",
            ),
            q(
              "mat",
              "hard",
              "fundal-assessment",
              "At 1 hour postpartum the fundus is boggy and deviated to the right with heavy lochia. What is the priority?",
              [
                "Massage the fundus and empty the bladder",
                "Apply ice to the abdomen",
                "Elevate the head of the bed",
                "Restrict oral fluids",
              ],
              0,
              "Saunders, p.736 stresses fundal massage and bladder emptying to address uterine atony manifested by bogginess and deviation.",
            ),
            q(
              "mat",
              "hard",
              "oxytocin-pp",
              "Which teaching reinforces the role of oxytocin postpartum?",
              [
                "It promotes uterine involution and milk ejection",
                "It suppresses uterine contractions",
                "It lowers thyroid activity",
                "It decreases prolactin release",
              ],
              0,
              "Saunders, p.640 describes posterior pituitary oxytocin as stimulating uterine contractions and supporting lactation.",
            ),
            q(
              "mat",
              "hard",
              "bleeding-eval",
              "Which assessment differentiates placenta previa from abruptio placentae?",
              [
                "Placenta previa presents with painless bright-red bleeding",
                "Abruptio placentae has painless bleeding",
                "Placenta previa causes rigid abdomen",
                "Abruptio placentae features relaxed uterus",
              ],
              0,
              "Saunders, pp.672 and 649 contrast placenta previa (painless bleeding) with abruptio (painful, tender uterus).",
            ),
          ]
        )
  hard_questions.extend(
          [
            q(
              "peds",
              "hard",
              "cerebral-palsy",
              "Which assessment supports a diagnosis of cerebral palsy in an infant?",
              [
                "Persistence of primitive reflexes beyond 6 months",
                "Soft anterior fontanel at birth",
                "Daily loose stools",
                "Early rolling over",
              ],
              0,
              "Saunders, p.1105 lists abnormal muscle tone and persistence of infant reflexes as hallmarks of cerebral palsy.",
            ),
            q(
              "peds",
              "hard",
              "nephrotic-diet",
              "Which dietary change is recommended for a child with nephrotic syndrome?",
              [
                "Limit sodium to help reduce edema",
                "Increase potassium restriction",
                "Avoid all protein",
                "Eliminate carbohydrates",
              ],
              0,
              "Saunders, p.340 includes nephrotic syndrome among conditions requiring a cardiac-style, low-sodium diet to manage fluid retention.",
            ),
            q(
              "peds",
              "hard",
              "scarlet-fever-precautions",
              "Which isolation precaution is required for scarlet fever?",
              [
                "Droplet precautions",
                "Airborne precautions",
                "Contact precautions only",
                "Protective isolation",
              ],
              0,
              "Saunders, p.423 categorizes scarlet fever among infections requiring droplet precautions.",
            ),
            q(
              "peds",
              "hard",
              "kawasaki-treatment",
              "What therapy reduces coronary artery complications in Kawasaki disease?",
              [
                "High-dose IV immunoglobulin with aspirin",
                "Prolonged corticosteroids",
                "Antibiotics only",
                "Diuretics",
              ],
              0,
              "Saunders, p.1072 outlines IVIG plus aspirin to quell inflammation and protect coronary arteries.",
            ),
            q(
              "peds",
              "hard",
              "intussusception-monitor",
              "After an air enema reduction for intussusception, which finding indicates the intervention was successful?",
              [
                "Passage of brown stool without blood",
                "Persistent currant jelly stools",
                "Bilious vomiting",
                "Increasing abdominal distention",
              ],
              0,
              "Saunders, p.978 explains that return of normal stool suggests the obstruction has resolved.",
            ),
          ]
        )
  hard_questions.extend(
          [
            q(
              "med-surg",
              "hard",
              "uc-acute-diet",
              "Which order is consistent with managing an acute ulcerative colitis exacerbation?",
              [
                "NPO with IV fluids, then advance to low-fiber as bleeding subsides",
                "Full liquids with dairy",
                "High-residue diet immediately",
                "Unlimited caffeine to slow motility",
              ],
              0,
              "Saunders, p.1508 recommends bowel rest with parenteral support followed by a gradual return to low-fiber intake once acute bleeding resolves.",
            ),
            q(
              "med-surg",
              "hard",
              "pancreatic-enzymes",
              "What teaching best supports a client prescribed pancreatic enzyme replacements?",
              [
                "Take enzymes with meals to aid fat and protein digestion",
                "Store the capsules in the freezer",
                "Chew the tablets thoroughly to increase absorption",
                "Skip doses when stools are normal",
              ],
              0,
              "Saunders, p.1507 directs clients to take pancreatic enzymes with food to optimize nutrient absorption.",
            ),
            q(
              "med-surg",
              "hard",
              "appendicitis-guarding",
              "Which finding signals perforation in acute appendicitis?",
              [
                "Sudden relief of pain followed by rigid abdomen",
                "Bradycardia with hypertension",
                "High-pitched bowel sounds",
                "Urinary frequency",
              ],
              0,
              "Saunders, p.974 warns that perforation can momentarily reduce pain before peritonitis develops with boardlike rigidity.",
            ),
            q(
              "med-surg",
              "hard",
              "dvt-aptt-adjust",
              "The aPTT exceeds 100 seconds on a heparin drip for DVT. What is the nurse's best action?",
              [
                "Stop the infusion and notify the provider",
                "Increase the rate by 2 units/kg/hr",
                "Give warfarin immediately",
                "Ignore if the client has no bleeding",
              ],
              0,
              "Saunders, p.323-324 indicates that a supratherapeutic aPTT requires holding the infusion and collaborating on dose adjustments to prevent bleeding.",
            ),
            q(
              "med-surg",
              "hard",
              "pad-education",
              "Which instruction is essential for home management of peripheral arterial disease?",
              [
                "Avoid crossing legs and inspect feet daily",
                "Use heating pads directly on the calves",
                "Elevate legs above the heart whenever sitting",
                "Wear constrictive socks",
              ],
              0,
              "Saunders, p.512 stresses dependent positioning and meticulous foot care to prevent ischemic injury in PAD.",
            ),
          ]
        )
  rn_questions: List[dict] = []
  rn_questions.extend(
          [
            q(
              "fundamentals",
              "rnworthy",
              "fire-triage",
              "Which finding indicates staff understand the RACE acronym during a unit fire?",
              [
                "Clients in immediate danger are evacuated before closing doors and calling for help",
                "Staff extinguish the fire before rescuing",
                "Everyone runs to the exit",
                "Alarms are ignored",
              ],
              0,
              "Saunders, p.104 references emergency response planning that prioritizes rescue, alarm, contain, extinguish.",
            ),
            q(
              "fundamentals",
              "rnworthy",
              "restraint-eval",
              "Which documentation supports ethical restraint use?",
              [
                "Order obtained, least restrictive tried, and ongoing assessments charted",
                "Restraints applied PRN without orders",
                "Client restrained indefinitely",
                "No monitoring after application",
              ],
              0,
              "Saunders, p.174 and p.2221 underline legal requirements for restraints including orders and frequent evaluation.",
            ),
            q(
              "fundamentals",
              "rnworthy",
              "delegation-eval",
              "Which assignment requires the RN to intervene?",
              [
                "UAP asked to assess a postoperative incision",
                "LPN reinforcing teaching",
                "UAP obtaining vital signs",
                "LPN administering oral meds",
              ],
              0,
              "Saunders, Chapter 7 (p.5) reminds that assessment remains an RN responsibility and should not be delegated to UAPs.",
            ),
            q(
              "fundamentals",
              "rnworthy",
              "infection-bundle",
                "Which bundle of interventions best minimizes infection risk in an immunocompromised client?",
              [
                "Meticulous hand hygiene, protective isolation as ordered, and equipment disinfection",
                "Placing flowers in the room",
                "Assigning multiple visitors",
                "Reusing single-use devices",
              ],
              0,
              "Saunders, p.104 and p.322 focus on hand hygiene, isolation, and environmental controls to prevent infection.",
            ),
            q(
              "fundamentals",
              "rnworthy",
              "pain-eval",
              "Which pain documentation best supports quality improvement?",
              [
                "Pain 8/10 pre-analgesic, 3/10 45 minutes post-dose",
                "\"Pain improved\"",
                "Client comfortable",
                "No change noted",
              ],
              0,
              "Saunders, p.305 notes that evaluating interventions requires comparing numeric scores before and after treatment.",
            ),
          ]
        )
  rn_questions.extend(
          [
            q(
              "mental",
              "rnworthy",
              "suicide-plan",
              "Which evaluation finding shows suicide precautions are effective?",
              [
                "Client remains under constant or q15-minute observation with documented mood checks",
                "Client kept personal belts",
                "Family provides 24/7 monitoring alone",
                "Client is allowed to roam unobserved",
              ],
              0,
              "Saunders, p.2325 stresses regimented observation and documentation for suicidal clients.",
            ),
            q(
              "mental",
              "rnworthy",
              "ptsd-support",
              "Which referral best supports recovery for a veteran with PTSD?",
              [
                "Trauma-focused therapy or support groups",
                "Weight-loss clinic",
                "Dermatology consult",
                "Cardiac rehab",
              ],
              0,
              "Saunders, p.130 encourages counseling and support programs tailored to PTSD triggers.",
            ),
            q(
              "mental",
              "rnworthy",
              "alcohol-monitor",
              "During alcohol withdrawal, which assessment finding requires immediate provider notification?",
              [
                "Temperature of 102°F and tactile hallucinations",
                "Mild tremor",
                "Anxiety",
                "Insomnia",
              ],
              0,
              "Saunders, p.2303 explains that fever and hallucinations signal progression toward delirium tremens, demanding prompt escalation.",
            ),
            q(
              "mental",
              "rnworthy",
              "anorexia-family",
              "An inpatient with anorexia nervosa is ready for discharge. Which goal indicates readiness?",
              [
                "Family participates in cognitive-behavioral meal plans",
                "Client refuses counseling",
                "Weight remains unstable",
                "Vital signs remain labile",
              ],
              0,
              "Saunders, p.2240 highlights collaborative planning and CBT strategies with family involvement.",
            ),
            q(
              "mental",
              "rnworthy",
              "borderline-contract",
              "Which strategy helps prevent splitting behaviors on a mental health unit?",
              [
                "Teamwide behavioral contracts outlining consistent limits",
                "Assign different nurses daily with new expectations",
                "Promise secrecy",
                "Allow client to set all rules",
              ],
              0,
              "Saunders, p.2271 suggests consistent, structured expectations across team members for borderline personality disorder.",
            ),
          ]
        )
  rn_questions.extend(
          [
            q(
              "mat",
              "rnworthy",
              "preeclampsia-teaching",
              "Which statement shows a client with preeclampsia understands when to seek urgent care at home?",
              [
                "\"If I notice visual changes or severe headache, I'll call right away.\"",
                "\"I will stop taking my antihypertensives when I feel better.\"",
                "\"Swelling is normal, so I can ignore it.\"",
                "\"Protein in the urine is harmless.\"",
              ],
              0,
              "Saunders, p.653 correlates visual disturbances and headaches with worsening preeclampsia requiring evaluation.",
            ),
            q(
              "mat",
              "rnworthy",
              "placenta-previa-plan",
              "Which care plan best supports a client with placenta previa awaiting fetal maturity?",
              [
                "Maintain pelvic rest, monitor bleeding, and prepare for cesarean delivery",
                "Encourage vigorous exercise",
                "Schedule weekly vaginal exams",
                "Plan for immediate induction",
              ],
              0,
              "Saunders, p.672 advocates pelvic rest and observation with cesarean delivery once fetal maturity or maternal stability dictates.",
            ),
            q(
              "mat",
              "rnworthy",
              "abruption-support",
              "During prenatal counseling, which risk-reduction topic is most important for preventing abruptio placentae?",
              [
                "Supporting the client to address intimate partner violence and blood pressure control",
                "Limiting vitamin intake",
                "Avoiding prenatal visits",
                "Increasing caffeine",
              ],
              0,
              "Saunders, p.649 identifies physical abuse and hypertensive disorders as modifiable risks for placental abruption.",
            ),
            q(
              "mat",
              "rnworthy",
              "fundal-tracking",
              "Which documentation demonstrates effective fundal height tracking at 28 weeks?",
              [
                "Fundal height equals gestational weeks, indicating appropriate growth",
                "Fundus remains pelvic",
                "Fundal height is unrelated to gestation",
                "Fundus declines after 20 weeks",
              ],
              0,
              "Saunders, p.639 notes that after 20 weeks the fundal height (in cm) roughly matches gestational age.",
            ),
            q(
              "mat",
              "rnworthy",
              "tocolytics-coordination",
              "A bleeding client receives IV fluids, Rhogam, and tocolytics. Which outcome reflects coordinated care?",
              [
                "Uterine activity decreases while fetal monitoring remains reassuring",
                "Contractions intensify",
                "Urine output falls below 10 mL/hr",
                "Bleeding persists unchecked",
              ],
              0,
              "Saunders, p.692 and p.651 emphasize combining tocolytics with volume support and Rh prophylaxis to stabilize bleeding clients.",
            ),
          ]
        )
  rn_questions.extend(
          [
            q(
              "peds",
              "rnworthy",
              "lead-environment",
              "Which collaborative action best reduces ongoing lead exposure for a toddler with elevated levels?",
              [
                "Arrange for lead abatement of peeling paint and reinforce wet-cleaning routines",
                "Advise the family to move immediately",
                "Give extra vitamin C only",
                "Allow the child to keep chewing painted toys",
              ],
              0,
              "Saunders, p.986 ties lead poisoning to ingesting chipped paint, so environmental remediation is essential.",
            ),
            q(
              "peds",
              "rnworthy",
              "epiglottitis-team",
              "Which preparation demonstrates readiness for sudden airway loss in epiglottitis?",
              [
                "Keep a pediatric tracheostomy set and intubation tray at the bedside",
                "Have the child practice deep coughing",
                "Place the child supine",
                "Insert an oral airway for comfort",
              ],
              0,
              "Saunders, p.57 stresses being prepared for emergency airway management while avoiding procedures that can worsen obstruction.",
            ),
            q(
              "peds",
              "rnworthy",
              "rheumatic-adherence",
              "Which outcome indicates successful teaching for a family managing rheumatic fever at home?",
              [
                "Parents describe the need for long-term prophylactic antibiotics",
                "Family plans to stop antibiotics once fever subsides",
                "Child resumes vigorous sports immediately",
                "Parents increase dietary sodium",
              ],
              0,
              "Saunders, p.1071 highlights prophylactic antibiotics to prevent recurrent streptococcal infections.",
            ),
            q(
              "peds",
              "rnworthy",
              "nephrotic-home",
              "Which instruction supports outpatient management of nephrotic syndrome?",
              [
                "Perform daily weights and report sudden gain",
                "Eliminate all activity",
                "Avoid vaccinations",
                "Encourage high-sodium snacks",
              ],
              0,
              "Saunders, p.340 emphasizes monitoring fluid status via daily weights when managing nephrotic syndrome.",
            ),
            q(
              "peds",
              "rnworthy",
              "cerebral-palsy-resources",
              "Which referral best supports a family after a new diagnosis of cerebral palsy?",
              [
                "Early intervention physical and occupational therapy services",
                "Hospice care",
                "Long-term acute care hospital",
                "Vacation planning",
              ],
              0,
              "Saunders, p.1105 encourages connecting families to therapy and community resources to optimize function.",
            ),
          ]
        )
  rn_questions.extend(
          [
            q(
              "med-surg",
              "rnworthy",
              "sepsis-triage",
              "When planning care for a neutropenic client with sepsis, which integrated priority protects both patient and staff?",
              [
                "Strict hand hygiene and timely use of call lights and emergency response protocols",
                "Limiting visitors only",
                "Placing all equipment in the hallway",
                "Delaying antibiotics until cultures return",
              ],
              0,
              "Saunders, p.104 emphasizes safety behaviors—hand hygiene, call-bell responsiveness, and emergency planning—for infection control scenarios.",
            ),
            q(
              "med-surg",
              "rnworthy",
              "endocarditis-prophy",
              "Which client requires antibiotic prophylaxis before dental work based on endocarditis risk?",
              [
                "Client with a prosthetic heart valve",
                "Client with controlled asthma",
                "Client with fibromyalgia",
                "Client with GERD",
              ],
              0,
              "Saunders, p.701 lists prosthetic valves and prior endocarditis among high-risk groups needing prophylaxis before invasive procedures.",
            ),
            q(
              "med-surg",
              "rnworthy",
              "burn-triage",
              "During mass-casualty triage, which burn client requires immediate red-tag assignment?",
              [
                "Facial burns with hoarseness and singed nasal hair",
                "Blistered hand burns with full pulses",
                "Superficial sunburn",
                "Healed graft sites",
              ],
              0,
              "Saunders, p.894 prioritizes airway compromise in burn injuries, prompting emergent intervention.",
            ),
            q(
              "med-surg",
              "rnworthy",
              "dvt-heparin-plan",
              "A client on heparin for DVT will transition to warfarin. Which plan demonstrates safe overlap?",
              [
                "Continue heparin until INR reaches the therapeutic range",
                "Stop heparin as soon as warfarin is started",
                "Increase heparin after the first warfarin dose",
                "Give vitamin K before starting warfarin",
              ],
              0,
              "Saunders, p.323 outlines maintaining heparin therapy until warfarin achieves therapeutic INR to prevent clot extension.",
            ),
            q(
              "med-surg",
              "rnworthy",
              "diabetes-insipidus-plan",
              "Which collaborative goal is most appropriate for the hospitalized client with diabetes insipidus and tachycardia?",
              [
                "Restore intravascular volume with prescribed IV fluids",
                "Restrict fluids to prevent overload",
                "Avoid desmopressin",
                "Administer diuretics",
              ],
              0,
              "Saunders, p.249 recommends IV fluid therapy to correct volume depletion caused by diabetes insipidus.",
            ),
          ]
        )

      return {
        "topic": topic_meta,
        "quizzes": [
          make_quiz("easy", "Easy", easy_questions),
          make_quiz("medium", "Medium", medium_questions),
          make_quiz("hard", "Hard", hard_questions),
          make_quiz("rnworthy", "RN Worthy", rn_questions),
        ],
      }


def build_pediatrics() -> dict:
  topic_meta = topic(
    "topic-pediatrics",
    "Pediatrics",
    "High-yield child health pathologies, growth milestones, and safety cues",
    ICON_PATH,
    "pediatrics",
  )

    def make_quiz(diff: str, label: str, questions: List[dict]) -> dict:
    return quiz(
      f"quiz-peds-{diff}",
      f"Pediatrics • {label}",
      topic_meta["id"],
      diff,
      questions,
    )

  easy_questions: List[dict] = []
  easy_questions.extend(
        [
          q(
            "fundamentals",
            "easy",
            "nursing-process",
            "Which step of the nursing process follows analysis/diagnosis?",
            [
              "Planning",
              "Implementation",
              "Evaluation",
              "Assessment",
            ],
            0,
            "Saunders, p.34 outlines the sequence: assessment, analysis, planning, implementation, evaluation.",
          ),
          q(
            "fundamentals",
            "easy",
            "hand-hygiene",
            "Which action best prevents client-to-client infection transmission?",
            [
              "Perform hand hygiene before and after patient contact",
              "Wear gloves for the entire shift",
              "Use only water to rinse",
              "Share personal items",
            ],
            0,
            "Saunders, p.322 emphasizes hand hygiene as the primary infection control measure.",
          ),
          q(
            "fundamentals",
            "easy",
            "vital-labs",
            "Why must nurses know normal vital signs and labs for NCLEX-style questions?",
            [
              "To determine whether values are within expected limits",
              "To replace provider orders",
              "To increase anxiety",
              "To chart faster",
            ],
            0,
            "Saunders, p.6 reminds nurses to memorize vital signs and common lab intervals for safe decision-making.",
          ),
          q(
            "fundamentals",
            "easy",
            "pulse-ox",
            "When monitoring oxygen saturation, which action is appropriate?",
            [
              "Ensure the sensor is secure and note positioning",
              "Ignore alarm limits",
              "Place the probe on an edematous site",
              "Use deflated probes",
            ],
            0,
            "Saunders, p.58 includes pulse oximetry as part of safety-focused monitoring during pediatric care.",
          ),
          q(
            "fundamentals",
            "easy",
            "pain-scale",
            "Which statement demonstrates proper use of a numeric pain scale?",
            [
              "Ask the client to rate pain from 0 (no pain) to 10 (worst pain)",
              "Only observe facial grimacing",
              "Assume sleeping clients have no pain",
              "Use the nurse's judgment only",
            ],
            0,
            "Saunders, p.305 advises using number-based or picture-based scales tailored to the client.",
          ),
        ]
      )
  easy_questions.extend(
        [
          q(
            "mental",
            "easy",
            "therapeutic-explore",
            "A client facing cardiac catheterization says, \"I'm so worried.\" Which therapeutic response is best?",
            [
              "\"Tell me more about what worries you most.\"",
              "\"You'll be fine; doctors do this daily.\"",
              "\"Don't worry, it's easy.\"",
              "Change the subject",
            ],
            0,
            "Saunders, p.55 highlights exploring the client's feelings rather than offering false reassurance.",
          ),
          q(
            "mental",
            "easy",
            "panic-signs",
            "Which finding is typical during a panic attack?",
            [
              "Extreme anxiety with disturbed behavior",
              "Mild restlessness",
              "Elated mood",
              "Slow respirations",
            ],
            0,
            "Saunders, p.2253 describes panic attacks as the most extreme anxiety level, impairing behavior.",
          ),
          q(
            "mental",
            "easy",
            "alcohol-withdrawal",
            "When do early signs of alcohol withdrawal usually appear after cessation?",
            [
              "Within a few hours",
              "After 5 days",
              "Two weeks later",
              "Only immediately",
            ],
            0,
            "Saunders, p.2303 notes early withdrawal symptoms develop within hours of the last drink.",
          ),
          q(
            "mental",
            "easy",
            "ptsd-symptoms",
            "Which manifestation is associated with post-traumatic stress disorder (PTSD)?",
            [
              "Nightmares and intrusive thoughts",
              "Bradycardia",
              "Euphoria",
              "Hyperglycemia",
            ],
            0,
            "Saunders, p.130 lists nightmares, anxiety, and uncontrollable thoughts among PTSD features.",
          ),
          q(
            "mental",
            "easy",
            "diazepam-safety",
            "Which teaching should accompany a new prescription for diazepam?",
            [
              "Expect sedation, so avoid driving initially",
              "Discontinue abruptly when feeling well",
              "Combine with alcohol for sleep",
              "Skip doses if anxious",
            ],
            0,
            "Saunders, p.2071 emphasizes sedation and ataxia with benzodiazepines, requiring safety precautions.",
          ),
        ]
      )
  easy_questions.extend(
        [
          q(
            "mat",
            "easy",
            "braxton-hicks",
            "What are Braxton Hicks contractions?",
            [
              "Irregular painless contractions occurring throughout pregnancy",
              "Strong regular contractions signaling true labor",
              "Contractions felt only during pushing",
              "Uterine cramps limited to the third trimester",
            ],
            0,
            "Saunders, p.638 defines Braxton Hicks contractions as irregular, painless tightening that can occur intermittently during pregnancy.",
          ),
          q(
            "mat",
            "easy",
            "fundal-height",
            "Why is fundal height measured at prenatal visits?",
            [
              "To estimate gestational age growth patterns",
              "To monitor fetal heart tones",
              "To confirm fetal presentation",
              "To measure pelvic width",
            ],
            0,
            "Saunders, p.639 states fundal height correlates with gestational age and helps monitor fetal growth trends.",
          ),
          q(
            "mat",
            "easy",
            "oxytocin-role",
            "Which hormone produced by the posterior pituitary stimulates uterine contractions?",
            [
              "Oxytocin",
              "Progesterone",
              "Estrogen",
              "Prolactin",
            ],
            0,
            "Saunders, p.640 explains that posterior pituitary secretion of oxytocin promotes uterine contractions.",
          ),
          q(
            "mat",
            "easy",
            "rhogam",
            "An Rh-negative gravida with a negative antibody screen at 28 weeks should expect which intervention?",
            [
              "Administration of Rh o (D) immune globulin",
              "Immediate labor induction",
              "Daily iron injections",
              "High-protein diet",
            ],
            0,
            "Saunders, p.651 instructs that Rh-negative clients receive Rh o (D) immune globulin at 28 weeks if antibody screen remains negative.",
          ),
          q(
            "mat",
            "easy",
            "lochia-stage4",
            "Which lochia finding is expected during the fourth stage of labor?",
            [
              "Moderate red lochia with a firm midline fundus",
              "Scant yellow lochia",
              "Large clots with boggy fundus",
              "Absence of lochia",
            ],
            0,
            "Saunders, p.736 notes that in stage 4 the fundus is contracted midline with moderate red lochia.",
          ),
        ]
      )
  easy_questions.extend(
        [
          q(
            "peds",
            "easy",
            "epiglottitis-airway",
            "A child with suspected epiglottitis arrives in the ED. Which action is priority?",
            [
              "Keep the child calm and avoid throat inspection",
              "Obtain a throat culture immediately",
              "Lay the child flat for assessment",
              "Give a warm bottle",
            ],
            0,
            "Saunders, p.57 and p.1021 caution against throat exams in epiglottitis because airway swelling can worsen; maintaining a patent airway is key.",
          ),
          q(
            "peds",
            "easy",
            "laryngotracheobronchitis",
            "Which symptom is typical of acute laryngotracheobronchitis (viral croup)?",
            [
              "Inspiratory stridor with barking cough",
              "High-pitched cry only",
              "Productive cough with green sputum",
              "Absent breath sounds",
            ],
            0,
            "Saunders, p.1023 describes parainfluenza croup as having a gradual onset with stridor and a barking cough in toddlers.",
          ),
          q(
            "peds",
            "easy",
            "kawasaki-sign",
            "Which finding supports the diagnosis of Kawasaki disease?",
            [
              "Strawberry tongue and conjunctival redness",
              "Maculopapular rash sparing the trunk",
              "Generalized pallor",
              "Sparse hair distribution",
            ],
            0,
            "Saunders, p.1072 notes mucocutaneous inflammation such as strawberry tongue and bilateral conjunctival redness in Kawasaki disease.",
          ),
          q(
            "peds",
            "easy",
            "intussusception-stool",
            "Which stool description is classic for intussusception?",
            [
              "Currant jelly stools",
              "Clay-colored stools",
              "Ribbon-like stools",
              "Hard pellets",
            ],
            0,
            "Saunders, p.978 identifies currant jelly stools from blood and mucus as a hallmark of intussusception.",
          ),
          q(
            "peds",
            "easy",
            "pyloric-stenosis",
            "Which assessment supports hypertrophic pyloric stenosis?",
            [
              "Projectile vomiting shortly after feeding",
              "Watery diarrhea",
              "High fever",
              "Frothy saliva",
            ],
            0,
            "Saunders, p.970 explains that hypertrophied pyloric muscles cause projectile vomiting soon after feeds.",
          ),
        ]
      )
  medium_questions: List[dict] = []
  hard_questions: List[dict] = []
  rn_questions: List[dict] = []

    return {
      "topic": topic_meta,
      "quizzes": [
        make_quiz("easy", "Easy", easy_questions),
        make_quiz("medium", "Medium", medium_questions),
        make_quiz("hard", "Hard", hard_questions),
        make_quiz("rnworthy", "RN Worthy", rn_questions),
      ],
    }


def build_maternal_newborn() -> dict:
  topic_meta = topic(
    "topic-maternal-newborn",
    "Maternal-Newborn",
    "Perinatal assessments, labor management, and postpartum priorities",
    ICON_PATH,
    "maternal-newborn",
  )

    def make_quiz(diff: str, label: str, questions: List[dict]) -> dict:
    return quiz(
      f"quiz-mat-{diff}",
      f"Maternal-Newborn • {label}",
      topic_meta["id"],
      diff,
      questions,
    )

  easy_questions: List[dict] = []
  medium_questions: List[dict] = []
  hard_questions: List[dict] = []
  rn_questions: List[dict] = []

    return {
      "topic": topic_meta,
      "quizzes": [
        make_quiz("easy", "Easy", easy_questions),
        make_quiz("medium", "Medium", medium_questions),
        make_quiz("hard", "Hard", hard_questions),
        make_quiz("rnworthy", "RN Worthy", rn_questions),
      ],
    }


def build_mental_health() -> dict:
  topic_meta = topic(
    "topic-mental-health",
    "Mental Health",
    "Therapeutic communication, crisis interventions, and psychopharmacology",
    ICON_PATH,
    "mental-health",
  )

    def make_quiz(diff: str, label: str, questions: List[dict]) -> dict:
    return quiz(
      f"quiz-mental-{diff}",
      f"Mental Health • {label}",
      topic_meta["id"],
      diff,
      questions,
    )

  easy_questions: List[dict] = []
  medium_questions: List[dict] = []
  hard_questions: List[dict] = []
  rn_questions: List[dict] = []

    return {
      "topic": topic_meta,
      "quizzes": [
        make_quiz("easy", "Easy", easy_questions),
        make_quiz("medium", "Medium", medium_questions),
        make_quiz("hard", "Hard", hard_questions),
        make_quiz("rnworthy", "RN Worthy", rn_questions),
      ],
    }


def build_fundamentals() -> dict:
  topic_meta = topic(
    "topic-fundamentals",
    "Fundamentals",
    "Core nursing process, safety, infection control, and delegation essentials",
    ICON_PATH,
    "fundamentals",
  )

    def make_quiz(diff: str, label: str, questions: List[dict]) -> dict:
    return quiz(
      f"quiz-fundamentals-{diff}",
      f"Fundamentals • {label}",
      topic_meta["id"],
      diff,
      questions,
    )

  easy_questions: List[dict] = []
  medium_questions: List[dict] = []
  hard_questions: List[dict] = []
  rn_questions: List[dict] = []

    return {
      "topic": topic_meta,
      "quizzes": [
        make_quiz("easy", "Easy", easy_questions),
        make_quiz("medium", "Medium", medium_questions),
        make_quiz("hard", "Hard", hard_questions),
        make_quiz("rnworthy", "RN Worthy", rn_questions),
      ],
    }


def main() -> None:
  data = {"topics": build_topics()}
  OUTPUT_PATH.write_text(json.dumps(data, indent=2), encoding="utf-8")


if __name__ == "__main__":
  main()
