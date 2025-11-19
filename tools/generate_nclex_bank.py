"""NCLEX-style question generator patterned after high-quality board review stems."""

from __future__ import annotations

import argparse
import json
import random
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import List, Sequence


@dataclass(frozen=True)
class OptionSeed:
    statement: str
    rationale: str
    priority: str  # "critical" entries become correct answers
    tags: Sequence[str]


@dataclass(frozen=True)
class ScenarioSeed:
    patient_overview: str
    setting: str
    therapy: str
    context: str
    monitoring_focus: str


@dataclass(frozen=True)
class Blueprint:
    id: str
    category: str
    theme: str
    stems: Sequence[str]
    scenarios: Sequence[ScenarioSeed]
    question_angles: Sequence[str]
    critical_cues: Sequence[OptionSeed]
    supportive_cues: Sequence[OptionSeed]
    default_difficulty: str
    cognitive_level: str
    references: Sequence[str]


BLUEPRINTS: Sequence[Blueprint] = [
    Blueprint(
        id="antiarrhythmic_monitoring",
        category="Pharmacological and Parenteral Therapies",
        theme="Lidocaine infusion safety",
        stems=[
            "Which cue needs the fastest intervention while titrating {monitoring_focus}?",
            "Which finding signals that the {therapy} should be paused?",
            "What assessment data takes priority as the nurse trends {monitoring_focus}?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 66-year-old male two hours post anterior myocardial infarction",
                setting="a cardiac ICU",
                therapy="lidocaine loading dose followed by 2 mg/min maintenance",
                context="Ventricular ectopy has persisted despite electrolyte correction.",
                monitoring_focus="ventricular ectopy and conduction times",
            ),
            ScenarioSeed(
                patient_overview="a 58-year-old female with dilated cardiomyopathy",
                setting="a telemetry step-down unit",
                therapy="continuous lidocaine infusion targeting ventricular trigeminy",
                context="The nurse is reviewing the rhythm strip during bedside rounds.",
                monitoring_focus="rhythm response to lidocaine",
            ),
            ScenarioSeed(
                patient_overview="a 70-year-old with ischemic cardiomyopathy and frequent PVCs",
                setting="a medical ICU",
                therapy="lidocaine at 1.5 mg/min",
                context="The client reports new light-headedness after an hour of therapy.",
                monitoring_focus="antiarrhythmic infusion",
            ),
        ],
        question_angles=[
            "managing an antiarrhythmic for ventricular ectopy",
            "responding to conduction changes caused by lidocaine",
            "evaluating neurologic status while titrating antiarrhythmics",
        ],
        critical_cues=[
            OptionSeed(
                statement="Telemetry tracing that now shows a broadening QRS duration",
                rationale="A widening QRS indicates progression toward heart block from lidocaine toxicity.",
                priority="critical",
                tags=("cardiac", "toxicity"),
            ),
            OptionSeed(
                statement="Sudden confusion and tremors noted during neurologic checks",
                rationale="Neurologic changes such as confusion or muscle twitching signal CNS toxicity.",
                priority="critical",
                tags=("neuro", "toxicity"),
            ),
            OptionSeed(
                statement="Serum potassium that dropped from 4.2 to 3.1 mEq/L",
                rationale="Hypokalemia increases ventricular irritability and undermines lidocaine effectiveness.",
                priority="critical",
                tags=("labs", "electrolyte"),
            ),
            OptionSeed(
                statement="A progressive drop in arterial blood pressure accompanied by bradycardia",
                rationale="Hypotension with bradycardia suggests hemodynamic compromise from the infusion.",
                priority="critical",
                tags=("hemodynamic", "toxicity"),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Complaint of mild metallic taste",
                rationale="A metallic taste can occur but does not require emergent action if isolated.",
                priority="supportive",
                tags=("expected",),
            ),
            OptionSeed(
                statement="Oxygen saturation trending 96% on 2 L/min nasal cannula",
                rationale="Adequate oxygenation supports perfusion and is not the priority concern.",
                priority="supportive",
                tags=("stable",),
            ),
            OptionSeed(
                statement="Occasional premature ventricular contractions that match baseline frequency",
                rationale="Ectopy that mirrors baseline does not represent treatment failure.",
                priority="supportive",
                tags=("baseline",),
            ),
            OptionSeed(
                statement="Client reporting localized IV site warmth",
                rationale="Local warmth warrants monitoring but does not outrank systemic toxicity cues.",
                priority="supportive",
                tags=("site",),
            ),
        ],
        default_difficulty="hard",
        cognitive_level="Analysis",
        references=("Antiarrhythmic monitoring", "ACLS infusion safety"),
    ),
    Blueprint(
        id="warfarin_discharge",
        category="Pharmacological and Parenteral Therapies",
        theme="Anticoagulant teaching",
        stems=[
            "Which instruction must the nurse emphasize before discharge?",
            "Which statement shows the client understands how to stay safe on {therapy}?",
            "What teaching point has the highest priority while reinforcing {monitoring_focus}?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 72-year-old with atrial fibrillation and a healed peptic ulcer",
                setting="an outpatient anticoagulation clinic",
                therapy="warfarin 5 mg daily",
                context="The INR today is 2.4 and the client is eager to resume normal activities.",
                monitoring_focus="bleeding precautions",
            ),
            ScenarioSeed(
                patient_overview="a 68-year-old recovering from a mechanical mitral valve replacement",
                setting="a cardiac step-down unit",
                therapy="warfarin with bridge therapy",
                context="The client takes herbal supplements at home and prepares leafy greens daily.",
                monitoring_focus="home safety on anticoagulants",
            ),
        ],
        question_angles=[
            "reinforcing bleeding precautions for vitamin K antagonists",
            "coordinating diet and medication interactions",
            "ensuring interprofessional communication for anticoagulant therapy",
        ],
        critical_cues=[
            OptionSeed(
                statement="Report any bruising, nosebleeds, or black stools to the provider immediately",
                rationale="Unusual bleeding can signal excessive anticoagulation and must be reported.",
                priority="critical",
                tags=("safety", "bleeding"),
            ),
            OptionSeed(
                statement="Keep vitamin K intake consistent rather than eliminating leafy vegetables",
                rationale="Stable vitamin K consumption prevents sudden INR shifts.",
                priority="critical",
                tags=("diet",),
            ),
            OptionSeed(
                statement="Inform every healthcare provider and dentist about warfarin therapy",
                rationale="All clinicians must know about anticoagulation before procedures or prescriptions.",
                priority="critical",
                tags=("communication",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Use an electric razor and soft toothbrush",
                rationale="Helpful teaching but not as critical as bleeding surveillance instructions.",
                priority="supportive",
                tags=("self-care",),
            ),
            OptionSeed(
                statement="Take the medication at bedtime to avoid daytime drowsiness",
                rationale="Warfarin does not typically cause drowsiness; timing is flexible.",
                priority="supportive",
                tags=("misconception",),
            ),
            OptionSeed(
                statement="Keep a blood pressure log every morning",
                rationale="Blood pressure monitoring is valuable but unrelated to anticoagulant safety.",
                priority="supportive",
                tags=("other-vitals",),
            ),
            OptionSeed(
                statement="Use ibuprofen for headaches instead of acetaminophen",
                rationale="NSAIDs increase bleeding risk, making this a poor instruction.",
                priority="supportive",
                tags=("unsafe",),
            ),
        ],
        default_difficulty="medium",
        cognitive_level="Application",
        references=("Anticoagulation education", "Client teaching priorities"),
    ),
    Blueprint(
        id="iv_site_preparation",
        category="Reduction of Risk Potential",
        theme="Peripheral IV catheter insertion on sensitive skin",
        stems=[
            "What is the safest way to manage excess hair before starting the IV?",
            "Which action protects the skin while preparing for {therapy}?",
            "How should the nurse address hair at the site to reduce infection risk?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 33-year-old scheduled for elective abdominal surgery",
                setting="a preoperative holding area",
                therapy="a short peripheral catheter",
                context="The forearm is very hairy and the client reacts to many adhesives.",
                monitoring_focus="catheter placement on sensitive skin",
            ),
            ScenarioSeed(
                patient_overview="a 41-year-old trauma patient",
                setting="an emergency department bay",
                therapy="large-bore IV for potential transfusion",
                context="Hair covers the antecubital region and needs quick management.",
                monitoring_focus="rapid vascular access",
            ),
        ],
        question_angles=[
            "skin protection while prepping for IV therapy",
            "infection control for catheter insertion",
            "reducing dermatitis risk in patients with adhesive allergies",
        ],
        critical_cues=[
            OptionSeed(
                statement="Use a single-patient clipper to trim hair down to stubble",
                rationale="Clipping removes hair without causing micro-abrasions that raise infection risk.",
                priority="critical",
                tags=("infection-control",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Shave the area with a razor just before insertion",
                rationale="Shaving creates nicks that increase infection risk and should be avoided.",
                priority="supportive",
                tags=("unsafe",),
            ),
            OptionSeed(
                statement="Apply depilatory cream and wipe it off after three minutes",
                rationale="Chemical depilatories can irritate sensitive skin and cause delays.",
                priority="supportive",
                tags=("irritation",),
            ),
            OptionSeed(
                statement="Leave the hair intact to avoid upsetting the client",
                rationale="Excess hair prevents secure dressing adherence and increases contamination.",
                priority="supportive",
                tags=("ineffective",),
            ),
            OptionSeed(
                statement="Use a sterile scalpel to remove hair close to the skin",
                rationale="Using a scalpel introduces laceration risk and is not standard of care.",
                priority="supportive",
                tags=("unsafe",),
            ),
            OptionSeed(
                statement="Smooth the hair with a water-based lubricant before taping",
                rationale="Gel interferes with adhesive integrity and does not control hair volume.",
                priority="supportive",
                tags=("ineffective",),
            ),
        ],
        default_difficulty="easy",
        cognitive_level="Comprehension",
        references=("Infusion therapy standards", "Infection prevention"),
    ),
    Blueprint(
        id="insulin_sick_day",
        category="Physiological Adaptation",
        theme="Sick-day management for insulin-dependent diabetes",
        stems=[
            "Which instruction should the nurse prioritize for {monitoring_focus}?",
            "What guidance keeps this client safest while {therapy}?",
            "Which statement shows correct understanding of sick-day insulin management?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 29-year-old with type 1 diabetes experiencing viral gastroenteritis",
                setting="a community health telehealth follow-up",
                therapy="basal-bolus insulin",
                context="The client has been vomiting but can sip clear liquids.",
                monitoring_focus="preventing ketosis",
            ),
            ScenarioSeed(
                patient_overview="a 35-year-old postpartum client with type 1 diabetes",
                setting="a home-health visit",
                therapy="insulin pump therapy",
                context="She has a low-grade fever and poor appetite.",
                monitoring_focus="glucose safety",
            ),
        ],
        question_angles=[
            "preventing diabetic ketoacidosis during illness",
            "balancing carbohydrates and insulin doses on sick days",
            "recognizing when to call the provider for hyperglycemia",
        ],
        critical_cues=[
            OptionSeed(
                statement="Check blood glucose and ketones every 3 to 4 hours",
                rationale="Frequent monitoring catches hypoglycemia or ketosis early during illness.",
                priority="critical",
                tags=("monitoring",),
            ),
            OptionSeed(
                statement="Continue basal insulin even if intake is limited",
                rationale="Basal insulin prevents ketosis and must continue during illness.",
                priority="critical",
                tags=("therapy",),
            ),
            OptionSeed(
                statement="Sip 8 to 12 ounces of carb-containing fluids each hour",
                rationale="Carbohydrates prevent starvation ketosis when solid food is not tolerated.",
                priority="critical",
                tags=("nutrition",),
            ),
            OptionSeed(
                statement="Contact the provider for persistent fever or moderate ketones",
                rationale="Escalation criteria help prevent DKA progression.",
                priority="critical",
                tags=("escalation",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Hold all insulin doses until solid food resumes",
                rationale="Stopping insulin invites ketosis and is unsafe.",
                priority="supportive",
                tags=("unsafe",),
            ),
            OptionSeed(
                statement="Take double the usual correction bolus at bedtime",
                rationale="Doubling insulin without guidance increases hypoglycemia risk.",
                priority="supportive",
                tags=("overdose",),
            ),
            OptionSeed(
                statement="Avoid electrolyte drinks because they contain sodium",
                rationale="Electrolyte solutions help replace losses and should not be avoided.",
                priority="supportive",
                tags=("misconception",),
            ),
            OptionSeed(
                statement="Skip ketone testing if glucose stays under 180 mg/dL",
                rationale="Ketones can develop despite moderate glucose levels during illness.",
                priority="supportive",
                tags=("incomplete",),
            ),
        ],
        default_difficulty="medium",
        cognitive_level="Application",
        references=("Diabetes sick-day rules", "Endocrine safety"),
    ),
    Blueprint(
        id="neuro_raised_icp",
        category="Physiological Adaptation",
        theme="Neurologic assessment for increased intracranial pressure",
        stems=[
            "Which assessment change requires immediate provider notification?",
            "What finding indicates the client's ICP is worsening?",
            "Which cue should prompt the nurse to prepare for rapid intervention?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 22-year-old with a traumatic brain injury",
                setting="a neuro ICU",
                therapy="ventricular drain with ICP monitoring",
                context="Sedation has been lightened for a neuro exam.",
                monitoring_focus="neurologic decline",
            ),
            ScenarioSeed(
                patient_overview="a 45-year-old with a hemorrhagic stroke",
                setting="a neuro step-down unit",
                therapy="hyperosmolar therapy",
                context="The nurse performs hourly cranial nerve checks.",
                monitoring_focus="intracranial pressure trends",
            ),
        ],
        question_angles=[
            "recognizing Cushing triad",
            "prioritizing neurologic cues",
            "escalating care for deteriorating neuro status",
        ],
        critical_cues=[
            OptionSeed(
                statement="Unequal pupils with sluggish reaction to light",
                rationale="Anisocoria with sluggish response suggests herniation risk.",
                priority="critical",
                tags=("cranial-nerve",),
            ),
            OptionSeed(
                statement="Widening pulse pressure with bradycardia",
                rationale="Cushing response indicates rising ICP and brainstem compression.",
                priority="critical",
                tags=("vitals",),
            ),
            OptionSeed(
                statement="Decorticate posturing noted during stimulation",
                rationale="Posturing signifies significant neurologic deterioration.",
                priority="critical",
                tags=("motor",),
            ),
            OptionSeed(
                statement="A sudden decrease in level of consciousness",
                rationale="LOC decline is the earliest and most important sign of worsening ICP.",
                priority="critical",
                tags=("loc",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Temperature of 99.2 F (37.3 C)",
                rationale="Low-grade fever may be expected and is not the top priority.",
                priority="supportive",
                tags=("expected",),
            ),
            OptionSeed(
                statement="Urine output of 55 mL/hour",
                rationale="Adequate urine output does not reflect ICP status directly.",
                priority="supportive",
                tags=("stable",),
            ),
            OptionSeed(
                statement="ICP waveform showing regular P1>P2 pattern",
                rationale="A normal waveform indicates stable compliance.",
                priority="supportive",
                tags=("stable",),
            ),
            OptionSeed(
                statement="Client reports headache rated 4/10",
                rationale="Mild headache is common in neuro clients but not emergent on its own.",
                priority="supportive",
                tags=("expected",),
            ),
        ],
        default_difficulty="hard",
        cognitive_level="Analysis",
        references=("Neuro critical care", "ICP monitoring"),
    ),
    Blueprint(
        id="infection_prevention_postop",
        category="Safety and Infection Control",
        theme="Preventing surgical site infection",
        stems=[
            "Which action should the nurse take first to reduce infection risk?",
            "What instruction best protects the client from a postoperative wound infection?",
            "Which observation requires intervention to maintain asepsis?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 54-year-old two days after colorectal surgery",
                setting="a surgical unit",
                therapy="a closed suction drain",
                context="The client is learning to care for the incision at home.",
                monitoring_focus="incision care",
            ),
            ScenarioSeed(
                patient_overview="a 62-year-old after knee arthroplasty",
                setting="an orthopedic unit",
                therapy="a negative pressure dressing",
                context="Family members are assisting with repositioning.",
                monitoring_focus="aseptic technique",
            ),
        ],
        question_angles=[
            "reinforcing hand hygiene",
            "recognizing breaks in sterile technique",
            "prioritizing dressing care",
        ],
        critical_cues=[
            OptionSeed(
                statement="Perform hand hygiene and don clean gloves before touching the incision",
                rationale="Hand hygiene remains the highest-leverage intervention to prevent infection.",
                priority="critical",
                tags=("hand-hygiene",),
            ),
            OptionSeed(
                statement="Teach the client to report increasing drainage volume or odor",
                rationale="Early reporting of abnormal drainage supports rapid treatment.",
                priority="critical",
                tags=("teaching",),
            ),
            OptionSeed(
                statement="Keep the incision covered when around pets or crowded areas",
                rationale="Barrier protection reduces exposure to environmental contaminants.",
                priority="critical",
                tags=("barrier",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Pack the incision with cotton balls soaked in peroxide",
                rationale="Peroxide damages new tissue and cotton sheds fibers, raising risk.",
                priority="supportive",
                tags=("unsafe",),
            ),
            OptionSeed(
                statement="Change the dressing only if it becomes fully saturated",
                rationale="Waiting for saturation allows bacterial proliferation.",
                priority="supportive",
                tags=("delay",),
            ),
            OptionSeed(
                statement="Massage around the incision to promote circulation",
                rationale="Manipulation can disrupt the wound seal and should be avoided.",
                priority="supportive",
                tags=("unsafe",),
            ),
        ],
        default_difficulty="medium",
        cognitive_level="Application",
        references=("CDC surgical site bundle",),
    ),
    Blueprint(
        id="magnesium_sulfate_precautions",
        category="Pharmacological and Parenteral Therapies",
        theme="Magnesium sulfate toxicity prevention",
        stems=[
            "Which assessment should prompt the nurse to stop the infusion and follow the emergency protocol?",
            "What finding is most concerning while monitoring {therapy}?",
            "Which cue signals magnesium sulfate toxicity?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 30-year-old at 33 weeks' gestation with severe preeclampsia",
                setting="a labor and delivery suite",
                therapy="magnesium sulfate at 2 g/hour",
                context="The nurse performs hourly assessments while antihypertensives run concurrently.",
                monitoring_focus="seizure prophylaxis",
            ),
            ScenarioSeed(
                patient_overview="a 26-year-old with postpartum hypertension",
                setting="a high-risk obstetric unit",
                therapy="magnesium sulfate infusion",
                context="Deep tendon reflexes and respiratory status are trending every 30 minutes.",
                monitoring_focus="toxicity surveillance",
            ),
        ],
        question_angles=[
            "identifying early magnesium toxicity",
            "protecting the airway during magnesium therapy",
            "knowing when to administer calcium gluconate",
        ],
        critical_cues=[
            OptionSeed(
                statement="Respiratory rate that falls to 10 breaths per minute",
                rationale="Respiratory depression is a hallmark of magnesium toxicity and requires action.",
                priority="critical",
                tags=("respiratory", "toxicity"),
            ),
            OptionSeed(
                statement="Absent patellar reflexes noted on exam",
                rationale="Loss of deep tendon reflexes precedes respiratory collapse and mandates stopping the infusion.",
                priority="critical",
                tags=("neuro",),
            ),
            OptionSeed(
                statement="Urine output that has dropped below 25 mL/hour",
                rationale="Renal insufficiency allows magnesium to accumulate, increasing toxicity risk.",
                priority="critical",
                tags=("renal",),
            ),
            OptionSeed(
                statement="Serum magnesium level of 9.0 mg/dL",
                rationale="Levels above the therapeutic range of 4-7 mg/dL indicate toxicity.",
                priority="critical",
                tags=("labs",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Client reports feeling warm and flushed",
                rationale="Flushing is an expected side effect and not a reason to stop therapy.",
                priority="supportive",
                tags=("expected",),
            ),
            OptionSeed(
                statement="Blood pressure decreases from 158/102 to 146/94",
                rationale="A moderate blood pressure drop is desired in severe preeclampsia.",
                priority="supportive",
                tags=("therapeutic",),
            ),
            OptionSeed(
                statement="Magnesium level reported at 5.5 mg/dL",
                rationale="Within therapeutic range; continue to monitor.",
                priority="supportive",
                tags=("therapeutic",),
            ),
            OptionSeed(
                statement="Client describes mild nausea",
                rationale="Nausea can occur but is not the priority toxicity cue.",
                priority="supportive",
                tags=("expected",),
            ),
        ],
        default_difficulty="hard",
        cognitive_level="Analysis",
        references=("Magnesium sulfate protocol", "Perinatal safety"),
    ),
    Blueprint(
        id="heart_failure_diuretics",
        category="Physiological Adaptation",
        theme="IV diuretic response in heart failure",
        stems=[
            "Which assessment finding shows the diuretic is causing harm?",
            "What cue should the nurse address first during high-dose diuresis?",
            "Which data require rapid provider notification while {therapy}?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 74-year-old with acute decompensated heart failure",
                setting="a cardiac step-down unit",
                therapy="IV furosemide bolus every 4 hours",
                context="The client has lost 1.5 kg since admission and labs are pending.",
                monitoring_focus="aggressive diuresis",
            ),
            ScenarioSeed(
                patient_overview="a 60-year-old with pulmonary edema",
                setting="an ICU",
                therapy="continuous bumetanide infusion",
                context="Strict intake and output and telemetry monitoring are in place.",
                monitoring_focus="loop diuretic therapy",
            ),
        ],
        question_angles=[
            "preventing electrolyte complications",
            "monitoring ototoxicity",
            "evaluating fluid removal effectiveness",
        ],
        critical_cues=[
            OptionSeed(
                statement="Potassium level of 2.9 mEq/L",
                rationale="Severe hypokalemia predisposes the client to lethal arrhythmias.",
                priority="critical",
                tags=("labs", "electrolyte"),
            ),
            OptionSeed(
                statement="Client reports ringing in the ears after the push dose",
                rationale="Tinnitus is a sign of loop diuretic ototoxicity and requires intervention.",
                priority="critical",
                tags=("ototoxicity",),
            ),
            OptionSeed(
                statement="Blood pressure drops to 82/50 mm Hg with dizziness",
                rationale="Symptomatic hypotension indicates excessive volume removal.",
                priority="critical",
                tags=("hemodynamic",),
            ),
            OptionSeed(
                statement="Serum creatinine rising from 1.0 to 1.8 mg/dL overnight",
                rationale="Renal dysfunction suggests diuresis is impairing perfusion.",
                priority="critical",
                tags=("renal",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Lung sounds improved from coarse crackles to fine bibasilar crackles",
                rationale="Indicates therapy is trending in the right direction.",
                priority="supportive",
                tags=("improving",),
            ),
            OptionSeed(
                statement="Net negative output of 1 liter over 8 hours",
                rationale="Expected response to IV diuretics for pulmonary edema.",
                priority="supportive",
                tags=("expected",),
            ),
            OptionSeed(
                statement="Sodium level of 134 mEq/L",
                rationale="Mild hyponatremia can occur and is monitored but not emergent.",
                priority="supportive",
                tags=("labs",),
            ),
            OptionSeed(
                statement="Client requests assistance to the bathroom every two hours",
                rationale="Frequent urination is an expected effect of diuretics.",
                priority="supportive",
                tags=("expected",),
            ),
        ],
        default_difficulty="medium",
        cognitive_level="Application",
        references=("Heart failure core measures", "Loop diuretic precautions"),
    ),
    Blueprint(
        id="pediatric_resp_distress",
        category="Health Promotion and Maintenance",
        theme="Early recognition of pediatric respiratory failure",
        stems=[
            "Which assessment requires immediate intervention?",
            "What observation indicates the child is tiring?",
            "Which cue suggests impending respiratory failure?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 9-month-old with bronchiolitis",
                setting="a pediatric step-down unit",
                therapy="high-flow nasal cannula oxygen",
                context="Parents are at the bedside during evening assessments.",
                monitoring_focus="respiratory status",
            ),
            ScenarioSeed(
                patient_overview="a 4-year-old with asthma exacerbation",
                setting="an emergency department",
                therapy="nebulized beta-agonists and steroids",
                context="The child has been receiving back-to-back treatments.",
                monitoring_focus="airway fatigue",
            ),
        ],
        question_angles=[
            "recognizing pediatric respiratory fatigue",
            "prioritizing airway cues",
            "escalating care for hypoxia",
        ],
        critical_cues=[
            OptionSeed(
                statement="Suprasternal and intercostal retractions that suddenly diminish",
                rationale="A sudden drop in retractions signals diaphragmatic fatigue and impending failure.",
                priority="critical",
                tags=("work-of-breathing",),
            ),
            OptionSeed(
                statement="Grunting with each exhalation",
                rationale="Grunting indicates the child is trying to maintain airway pressure.",
                priority="critical",
                tags=("respiratory",),
            ),
            OptionSeed(
                statement="Pulse oximetry falling to 88% despite oxygen support",
                rationale="Persistent hypoxemia warrants escalation.",
                priority="critical",
                tags=("oxygenation",),
            ),
            OptionSeed(
                statement="Altered mental status with lethargy",
                rationale="Decreased responsiveness signals severe hypoxia and CO2 retention.",
                priority="critical",
                tags=("neurologic",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Respiratory rate of 34/min with even chest rise",
                rationale="Within expected range for an infant under stress.",
                priority="supportive",
                tags=("expected",),
            ),
            OptionSeed(
                statement="Mild inspiratory wheezing improving after treatment",
                rationale="Improving wheeze is desirable.",
                priority="supportive",
                tags=("improving",),
            ),
            OptionSeed(
                statement="Heart rate 160/min while crying",
                rationale="Tachycardia during distress is expected and not the most urgent cue.",
                priority="supportive",
                tags=("expected",),
            ),
            OptionSeed(
                statement="Capillary refill under 2 seconds",
                rationale="Normal perfusion indicates stability.",
                priority="supportive",
                tags=("stable",),
            ),
        ],
        default_difficulty="hard",
        cognitive_level="Analysis",
        references=("Pediatric airway management",),
    ),
    Blueprint(
        id="mental_health_suicide_precautions",
        category="Psychosocial Integrity",
        theme="Suicide risk management",
        stems=[
            "Which statement requires the fastest action?",
            "What observation places the client at highest risk for self-harm?",
            "Which cue indicates the safety plan is failing?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 17-year-old admitted for major depressive disorder",
                setting="an inpatient behavioral health unit",
                therapy="SSRIs and cognitive behavioral therapy",
                context="The client is on 15-minute checks.",
                monitoring_focus="suicide precautions",
            ),
            ScenarioSeed(
                patient_overview="a 45-year-old recently divorced adult",
                setting="an outpatient crisis center",
                therapy="day-treatment program",
                context="Session notes mention escalating hopelessness.",
                monitoring_focus="safety planning",
            ),
        ],
        question_angles=[
            "identifying imminent suicide risk",
            "safety planning communication",
            "managing contraband and supervision",
        ],
        critical_cues=[
            OptionSeed(
                statement="Client states, 'I finally figured out how to make the pain stop tonight.'",
                rationale="A specific statement about ending life tonight indicates imminent risk.",
                priority="critical",
                tags=("verbalization",),
            ),
            OptionSeed(
                statement="Client gives cherished belongings to peers",
                rationale="Giving away possessions is a warning sign of suicide intent.",
                priority="critical",
                tags=("behavior",),
            ),
            OptionSeed(
                statement="Client hoards medications instead of taking them",
                rationale="Medication hoarding suggests preparation for overdose.",
                priority="critical",
                tags=("contraband",),
            ),
            OptionSeed(
                statement="Client refuses to contract for safety after disclosing a lethal plan",
                rationale="Refusal indicates the plan is active and requires continuous observation.",
                priority="critical",
                tags=("safety",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Client journals feelings during group therapy",
                rationale="Therapeutic journaling is protective, not high-risk.",
                priority="supportive",
                tags=("coping",),
            ),
            OptionSeed(
                statement="Client requests extra art supplies for distraction",
                rationale="Healthy distraction indicates engagement.",
                priority="supportive",
                tags=("coping",),
            ),
            OptionSeed(
                statement="Client attends all therapy groups and participates",
                rationale="Active participation reduces risk rather than increases it.",
                priority="supportive",
                tags=("engagement",),
            ),
            OptionSeed(
                statement="Client sleeps six hours overnight",
                rationale="Rested behavior is not a warning sign by itself.",
                priority="supportive",
                tags=("sleep",),
            ),
        ],
        default_difficulty="medium",
        cognitive_level="Analysis",
        references=("Suicide prevention guidelines",),
    ),
    # MATERNAL-CHILD HEALTH
    Blueprint(
        id="labor_fetal_monitoring",
        category="Health Promotion and Maintenance",
        theme="Intrapartum fetal heart rate interpretation",
        stems=[
            "Which fetal heart rate pattern requires immediate intervention?",
            "What action should the nurse take first upon observing this tracing?",
            "Which finding on the monitor strip indicates fetal compromise?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 28-year-old G2P1 at 39 weeks' gestation in active labor",
                setting="a labor and delivery suite",
                therapy="continuous external fetal monitoring",
                context="Contractions are occurring every 3 minutes lasting 60 seconds.",
                monitoring_focus="fetal well-being",
            ),
            ScenarioSeed(
                patient_overview="a 32-year-old primigravida with epidural analgesia",
                setting="a birthing center",
                therapy="internal fetal scalp electrode monitoring",
                context="The client is fully dilated and beginning to push.",
                monitoring_focus="second stage labor tolerance",
            ),
        ],
        question_angles=[
            "recognizing Category III fetal heart rate patterns",
            "implementing intrauterine resuscitation",
            "escalating care for non-reassuring tracings",
        ],
        critical_cues=[
            OptionSeed(
                statement="Recurrent late decelerations with minimal variability",
                rationale="Late decelerations indicate uteroplacental insufficiency and fetal hypoxia.",
                priority="critical",
                tags=("fhr-pattern",),
            ),
            OptionSeed(
                statement="Prolonged deceleration lasting 4 minutes with baseline below 90 bpm",
                rationale="Prolonged bradycardia suggests cord compression or placental abruption.",
                priority="critical",
                tags=("emergency",),
            ),
            OptionSeed(
                statement="Absent variability with recurrent variable decelerations",
                rationale="Loss of variability with decelerations signals severe fetal acidosis.",
                priority="critical",
                tags=("fhr-pattern",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Moderate variability with accelerations during fetal movement",
                rationale="This is a reassuring Category I pattern indicating fetal well-being.",
                priority="supportive",
                tags=("reassuring",),
            ),
            OptionSeed(
                statement="Early decelerations that mirror contraction pattern",
                rationale="Early decelerations are benign and caused by head compression.",
                priority="supportive",
                tags=("benign",),
            ),
            OptionSeed(
                statement="Baseline fetal heart rate of 145 bpm",
                rationale="Within normal range of 110-160 bpm.",
                priority="supportive",
                tags=("normal",),
            ),
        ],
        default_difficulty="hard",
        cognitive_level="Analysis",
        references=("AWHONN fetal monitoring",),
    ),
    Blueprint(
        id="newborn_hypoglycemia",
        category="Physiological Adaptation",
        theme="Neonatal glucose management",
        stems=[
            "Which newborn is at highest risk for hypoglycemia?",
            "What intervention should the nurse implement first for this at-risk infant?",
            "Which assessment finding requires glucose screening?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 2-hour-old term infant born to a mother with gestational diabetes",
                setting="a newborn nursery",
                therapy="early breastfeeding attempts",
                context="The infant weighed 4200 grams at birth.",
                monitoring_focus="glucose stability",
            ),
            ScenarioSeed(
                patient_overview="a 36-week gestation infant, appropriate for gestational age",
                setting="a level II NICU",
                therapy="IV glucose supplementation",
                context="The infant has been jittery with a high-pitched cry.",
                monitoring_focus="preventing seizures",
            ),
        ],
        question_angles=[
            "identifying infants at risk for hypoglycemia",
            "recognizing signs of neonatal hypoglycemia",
            "implementing early feeding strategies",
        ],
        critical_cues=[
            OptionSeed(
                statement="Jitteriness, lethargy, and poor feeding within the first hours of life",
                rationale="These are classic signs of neonatal hypoglycemia requiring immediate glucose check.",
                priority="critical",
                tags=("clinical-signs",),
            ),
            OptionSeed(
                statement="Blood glucose level of 35 mg/dL at 1 hour of age",
                rationale="Below 40-45 mg/dL requires intervention to prevent neurologic damage.",
                priority="critical",
                tags=("labs",),
            ),
            OptionSeed(
                statement="Initiate early and frequent breastfeeding every 2-3 hours",
                rationale="Early feeding is the primary prevention strategy for at-risk newborns.",
                priority="critical",
                tags=("intervention",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Term infant born via scheduled cesarean section",
                rationale="Mode of delivery alone does not create high hypoglycemia risk.",
                priority="supportive",
                tags=("low-risk",),
            ),
            OptionSeed(
                statement="Glucose level of 55 mg/dL at 4 hours of life",
                rationale="Within acceptable range for a newborn after initial transition.",
                priority="supportive",
                tags=("normal",),
            ),
            OptionSeed(
                statement="Pink, active infant with strong cry",
                rationale="These are reassuring signs not consistent with hypoglycemia.",
                priority="supportive",
                tags=("stable",),
            ),
        ],
        default_difficulty="medium",
        cognitive_level="Application",
        references=("Neonatal glucose protocols",),
    ),
    # CRITICAL CARE
    Blueprint(
        id="septic_shock_management",
        category="Physiological Adaptation",
        theme="Early sepsis recognition and resuscitation",
        stems=[
            "Which assessment finding is the earliest indicator of septic shock?",
            "What intervention has the highest priority in the first hour?",
            "Which laboratory value best indicates adequate resuscitation?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 55-year-old with suspected urosepsis",
                setting="an emergency department",
                therapy="broad-spectrum antibiotics and IV fluid bolus",
                context="The client arrived with fever, confusion, and hypotension.",
                monitoring_focus="sepsis bundle completion",
            ),
            ScenarioSeed(
                patient_overview="a 68-year-old post-op day 3 from bowel resection",
                setting="a surgical ICU",
                therapy="vasopressor support",
                context="Blood cultures are pending and lactate is 4.2 mmol/L.",
                monitoring_focus="shock reversal",
            ),
        ],
        question_angles=[
            "implementing sepsis bundles",
            "titrating vasopressors",
            "monitoring perfusion markers",
        ],
        critical_cues=[
            OptionSeed(
                statement="Administer 30 mL/kg crystalloid bolus within the first 3 hours",
                rationale="Early aggressive fluid resuscitation is a core sepsis bundle element.",
                priority="critical",
                tags=("resuscitation",),
            ),
            OptionSeed(
                statement="Obtain blood cultures before initiating antibiotics",
                rationale="Cultures must be drawn before antibiotics to identify the organism.",
                priority="critical",
                tags=("diagnostics",),
            ),
            OptionSeed(
                statement="Lactate level trending down from 4.2 to 2.1 mmol/L",
                rationale="Clearing lactate indicates improved tissue perfusion.",
                priority="critical",
                tags=("labs",),
            ),
            OptionSeed(
                statement="Mean arterial pressure drops below 65 mm Hg despite fluids",
                rationale="Persistent hypotension after fluid resuscitation requires vasopressors.",
                priority="critical",
                tags=("hemodynamic",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="White blood cell count of 18,000/mm³",
                rationale="Leukocytosis supports infection but does not guide immediate therapy.",
                priority="supportive",
                tags=("labs",),
            ),
            OptionSeed(
                statement="Urine output of 35 mL/hour after fluid bolus",
                rationale="Improving output is encouraging but not the primary resuscitation target.",
                priority="supportive",
                tags=("improving",),
            ),
            OptionSeed(
                statement="Temperature of 101.8°F (38.8°C)",
                rationale="Fever is expected with sepsis but does not dictate resuscitation steps.",
                priority="supportive",
                tags=("expected",),
            ),
        ],
        default_difficulty="hard",
        cognitive_level="Analysis",
        references=("Surviving Sepsis Campaign",),
    ),
    Blueprint(
        id="mechanical_ventilation_weaning",
        category="Physiological Adaptation",
        theme="Ventilator weaning readiness",
        stems=[
            "Which parameter indicates the client is ready for a spontaneous breathing trial?",
            "What finding would cause the nurse to abort the weaning attempt?",
            "Which assessment supports successful extubation?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 58-year-old on mechanical ventilation for 5 days post-ARDS",
                setting="a medical ICU",
                therapy="pressure support ventilation",
                context="Sedation has been lightened and the client follows commands.",
                monitoring_focus="weaning readiness",
            ),
            ScenarioSeed(
                patient_overview="a 70-year-old recovering from respiratory failure",
                setting="a critical care step-down unit",
                therapy="spontaneous breathing trial",
                context="The trial has been ongoing for 20 minutes.",
                monitoring_focus="trial tolerance",
            ),
        ],
        question_angles=[
            "assessing weaning criteria",
            "monitoring spontaneous breathing trials",
            "recognizing trial failure",
        ],
        critical_cues=[
            OptionSeed(
                statement="Rapid shallow breathing index below 105 with PEEP of 5 cm H2O",
                rationale="Low RSBI indicates adequate respiratory muscle strength for weaning.",
                priority="critical",
                tags=("criteria",),
            ),
            OptionSeed(
                statement="PaO2/FiO2 ratio greater than 200",
                rationale="P/F ratio above 200 demonstrates adequate oxygenation for extubation.",
                priority="critical",
                tags=("oxygenation",),
            ),
            OptionSeed(
                statement="Respiratory rate climbing from 18 to 35/min with accessory muscle use",
                rationale="Tachypnea and increased work signal trial failure.",
                priority="critical",
                tags=("failure",),
            ),
            OptionSeed(
                statement="Strong cough with copious secretions managed independently",
                rationale="Airway protection is essential for successful extubation.",
                priority="critical",
                tags=("airway",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Chest X-ray showing bibasilar atelectasis",
                rationale="Minor atelectasis is common and does not preclude weaning.",
                priority="supportive",
                tags=("imaging",),
            ),
            OptionSeed(
                statement="Heart rate increase from 78 to 88/min during trial",
                rationale="Mild tachycardia is expected and tolerable during spontaneous breathing.",
                priority="supportive",
                tags=("expected",),
            ),
            OptionSeed(
                statement="Client reports feeling anxious during the trial",
                rationale="Some anxiety is normal but does not mandate stopping if vitals are stable.",
                priority="supportive",
                tags=("expected",),
            ),
        ],
        default_difficulty="hard",
        cognitive_level="Analysis",
        references=("Ventilator liberation protocols",),
    ),
    # MEDICAL-SURGICAL
    Blueprint(
        id="stroke_tpa_eligibility",
        category="Pharmacological and Parenteral Therapies",
        theme="Tissue plasminogen activator administration",
        stems=[
            "Which assessment finding is an absolute contraindication to tPA?",
            "What must the nurse verify before administering thrombolytic therapy?",
            "Which client statement would exclude them from receiving tPA?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 62-year-old presenting with left-sided weakness and slurred speech",
                setting="an emergency department",
                therapy="alteplase infusion",
                context="Symptom onset was 90 minutes ago and CT shows no hemorrhage.",
                monitoring_focus="thrombolytic eligibility",
            ),
            ScenarioSeed(
                patient_overview="a 55-year-old with sudden aphasia and facial droop",
                setting="a comprehensive stroke center",
                therapy="consideration for IV tPA",
                context="The family is uncertain about the exact time symptoms began.",
                monitoring_focus="inclusion criteria",
            ),
        ],
        question_angles=[
            "applying tPA eligibility criteria",
            "recognizing contraindications",
            "timing therapeutic window",
        ],
        critical_cues=[
            OptionSeed(
                statement="Blood pressure of 220/120 mm Hg that remains elevated despite treatment",
                rationale="Uncontrolled hypertension above 185/110 is a contraindication due to bleeding risk.",
                priority="critical",
                tags=("contraindication",),
            ),
            OptionSeed(
                statement="Client had major surgery 10 days ago",
                rationale="Recent major surgery within 14 days increases hemorrhage risk.",
                priority="critical",
                tags=("contraindication",),
            ),
            OptionSeed(
                statement="Onset time documented at 4.5 hours ago",
                rationale="tPA must be given within 3-4.5 hours of symptom onset.",
                priority="critical",
                tags=("timing",),
            ),
            OptionSeed(
                statement="Platelet count of 88,000/mm³",
                rationale="Thrombocytopenia below 100,000 is a contraindication.",
                priority="critical",
                tags=("labs",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="NIH Stroke Scale score of 8",
                rationale="Moderate stroke severity supports tPA benefit but is not exclusionary.",
                priority="supportive",
                tags=("assessment",),
            ),
            OptionSeed(
                statement="Client takes daily aspirin 81 mg",
                rationale="Low-dose aspirin is not a contraindication to tPA.",
                priority="supportive",
                tags=("medication",),
            ),
            OptionSeed(
                statement="Blood glucose level of 180 mg/dL",
                rationale="Hyperglycemia should be managed but does not exclude tPA.",
                priority="supportive",
                tags=("labs",),
            ),
        ],
        default_difficulty="hard",
        cognitive_level="Analysis",
        references=("AHA stroke guidelines",),
    ),
    Blueprint(
        id="copd_exacerbation",
        category="Physiological Adaptation",
        theme="COPD exacerbation management",
        stems=[
            "Which intervention should the nurse implement first?",
            "What assessment finding indicates the client's status is worsening?",
            "Which oxygen delivery method is most appropriate?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 68-year-old with COPD admitted for increased dyspnea and purulent sputum",
                setting="a medical unit",
                therapy="nebulized bronchodilators and systemic corticosteroids",
                context="The client is tripod positioning and using pursed-lip breathing.",
                monitoring_focus="respiratory status",
            ),
            ScenarioSeed(
                patient_overview="a 72-year-old with home oxygen presenting with worsening cough",
                setting="an emergency department",
                therapy="antibiotics for suspected bacterial superinfection",
                context="Oxygen saturation is 88% on room air.",
                monitoring_focus="oxygenation targets",
            ),
        ],
        question_angles=[
            "preventing CO2 retention",
            "recognizing respiratory fatigue",
            "optimizing bronchodilator therapy",
        ],
        critical_cues=[
            OptionSeed(
                statement="Maintain oxygen saturation between 88-92% using low-flow oxygen",
                rationale="COPD patients rely on hypoxic drive; excessive oxygen can suppress respirations.",
                priority="critical",
                tags=("oxygenation",),
            ),
            OptionSeed(
                statement="Decreasing level of consciousness with CO2 retention",
                rationale="Mental status changes indicate hypercapnic respiratory failure.",
                priority="critical",
                tags=("deterioration",),
            ),
            OptionSeed(
                statement="Administer methylprednisolone to reduce airway inflammation",
                rationale="Corticosteroids shorten exacerbation duration and are first-line therapy.",
                priority="critical",
                tags=("pharmacology",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Increase oxygen to maintain saturation above 95%",
                rationale="Excessive oxygenation can worsen hypercapnia in COPD.",
                priority="supportive",
                tags=("unsafe",),
            ),
            OptionSeed(
                statement="Respiratory rate of 24/min with prolonged expiration",
                rationale="Expected findings during exacerbation but not the priority concern.",
                priority="supportive",
                tags=("expected",),
            ),
            OptionSeed(
                statement="Bilateral expiratory wheezes throughout lung fields",
                rationale="Consistent with COPD baseline and does not indicate acute worsening.",
                priority="supportive",
                tags=("baseline",),
            ),
        ],
        default_difficulty="medium",
        cognitive_level="Application",
        references=("GOLD COPD guidelines",),
    ),
    Blueprint(
        id="gi_bleed_assessment",
        category="Physiological Adaptation",
        theme="Upper GI bleeding management",
        stems=[
            "Which assessment finding indicates hypovolemic shock?",
            "What intervention takes priority for this client?",
            "Which diagnostic test should the nurse anticipate first?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 56-year-old with a history of alcohol use disorder presenting with hematemesis",
                setting="an emergency department",
                therapy="two large-bore IVs and crystalloid resuscitation",
                context="The client reports black tarry stools for two days.",
                monitoring_focus="volume status",
            ),
            ScenarioSeed(
                patient_overview="a 70-year-old taking NSAIDs for arthritis with sudden weakness",
                setting="a medical unit",
                therapy="IV proton pump inhibitor infusion",
                context="Hemoglobin dropped from 12 to 8 g/dL overnight.",
                monitoring_focus="bleeding control",
            ),
        ],
        question_angles=[
            "recognizing hypovolemic shock",
            "prioritizing resuscitation",
            "preparing for endoscopy",
        ],
        critical_cues=[
            OptionSeed(
                statement="Heart rate 120/min with blood pressure 88/54 mm Hg",
                rationale="Tachycardia with hypotension indicates significant volume loss.",
                priority="critical",
                tags=("shock",),
            ),
            OptionSeed(
                statement="Establish large-bore IV access and initiate rapid fluid replacement",
                rationale="Volume resuscitation is the immediate priority in hemorrhage.",
                priority="critical",
                tags=("intervention",),
            ),
            OptionSeed(
                statement="Type and crossmatch for packed red blood cells",
                rationale="Prepare for transfusion as hemoglobin is likely to drop further.",
                priority="critical",
                tags=("lab-prep",),
            ),
            OptionSeed(
                statement="Altered mental status with cool, clammy skin",
                rationale="Signs of inadequate cerebral perfusion from shock.",
                priority="critical",
                tags=("perfusion",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Nasogastric tube insertion to assess gastric contents",
                rationale="Helpful but not the immediate priority over resuscitation.",
                priority="supportive",
                tags=("assessment",),
            ),
            OptionSeed(
                statement="Client reports epigastric pain",
                rationale="Expected with GI bleed but does not guide emergent treatment.",
                priority="supportive",
                tags=("expected",),
            ),
            OptionSeed(
                statement="Bowel sounds present in all four quadrants",
                rationale="Not relevant to acute hemorrhage management.",
                priority="supportive",
                tags=("non-urgent",),
            ),
        ],
        default_difficulty="medium",
        cognitive_level="Application",
        references=("GI hemorrhage protocols",),
    ),
    # RENAL & GENITOURINARY
    Blueprint(
        id="aki_recognition",
        category="Physiological Adaptation",
        theme="Acute kidney injury identification",
        stems=[
            "Which laboratory finding is the earliest indicator of acute kidney injury?",
            "What assessment data requires immediate intervention?",
            "Which client is at highest risk for developing AKI?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 65-year-old post-cardiac catheterization with contrast dye",
                setting="a cardiac step-down unit",
                therapy="IV hydration protocol",
                context="Urine output has decreased to 20 mL/hour over the past 4 hours.",
                monitoring_focus="renal function",
            ),
            ScenarioSeed(
                patient_overview="a 58-year-old with septic shock on vasopressor support",
                setting="a medical ICU",
                therapy="norepinephrine infusion",
                context="Creatinine rose from 1.1 to 2.4 mg/dL in 24 hours.",
                monitoring_focus="kidney perfusion",
            ),
        ],
        question_angles=[
            "identifying AKI risk factors",
            "monitoring renal biomarkers",
            "preventing contrast-induced nephropathy",
        ],
        critical_cues=[
            OptionSeed(
                statement="Serum creatinine increase of 0.3 mg/dL or more within 48 hours",
                rationale="Meets KDIGO criteria for acute kidney injury diagnosis.",
                priority="critical",
                tags=("labs",),
            ),
            OptionSeed(
                statement="Urine output less than 0.5 mL/kg/hour for 6 consecutive hours",
                rationale="Oliguria is a defining characteristic of AKI.",
                priority="critical",
                tags=("output",),
            ),
            OptionSeed(
                statement="Potassium level of 6.2 mEq/L with peaked T waves on ECG",
                rationale="Hyperkalemia with cardiac changes is life-threatening in AKI.",
                priority="critical",
                tags=("complication",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="BUN/creatinine ratio of 15:1",
                rationale="Normal ratio does not rule out AKI but provides context.",
                priority="supportive",
                tags=("labs",),
            ),
            OptionSeed(
                statement="Urine specific gravity of 1.010",
                rationale="May indicate isosthenuria but not specific enough alone.",
                priority="supportive",
                tags=("urinalysis",),
            ),
            OptionSeed(
                statement="Client reports nausea and fatigue",
                rationale="Common with uremia but non-specific symptoms.",
                priority="supportive",
                tags=("symptoms",),
            ),
        ],
        default_difficulty="medium",
        cognitive_level="Application",
        references=("KDIGO AKI guidelines",),
    ),
    # ENDOCRINE
    Blueprint(
        id="dka_management",
        category="Physiological Adaptation",
        theme="Diabetic ketoacidosis treatment",
        stems=[
            "Which intervention should the nurse implement first?",
            "What laboratory finding indicates DKA is resolving?",
            "Which complication requires immediate recognition during treatment?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 19-year-old with type 1 diabetes presenting with Kussmaul respirations",
                setting="an emergency department",
                therapy="insulin infusion protocol",
                context="Blood glucose is 520 mg/dL with pH 7.18 and positive ketones.",
                monitoring_focus="acidosis correction",
            ),
            ScenarioSeed(
                patient_overview="a 24-year-old admitted for DKA now on hour 8 of treatment",
                setting="a medical ICU",
                therapy="IV regular insulin and potassium replacement",
                context="Glucose has dropped to 180 mg/dL but pH remains 7.28.",
                monitoring_focus="anion gap closure",
            ),
        ],
        question_angles=[
            "implementing DKA protocols",
            "preventing cerebral edema",
            "monitoring electrolyte shifts",
        ],
        critical_cues=[
            OptionSeed(
                statement="Initiate 0.9% normal saline bolus before starting insulin",
                rationale="Fluid resuscitation must precede insulin to prevent vascular collapse.",
                priority="critical",
                tags=("resuscitation",),
            ),
            OptionSeed(
                statement="Anion gap closed with bicarbonate above 18 mEq/L",
                rationale="Closure of anion gap indicates resolution of ketoacidosis.",
                priority="critical",
                tags=("resolution",),
            ),
            OptionSeed(
                statement="New onset headache, bradycardia, and altered mental status",
                rationale="Signs of cerebral edema, a life-threatening complication of DKA treatment.",
                priority="critical",
                tags=("complication",),
            ),
            OptionSeed(
                statement="Add potassium to IV fluids once level drops below 5.3 mEq/L",
                rationale="Insulin drives potassium intracellularly; replacement prevents cardiac arrhythmias.",
                priority="critical",
                tags=("electrolyte",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Continue insulin infusion until anion gap closes, not just until glucose normalizes",
                rationale="Important teaching point but glucose will be addressed with dextrose addition.",
                priority="supportive",
                tags=("protocol",),
            ),
            OptionSeed(
                statement="Blood glucose of 180 mg/dL after 6 hours of treatment",
                rationale="Expected response; add dextrose to fluids to prevent hypoglycemia.",
                priority="supportive",
                tags=("expected",),
            ),
            OptionSeed(
                statement="Client reports extreme thirst",
                rationale="Expected symptom that will improve with hydration.",
                priority="supportive",
                tags=("symptom",),
            ),
        ],
        default_difficulty="hard",
        cognitive_level="Analysis",
        references=("ADA DKA guidelines",),
    ),
    # ONCOLOGY
    Blueprint(
        id="tumor_lysis_syndrome",
        category="Physiological Adaptation",
        theme="Tumor lysis syndrome prevention",
        stems=[
            "Which laboratory finding is most concerning for tumor lysis syndrome?",
            "What intervention should the nurse prioritize?",
            "Which client is at highest risk for this complication?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 52-year-old beginning chemotherapy for acute lymphoblastic leukemia",
                setting="an oncology unit",
                therapy="aggressive IV hydration and allopurinol",
                context="Pre-treatment labs show high white blood cell count with large tumor burden.",
                monitoring_focus="metabolic complications",
            ),
            ScenarioSeed(
                patient_overview="a 45-year-old on day 2 of chemotherapy for Burkitt lymphoma",
                setting="a cancer center",
                therapy="rasburicase administration",
                context="Urine output has been adequate at 150 mL/hour.",
                monitoring_focus="TLS prevention",
            ),
        ],
        question_angles=[
            "recognizing TLS triad",
            "preventing uric acid nephropathy",
            "monitoring cardiac effects of hyperkalemia",
        ],
        critical_cues=[
            OptionSeed(
                statement="Potassium 6.8 mEq/L, phosphorus 7.2 mg/dL, calcium 6.9 mg/dL",
                rationale="The classic TLS triad: hyperkalemia, hyperphosphatemia, hypocalcemia.",
                priority="critical",
                tags=("labs",),
            ),
            OptionSeed(
                statement="Uric acid level of 12 mg/dL with decreased urine output",
                rationale="Severe hyperuricemia can cause acute kidney injury from crystal deposition.",
                priority="critical",
                tags=("renal",),
            ),
            OptionSeed(
                statement="Maintain urine output of at least 2-3 L/day with IV hydration",
                rationale="High urine flow prevents crystal formation and flushes metabolites.",
                priority="critical",
                tags=("prevention",),
            ),
            OptionSeed(
                statement="Cardiac monitor showing peaked T waves and widened QRS",
                rationale="Life-threatening hyperkalemia requires emergent treatment.",
                priority="critical",
                tags=("cardiac",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="LDH elevated at twice the upper limit of normal",
                rationale="Supports TLS diagnosis but is not specific.",
                priority="supportive",
                tags=("labs",),
            ),
            OptionSeed(
                statement="Client reports muscle cramps and tingling",
                rationale="May indicate electrolyte imbalance but not immediately life-threatening.",
                priority="supportive",
                tags=("symptoms",),
            ),
            OptionSeed(
                statement="Urine pH of 6.5",
                rationale="Alkalinization was previously recommended but is no longer standard practice.",
                priority="supportive",
                tags=("outdated",),
            ),
        ],
        default_difficulty="hard",
        cognitive_level="Analysis",
        references=("TLS management guidelines",),
    ),
    # HEMATOLOGY
    Blueprint(
        id="sickle_cell_crisis",
        category="Physiological Adaptation",
        theme="Vaso-occlusive crisis management",
        stems=[
            "Which intervention should the nurse implement first?",
            "What assessment finding indicates the crisis is worsening?",
            "Which pain management strategy is most appropriate?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 28-year-old with sickle cell disease reporting severe chest and back pain",
                setting="an emergency department",
                therapy="IV opioid analgesia and hydration",
                context="Pain started 6 hours ago and rates it 9/10.",
                monitoring_focus="pain control and complications",
            ),
            ScenarioSeed(
                patient_overview="a 16-year-old admitted for vaso-occlusive crisis",
                setting="a hematology unit",
                therapy="patient-controlled analgesia",
                context="Temperature is 100.8°F with decreased breath sounds in the right base.",
                monitoring_focus="acute chest syndrome prevention",
            ),
        ],
        question_angles=[
            "managing acute pain crisis",
            "recognizing acute chest syndrome",
            "preventing complications",
        ],
        critical_cues=[
            OptionSeed(
                statement="Administer IV fluids at 1.5 times maintenance to promote hemodilution",
                rationale="Hydration reduces blood viscosity and improves microcirculation.",
                priority="critical",
                tags=("hydration",),
            ),
            OptionSeed(
                statement="New onset fever, chest pain, and decreased oxygen saturation",
                rationale="Triad of acute chest syndrome, a life-threatening complication.",
                priority="critical",
                tags=("complication",),
            ),
            OptionSeed(
                statement="Initiate aggressive pain management with opioids around-the-clock",
                rationale="Adequate analgesia is essential; use scheduled dosing rather than PRN only.",
                priority="critical",
                tags=("pain-management",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Encourage bed rest to conserve energy",
                rationale="Activity should be balanced; complete immobility increases thrombosis risk.",
                priority="supportive",
                tags=("activity",),
            ),
            OptionSeed(
                statement="Hemoglobin of 8 g/dL",
                rationale="Chronic anemia is baseline for sickle cell patients.",
                priority="supportive",
                tags=("baseline",),
            ),
            OptionSeed(
                statement="Client requests heating pad for painful joints",
                rationale="Heat may provide comfort but is not the priority intervention.",
                priority="supportive",
                tags=("comfort",),
            ),
        ],
        default_difficulty="medium",
        cognitive_level="Application",
        references=("Sickle cell disease management",),
    ),
    # IMMUNOLOGY
    Blueprint(
        id="anaphylaxis_management",
        category="Physiological Adaptation",
        theme="Anaphylactic reaction treatment",
        stems=[
            "Which intervention should the nurse implement immediately?",
            "What assessment finding confirms anaphylaxis?",
            "Which medication should be administered first?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 35-year-old receiving IV antibiotics who suddenly develops hives and throat tightness",
                setting="a medical unit",
                therapy="epinephrine administration",
                context="The infusion was started 10 minutes ago.",
                monitoring_focus="airway patency",
            ),
            ScenarioSeed(
                patient_overview="a 42-year-old stung by a bee in the hospital garden",
                setting="an outpatient clinic",
                therapy="emergency anaphylaxis protocol",
                context="The client has known bee allergy and appears anxious with flushed skin.",
                monitoring_focus="systemic reaction",
            ),
        ],
        question_angles=[
            "implementing anaphylaxis protocols",
            "prioritizing airway management",
            "providing post-reaction monitoring",
        ],
        critical_cues=[
            OptionSeed(
                statement="Administer epinephrine 0.3-0.5 mg IM into the lateral thigh immediately",
                rationale="Epinephrine is the first-line treatment for anaphylaxis.",
                priority="critical",
                tags=("medication",),
            ),
            OptionSeed(
                statement="Stridor, wheezing, and oxygen saturation dropping to 88%",
                rationale="Indicates upper airway edema and bronchospasm from anaphylaxis.",
                priority="critical",
                tags=("airway",),
            ),
            OptionSeed(
                statement="Stop the infusion and maintain IV access with normal saline",
                rationale="Remove the antigen source while preserving access for medications.",
                priority="critical",
                tags=("intervention",),
            ),
            OptionSeed(
                statement="Blood pressure 82/50 mm Hg with rapid, weak pulse",
                rationale="Distributive shock from massive vasodilation requires immediate treatment.",
                priority="critical",
                tags=("hemodynamic",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Administer diphenhydramine 50 mg IV after epinephrine",
                rationale="Antihistamines are adjunctive therapy but not first-line.",
                priority="supportive",
                tags=("adjunct",),
            ),
            OptionSeed(
                statement="Client reports feeling anxious and dizzy",
                rationale="Expected symptoms but not the priority assessment.",
                priority="supportive",
                tags=("symptoms",),
            ),
            OptionSeed(
                statement="Urticaria spreading across the chest and arms",
                rationale="Confirms allergic reaction but skin findings alone don't require epinephrine.",
                priority="supportive",
                tags=("skin",),
            ),
        ],
        default_difficulty="medium",
        cognitive_level="Application",
        references=("Anaphylaxis emergency guidelines",),
    ),
    # MUSCULOSKELETAL
    Blueprint(
        id="compartment_syndrome",
        category="Physiological Adaptation",
        theme="Compartment syndrome recognition",
        stems=[
            "Which assessment finding is the earliest sign of compartment syndrome?",
            "What intervention requires immediate action?",
            "Which client complaint warrants urgent evaluation?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 23-year-old with a tibial fracture and new cast applied 4 hours ago",
                setting="an orthopedic unit",
                therapy="elevation and ice application",
                context="The client reports increasing pain despite opioid administration.",
                monitoring_focus="neurovascular status",
            ),
            ScenarioSeed(
                patient_overview="a 30-year-old post-op day 1 from forearm fracture repair",
                setting="a surgical unit",
                therapy="compression dressing",
                context="Fingers appear pale with decreased capillary refill.",
                monitoring_focus="compartment pressure",
            ),
        ],
        question_angles=[
            "recognizing the 5 Ps",
            "preventing irreversible damage",
            "facilitating fasciotomy",
        ],
        critical_cues=[
            OptionSeed(
                statement="Pain that is disproportionate to injury and unrelieved by opioids",
                rationale="Progressive, severe pain is the earliest and most reliable sign.",
                priority="critical",
                tags=("pain",),
            ),
            OptionSeed(
                statement="Pain with passive stretching of muscles in the affected compartment",
                rationale="Passive stretch pain indicates ischemia and impending necrosis.",
                priority="critical",
                tags=("assessment",),
            ),
            OptionSeed(
                statement="Bivalve the cast immediately and remove all constrictive dressings",
                rationale="Immediate pressure relief can prevent permanent damage.",
                priority="critical",
                tags=("intervention",),
            ),
            OptionSeed(
                statement="Paresthesia and decreased sensation in the affected extremity",
                rationale="Nerve ischemia indicates advanced compartment syndrome.",
                priority="critical",
                tags=("neurovascular",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Absence of pulses in the affected extremity",
                rationale="This is a late sign indicating severe vascular compromise.",
                priority="supportive",
                tags=("late-sign",),
            ),
            OptionSeed(
                statement="Affected limb is cool to touch",
                rationale="Temperature changes occur late in the progression.",
                priority="supportive",
                tags=("late-sign",),
            ),
            OptionSeed(
                statement="Client reports the cast feels tight",
                rationale="Common complaint but not specific for compartment syndrome.",
                priority="supportive",
                tags=("non-specific",),
            ),
        ],
        default_difficulty="medium",
        cognitive_level="Application",
        references=("Compartment syndrome protocols",),
    ),
    # NEUROLOGICAL
    Blueprint(
        id="myasthenia_gravis_crisis",
        category="Physiological Adaptation",
        theme="Myasthenic vs. cholinergic crisis",
        stems=[
            "Which assessment finding helps differentiate myasthenic from cholinergic crisis?",
            "What intervention should the nurse anticipate first?",
            "Which medication change likely precipitated this crisis?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 45-year-old with myasthenia gravis presenting with severe weakness",
                setting="an emergency department",
                therapy="edrophonium test consideration",
                context="The client has been taking pyridostigmine regularly but had a recent dosage increase.",
                monitoring_focus="respiratory function",
            ),
            ScenarioSeed(
                patient_overview="a 38-year-old with MG admitted for pneumonia",
                setting="a medical ICU",
                therapy="plasma exchange",
                context="Bulbar symptoms are worsening with dysphagia and weak cough.",
                monitoring_focus="airway protection",
            ),
        ],
        question_angles=[
            "distinguishing crisis types",
            "protecting the airway",
            "managing anticholinesterase medications",
        ],
        critical_cues=[
            OptionSeed(
                statement="Fasciculations, increased salivation, and miosis with bradycardia",
                rationale="These cholinergic signs indicate excessive acetylcholinesterase inhibition.",
                priority="critical",
                tags=("cholinergic",),
            ),
            OptionSeed(
                statement="Ptosis, diplopia, and dysphagia with normal pupil size",
                rationale="Classic myasthenic symptoms without cholinergic signs suggest myasthenic crisis.",
                priority="critical",
                tags=("myasthenic",),
            ),
            OptionSeed(
                statement="Prepare for intubation with declining respiratory effort",
                rationale="Both crisis types can cause respiratory failure requiring mechanical ventilation.",
                priority="critical",
                tags=("airway",),
            ),
            OptionSeed(
                statement="Recent antibiotic therapy with fluoroquinolone",
                rationale="Certain antibiotics can precipitate myasthenic crisis.",
                priority="critical",
                tags=("trigger",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Administer atropine if cholinergic crisis is confirmed",
                rationale="Correct intervention but only after differentiation is made.",
                priority="supportive",
                tags=("treatment",),
            ),
            OptionSeed(
                statement="Client reports feeling more fatigued than usual",
                rationale="Non-specific complaint that doesn't differentiate crisis type.",
                priority="supportive",
                tags=("non-specific",),
            ),
            OptionSeed(
                statement="Muscle strength improves temporarily after edrophonium administration",
                rationale="Indicates myasthenic crisis, but the test itself is the diagnostic tool.",
                priority="supportive",
                tags=("diagnostic",),
            ),
        ],
        default_difficulty="hard",
        cognitive_level="Analysis",
        references=("Myasthenia gravis crisis management",),
    ),
    # DELEGATION & PRIORITIZATION
    Blueprint(
        id="delegation_unlicensed_personnel",
        category="Management of Care",
        theme="Appropriate delegation to UAP",
        stems=[
            "Which task can the RN safely delegate to unlicensed assistive personnel?",
            "What assignment would be inappropriate to delegate?",
            "Which client care activity requires RN assessment and cannot be delegated?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="multiple clients on a medical-surgical unit",
                setting="a busy med-surg floor during morning shift",
                therapy="routine care activities",
                context="The RN is working with two UAPs and has six assigned clients.",
                monitoring_focus="delegation decisions",
            ),
            ScenarioSeed(
                patient_overview="post-operative clients requiring various interventions",
                setting="a surgical recovery unit",
                therapy="post-op care protocols",
                context="Staffing is adequate with a mix of RNs, LPNs, and UAPs.",
                monitoring_focus="scope of practice",
            ),
        ],
        question_angles=[
            "applying delegation principles",
            "understanding UAP scope",
            "maintaining patient safety",
        ],
        critical_cues=[
            OptionSeed(
                statement="Obtain vital signs on a stable post-op client",
                rationale="Routine vital signs on stable clients can be delegated to UAP.",
                priority="critical",
                tags=("appropriate",),
            ),
            OptionSeed(
                statement="Assist a client with ambulation using a gait belt",
                rationale="Standard mobility assistance is within UAP scope.",
                priority="critical",
                tags=("appropriate",),
            ),
            OptionSeed(
                statement="Feed a client with dysphagia and aspiration risk",
                rationale="Requires nursing judgment and swallowing assessment; cannot be delegated.",
                priority="critical",
                tags=("inappropriate",),
            ),
            OptionSeed(
                statement="Perform initial assessment on a newly admitted client",
                rationale="Initial assessments require RN clinical judgment and cannot be delegated.",
                priority="critical",
                tags=("rn-only",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Document intake and output measurements",
                rationale="UAP can measure and report, but RN interprets significance.",
                priority="supportive",
                tags=("shared",),
            ),
            OptionSeed(
                statement="Apply non-sterile dressing to a chronic wound",
                rationale="Wound care generally requires nursing assessment.",
                priority="supportive",
                tags=("nursing-task",),
            ),
            OptionSeed(
                statement="Report changes in client condition to the charge nurse",
                rationale="UAP should report but cannot interpret clinical significance.",
                priority="supportive",
                tags=("reporting",),
            ),
        ],
        default_difficulty="easy",
        cognitive_level="Application",
        references=("Delegation principles",),
    ),
    # INFECTION CONTROL
    Blueprint(
        id="isolation_precautions",
        category="Safety and Infection Control",
        theme="Transmission-based precautions",
        stems=[
            "Which type of isolation precaution is required for this client?",
            "What personal protective equipment must the nurse wear?",
            "Which infection requires airborne precautions?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 52-year-old admitted with active pulmonary tuberculosis",
                setting="a medical unit",
                therapy="multi-drug anti-tubercular regimen",
                context="Sputum cultures are positive for acid-fast bacilli.",
                monitoring_focus="transmission prevention",
            ),
            ScenarioSeed(
                patient_overview="a 3-year-old with suspected measles",
                setting="a pediatric emergency department",
                therapy="supportive care",
                context="The child has fever, cough, and characteristic rash.",
                monitoring_focus="exposure control",
            ),
        ],
        question_angles=[
            "selecting appropriate precautions",
            "applying PPE correctly",
            "protecting healthcare workers",
        ],
        critical_cues=[
            OptionSeed(
                statement="Place the client in a negative pressure isolation room",
                rationale="Airborne precautions require negative pressure to prevent organism spread.",
                priority="critical",
                tags=("airborne",),
            ),
            OptionSeed(
                statement="Wear an N95 respirator before entering the room",
                rationale="N95 filters particles <5 microns necessary for airborne pathogens.",
                priority="critical",
                tags=("ppe",),
            ),
            OptionSeed(
                statement="Keep the door closed at all times",
                rationale="Essential for maintaining negative pressure in airborne isolation.",
                priority="critical",
                tags=("environmental",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Wear a surgical mask, which is sufficient for TB",
                rationale="Surgical masks do not filter small particles; N95 required.",
                priority="supportive",
                tags=("incorrect",),
            ),
            OptionSeed(
                statement="Standard precautions alone are adequate",
                rationale="TB requires airborne precautions beyond standard.",
                priority="supportive",
                tags=("insufficient",),
            ),
            OptionSeed(
                statement="Cohort the client with another TB patient",
                rationale="Acceptable in outbreak but not the primary intervention.",
                priority="supportive",
                tags=("secondary",),
            ),
        ],
        default_difficulty="medium",
        cognitive_level="Application",
        references=("CDC isolation guidelines",),
    ),
    # GERIATRICS
    Blueprint(
        id="delirium_vs_dementia",
        category="Psychosocial Integrity",
        theme="Distinguishing delirium from dementia",
        stems=[
            "Which assessment finding suggests delirium rather than dementia?",
            "What intervention should the nurse prioritize for this client?",
            "Which factor is most likely contributing to the acute confusion?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="an 82-year-old post-op day 2 from hip replacement with sudden confusion",
                setting="an orthopedic unit",
                therapy="pain management and antibiotics",
                context="Family reports the client was oriented and independent before surgery.",
                monitoring_focus="cognitive status",
            ),
            ScenarioSeed(
                patient_overview="a 75-year-old with known Alzheimer's disease now more confused",
                setting="a skilled nursing facility",
                therapy="urinary catheter for retention",
                context="Staff notes worsening agitation over the past 24 hours.",
                monitoring_focus="acute change evaluation",
            ),
        ],
        question_angles=[
            "differentiating acute vs chronic confusion",
            "identifying delirium causes",
            "implementing delirium prevention",
        ],
        critical_cues=[
            OptionSeed(
                statement="Acute onset of confusion with fluctuating level of consciousness",
                rationale="Sudden onset and fluctuation are hallmarks of delirium.",
                priority="critical",
                tags=("delirium",),
            ),
            OptionSeed(
                statement="Investigate for underlying infection, hypoxia, or metabolic disturbance",
                rationale="Delirium has reversible causes that must be identified and treated.",
                priority="critical",
                tags=("assessment",),
            ),
            OptionSeed(
                statement="Recent addition of multiple new medications including opioids and anticholinergics",
                rationale="Polypharmacy, especially with high-risk meds, commonly triggers delirium.",
                priority="critical",
                tags=("medication",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Gradual cognitive decline over several years",
                rationale="Insidious onset suggests dementia, not acute delirium.",
                priority="supportive",
                tags=("dementia",),
            ),
            OptionSeed(
                statement="Client cannot recall short-term events",
                rationale="Memory impairment occurs in both conditions.",
                priority="supportive",
                tags=("non-specific",),
            ),
            OptionSeed(
                statement="Family requests pharmacologic sedation",
                rationale="Antipsychotics may worsen delirium and are not first-line.",
                priority="supportive",
                tags=("non-preferred",),
            ),
        ],
        default_difficulty="medium",
        cognitive_level="Analysis",
        references=("Delirium assessment tools",),
    ),
    # NUTRITION
    Blueprint(
        id="enteral_feeding_complications",
        category="Basic Care and Comfort",
        theme="Nasogastric tube feeding management",
        stems=[
            "Which assessment finding requires immediate intervention?",
            "What action should the nurse take before initiating tube feeding?",
            "Which complication is the client experiencing?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 68-year-old receiving continuous tube feeding via NG tube",
                setting="a long-term acute care facility",
                therapy="high-protein enteral formula at 60 mL/hour",
                context="The client has been NPO for 5 days following stroke.",
                monitoring_focus="feeding tolerance",
            ),
            ScenarioSeed(
                patient_overview="a 55-year-old with head injury and impaired swallowing",
                setting="a rehabilitation unit",
                therapy="bolus tube feedings four times daily",
                context="The client develops sudden coughing and respiratory distress during feeding.",
                monitoring_focus="aspiration prevention",
            ),
        ],
        question_angles=[
            "verifying tube placement",
            "preventing aspiration",
            "managing feeding complications",
        ],
        critical_cues=[
            OptionSeed(
                statement="Verify tube placement by checking pH of aspirate and comparing to X-ray",
                rationale="Confirming gastric placement prevents pulmonary administration.",
                priority="critical",
                tags=("safety",),
            ),
            OptionSeed(
                statement="Sudden respiratory distress with diminished breath sounds",
                rationale="Suggests aspiration or tube displacement into the lung.",
                priority="critical",
                tags=("complication",),
            ),
            OptionSeed(
                statement="Maintain head of bed elevation at least 30-45 degrees during and after feeding",
                rationale="Positioning reduces aspiration risk significantly.",
                priority="critical",
                tags=("prevention",),
            ),
            OptionSeed(
                statement="Gastric residual volume of 350 mL on consecutive checks",
                rationale="High residual increases aspiration risk and may require holding feeding.",
                priority="critical",
                tags=("intolerance",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Client reports feeling bloated",
                rationale="Common complaint but not immediately dangerous.",
                priority="supportive",
                tags=("minor",),
            ),
            OptionSeed(
                statement="Flush the tube with 30 mL water before and after feeding",
                rationale="Good practice for patency but not the priority safety concern.",
                priority="supportive",
                tags=("maintenance",),
            ),
            OptionSeed(
                statement="Gastric residual of 75 mL",
                rationale="Within acceptable range; feeding can continue.",
                priority="supportive",
                tags=("acceptable",),
            ),
        ],
        default_difficulty="medium",
        cognitive_level="Application",
        references=("Enteral nutrition guidelines",),
    ),
    # BURNS & TRAUMA
    Blueprint(
        id="burn_fluid_resuscitation",
        category="Physiological Adaptation",
        theme="Burn shock and fluid replacement",
        stems=[
            "Which assessment finding indicates adequate burn resuscitation?",
            "What is the priority intervention during the emergent phase?",
            "Which formula guides initial fluid replacement?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 40-year-old with 35% TBSA full-thickness burns from a house fire",
                setting="a burn ICU",
                therapy="Parkland formula fluid resuscitation",
                context="The client was injured 2 hours ago and has two large-bore IVs.",
                monitoring_focus="burn shock prevention",
            ),
            ScenarioSeed(
                patient_overview="a 28-year-old on hour 16 of burn resuscitation",
                setting="a regional burn center",
                therapy="lactated Ringer's infusion",
                context="Urine output has been trending 25 mL/hour for the past 3 hours.",
                monitoring_focus="perfusion adequacy",
            ),
        ],
        question_angles=[
            "calculating fluid requirements",
            "monitoring resuscitation endpoints",
            "preventing complications of burn shock",
        ],
        critical_cues=[
            OptionSeed(
                statement="Urine output maintained at 30-50 mL/hour or 0.5 mL/kg/hour",
                rationale="Adequate urine output is the primary indicator of successful resuscitation.",
                priority="critical",
                tags=("endpoint",),
            ),
            OptionSeed(
                statement="Administer half of calculated 24-hour fluid volume in the first 8 hours",
                rationale="Parkland formula requires frontloading fluids in the first 8 hours post-burn.",
                priority="critical",
                tags=("protocol",),
            ),
            OptionSeed(
                statement="Urine output consistently below 30 mL/hour despite aggressive fluids",
                rationale="Oliguria indicates inadequate resuscitation requiring rate adjustment.",
                priority="critical",
                tags=("inadequate",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Blood pressure of 110/70 mm Hg",
                rationale="BP alone is not a reliable resuscitation endpoint in burns.",
                priority="supportive",
                tags=("non-specific",),
            ),
            OptionSeed(
                statement="Hematocrit elevation to 52%",
                rationale="Expected hemoconcentration during burn shock.",
                priority="supportive",
                tags=("expected",),
            ),
            OptionSeed(
                statement="Client reports severe pain at burn sites",
                rationale="Full-thickness burns destroy nerve endings; pain suggests partial thickness.",
                priority="supportive",
                tags=("assessment",),
            ),
        ],
        default_difficulty="hard",
        cognitive_level="Analysis",
        references=("Burn resuscitation protocols",),
    ),
    # RESPIRATORY
    Blueprint(
        id="pneumothorax_recognition",
        category="Physiological Adaptation",
        theme="Tension pneumothorax identification",
        stems=[
            "Which assessment finding is most concerning for tension pneumothorax?",
            "What intervention must the nurse anticipate immediately?",
            "Which client is at highest risk for this complication?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 32-year-old post-central line insertion with sudden dyspnea",
                setting="a medical ICU",
                therapy="supplemental oxygen",
                context="The client received a subclavian line 30 minutes ago.",
                monitoring_focus="procedural complications",
            ),
            ScenarioSeed(
                patient_overview="a 25-year-old trauma patient with rib fractures",
                setting="a trauma bay",
                therapy="mechanical ventilation",
                context="The client's oxygen saturation is declining rapidly despite ventilator adjustments.",
                monitoring_focus="life-threatening complications",
            ),
        ],
        question_angles=[
            "recognizing tension pneumothorax",
            "differentiating from simple pneumothorax",
            "facilitating emergency decompression",
        ],
        critical_cues=[
            OptionSeed(
                statement="Tracheal deviation away from the affected side with severe dyspnea",
                rationale="Tracheal shift indicates mediastinal displacement from tension pneumothorax.",
                priority="critical",
                tags=("clinical-sign",),
            ),
            OptionSeed(
                statement="Absent breath sounds with hyperresonance to percussion on one side",
                rationale="Classic findings of pneumothorax; hyperresonance indicates air-filled space.",
                priority="critical",
                tags=("assessment",),
            ),
            OptionSeed(
                statement="Hypotension, distended neck veins, and rapid deterioration",
                rationale="Hemodynamic compromise from impaired venous return requires immediate needle decompression.",
                priority="critical",
                tags=("emergency",),
            ),
            OptionSeed(
                statement="Prepare for immediate needle thoracostomy followed by chest tube insertion",
                rationale="Tension pneumothorax is a true emergency requiring rapid decompression.",
                priority="critical",
                tags=("intervention",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Chest X-ray confirmation before treatment",
                rationale="Tension pneumothorax is a clinical diagnosis; do not delay for imaging.",
                priority="supportive",
                tags=("delay",),
            ),
            OptionSeed(
                statement="Unilateral chest pain worsening with deep breathing",
                rationale="Pleuritic pain suggests pneumothorax but doesn't confirm tension.",
                priority="supportive",
                tags=("non-specific",),
            ),
            OptionSeed(
                statement="Subcutaneous emphysema palpable at the insertion site",
                rationale="Suggests air leak but is not specific for tension pneumothorax.",
                priority="supportive",
                tags=("related",),
            ),
        ],
        default_difficulty="hard",
        cognitive_level="Analysis",
        references=("Emergency thoracic procedures",),
    ),
    # ETHICAL & LEGAL
    Blueprint(
        id="informed_consent_principles",
        category="Management of Care",
        theme="Informed consent validation",
        stems=[
            "Which situation requires the nurse to intervene before the procedure?",
            "What indicates the consent is not valid?",
            "Which action protects the client's rights?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 68-year-old scheduled for cardiac catheterization in one hour",
                setting="a pre-procedure area",
                therapy="informed consent process",
                context="The client signed the consent form but asks basic questions about the procedure.",
                monitoring_focus="consent validity",
            ),
            ScenarioSeed(
                patient_overview="a 45-year-old with limited English proficiency signing surgical consent",
                setting="a surgical holding area",
                therapy="interpreter services",
                context="The consent form is in English and no interpreter was present.",
                monitoring_focus="patient advocacy",
            ),
        ],
        question_angles=[
            "validating informed consent",
            "advocating for patient rights",
            "recognizing consent violations",
        ],
        critical_cues=[
            OptionSeed(
                statement="Client asks, 'What exactly are they going to do during this test?'",
                rationale="Indicates lack of understanding; consent may not be truly informed.",
                priority="critical",
                tags=("understanding",),
            ),
            OptionSeed(
                statement="Notify the physician that the client needs clarification before proceeding",
                rationale="Nurse advocates by ensuring informed consent requirements are met.",
                priority="critical",
                tags=("advocacy",),
            ),
            OptionSeed(
                statement="Client states, 'I don't want the procedure, but my family insists'",
                rationale="Coercion invalidates consent; client autonomy must be respected.",
                priority="critical",
                tags=("autonomy",),
            ),
            OptionSeed(
                statement="Consent signed while client was under influence of sedative medications",
                rationale="Patient must be competent and alert to provide valid consent.",
                priority="critical",
                tags=("capacity",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Witness the client's signature on the consent form",
                rationale="Nurse role is to witness signature, not to obtain informed consent.",
                priority="supportive",
                tags=("role-clarification",),
            ),
            OptionSeed(
                statement="Client appears nervous about the procedure",
                rationale="Anxiety is normal and does not invalidate consent.",
                priority="supportive",
                tags=("expected",),
            ),
            OptionSeed(
                statement="Family members are present and supportive",
                rationale="Family support is beneficial but doesn't substitute for patient understanding.",
                priority="supportive",
                tags=("support",),
            ),
        ],
        default_difficulty="medium",
        cognitive_level="Application",
        references=("Patient rights and consent",),
    ),
    # PHARMACOLOGY - MULTIPLE MEDICATIONS
    Blueprint(
        id="polypharmacy_elderly",
        category="Pharmacological and Parenteral Therapies",
        theme="Polypharmacy management in older adults",
        stems=[
            "Which medication should the nurse question for this elderly client?",
            "What adverse effect is most concerning with this medication combination?",
            "Which assessment finding suggests medication toxicity?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="an 80-year-old taking 12 daily medications including anticholinergics",
                setting="a geriatric clinic",
                therapy="comprehensive medication review",
                context="The client reports new-onset confusion and recent falls.",
                monitoring_focus="inappropriate prescribing",
            ),
            ScenarioSeed(
                patient_overview="a 76-year-old with newly prescribed medications after hospitalization",
                setting="a transitional care clinic",
                therapy="medication reconciliation",
                context="Home medications include anticoagulants, NSAIDs, and antiplatelets.",
                monitoring_focus="drug interactions",
            ),
        ],
        question_angles=[
            "applying Beers Criteria",
            "recognizing anticholinergic burden",
            "preventing adverse drug events",
        ],
        critical_cues=[
            OptionSeed(
                statement="Diphenhydramine prescribed for sleep in an 82-year-old",
                rationale="Beers Criteria identifies antihistamines as potentially inappropriate for elderly due to anticholinergic effects.",
                priority="critical",
                tags=("inappropriate",),
            ),
            OptionSeed(
                statement="Concurrent use of warfarin, aspirin, and ibuprofen",
                rationale="Triple antithrombotic therapy dramatically increases bleeding risk.",
                priority="critical",
                tags=("interaction",),
            ),
            OptionSeed(
                statement="New cognitive impairment with urinary retention and dry mouth",
                rationale="Classic anticholinergic toxicity syndrome requiring medication review.",
                priority="critical",
                tags=("toxicity",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Client uses a weekly pill organizer",
                rationale="Good adherence strategy but doesn't address appropriateness.",
                priority="supportive",
                tags=("adherence",),
            ),
            OptionSeed(
                statement="Family helps manage medication administration",
                rationale="Supportive but doesn't prevent polypharmacy complications.",
                priority="supportive",
                tags=("support",),
            ),
            OptionSeed(
                statement="Client sees multiple specialists",
                rationale="Increases polypharmacy risk but is not itself a medication error.",
                priority="supportive",
                tags=("context",),
            ),
        ],
        default_difficulty="medium",
        cognitive_level="Analysis",
        references=("Beers Criteria", "Geriatric pharmacology"),
    ),
    # PAIN MANAGEMENT
    Blueprint(
        id="opioid_safe_administration",
        category="Pharmacological and Parenteral Therapies",
        theme="Opioid safety and monitoring",
        stems=[
            "Which assessment finding requires withholding the opioid dose?",
            "What intervention should the nurse have readily available?",
            "Which vital sign is most important to monitor?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 58-year-old receiving IV morphine for post-operative pain",
                setting="a surgical recovery unit",
                therapy="PCA morphine with basal rate",
                context="The client has obstructive sleep apnea and received a bolus dose 30 minutes ago.",
                monitoring_focus="respiratory depression",
            ),
            ScenarioSeed(
                patient_overview="a 70-year-old opioid-naive patient starting oral oxycodone",
                setting="an oncology clinic",
                therapy="immediate-release opioids for cancer pain",
                context="The client has renal insufficiency with a creatinine of 2.1 mg/dL.",
                monitoring_focus="safe opioid initiation",
            ),
        ],
        question_angles=[
            "preventing respiratory depression",
            "using naloxone appropriately",
            "assessing sedation levels",
        ],
        critical_cues=[
            OptionSeed(
                statement="Respiratory rate of 8 breaths per minute with sedation score of 3",
                rationale="Bradypnea with deep sedation indicates dangerous respiratory depression.",
                priority="critical",
                tags=("respiratory",),
            ),
            OptionSeed(
                statement="Keep naloxone readily available at the bedside",
                rationale="Opioid antagonist must be immediately accessible to reverse respiratory depression.",
                priority="critical",
                tags=("reversal-agent",),
            ),
            OptionSeed(
                statement="Inability to arouse the client with verbal or tactile stimulation",
                rationale="Profound sedation precedes apnea and requires immediate intervention.",
                priority="critical",
                tags=("sedation",),
            ),
            OptionSeed(
                statement="Pinpoint pupils with decreased level of consciousness",
                rationale="Classic signs of opioid overdose requiring naloxone administration.",
                priority="critical",
                tags=("overdose",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Client reports pain level of 6/10",
                rationale="Pain presence doesn't override safety concerns about respiratory depression.",
                priority="supportive",
                tags=("pain",),
            ),
            OptionSeed(
                statement="Blood pressure slightly decreased from baseline",
                rationale="Mild hypotension is common but respiratory status is the priority.",
                priority="supportive",
                tags=("expected",),
            ),
            OptionSeed(
                statement="Client sleeping but easily arousable with normal respirations",
                rationale="Appropriate sedation for pain relief; safe to continue monitoring.",
                priority="supportive",
                tags=("safe",),
            ),
        ],
        default_difficulty="medium",
        cognitive_level="Application",
        references=("Opioid safety protocols",),
    ),
    # PSYCHIATRIC-MENTAL HEALTH
    Blueprint(
        id="schizophrenia_antipsychotics",
        category="Psychosocial Integrity",
        theme="Antipsychotic medication management",
        stems=[
            "Which adverse effect requires immediate intervention?",
            "What assessment finding indicates a serious medication reaction?",
            "Which teaching point is most important for this medication?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 34-year-old with schizophrenia taking haloperidol",
                setting="a psychiatric outpatient clinic",
                therapy="typical antipsychotic medication",
                context="The client reports new muscle stiffness and difficulty swallowing.",
                monitoring_focus="extrapyramidal symptoms",
            ),
            ScenarioSeed(
                patient_overview="a 28-year-old recently started on clozapine",
                setting="a mental health treatment facility",
                therapy="atypical antipsychotic with weekly monitoring",
                context="The client develops fever, confusion, and muscle rigidity.",
                monitoring_focus="life-threatening reactions",
            ),
        ],
        question_angles=[
            "recognizing neuroleptic malignant syndrome",
            "managing extrapyramidal side effects",
            "monitoring for agranulocytosis",
        ],
        critical_cues=[
            OptionSeed(
                statement="Temperature 104°F (40°C) with severe muscle rigidity and altered mental status",
                rationale="Neuroleptic malignant syndrome is a life-threatening emergency requiring immediate discontinuation.",
                priority="critical",
                tags=("emergency",),
            ),
            OptionSeed(
                statement="White blood cell count of 2,000/mm³ with neutropenia",
                rationale="Agranulocytosis from clozapine requires immediate discontinuation to prevent sepsis.",
                priority="critical",
                tags=("hematologic",),
            ),
            OptionSeed(
                statement="Involuntary tongue protrusion and facial grimacing",
                rationale="Acute dystonia requires immediate treatment with anticholinergic agents.",
                priority="critical",
                tags=("eps",),
            ),
            OptionSeed(
                statement="Teach client to report fever, sore throat, or flu-like symptoms immediately",
                rationale="Early signs of agranulocytosis require urgent medical evaluation.",
                priority="critical",
                tags=("teaching",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Client reports feeling drowsy in the afternoon",
                rationale="Sedation is a common side effect that usually improves with time.",
                priority="supportive",
                tags=("expected",),
            ),
            OptionSeed(
                statement="Mild hand tremor noted during medication administration",
                rationale="Fine tremor is common but not emergent; monitor for progression.",
                priority="supportive",
                tags=("minor",),
            ),
            OptionSeed(
                statement="Weight gain of 5 pounds over 2 months",
                rationale="Metabolic side effect requiring dietary counseling but not urgent.",
                priority="supportive",
                tags=("metabolic",),
            ),
        ],
        default_difficulty="hard",
        cognitive_level="Analysis",
        references=("Antipsychotic monitoring protocols",),
    ),
    # PERIOPERATIVE
    Blueprint(
        id="malignant_hyperthermia",
        category="Physiological Adaptation",
        theme="Malignant hyperthermia recognition",
        stems=[
            "Which assessment finding during surgery suggests malignant hyperthermia?",
            "What is the priority intervention?",
            "Which medication should the nurse prepare to administer?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 32-year-old undergoing general anesthesia for orthopedic surgery",
                setting="an operating room",
                therapy="inhalational anesthetic agents",
                context="The client suddenly develops tachycardia and rigidity during the procedure.",
                monitoring_focus="anesthesia complications",
            ),
            ScenarioSeed(
                patient_overview="a 25-year-old with family history of anesthesia complications",
                setting="a surgical suite",
                therapy="emergency protocol activation",
                context="End-tidal CO2 is rapidly rising with muscle rigidity noted.",
                monitoring_focus="hypermetabolic crisis",
            ),
        ],
        question_angles=[
            "identifying early malignant hyperthermia signs",
            "implementing emergency protocols",
            "genetic risk counseling",
        ],
        critical_cues=[
            OptionSeed(
                statement="Rapidly rising end-tidal CO2 with unexplained tachycardia and rigidity",
                rationale="Early signs of MH hypermetabolic state requiring immediate action.",
                priority="critical",
                tags=("early-signs",),
            ),
            OptionSeed(
                statement="Discontinue all triggering agents and hyperventilate with 100% oxygen",
                rationale="First priority is to stop causative agents and increase oxygen delivery.",
                priority="critical",
                tags=("intervention",),
            ),
            OptionSeed(
                statement="Prepare dantrolene sodium for immediate IV administration",
                rationale="Dantrolene is the specific antidote and must be given immediately.",
                priority="critical",
                tags=("antidote",),
            ),
            OptionSeed(
                statement="Temperature spiking to 105°F (40.6°C) or higher",
                rationale="Extreme hyperthermia is a late but characteristic sign of MH.",
                priority="critical",
                tags=("late-sign",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Obtain arterial blood gas to assess metabolic acidosis",
                rationale="Important for monitoring but secondary to immediate treatment.",
                priority="supportive",
                tags=("monitoring",),
            ),
            OptionSeed(
                statement="Family history of unexplained perioperative death",
                rationale="Increases risk but doesn't confirm current crisis.",
                priority="supportive",
                tags=("risk-factor",),
            ),
            OptionSeed(
                statement="Initiate active cooling measures",
                rationale="Supportive care but dantrolene administration is the priority.",
                priority="supportive",
                tags=("supportive",),
            ),
        ],
        default_difficulty="hard",
        cognitive_level="Analysis",
        references=("Malignant hyperthermia protocols",),
    ),
    # MATERNAL POSTPARTUM
    Blueprint(
        id="postpartum_hemorrhage",
        category="Physiological Adaptation",
        theme="Early postpartum hemorrhage management",
        stems=[
            "Which assessment finding indicates postpartum hemorrhage?",
            "What intervention should the nurse implement first?",
            "Which factor places this client at highest risk?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 28-year-old 30 minutes post-vaginal delivery",
                setting="a labor and delivery unit",
                therapy="fundal massage and oxytocin infusion",
                context="The client delivered a 9-pound infant after prolonged labor.",
                monitoring_focus="uterine atony",
            ),
            ScenarioSeed(
                patient_overview="a 32-year-old post-cesarean section for placenta previa",
                setting="a postpartum recovery area",
                therapy="blood transfusion protocol",
                context="Estimated blood loss was 1200 mL and the client appears pale and dizzy.",
                monitoring_focus="hypovolemic shock",
            ),
        ],
        question_angles=[
            "recognizing PPH risk factors",
            "implementing hemorrhage protocols",
            "preventing maternal mortality",
        ],
        critical_cues=[
            OptionSeed(
                statement="Fundus boggy and displaced to the right above the umbilicus",
                rationale="Indicates uterine atony requiring immediate massage and bladder emptying.",
                priority="critical",
                tags=("assessment",),
            ),
            OptionSeed(
                statement="Blood loss exceeding 500 mL vaginal or 1000 mL cesarean",
                rationale="Meets definition of postpartum hemorrhage requiring intervention.",
                priority="critical",
                tags=("quantification",),
            ),
            OptionSeed(
                statement="Perform vigorous fundal massage while supporting the lower uterine segment",
                rationale="Stimulates uterine contraction to control bleeding from placental site.",
                priority="critical",
                tags=("intervention",),
            ),
            OptionSeed(
                statement="Rapid pulse, decreased blood pressure, and restlessness",
                rationale="Signs of hypovolemic shock requiring aggressive fluid resuscitation.",
                priority="critical",
                tags=("shock",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Lochia rubra with small clots",
                rationale="Expected normal postpartum bleeding in early hours.",
                priority="supportive",
                tags=("normal",),
            ),
            OptionSeed(
                statement="Client reports feeling weak and thirsty",
                rationale="Common postpartum symptoms but monitor for worsening.",
                priority="supportive",
                tags=("non-specific",),
            ),
            OptionSeed(
                statement="Fundus firm at umbilicus level",
                rationale="Appropriate finding indicating good uterine tone.",
                priority="supportive",
                tags=("reassuring",),
            ),
        ],
        default_difficulty="medium",
        cognitive_level="Application",
        references=("Postpartum hemorrhage bundles",),
    ),
    # PEDIATRIC EMERGENCIES
    Blueprint(
        id="pediatric_dehydration",
        category="Physiological Adaptation",
        theme="Pediatric dehydration assessment",
        stems=[
            "Which assessment finding indicates severe dehydration?",
            "What is the priority intervention for this child?",
            "Which clinical sign appears earliest in dehydration?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="an 18-month-old with vomiting and diarrhea for 48 hours",
                setting="a pediatric emergency department",
                therapy="oral rehydration therapy",
                context="Parents report only 2 wet diapers in the past 24 hours.",
                monitoring_focus="hydration status",
            ),
            ScenarioSeed(
                patient_overview="a 6-month-old infant with decreased feeding and lethargy",
                setting="an urgent care clinic",
                therapy="fluid replacement consideration",
                context="Anterior fontanel appears sunken and mucous membranes are dry.",
                monitoring_focus="dehydration severity",
            ),
        ],
        question_angles=[
            "assessing dehydration percentage",
            "choosing appropriate rehydration",
            "recognizing shock indicators",
        ],
        critical_cues=[
            OptionSeed(
                statement="Sunken fontanel, absent tears, and dry mucous membranes",
                rationale="Classic signs of moderate to severe dehydration in infants.",
                priority="critical",
                tags=("clinical-signs",),
            ),
            OptionSeed(
                statement="Capillary refill time greater than 3 seconds with cool extremities",
                rationale="Indicates poor perfusion and potential hypovolemic shock.",
                priority="critical",
                tags=("perfusion",),
            ),
            OptionSeed(
                statement="Establish IV access and begin 20 mL/kg bolus of normal saline",
                rationale="Severe dehydration with shock requires immediate IV fluid resuscitation.",
                priority="critical",
                tags=("intervention",),
            ),
            OptionSeed(
                statement="Weight loss of 12% from pre-illness weight",
                rationale="Greater than 10% weight loss indicates severe dehydration.",
                priority="critical",
                tags=("quantification",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Slightly decreased skin turgor on the abdomen",
                rationale="Suggests mild dehydration; oral rehydration may be sufficient.",
                priority="supportive",
                tags=("mild",),
            ),
            OptionSeed(
                statement="Child is fussy and irritable",
                rationale="Behavioral changes occur but are non-specific.",
                priority="supportive",
                tags=("non-specific",),
            ),
            OptionSeed(
                statement="Urine specific gravity of 1.025",
                rationale="Elevated but not severely; indicates concentrated urine.",
                priority="supportive",
                tags=("labs",),
            ),
        ],
        default_difficulty="medium",
        cognitive_level="Application",
        references=("Pediatric dehydration guidelines",),
    ),
    # CARDIOVASCULAR ADVANCED
    Blueprint(
        id="cardiogenic_shock",
        category="Physiological Adaptation",
        theme="Cardiogenic shock management",
        stems=[
            "Which hemodynamic finding confirms cardiogenic shock?",
            "What intervention should the nurse anticipate?",
            "Which medication is contraindicated in this situation?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 66-year-old with acute MI presenting with hypotension and pulmonary edema",
                setting="a cardiac catheterization lab",
                therapy="inotropic support and mechanical circulatory support consideration",
                context="The client has cold, clammy skin with decreased urine output.",
                monitoring_focus="cardiogenic shock",
            ),
            ScenarioSeed(
                patient_overview="a 58-year-old with severe heart failure and declining cardiac index",
                setting="a cardiac ICU",
                therapy="dobutamine infusion",
                context="Pulmonary artery catheter shows elevated wedge pressure with low cardiac output.",
                monitoring_focus="hemodynamic optimization",
            ),
        ],
        question_angles=[
            "interpreting hemodynamic parameters",
            "selecting appropriate vasopressors",
            "timing mechanical support",
        ],
        critical_cues=[
            OptionSeed(
                statement="Cardiac index below 2.2 L/min/m² with elevated pulmonary capillary wedge pressure",
                rationale="Defines cardiogenic shock: inadequate cardiac output despite adequate preload.",
                priority="critical",
                tags=("hemodynamics",),
            ),
            OptionSeed(
                statement="Initiate dobutamine to improve contractility and cardiac output",
                rationale="Positive inotrope is first-line for cardiogenic shock to enhance myocardial function.",
                priority="critical",
                tags=("medication",),
            ),
            OptionSeed(
                statement="Avoid IV fluid boluses that would worsen pulmonary edema",
                rationale="Cardiogenic shock is NOT volume responsive; fluids worsen pulmonary congestion.",
                priority="critical",
                tags=("contraindication",),
            ),
            OptionSeed(
                statement="Prepare for intra-aortic balloon pump or mechanical circulatory support",
                rationale="Refractory cardiogenic shock may require mechanical assistance.",
                priority="critical",
                tags=("escalation",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Administer morphine for chest pain and anxiety",
                rationale="Reduces preload and anxiety but doesn't address primary shock state.",
                priority="supportive",
                tags=("adjunct",),
            ),
            OptionSeed(
                statement="Blood pressure 88/60 mm Hg",
                rationale="Hypotension present but hemodynamic values define cardiogenic shock.",
                priority="supportive",
                tags=("supportive-data",),
            ),
            OptionSeed(
                statement="Lactate level elevated at 3.2 mmol/L",
                rationale="Indicates tissue hypoperfusion but not specific to cardiogenic etiology.",
                priority="supportive",
                tags=("labs",),
            ),
        ],
        default_difficulty="hard",
        cognitive_level="Analysis",
        references=("Cardiogenic shock guidelines",),
    ),
    # ABUSE & VIOLENCE
    Blueprint(
        id="intimate_partner_violence",
        category="Psychosocial Integrity",
        theme="Intimate partner violence screening and response",
        stems=[
            "Which assessment finding raises concern for intimate partner violence?",
            "What is the nurse's priority action?",
            "Which interview technique is most appropriate?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 32-year-old presenting to the ED with a wrist fracture",
                setting="an emergency department",
                therapy="injury treatment and safety assessment",
                context="The client has multiple bruises in various stages of healing and partner refuses to leave the room.",
                monitoring_focus="abuse identification",
            ),
            ScenarioSeed(
                patient_overview="a 28-year-old at a prenatal visit appearing anxious and withdrawn",
                setting="an outpatient obstetric clinic",
                therapy="routine prenatal care",
                context="The client minimizes injuries and partner controls all conversation.",
                monitoring_focus="patient safety",
            ),
        ],
        question_angles=[
            "recognizing abuse patterns",
            "conducting private screening",
            "implementing safety planning",
        ],
        critical_cues=[
            OptionSeed(
                statement="Interview the client privately without the partner present",
                rationale="Mandatory for accurate assessment and to provide opportunity for disclosure.",
                priority="critical",
                tags=("intervention",),
            ),
            OptionSeed(
                statement="Injuries in various stages of healing with inconsistent explanations",
                rationale="Pattern highly suspicious for repeated non-accidental trauma.",
                priority="critical",
                tags=("red-flag",),
            ),
            OptionSeed(
                statement="Document findings objectively using body maps and photographs with consent",
                rationale="Thorough documentation supports legal proceedings and continuity of care.",
                priority="critical",
                tags=("documentation",),
            ),
            OptionSeed(
                statement="Provide information about domestic violence resources and safety planning",
                rationale="Empowers the client with options while respecting autonomy.",
                priority="critical",
                tags=("resources",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Partner appears concerned and attentive",
                rationale="Abusers may present as caring in public settings.",
                priority="supportive",
                tags=("deceptive",),
            ),
            OptionSeed(
                statement="Client denies abuse when partner is present",
                rationale="Victims often cannot disclose safely in presence of abuser.",
                priority="supportive",
                tags=("expected",),
            ),
            OptionSeed(
                statement="Delay in seeking treatment after injury",
                rationale="Common pattern but not diagnostic alone.",
                priority="supportive",
                tags=("pattern",),
            ),
        ],
        default_difficulty="medium",
        cognitive_level="Application",
        references=("IPV screening protocols",),
    ),
    # --- NEW BLUEPRINTS ADDED FOR COMPREHENSIVE COVERAGE ---
    Blueprint(
        id="anatomy_cardio_hemodynamics",
        category="Physiological Adaptation",
        theme="Cardiovascular Anatomy and Hemodynamics",
        stems=[
            "Based on the anatomy involved, what is the nurse's priority assessment?",
            "Which physiological mechanism explains the client's current symptoms?",
            "Where should the nurse place the stethoscope to best assess this finding?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 68-year-old with left-sided heart failure",
                setting="a cardiac step-down unit",
                therapy="diuretic therapy and fluid restriction",
                context="The client complains of increasing shortness of breath when lying flat.",
                monitoring_focus="pulmonary congestion",
            ),
            ScenarioSeed(
                patient_overview="a 55-year-old with mitral valve stenosis",
                setting="an outpatient cardiology clinic",
                therapy="monitoring for valve replacement",
                context="The nurse is performing a focused cardiac assessment.",
                monitoring_focus="heart sounds",
            ),
            ScenarioSeed(
                patient_overview="a 72-year-old with a history of aortic aneurysm",
                setting="an emergency department",
                therapy="blood pressure management",
                context="The client reports a tearing sensation in the chest radiating to the back.",
                monitoring_focus="hemodynamic stability",
            ),
        ],
        question_angles=[
            "correlating anatomy with symptoms",
            "assessing specific heart sounds",
            "understanding hemodynamic changes",
        ],
        critical_cues=[
            OptionSeed(
                statement="Auscultate the fifth intercostal space at the midclavicular line",
                rationale="This is the mitral area (apex), best for hearing mitral valve sounds and S3/S4.",
                priority="critical",
                tags=("assessment", "anatomy"),
            ),
            OptionSeed(
                statement="Pulmonary venous congestion due to backward failure of the left ventricle",
                rationale="Left ventricular failure causes blood to back up into the pulmonary veins, leading to dyspnea.",
                priority="critical",
                tags=("physiology", "pathophysiology"),
            ),
            OptionSeed(
                statement="Assess blood pressure in both arms to check for discrepancy",
                rationale="A significant difference (>20 mmHg) suggests aortic dissection affecting subclavian arteries.",
                priority="critical",
                tags=("assessment", "safety"),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Palpate the carotid arteries simultaneously",
                rationale="Never palpate both carotids at once as it can compromise cerebral blood flow.",
                priority="supportive",
                tags=("unsafe",),
            ),
            OptionSeed(
                statement="Right ventricular failure causing systemic congestion",
                rationale="Right failure causes peripheral edema, not the primary pulmonary symptoms described.",
                priority="supportive",
                tags=("pathophysiology",),
            ),
            OptionSeed(
                statement="Auscultate the second intercostal space right sternal border",
                rationale="This is the aortic area, not the best location for mitral sounds.",
                priority="supportive",
                tags=("anatomy",),
            ),
        ],
        default_difficulty="hard",
        cognitive_level="Analysis",
        references=("Cardiovascular anatomy", "Physical assessment"),
    ),
    Blueprint(
        id="fundamentals_sterile_technique",
        category="Safety and Infection Control",
        theme="Surgical Asepsis and Sterile Field",
        stems=[
            "Which action by the nurse requires immediate correction?",
            "How should the nurse proceed to maintain the sterile field?",
            "Which observation indicates the sterile field has been contaminated?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 45-year-old requiring urinary catheterization",
                setting="a medical-surgical unit",
                therapy="insertion of an indwelling Foley catheter",
                context="The nurse is setting up the sterile tray on the bedside table.",
                monitoring_focus="sterile technique",
            ),
            ScenarioSeed(
                patient_overview="a 60-year-old with a central venous line",
                setting="an ICU",
                therapy="central line dressing change",
                context="The nurse and a student nurse are performing the procedure together.",
                monitoring_focus="infection control",
            ),
            ScenarioSeed(
                patient_overview="a 30-year-old with a large abdominal wound",
                setting="a wound care clinic",
                therapy="sterile wound irrigation and packing",
                context="The nurse opens a bottle of sterile saline solution.",
                monitoring_focus="asepsis",
            ),
        ],
        question_angles=[
            "identifying breaks in sterility",
            "maintaining a sterile field",
            "correcting contamination",
        ],
        critical_cues=[
            OptionSeed(
                statement="Discard the entire sterile field and start over with a new kit",
                rationale="If sterility is compromised, the entire field is considered contaminated and must be replaced.",
                priority="critical",
                tags=("safety", "infection-control"),
            ),
            OptionSeed(
                statement="Keep the sterile field in direct line of sight at all times",
                rationale="Turning the back to a sterile field renders it unmonitored and potentially contaminated.",
                priority="critical",
                tags=("technique",),
            ),
            OptionSeed(
                statement="Pour the saline solution without splashing onto the sterile field",
                rationale="Moisture allows bacteria to travel through the sterile drape (wicking), contaminating the field.",
                priority="critical",
                tags=("technique",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Reach over the sterile field to grab a supply",
                rationale="Reaching over a sterile field contaminates it with skin flora/debris.",
                priority="supportive",
                tags=("unsafe",),
            ),
            OptionSeed(
                statement="Place the sterile field 1 inch from the edge of the table",
                rationale="The outer 1-inch border is considered non-sterile.",
                priority="supportive",
                tags=("technique",),
            ),
            OptionSeed(
                statement="Use a sterile gloved hand to adjust the face mask",
                rationale="The face mask is not sterile; touching it contaminates the gloves.",
                priority="supportive",
                tags=("unsafe",),
            ),
        ],
        default_difficulty="medium",
        cognitive_level="Application",
        references=("Sterile technique principles", "Infection control"),
    ),
    Blueprint(
        id="maternal_labor_monitoring",
        category="Health Promotion and Maintenance",
        theme="Intrapartum Care and Fetal Monitoring",
        stems=[
            "What is the nurse's priority intervention based on the fetal monitor tracing?",
            "How should the nurse interpret this assessment finding?",
            "Which action is most appropriate for this stage of labor?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 25-year-old primigravida in active labor",
                setting="a labor and delivery unit",
                therapy="continuous electronic fetal monitoring",
                context="The monitor shows a pattern of V-shaped decelerations unrelated to contractions.",
                monitoring_focus="fetal heart rate patterns",
            ),
            ScenarioSeed(
                patient_overview="a 30-year-old multipara at 39 weeks gestation",
                setting="a birthing center",
                therapy="labor augmentation with oxytocin",
                context="Contractions are occurring every 1.5 minutes and lasting 90 seconds.",
                monitoring_focus="uterine tachysystole",
            ),
            ScenarioSeed(
                patient_overview="a 22-year-old in the transition phase of labor",
                setting="a labor room",
                therapy="natural childbirth support",
                context="The client reports feeling the urge to push but is only 8 cm dilated.",
                monitoring_focus="labor progression",
            ),
        ],
        question_angles=[
            "interpreting fetal heart rate",
            "managing labor complications",
            "supporting labor stages",
        ],
        critical_cues=[
            OptionSeed(
                statement="Reposition the client to the left lateral or knee-chest position",
                rationale="Variable decelerations indicate cord compression; position change often relieves pressure.",
                priority="critical",
                tags=("intervention", "fetal-monitoring"),
            ),
            OptionSeed(
                statement="Discontinue the oxytocin infusion immediately",
                rationale="Uterine tachysystole reduces fetal oxygenation; stopping oxytocin is the first step.",
                priority="critical",
                tags=("safety", "medication"),
            ),
            OptionSeed(
                statement="Encourage the client to blow in short breaths and not push",
                rationale="Pushing before full dilation can cause cervical edema and lacerations.",
                priority="critical",
                tags=("coaching",),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Administer oxygen via nasal cannula at 2 L/min",
                rationale="For fetal distress, oxygen is typically given via non-rebreather at 8-10 L/min.",
                priority="supportive",
                tags=("intervention",),
            ),
            OptionSeed(
                statement="Prepare for immediate cesarean section",
                rationale="Conservative measures (position, fluids, O2) are tried first unless distress is severe/prolonged.",
                priority="supportive",
                tags=("escalation",),
            ),
            OptionSeed(
                statement="Increase the IV fluid rate",
                rationale="Helpful for late decelerations (placental insufficiency), but position is key for variables.",
                priority="supportive",
                tags=("intervention",),
            ),
        ],
        default_difficulty="hard",
        cognitive_level="Analysis",
        references=("Fetal monitoring", "Labor management"),
    ),
    Blueprint(
        id="peds_development_safety",
        category="Health Promotion and Maintenance",
        theme="Pediatric Development and Safety",
        stems=[
            "Which statement by the parent indicates a need for further teaching?",
            "What is the most appropriate toy for this child?",
            "Which finding should the nurse recognize as a developmental delay?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 9-month-old infant",
                setting="a pediatric clinic",
                therapy="well-child checkup",
                context="The nurse is discussing home safety and developmental milestones with the parents.",
                monitoring_focus="developmental milestones",
            ),
            ScenarioSeed(
                patient_overview="a 4-year-old toddler",
                setting="a pediatric ward",
                therapy="hospitalization for pneumonia",
                context="The child is bored and the parents ask for activity recommendations.",
                monitoring_focus="therapeutic play",
            ),
            ScenarioSeed(
                patient_overview="a 15-month-old toddler",
                setting="a community health center",
                therapy="nutritional counseling",
                context="The parent reports the child is not yet walking independently.",
                monitoring_focus="gross motor skills",
            ),
        ],
        question_angles=[
            "anticipatory guidance",
            "developmental assessment",
            "age-appropriate activities",
        ],
        critical_cues=[
            OptionSeed(
                statement="I can leave the baby in the bathtub for a minute to get a towel",
                rationale="Infants can drown in an inch of water; never leave them unattended.",
                priority="critical",
                tags=("safety", "education"),
            ),
            OptionSeed(
                statement="Provide a medical kit or puppets for dramatic play",
                rationale="Preschoolers use magical thinking and play to cope with hospitalization fears.",
                priority="critical",
                tags=("development", "play"),
            ),
            OptionSeed(
                statement="Not pulling up to a standing position",
                rationale="By 15 months, a child should be walking or at least cruising/standing. Not pulling up is a delay.",
                priority="critical",
                tags=("assessment", "milestones"),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="My baby sits without support",
                rationale="Sitting without support is expected by 8 months.",
                priority="supportive",
                tags=("normal",),
            ),
            OptionSeed(
                statement="Give the child a 50-piece jigsaw puzzle",
                rationale="Too complex for a 4-year-old; frustration may result.",
                priority="supportive",
                tags=("development",),
            ),
            OptionSeed(
                statement="Speaking 3-5 words",
                rationale="Normal for a 15-month-old (range 3-6 words).",
                priority="supportive",
                tags=("normal",),
            ),
        ],
        default_difficulty="medium",
        cognitive_level="Application",
        references=("Pediatric development", "Safety guidelines"),
    ),
    Blueprint(
        id="mental_health_crisis",
        category="Psychosocial Integrity",
        theme="Crisis Intervention and Suicide Risk",
        stems=[
            "What is the nurse's priority action to ensure safety?",
            "Which statement by the client requires immediate follow-up?",
            "How should the nurse respond to the client's statement?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 24-year-old with major depressive disorder",
                setting="an emergency department",
                therapy="psychiatric evaluation",
                context="The client admits to having a plan to overdose on medication.",
                monitoring_focus="suicide risk",
            ),
            ScenarioSeed(
                patient_overview="a 40-year-old with bipolar disorder",
                setting="an inpatient psychiatric unit",
                therapy="stabilization of acute mania",
                context="The client is pacing rapidly, talking loudly, and intruding on others.",
                monitoring_focus="milieu management",
            ),
            ScenarioSeed(
                patient_overview="a 19-year-old with borderline personality disorder",
                setting="a mental health clinic",
                therapy="dialectical behavior therapy",
                context="The client expresses feelings of emptiness and fear of abandonment.",
                monitoring_focus="therapeutic communication",
            ),
        ],
        question_angles=[
            "assessing suicide lethality",
            "managing acute agitation",
            "therapeutic communication",
        ],
        critical_cues=[
            OptionSeed(
                statement="Assign a staff member to stay with the client at all times (1:1 observation)",
                rationale="Direct observation is the only way to ensure safety for a client with a specific suicide plan.",
                priority="critical",
                tags=("safety", "suicide"),
            ),
            OptionSeed(
                statement="Walk with the client to a quiet area and speak in a calm, low voice",
                rationale="Reducing stimulation and using a calm approach helps de-escalate manic behavior.",
                priority="critical",
                tags=("intervention", "mania"),
            ),
            OptionSeed(
                statement="I have given away my prized guitar collection",
                rationale="Giving away possessions is a classic warning sign of impending suicide attempt.",
                priority="critical",
                tags=("assessment", "red-flag"),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Ask the client why they feel this way",
                rationale="'Why' questions can be perceived as judgmental and block communication.",
                priority="supportive",
                tags=("communication",),
            ),
            OptionSeed(
                statement="Administer a sedative immediately",
                rationale="Least restrictive measures (verbal de-escalation, quiet room) should be tried first.",
                priority="supportive",
                tags=("intervention",),
            ),
            OptionSeed(
                statement="Contract for safety",
                rationale="No-suicide contracts are not a substitute for observation and are controversial in efficacy.",
                priority="supportive",
                tags=("intervention",),
            ),
        ],
        default_difficulty="hard",
        cognitive_level="Analysis",
        references=("Suicide prevention", "Crisis intervention"),
    ),
    Blueprint(
        id="pharm_high_alert",
        category="Pharmacological and Parenteral Therapies",
        theme="High-Alert Medication Safety",
        stems=[
            "Which action is essential to prevent a medication error?",
            "What is the priority assessment before administering this medication?",
            "Which finding indicates an adverse reaction to the medication?",
        ],
        scenarios=[
            ScenarioSeed(
                patient_overview="a 55-year-old with diabetic ketoacidosis (DKA)",
                setting="an ICU",
                therapy="continuous IV insulin infusion",
                context="The nurse is preparing to adjust the infusion rate based on blood glucose levels.",
                monitoring_focus="insulin safety",
            ),
            ScenarioSeed(
                patient_overview="a 62-year-old with a pulmonary embolism",
                setting="a medical unit",
                therapy="IV heparin protocol",
                context="The latest PTT result is 98 seconds (control 30 seconds).",
                monitoring_focus="anticoagulation monitoring",
            ),
            ScenarioSeed(
                patient_overview="a 70-year-old with heart failure",
                setting="a telemetry unit",
                therapy="digoxin and furosemide therapy",
                context="The client reports seeing yellow halos around lights.",
                monitoring_focus="drug toxicity",
            ),
        ],
        question_angles=[
            "safe administration of high-alert meds",
            "monitoring for toxicity",
            "interpreting lab values for dosing",
        ],
        critical_cues=[
            OptionSeed(
                statement="Verify the insulin dose and rate with a second registered nurse",
                rationale="Independent double-checks are standard of care for high-alert medications like IV insulin.",
                priority="critical",
                tags=("safety", "medication"),
            ),
            OptionSeed(
                statement="Stop the heparin infusion and notify the provider",
                rationale="A PTT of 98 is >3x control, indicating high bleeding risk. The infusion should be held.",
                priority="critical",
                tags=("safety", "anticoagulation"),
            ),
            OptionSeed(
                statement="Obtain a serum digoxin level and potassium level",
                rationale="Visual disturbances are a sign of digoxin toxicity, often potentiated by hypokalemia.",
                priority="critical",
                tags=("assessment", "toxicity"),
            ),
        ],
        supportive_cues=[
            OptionSeed(
                statement="Administer the insulin via gravity drip",
                rationale="Insulin must be on an electronic infusion pump for precise dosing.",
                priority="supportive",
                tags=("unsafe",),
            ),
            OptionSeed(
                statement="Decrease the heparin rate by 2 units/kg/hr",
                rationale="With a critically high PTT, holding the dose is usually required before restarting at a lower rate.",
                priority="supportive",
                tags=("intervention",),
            ),
            OptionSeed(
                statement="Administer the next dose of digoxin",
                rationale="With signs of toxicity, the dose should be held until levels are checked.",
                priority="supportive",
                tags=("unsafe",),
            ),
        ],
        default_difficulty="hard",
        cognitive_level="Application",
        references=("High-alert medications", "Medication safety"),
    ),
]

