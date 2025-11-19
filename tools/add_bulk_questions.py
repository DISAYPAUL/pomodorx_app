import json
import sys

# Load existing JSON
with open('assets/data/nclex_practice_bank.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# Additional questions for Maternal-Newborn (add 10 more)
maternal_questions = [
    {
        "id": "MAT-POST-001",
        "text": "28yo woman 6 hours post-vaginal delivery. Fundus firm at umbilicus. Lochia rubra heavy, saturating pad in 15 minutes, passing large clots. BP 98/54 (was 118/76), HR 110, pale. Priority action?",
        "options": [
            "Massage fundus vigorously to prevent uterine atony and continue monitoring",
            "Notify provider immediately, establish second IV, prepare for potential hemorrhage interventions",
            "Encourage frequent voiding as full bladder can displace uterus and cause bleeding",
            "Document findings as normal postpartum bleeding, continue routine assessments q15min"
        ],
        "correctIndex": 1,
        "explanation": "POSTPARTUM HEMORRHAGE: Saturating pad in <1 hour = excessive bleeding. Patient showing signs of hypovolemia (↑HR, ↓BP, pale). Leading cause: uterine atony, but fundus is firm here so consider lacerations, retained placenta fragments, coagulopathy. PRIORITY: Notify provider STAT, establish second large-bore IV, prepare for hemorrhage protocol (blood type/cross, CBC, clotting studies, possible meds like oxytocin/methergine/misoprostol/TXA, potential D&C or OR for repair). Fundal massage only for atony. Early recognition prevents shock.",
        "type": "mcq",
        "variants": []
    },
    {
        "id": "MAT-GЕСТ-001",
        "text": "32yo G1P0 at 28 weeks with gestational diabetes on insulin. Fasting glucose 118 mg/dL (goal <95), 1-hr post-meal 165 mg/dL (goal <140). Reports following diet but 'sometimes have cravings.' What's priority teaching?",
        "options": [
            "Educate about risks of hyperglycemia: macrosomia, birth trauma, neonatal hypoglycemia, increased C-section risk",
            "Instruct to decrease carbohydrates drastically to achieve better glucose control",
            "Reassure that slightly elevated glucose is normal in pregnancy and not concerning",
            "Recommend switching from insulin to oral medications for better compliance"
        ],
        "correctIndex": 0,
        "explanation": "GESTATIONAL DIABETES MANAGEMENT: Patient's glucose levels exceed targets (fasting >95, post-meal >140), indicating inadequate control despite insulin. PRIORITY: Education about fetal/neonatal risks motivates compliance. Risks include: Macrosomia (large baby >4000g) causing shoulder dystocia/birth injury, Polyhydramnios, Preterm birth, Respiratory distress, Neonatal hypoglycemia (baby's pancreas overproduces insulin in response to maternal hyperglycemia, then at birth glucose supply stops but insulin still high), Increased C-section, Future diabetes risk for both. Need to reinforce diet adherence, proper insulin technique, glucose monitoring. Don't drastically restrict carbs (need 175g/day minimum for fetal brain). Oral agents (metformin/glyburide) used second-line, not first switch.",
        "type": "mcq",
        "variants": []
    },
    {
        "id": "MAT-NEONATAL-001",
        "text": "Newborn 2 hours old, term infant. Nurse notes: HR 145, RR 68, grunting, nasal flaring, intercostal retractions, central cyanosis. SpO2 88% on RA. What's immediate action?",
        "options": [
            "Document findings as normal transitional breathing in newborn first few hours",
            "Provide oxygen support, notify provider immediately, prepare for possible sepsis workup or respiratory support",
            "Suction nose and mouth thoroughly to clear secretions causing respiratory distress",
            "Stimulate newborn by rubbing back vigorously to encourage deeper breathing"
        ],
        "correctIndex": 1,
        "explanation": "NEONATAL RESPIRATORY DISTRESS: Grunting + nasal flaring + retractions + central cyanosis + tachypnea (RR >60) + hypoxia (SpO2 <90%) = ABNORMAL, requires immediate intervention. Causes: TTN (transient tachypnea of newborn - retained fetal lung fluid), RDS (respiratory distress syndrome - surfactant deficiency, more common in preterm), pneumonia/sepsis, meconium aspiration, pneumothorax, congenital heart disease. PRIORITY: Provide supplemental O2 (hood, CPAP as needed), notify provider/NICU team, continuous monitoring, assess for sepsis risk factors, chest X-ray. This is NOT normal transition (normal RR <60, no grunting/retractions, no cyanosis). Early intervention prevents hypoxic injury.",
        "type": "mcq",
        "variants": []
    },
    {
        "id": "MAT-BREASTFEED-001",
        "text": "First-time mom attempting breastfeeding day 2 postpartum. Baby latching poorly, mother's nipples cracked and bleeding, baby lost 8% birth weight. Mom crying, says 'I'm a failure, formula would be easier.' Best nursing response?",
        "options": [
            "Agree that formula would be easier and less painful, support her decision to switch",
            "Assess latch technique, provide lactation support, validate feelings, discuss benefits of continuing with proper technique and pain management",
            "Tell her that breast is best and she needs to continue despite difficulty for baby's health",
            "Recommend pumping exclusively to avoid nipple pain while still providing breast milk"
        ],
        "correctIndex": 1,
        "explanation": "BREASTFEEDING SUPPORT: Poor latch causes nipple trauma and inadequate milk transfer (8% weight loss is upper limit of normal, >10% concerning). Patient needs SUPPORT, not judgment. APPROACH: 1) Validate feelings ('Breastfeeding is challenging, you're not failing'), 2) Assess latch (look for wide open mouth, flanged lips, nose touching breast, audible swallowing), 3) Correct positioning (football hold, cross-cradle, laid-back nursing), 4) Pain management (warm compresses, nipple ointment, hydrogel pads, proper latch), 5) Lactation consultant referral, 6) Reassure milk production increases days 3-5, 7) Supplementation if medically indicated with plan to continue breastfeeding. Pressuring or dismissing concerns undermines confidence. Exclusive pumping is option but harder. Informed decision-making supported.",
        "type": "mcq",
        "variants": []
    },
    {
        "id": "MAT-ECLAMPSIA-001",
        "text": "36-week pregnant woman with severe preeclampsia on magnesium sulfate. Nurse notes: decreased LOC, RR 10/min, absent deep tendon reflexes, UOP 20 mL past 4 hours. What's priority action?",
        "options": [
            "Increase magnesium sulfate infusion rate per protocol to prevent seizures",
            "Stop magnesium sulfate immediately, notify provider, prepare calcium gluconate at bedside",
            "Continue current magnesium rate, encourage oral fluids to increase urine output",
            "Perform neurological assessment and document findings in chart"
        ],
        "correctIndex": 1,
        "explanation": "MAGNESIUM TOXICITY: Absent reflexes + decreased RR + decreased LOC + oliguria = TOXIC magnesium levels requiring immediate intervention. Therapeutic mag level 4-7 mEq/L, toxic >7-8. Signs of toxicity progress: Loss of deep tendon reflexes (first sign, 10-12 mEq/L), Respiratory depression <12/min (12 mEq/L), Decreased LOC, Cardiac arrest (>15 mEq/L). IMMEDIATE ACTIONS: 1) STOP mag sulfate infusion, 2) Notify provider STAT, 3) Prepare ANTIDOTE: calcium gluconate 1g (10 mL of 10% solution) IV over 3 minutes, 4) Support respirations (may need bag-valve-mask or intubation), 5) Continuous monitoring, 6) Stat mag level. Continuing mag or increasing dose is LETHAL. Oliguria causes mag accumulation (excreted renally). Mag prevents seizures but toxicity causes respiratory/cardiac arrest.",
        "type": "mcq",
        "variants": []
    }
]

# Find Maternal-Newborn quiz and add questions
for quiz in data['quizzes']:
    if quiz['id'] == 'quiz-nclex-maternal':
        quiz['questions'].extend(maternal_questions)
        print(f"Added {len(maternal_questions)} questions to Maternal-Newborn Nursing")

# Additional questions for Pediatric (add 10 more)
pediatric_questions = [
    {
        "id": "PEDS-ASTHMA-001",
        "text": "5yo with asthma in ED. Received 3 albuterol nebs, still wheezing, retractions, RR 44, SpO2 90%, can't speak full sentences. Peak flow 40% predicted. What's next priority medication?",
        "options": [
            "Continue albuterol nebulizers q20min and reassess response",
            "Administer systemic corticosteroids (prednisone PO or methylprednisolone IV) immediately",
            "Give inhaled corticosteroid (fluticasone) via nebulizer for anti-inflammatory effect",
            "Administer antibiotics for suspected respiratory infection triggering asthma"
        ],
        "correctIndex": 1,
        "explanation": "SEVERE ASTHMA EXACERBATION: Failed to respond to 3 albuterol treatments + severe symptoms (can't speak sentences, high RR, hypoxia, low peak flow <50%) = SEVERE exacerbation requiring systemic steroids. Albuterol (bronchodilator) opens airways immediately but doesn't treat inflammation. Corticosteroids (prednisone PO or methylprednisolone IV) reduce airway inflammation but take 4-6 hours to work - must give EARLY. Standard severe asthma treatment: 1) Continuous albuterol nebs or high-dose q20min, 2) Systemic corticosteroids within first hour, 3) Ipratropium bromide added to albuterol, 4) Oxygen to maintain SpO2 >90%, 5) Consider IV magnesium sulfate for refractory cases, 6) Possible ICU/intubation if not improving. Inhaled steroids don't work in acute severe exacerbation. Antibiotics only if bacterial infection present (asthma often viral-triggered).",
        "type": "mcq",
        "variants": []
    },
    {
        "id": "PEDS-DIABETES-001",
        "text": "12yo with type 1 diabetes at camp. Before lunch glucose 62 mg/dL. Child alert, oriented, cooperative. Lunch in 15 minutes. What's appropriate intervention?",
        "options": [
            "Give 15g fast-acting carbs immediately (juice, glucose tabs), recheck glucose in 15 min, then give lunch with usual insulin",
            "Have child eat lunch immediately with double insulin dose to prevent rebound hyperglycemia",
            "Skip lunch insulin dose entirely since glucose is low, allow child to eat freely",
            "Administer glucagon injection IM immediately for hypoglycemia treatment"
        ],
        "correctIndex": 0,
        "explanation": "HYPOGLYCEMIA TREATMENT (conscious patient): 'Rule of 15' - Give 15g fast-acting carbohydrate (4oz juice, 3-4 glucose tabs, 1 tbsp honey), Wait 15 minutes and recheck glucose, Repeat if still <70 mg/dL, Once glucose normalized, give complex carb/protein to prevent recurrence. Then proceed with normal meal and insulin dosing. Glucagon is for UNCONSCIOUS/seizing patients unable to swallow safely. Doubling insulin with low glucose is dangerous. Skipping insulin completely causes hyperglycemia. Fast-acting carbs first, then regular meal prevents hypoglycemia continuing or rebounding. Teach child to always treat hypo symptoms immediately.",
        "type": "mcq",
        "variants": []
    },
    {
        "id": "PEDS-MENINGITIS-001",
        "text": "3yo in ED with fever 103.8°F, severe headache, vomiting, nuchal rigidity, petechial rash on trunk/legs. Lethargic. LP shows elevated WBC, low glucose, high protein in CSF. Priority nursing action?",
        "options": [
            "Place in private room, initiate droplet precautions, administer IV antibiotics within 30 minutes per protocol",
            "Perform thorough neurological assessment and document findings before starting treatment",
            "Notify parents of serious diagnosis, allow time for visitation before isolation precautions",
            "Obtain blood cultures, then wait for CSF culture results before starting antibiotics"
        ],
        "correctIndex": 0,
        "explanation": "BACTERIAL MENINGITIS: Fever + headache + nuchal rigidity + petechiae + altered mental status + CSF findings = BACTERIAL MENINGITIS (likely meningococcal given rash). This is MEDICAL EMERGENCY with high mortality/morbidity. PRIORITY: 1) ISOLATION - droplet precautions immediately (meningococcus spreads via respiratory droplets), 2) IV ANTIBIOTICS within 30-60 minutes (every hour delay increases mortality - give empiric broad-spectrum like ceftriaxone + vancomycin BEFORE culture results), 3) Supportive care (fluids, antipyretics, seizure precautions), 4) Close contact prophylaxis for family/healthcare workers. Don't delay antibiotics for assessment or cultures - time is brain tissue. Petechial/purpuric rash suggests meningococcemia (can progress to septic shock rapidly). Complications: death, hearing loss, brain damage, limb amputation if septic shock.",
        "type": "mcq",
        "variants": []
    },
    {
        "id": "PEDS-EPIGLOTTITIS-001",
        "text": "4yo in ED with sudden onset high fever 104°F, severe sore throat, drooling, tripod positioning, muffled voice, inspiratory stridor. Appears toxic. Suspected epiglottitis. What should nurse avoid?",
        "options": [
            "Keeping child calm in position of comfort on parent's lap",
            "Examining throat with tongue depressor to visualize epiglottis",
            "Administering oxygen via blow-by method",
            "Maintaining NPO status and having intubation equipment ready"
        ],
        "correctIndex": 1,
        "explanation": "EPIGLOTTITIS (medical emergency): Sudden onset, high fever, drooling (can't swallow), tripod position (leaning forward with jaw thrust), toxic appearance, stridor. Caused by H. influenzae type B (less common post-Hib vaccine) or other bacteria. Inflamed epiglottis can completely obstruct airway. NEVER EXAMINE THROAT with tongue depressor - can trigger laryngospasm causing complete airway obstruction and death. MANAGEMENT: 1) Keep child CALM (crying worsens obstruction), 2) Let parent hold in position of comfort, 3) Blow-by oxygen, 4) NPO (potential for intubation/surgery), 5) Notify anesthesia/ENT STAT, 6) Intubation in OR (controlled environment by experienced provider), 7) IV antibiotics after airway secured. Lateral neck X-ray shows 'thumb sign' but don't leave child to get X-ray if unstable. Treat as emergency until proven otherwise.",
        "type": "mcq",
        "variants": []
    },
    {
        "id": "PEDS-POISONING-001",
        "text": "2yo brought to ED after ingesting grandmother's digoxin tablets 90 minutes ago. Unknown amount. Child currently asymptomatic. HR 88, regular rhythm on monitor. What's priority?",
        "options": [
            "Reassure parents that child appears fine and discharge home with poison control follow-up instructions",
            "Admit for continuous cardiac monitoring, check digoxin level, electrolytes, ECG, observe minimum 24 hours",
            "Administer activated charcoal immediately to prevent digoxin absorption",
            "Induce vomiting with syrup of ipecac to remove pills from stomach"
        ],
        "correctIndex": 1,
        "explanation": "DIGOXIN INGESTION IN CHILD: Potentially FATAL even if currently asymptomatic. Digoxin has long half-life (36-48 hours), narrow therapeutic window, severe toxicity in children. Toxicity causes: bradycardia, heart blocks, ventricular arrhythmias (including V-fib), hyperkalemia, nausea/vomiting, neurological symptoms. MANAGEMENT: 1) Admit for cardiac monitoring minimum 24 hours (toxicity can develop hours later), 2) Check digoxin level (may not peak for several hours), 3) ECG (look for bradycardia, AV blocks, T-wave changes), 4) Electrolytes (hyperkalemia is major concern, treat with digoxin-specific antibody fragments - Digibind/DigiFab), 5) Activated charcoal if within 1 hour of ingestion AND child can protect airway (often too late at 90 min but may give if significant ingestion), 6) Do NOT induce vomiting (ipecac is contraindicated). Never discharge asymptomatic poisoned child without full evaluation - appearance doesn't predict toxicity.",
        "type": "mcq",
        "variants": []
    }
]

for quiz in data['quizzes']:
    if quiz['id'] == 'quiz-nclex-pediatric':
        quiz['questions'].extend(pediatric_questions)
        print(f"Added {len(pediatric_questions)} questions to Pediatric Nursing")

# Additional questions for Mental Health (add 10 more)
mental_health_questions = [
    {
        "id": "MH-SUICIDE-001",
        "text": "52yo man admitted for depression states 'I've been a burden to my family too long. I've made arrangements for after I'm gone.' What's priority nursing assessment?",
        "options": [
            "Ask directly: 'Are you thinking about killing yourself? Do you have a plan? Do you have access to means?'",
            "Avoid asking about suicide as it might give patient ideas or upset them further",
            "Change subject to more positive topics to improve patient's mood and outlook",
            "Document concerning statement and notify provider at end of shift"
        ],
        "correctIndex": 0,
        "explanation": "SUICIDE ASSESSMENT: 'Made arrangements' suggests planning (getting affairs in order), significantly elevates risk. ALWAYS ask directly about suicidal ideation - asking does NOT plant ideas, it opens conversation and shows you care. Assess using SAD PERSONS or similar: Specific plan? (method, time, place), Access to means? (guns, pills, etc), Deterrents? (reasons to live, religious beliefs, family), Prior attempts?, Hopelessness level, Support system. HIGH RISK INDICATORS: Specific detailed plan, Access to lethal means, Previous attempt, Male gender, Older age, Living alone, Chronic illness, Recent major loss, Substance abuse, Giving away possessions, 'Saying goodbye'. IMMEDIATE ACTIONS: 1-to-1 observation, Remove dangerous objects, Notify provider immediately for psychiatric evaluation, Safety contract, Possible transfer to psychiatric unit. Never ignore or delay reporting suicidal statements.",
        "type": "mcq",
        "variants": []
    },
    {
        "id": "MH-MANIA-001",
        "text": "Patient with bipolar disorder in manic phase: hyperactive, pressured speech, hasn't slept 3 days, hypersexual comments to staff, throwing objects. Priority nursing intervention?",
        "options": [
            "Place patient in seclusion room immediately to protect staff and other patients from harm",
            "Set clear behavioral limits in calm, non-confrontational manner, redirect to quiet activity, ensure safety, administer ordered PRN medication",
            "Engage patient in vigorous physical activity (basketball, running) to burn off excess energy",
            "Ignore inappropriate behavior as confronting will escalate agitation in manic state"
        ],
        "correctIndex": 1,
        "explanation": "ACUTE MANIA MANAGEMENT: Hyperactivity + pressured speech + insomnia + hypersexuality + aggression = manic episode requiring de-escalation and safety. APPROACH: 1) Calm, firm, consistent limits ('I can't allow you to throw objects. That's not safe'), 2) Low-stimulation environment (decrease noise, lights, activity), 3) Redirect to calming activities (walking, writing, art), 4) Brief, clear communication (attention span limited), 5) Pharmacological intervention (mood stabilizers like lithium/valproate, antipsychotics like olanzapine/risperidone for acute symptoms, benzodiazepines PRN for agitation), 6) Ensure safety of patient/others. Seclusion is LAST RESORT after less restrictive interventions fail. Vigorous activity can escalate mania. Ignoring dangerous behavior is unsafe. Balance: structure/limits while maintaining therapeutic relationship.",
        "type": "mcq",
        "variants": []
    },
    {
        "id": "MH-ALCOHOL-001",
        "text": "48yo man admitted for surgery reports drinking 'a few beers daily.' Last drink 18 hours ago. Now anxious, tremulous, HR 108, BP 156/94, diaphoretic. What's priority action?",
        "options": [
            "Reassure patient this is normal preoperative anxiety and give relaxation techniques",
            "Notify provider immediately, initiate alcohol withdrawal protocol (CIWA scale), anticipate benzodiazepine orders",
            "Administer one alcoholic beverage to prevent withdrawal symptoms before surgery",
            "Proceed with surgery as scheduled since patient is medically stable"
        ],
        "correctIndex": 1,
        "explanation": "ALCOHOL WITHDRAWAL: 'Few beers daily' = chronic alcohol use, now 18 hours abstinent with autonomic hyperactivity (tremor, tachycardia, hypertension, diaphoresis, anxiety) = early withdrawal. Timeline: 6-24 hours: tremor, anxiety, tachycardia, hypertension, 12-48 hours: hallucinations (usually visual), 24-72 hours: seizures, 48-96 hours: delirium tremens (DTs - confusion, severe autonomic instability, hallucinations, hyperthermia - 15% mortality if untreated). PRIORITY: 1) Notify provider for withdrawal protocol orders, 2) CIWA-Ar scale (Clinical Institute Withdrawal Assessment for Alcohol) q1-4 hours, 3) Benzodiazepines (lorazepam, diazepam) symptom-triggered or fixed-schedule dosing prevent seizures/DTs, 4) Thiamine/folate/multivitamin (prevent Wernicke's encephalopathy), 5) Hydration, electrolytes, 6) Seizure precautions, 7) Surgery likely delayed until withdrawal managed. Never give alcohol in hospital (medically inappropriate, illegal, dangerous). Untreated withdrawal can be fatal.",
        "type": "mcq",
        "variants": []
    },
    {
        "id": "MH-SCHIZOPHRENIA-001",
        "text": "Patient with schizophrenia reports 'The CIA planted a microchip in my brain that controls my thoughts.' Best nursing response?",
        "options": [
            "'That's not true. There's no microchip in your brain. You're having a delusion from your illness.'",
            "'I understand you believe that. It must be frightening. I don't share that perception. Let's talk about how you're feeling.'",
            "'Tell me more about the microchip. What does it look like? When was it implanted?'",
            "'You're safe here. Let's not talk about the microchip. Would you like to play cards?'"
        ],
        "correctIndex": 1,
        "explanation": "RESPONDING TO DELUSIONS: Delusion = fixed false belief not based in reality, not changed by logical argument. THERAPEUTIC APPROACH: 1) Don't argue or try to convince patient delusion is false (reinforces delusion, damages trust, creates power struggle), 2) Don't agree with delusion ('Yes, the CIA did that'), 3) Acknowledge feelings without confirming content ('I understand you believe that' vs 'I believe that too'), 4) Present reality gently ('I don't share that perception'), 5) Focus on underlying emotion (fear, anxiety, paranoia), 6) Redirect to reality-based topics when appropriate. Don't explore delusion details (option 3) - reinforces it. Don't abruptly dismiss concerns (option 4) - patient feels invalidated. Goal: maintain therapeutic alliance while not reinforcing psychotic symptoms. Antipsychotic medications treat underlying pathology.",
        "type": "mcq",
        "variants": []
    },
    {
        "id": "MH-EATING-DISORDER-001",
        "text": "17yo female with anorexia nervosa, BMI 14.5, admitted for refeeding. Day 3, complains of muscle weakness, paresthesias. ECG shows prolonged QT, flattened T-waves. What's priority concern?",
        "options": [
            "Normal effects of malnutrition that will resolve with continued nutritional rehabilitation",
            "Refeeding syndrome with electrolyte imbalances (hypophosphatemia, hypokalemia, hypomagnesemia), life-threatening arrhythmia risk",
            "Patient manipulating staff to avoid eating by feigning symptoms",
            "Anxiety symptoms from fear of weight gain requiring reassurance"
        ],
        "correctIndex": 1,
        "explanation": "REFEEDING SYNDROME: Occurs when severely malnourished patients receive nutrition too rapidly. During starvation, body adapts to low-energy state. Refeeding causes insulin surge driving glucose, phosphate, potassium, magnesium intracellularly, causing dangerously LOW serum levels. Hypophosphatemia (most dangerous): causes muscle weakness, respiratory failure, cardiac dysfunction, rhabdomyolysis, seizures. Hypokalemia: arrhythmias (prolonged QT, T-wave changes, V-fib, sudden death). Hypomagnesemia: arrhythmias, seizures. Thiamine deficiency: Wernicke's encephalopathy. PREVENTION/MANAGEMENT: 1) Start refeeding slowly (start 20-30 kcal/kg/day, advance gradually), 2) Monitor electrolytes daily (phosphate, potassium, magnesium), 3) Supplement prophylactically (phosphate, potassium, magnesium, thiamine before feeding), 4) Cardiac monitoring (ECG changes indicate electrolyte abnormalities), 5) Fluid management (avoid overload). This patient has classic refeeding syndrome signs - not malingering. Medical emergency requiring immediate electrolyte correction.",
        "type": "mcq",
        "variants": []
    }
]

for quiz in data['quizzes']:
    if quiz['id'] == 'quiz-nclex-mental':
        quiz['questions'].extend(mental_health_questions)
        print(f"Added {len(mental_health_questions)} questions to Mental Health Nursing")

# Additional questions for Pharmacology (add 10 more)
pharmacology_questions = [
    {
        "id": "PHARM-WARFARIN-001",
        "text": "Patient on warfarin for A-fib, INR 1.8 (goal 2-3). Provider orders warfarin 7.5mg tonight (usual dose 5mg). Patient asks why dose increased. Best explanation?",
        "options": [
            "'Your blood is clotting too easily (INR too low), so we need more warfarin to reach therapeutic anticoagulation and prevent stroke.'",
            "'The provider made an error. Your INR is fine. I'll clarify the order before giving medication.'",
            "'Higher doses are given periodically to prevent resistance to the medication developing over time.'",
            "'INR measures liver function, and yours is low, so we need to protect your liver with more medication.'"
        ],
        "correctIndex": 0,
        "explanation": "WARFARIN DOSING BASED ON INR: INR (International Normalized Ratio) measures warfarin's anticoagulant effect. Goal for A-fib: 2-3 (balances stroke prevention vs bleeding risk). INR 1.8 = SUBtherapeutic (not adequately anticoagulated), patient at increased stroke risk. Warfarin dose adjusted to achieve goal: INR too low → increase dose, INR too high → decrease or hold dose. Typical dose adjustments: 10-20% increase/decrease. Increasing from 5mg to 7.5mg (50% increase) is reasonable for INR 1.8 to bring into therapeutic range. INR checked frequently during initiation/adjustment (q3-7 days), then monthly when stable. Patient education: warfarin prevents blood clots/stroke, INR monitors effectiveness, diet consistency (vitamin K in green leafy veggies antagonizes warfarin), avoid alcohol excess, watch for bleeding signs. NOT liver function test (that's LFTs).",
        "type": "mcq",
        "variants": []
    },
    {
        "id": "PHARM-INSULIN-001",
        "text": "Type 1 diabetic takes NPH insulin 20 units every morning at 8 AM and regular insulin with meals. At 3 PM, patient reports shakiness, diaphoresis, hunger, confusion. Glucose 58 mg/dL. What's likely cause?",
        "options": [
            "Regular insulin from lunch peaking at this time causing hypoglycemia",
            "NPH insulin peaking 6-8 hours after morning dose causing hypoglycemia",
            "Insufficient NPH insulin dose causing hyperglycemia with ketosis symptoms",
            "Somogyi effect (rebound hyperglycemia from nocturnal hypoglycemia)"
        ],
        "correctIndex": 1,
        "explanation": "INSULIN TYPES AND ONSET/PEAK/DURATION: NPH (intermediate-acting): Onset 1-2hr, PEAK 4-8hr, Duration 12-16hr. Regular (short-acting): Onset 30min, Peak 2-3hr, Duration 5-8hr. This patient took NPH at 8 AM, now 3 PM (7 hours later) = NPH IS PEAKING causing hypoglycemia. Regular insulin from lunch (assuming noon) would peak around 2-3 PM, but it's 3 PM now (past peak). NPH is notorious for causing hypoglycemia during peak times (mid-afternoon and overnight). PREVENTION: Ensure adequate snack at NPH peak times (mid-afternoon snack, bedtime snack), Consider switching to basal insulin analogs (glargine, detemir) which have no peak and more stable coverage. TREATMENT: Give 15g fast-acting carbs now, recheck in 15 min. Somogyi effect is morning hyperglycemia from rebound after nighttime hypo (not applicable here).",
        "type": "mcq",
        "variants": []
    },
    {
        "id": "PHARM-VANCOMYCIN-001",
        "text": "Patient receiving IV vancomycin for MRSA infection. During infusion, develops flushing, pruritus, rash on face/neck/chest, hypotension. What's likely cause and appropriate action?",
        "options": [
            "Anaphylactic allergic reaction - stop infusion immediately, give epinephrine IM, prepare for potential airway management",
            "Red man syndrome from rapid infusion - slow or stop infusion, give diphenhydramine, premedicate future doses",
            "Expected side effect of vancomycin therapy - continue infusion and document findings",
            "Phlebitis from peripheral IV - discontinue IV, apply warm compress, restart in different site"
        ],
        "correctIndex": 1,
        "explanation": "RED MAN SYNDROME: Non-allergic histamine release reaction from rapid vancomycin infusion. Causes flushing, pruritus, erythematous rash (face, neck, upper torso - 'red man'), sometimes hypotension/chest pain. Appears during/shortly after infusion. NOT true allergy (not IgE-mediated, not anaphylaxis). MANAGEMENT: 1) Slow or stop infusion temporarily (symptoms usually resolve quickly), 2) Give antihistamine (diphenhydramine 25-50mg IV), 3) Resume infusion at slower rate (vancomycin must infuse over at least 60 minutes per gram - so 1g over 60min minimum, 2g over 120min), 4) Future doses: premedicate with antihistamine 30-60min before, ensure proper infusion time. CONTRAST WITH ANAPHYLAXIS: Anaphylaxis has airway involvement (stridor, wheezing), respiratory distress, swelling (angioedema), requires epinephrine. Red man syndrome is uncomfortable but not life-threatening, managed by slowing infusion. Patient can safely continue vancomycin with proper infusion rate.",
        "type": "mcq",
        "variants": []
    },
    {
        "id": "PHARM-DIGOXIN-001",
        "text": "Patient on digoxin 0.125mg daily for heart failure. Before giving morning dose, nurse notes: HR 52 bpm, patient reports nausea and 'yellow-green vision.' What's priority action?",
        "options": [
            "Give digoxin as ordered since symptoms unrelated to medication",
            "Hold digoxin, notify provider, check digoxin level and potassium - concern for digoxin toxicity",
            "Give half the digoxin dose to maintain some therapeutic effect while reducing side effects",
            "Give digoxin with food to reduce nausea and continue monitoring"
        ],
        "correctIndex": 1,
        "explanation": "DIGOXIN TOXICITY: Bradycardia (HR <60, especially <50) + GI symptoms (nausea, vomiting, anorexia) + Visual changes (yellow-green or halo vision) = CLASSIC digoxin toxicity signs. Narrow therapeutic window (0.5-2 ng/mL therapeutic, >2 toxic). RISK FACTORS: Renal impairment (digoxin renally excreted), Hypokalemia (low K+ enhances digoxin toxicity), Drug interactions (many), Elderly patients. TOXICITY SIGNS: Cardiac: bradycardia, heart blocks, PVCs, bigeminy, V-tach (any arrhythmia), GI: nausea, vomiting, diarrhea, anorexia, Neurologic: confusion, weakness, headache, Visual: yellow-green or halo vision (xanthopsia). MANAGEMENT: 1) HOLD digoxin, 2) Notify provider immediately, 3) Check digoxin level (helps confirm toxicity), 4) Check electrolytes especially potassium and magnesium (correct deficiencies), 5) ECG (assess for arrhythmias), 6) For severe toxicity: digoxin-specific antibody fragments (Digibind, DigiFab), 7) Avoid calcium (can precipitate fatal arrhythmias with digoxin). NEVER give partial dose or continue when toxicity suspected - can be fatal. Before each dose, check apical pulse ×1 full minute (hold if <60), assess for toxicity symptoms.",
        "type": "mcq",
        "variants": []
    },
    {
        "id": "PHARM-HEPARIN-001",
        "text": "Patient on continuous heparin infusion for DVT. aPTT result 110 seconds (control 30 seconds, goal 60-80 seconds). Patient has mild gum bleeding. What's appropriate nursing action?",
        "options": [
            "Continue current heparin rate, document findings, recheck aPTT in 6 hours per protocol",
            "Hold heparin infusion, notify provider, check for other bleeding, anticipate aPTT recheck and rate adjustment",
            "Increase heparin rate per protocol since goal is 2-2.5 times control (should be 60-75 seconds)",
            "Administer protamine sulfate immediately to reverse heparin and stop bleeding"
        ],
        "correctIndex": 1,
        "explanation": "HEPARIN MANAGEMENT: aPTT (activated Partial Thromboplastin Time) monitors heparin therapy. Goal: 1.5-2.5 times control (if control 30 seconds, goal 45-75 seconds, or often 60-80 seconds per protocol). This patient: aPTT 110 seconds = EXCESSIVE anticoagulation (>2.5x control) + bleeding signs = HOLD heparin. ACTIONS: 1) STOP heparin infusion (half-life ~90 minutes, so levels will decrease), 2) Notify provider for orders, 3) Assess for bleeding (gums, urine, stool, IV sites, bruising), 4) Recheck aPTT in 4-6 hours (expect decrease as heparin clears), 5) Restart at lower rate when aPTT in goal range. Protamine sulfate (heparin antidote) is for severe life-threatening bleeding (major hemorrhage, intracranial bleed) - not for mild gum bleeding. Mild bleeding usually resolves with holding heparin. If aPTT too LOW: increase rate per protocol. If aPTT in goal: continue current rate. If aPTT too HIGH: hold infusion, recheck, decrease rate. Weight-based protocol typically used with specific adjustments.",
        "type": "mcq",
        "variants": []
    }
]

for quiz in data['quizzes']:
    if quiz['id'] == 'quiz-nclex-pharmacology':
        quiz['questions'].extend(pharmacology_questions)
        print(f"Added {len(pharmacology_questions)} questions to Pharmacology & Medication Administration")

# Save updated JSON
with open('assets/data/nclex_practice_bank.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

# Count totals
total = sum(len(quiz['questions']) for quiz in data['quizzes'])
print(f"\n=== TOTALS ===")
for quiz in data['quizzes']:
    print(f"{quiz['title']}: {len(quiz['questions'])} questions")
print(f"\nGRAND TOTAL: {total} questions")
print("\nSuccessfully updated nclex_practice_bank.json!")