PATIENT_NAMES = [
    "Mr. Alvarez",
    "Ms. Chen",
    "Mx. Jordan",
    "Ms. Okafor",
    "Mr. Singh",
    "Ms. Romero",
    "Mr. Ibrahim",
    "Ms. Patel",
    "Mr. Wallace",
    "Ms. Nguyen",
    "Mx. Santos",
    "Ms. Harper",
    "Mr. Lopez",
    "Ms. Mbatha",
    "Mr. Carter",
    "Ms. Osei",
    "Mr. Park",
    "Ms. Silva",
    "Mr. Brown",
    "Ms. Rodriguez",
    "Mr. Okoye",
    "Ms. Yamamoto",
    "Dr. Bennett",
    "Mr. Al-Rashid",
    "Ms. Kowalski",
    "Mr. Haddad",
    "Ms. Gomez",
    "Mr. Rossi",
    "Ms. Chenoweth",
    "Mr. Yang",
    "Ms. Wilson",
    "Mr. Kaur",
]


def choose_options(blueprint: Blueprint, rng: random.Random, option_target: int = 6) -> List[dict]:
    option_target = max(4, option_target)
    correct_pool = list(blueprint.critical_cues)
    incorrect_pool = list(blueprint.supportive_cues)
    rng.shuffle(correct_pool)
    rng.shuffle(incorrect_pool)
    num_correct = 1
    selected = correct_pool[:num_correct]
    min_incorrect_needed = max(option_target - len(selected), 2)
    remaining_slots = min(len(incorrect_pool), min_incorrect_needed)
    if remaining_slots < min_incorrect_needed and len(correct_pool) > num_correct:
        extra_needed = min_incorrect_needed - remaining_slots
        selected += correct_pool[num_correct : num_correct + extra_needed]
    selected += incorrect_pool[:remaining_slots]
    if len(selected) > option_target:
        critical = [opt for opt in selected if opt.priority == "critical"]
        supportive = [opt for opt in selected if opt.priority != "critical"]
        rng.shuffle(critical)
        rng.shuffle(supportive)
        trimmed: List[OptionSeed] = []
        while critical and len(trimmed) < 2:
            trimmed.append(critical.pop())
        while critical and len(trimmed) < option_target:
            trimmed.append(critical.pop())
        while supportive and len(trimmed) < option_target:
            trimmed.append(supportive.pop())
        selected = trimmed
    rng.shuffle(selected)
    options = []
    label_ord = ord('A')
    for seed in selected:
        options.append(
            {
                "label": chr(label_ord),
                "text": seed.statement,
                "is_correct": seed.priority == "critical",
                "rationale": seed.rationale,
                "tags": list(seed.tags),
            }
        )
        label_ord += 1
    return options


def build_question(blueprint: Blueprint, scenario: ScenarioSeed, idx: int, total: int, rng: random.Random) -> dict:
    stem_template = rng.choice(list(blueprint.stems))
    angle = rng.choice(list(blueprint.question_angles))
    assigned_name = rng.choice(PATIENT_NAMES)
    
    # Helper to capitalize the first letter of the patient overview if needed
    p_overview = scenario.patient_overview
    p_overview_cap = p_overview[0].upper() + p_overview[1:] if p_overview else p_overview

    # Diverse scenario templates to avoid "The nurse is caring for..." repetition
    templates = [
        # Standard Clinical Narrative
        f"The nurse is caring for {p_overview} ({assigned_name}) in {scenario.setting}. The client is receiving {scenario.therapy}. {scenario.context}",
        f"{p_overview_cap} ({assigned_name}) is being treated in {scenario.setting} with {scenario.therapy}. {scenario.context}",
        
        # Shift Report / Handover
        f"During shift report, the nurse receives information about {assigned_name}, {p_overview} in {scenario.setting} who is receiving {scenario.therapy}. {scenario.context}",
        f"The nurse assumes care of {p_overview} ({assigned_name}) in {scenario.setting}. The client's current regimen includes {scenario.therapy}. {scenario.context}",
        
        # Assignment / Caseload
        f"The nurse is assigned to {p_overview} ({assigned_name}) in {scenario.setting}. Current therapy includes {scenario.therapy}. {scenario.context}",
        f"A nurse in {scenario.setting} is managing the care of {assigned_name}, {p_overview}, who is undergoing {scenario.therapy}. {scenario.context}",
        
        # Location / Setting Focus
        f"In {scenario.setting}, the nurse is evaluating {p_overview} ({assigned_name}) who is receiving {scenario.therapy}. {scenario.context}",
        f"A client, {assigned_name} ({p_overview}), is admitted to {scenario.setting} for {scenario.therapy}. {scenario.context}",
        
        # Action / Assessment Focus
        f"The nurse is preparing to assess {assigned_name}, {p_overview} in {scenario.setting}, who is currently on {scenario.therapy}. {scenario.context}",
        f"While assessing {p_overview} ({assigned_name}) in {scenario.setting}, the nurse notes the client is receiving {scenario.therapy}. {scenario.context}",
        f"The nurse enters the room of {p_overview} ({assigned_name}) in {scenario.setting} to administer {scenario.therapy}. {scenario.context}",
        
        # Chart / Record Review
        f"The nurse reviews the medical record of {p_overview} ({assigned_name}) in {scenario.setting}. The client is prescribed {scenario.therapy}. {scenario.context}",
        f"Electronic health records for {assigned_name}, {p_overview} in {scenario.setting}, indicate active treatment with {scenario.therapy}. {scenario.context}",
        
        # Team / Provider Interaction
        f"The healthcare provider prescribes {scenario.therapy} for {p_overview} ({assigned_name}) in {scenario.setting}. {scenario.context}",
        f"An interdisciplinary team in {scenario.setting} is discussing the care plan for {assigned_name}, {p_overview}, who is receiving {scenario.therapy}. {scenario.context}",
        
        # Urgent / Emergency Context
        f"The nurse responds to a call light for {p_overview} ({assigned_name}) in {scenario.setting}. The client is on {scenario.therapy}. {scenario.context}",
        
        # Education / Discharge
        f"The nurse is planning discharge teaching for {p_overview} ({assigned_name}) in {scenario.setting} regarding {scenario.therapy}. {scenario.context}",
        f"A client, {assigned_name} ({p_overview}), asks the nurse in {scenario.setting} about their {scenario.therapy}. {scenario.context}",
        
        # Temporal / Sequence
        f"Following the initiation of {scenario.therapy} for {p_overview} ({assigned_name}) in {scenario.setting}, the nurse performs an assessment. {scenario.context}",
        f"At the beginning of the shift in {scenario.setting}, the nurse checks on {assigned_name}, {p_overview}, who is receiving {scenario.therapy}. {scenario.context}",
    ]
    
    scenario_text = rng.choice(templates)
    
    stem = stem_template.format(therapy=scenario.therapy, monitoring_focus=scenario.monitoring_focus)
    options = choose_options(blueprint, rng)
    correct_labels = [opt["label"] for opt in options if opt["is_correct"]]
    return {
        "id": f"NCLEX-{idx:04d}",
        "sequence": idx,
        "category": blueprint.category,
        "theme": blueprint.theme,
        "case_summary": scenario_text,
        "question": stem,
        "angle": angle,
        "options": options,
        "correct_labels": correct_labels,
        "difficulty": blueprint.default_difficulty,
        "cognitive_level": blueprint.cognitive_level,
        "blueprint_id": blueprint.id,
        "references": list(blueprint.references),
        "rendered_prompt": (
            f"Question {idx} of {total}\n"
            f"Category: {blueprint.category}\n\n{scenario_text}\n\n{stem}"
        ),
    }


def convert_to_app_question(q: dict, quiz_id: str) -> dict:
    # Combine case summary and question stem
    text = f"{q['case_summary']}\n\n{q['question']}"
    
    options_list = q['options']
    option_texts = [o['text'] for o in options_list]
    
    correct_idx = 0
    explanation = ""
    
    for i, opt in enumerate(options_list):
        if opt['is_correct']:
            correct_idx = i
            explanation = opt['rationale']
            break
            
    return {
        "id": q['id'],
        "text": text,
        "options": option_texts,
        "correctIndex": correct_idx,
        "explanation": explanation,
        "type": "mcq",
        "variants": []
    }


def generate_bank(count: int, seed: int | None) -> dict:
    rng = random.Random(seed)
    questions_data: List[dict] = []
    
    # Create a pool of blueprints to cycle through to minimize repetition
    blueprint_pool = list(BLUEPRINTS)
    rng.shuffle(blueprint_pool)
    pool_index = 0
    
    for idx in range(1, count + 1):
        if pool_index >= len(blueprint_pool):
            rng.shuffle(blueprint_pool)
            pool_index = 0
            
        blueprint = blueprint_pool[pool_index]
        pool_index += 1
        
        scenario = rng.choice(list(blueprint.scenarios))
        questions_data.append(build_question(blueprint, scenario, idx, count, rng))
    
    # Group by category
    by_category = {}
    for q in questions_data:
        cat = q["category"]
        if cat not in by_category:
            by_category[cat] = []
        by_category[cat].append(q)

    quizzes = []
    
    # 1. Comprehensive Quiz
    comp_quiz_id = "quiz-nclex-comprehensive"
    all_app_questions = [convert_to_app_question(q, comp_quiz_id) for q in questions_data]
        
    quizzes.append({
        "id": comp_quiz_id,
        "title": "NCLEX Comprehensive Practice",
        "durationMinutes": 90,
        "createdAt": datetime.utcnow().isoformat() + "Z",
        "isOffline": True,
        "questions": all_app_questions
    })

    # 2. Category Quizzes
    for cat, cat_questions in by_category.items():
        slug = cat.lower().replace(" ", "-").replace("&", "and").replace(",", "")
        quiz_id = f"quiz-nclex-{slug}"
        quizzes.append({
            "id": quiz_id,
            "title": f"NCLEX: {cat}",
            "durationMinutes": 45,
            "createdAt": datetime.utcnow().isoformat() + "Z",
            "isOffline": True,
            "questions": [convert_to_app_question(q, quiz_id) for q in cat_questions]
        })

    topic = {
        "id": "topic-nclex",
        "name": "NCLEX Practice",
        "description": "Comprehensive NCLEX-RN practice questions covering all major client needs categories.",
        "detailedDescription": "Authentic NCLEX-RN style practice questions designed following the NCLEX test plan and Nurseslabs methodology. This comprehensive question bank covers all Client Needs categories: Safe and Effective Care Environment (Management of Care, Safety and Infection Control), Health Promotion and Maintenance, Psychosocial Integrity, and Physiological Integrity (Basic Care and Comfort, Pharmacological Therapies, Reduction of Risk Potential, Physiological Adaptation). Each question includes detailed clinical scenarios, rationales for correct and incorrect answers, and mirrors the complexity and format of actual NCLEX exam questions. Perfect for final exam preparation and building test-taking confidence.",
        "icon": "assets/icons/logo.png",
        "slug": "nclex-practice",
        "createdAt": datetime.utcnow().isoformat() + "Z"
    }

    return {
        "topic": topic,
        "quizzes": quizzes
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate NCLEX-style practice questions.")
    parser.add_argument("--count", type=int, default=750, help="Number of questions to generate (default: 750)")
    parser.add_argument("--seed", type=int, default=None, help="Optional random seed for reproducibility")
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("assets/data/nclex_practice_bank.json"),
        help="Where to write the generated bank (default: assets/data/nclex_practice_bank.json)",
    )
    args = parser.parse_args()

    bank = generate_bank(args.count, args.seed)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(bank, indent=2), encoding="utf-8")
    print(f"Wrote {args.count} NCLEX-style questions (grouped into quizzes) to {args.output}")


if __name__ == "__main__":
    main()
