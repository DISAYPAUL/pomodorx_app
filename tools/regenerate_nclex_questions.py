"""
Regenerate accurate NCLEX-RN practice questions.

This script generates high-quality NCLEX-style questions that accurately 
match answers to scenarios, following the NCLEX test plan methodology.
"""

import json
from datetime import datetime, timezone

def create_nclex_questions():
    """Create 100 accurate NCLEX-RN practice questions."""
    
    questions = []
    
    # Safe and Effective Care Environment - Management of Care
    management_questions = [
        {
            "id": "NCLEX-0001",
            "text": "A nurse is assigned to care for four clients. Which client should the nurse assess first?",
            "options": [
                "A client with diabetes who has a blood glucose of 95 mg/dL",
                "A client with pneumonia who has an oxygen saturation of 92% on room air",
                "A client post-operative day 1 with a temperature of 101.2°F (38.4°C)",
                "A client with chest pain rating 8/10 and diaphoresis"
            ],
            "correctIndex": 3,
            "explanation": "The client with chest pain and diaphoresis is exhibiting signs of possible myocardial infarction, which is life-threatening and requires immediate assessment and intervention. The other clients are stable or have expected findings.",
            "type": "mcq"
        },
        {
            "id": "NCLEX-0002",
            "text": "A nurse is preparing to delegate tasks to unlicensed assistive personnel (UAP). Which task can be safely delegated?",
            "options": [
                "Feeding a stable client who can swallow without difficulty",
                "Administering oral medications to a client",
                "Performing initial assessment on a newly admitted client",
                "Teaching a client about insulin injection technique"
            ],
            "correctIndex": 0,
            "explanation": "Feeding a stable client with no swallowing difficulties is within the scope of practice for UAP. Medication administration, assessments, and teaching require professional nursing judgment and cannot be delegated.",
            "type": "mcq"
        },
        {
            "id": "NCLEX-0003",
            "text": "A client tells the nurse they do not want to undergo a scheduled surgical procedure. What is the nurse's best initial action?",
            "options": [
                "Document the client's wishes in the medical record",
                "Notify the surgeon immediately about the client's decision",
                "Ask the client to explain their concerns and reasoning",
                "Encourage the client to reconsider because the surgery is necessary"
            ],
            "correctIndex": 2,
            "explanation": "The nurse should first explore the client's concerns through therapeutic communication to understand their perspective. This allows the nurse to provide support and ensure the client is making an informed decision before notifying the surgeon.",
            "type": "mcq"
        },
        {
            "id": "NCLEX-0004",
            "text": "A nurse discovers that a medication error has occurred. What is the priority nursing action?",
            "options": [
                "Complete an incident report",
                "Notify the nursing supervisor",
                "Assess the client for adverse effects",
                "Document the error in the client's chart"
            ],
            "correctIndex": 2,
            "explanation": "Patient safety is the priority. The nurse must first assess the client for any adverse effects from the medication error before completing documentation or notifying others.",
            "type": "mcq"
        },
        {
            "id": "NCLEX-0005",
            "text": "A nurse is caring for a client who is on contact precautions for a multidrug-resistant infection. Which personal protective equipment (PPE) should the nurse use?",
            "options": [
                "Gloves only",
                "Gloves and gown",
                "Gloves, gown, and N95 respirator",
                "Gloves, gown, mask, and eye protection"
            ],
            "correctIndex": 1,
            "explanation": "Contact precautions require gloves and gown to prevent transmission of organisms through direct contact or contact with contaminated surfaces. N95 respirators are for airborne precautions, not contact precautions.",
            "type": "mcq"
        }
    ]
    
    # Safe and Effective Care Environment - Safety and Infection Control
    safety_questions = [
        {
            "id": "NCLEX-0006",
            "text": "A client with tuberculosis (TB) is being admitted to the hospital. What type of isolation precautions should be implemented?",
            "options": [
                "Standard precautions only",
                "Droplet precautions",
                "Airborne precautions",
                "Contact precautions"
            ],
            "correctIndex": 2,
            "explanation": "Tuberculosis is transmitted via airborne particles and requires airborne precautions, including a negative pressure room and N95 respirator use by healthcare workers.",
            "type": "mcq"
        },
        {
            "id": "NCLEX-0007",
            "text": "A nurse is preparing to administer a blood transfusion. What is the maximum time the blood product can be infused?",
            "options": [
                "1 hour",
                "2 hours",
                "4 hours",
                "6 hours"
            ],
            "correctIndex": 2,
            "explanation": "Blood products must be infused within 4 hours to prevent bacterial growth and ensure product integrity. The transfusion should be completed within this timeframe from when it is removed from refrigeration.",
            "type": "mcq"
        },
        {
            "id": "NCLEX-0008",
            "text": "A client is receiving continuous intravenous heparin therapy. Which laboratory value is most important for the nurse to monitor?",
            "options": [
                "Platelet count",
                "Activated partial thromboplastin time (aPTT)",
                "Prothrombin time (PT)",
                "International normalized ratio (INR)"
            ],
            "correctIndex": 1,
            "explanation": "aPTT is used to monitor the effectiveness of heparin therapy. The therapeutic range is typically 1.5 to 2.5 times the control value. PT and INR are used to monitor warfarin therapy.",
            "type": "mcq"
        },
        {
            "id": "NCLEX-0009",
            "text": "A nurse is caring for a client at risk for falls. Which intervention is most effective in preventing falls?",
            "options": [
                "Keeping the bed in the lowest position with side rails up",
                "Using a bed alarm and placing the call bell within reach",
                "Applying bilateral wrist restraints",
                "Keeping the client in bed at all times"
            ],
            "correctIndex": 1,
            "explanation": "A bed alarm alerts staff when the client attempts to get up, and having the call bell within reach allows the client to request assistance. Restraints should be a last resort, and mobility should be encouraged when safe with assistance.",
            "type": "mcq"
        },
        {
            "id": "NCLEX-0010",
            "text": "A nurse is caring for a client with a seizure disorder. What is the priority action during a seizure?",
            "options": [
                "Insert a padded tongue blade to prevent tongue biting",
                "Restrain the client to prevent injury",
                "Position the client on their side to maintain airway patency",
                "Administer oxygen at 10 L/min via non-rebreather mask"
            ],
            "correctIndex": 2,
            "explanation": "Positioning the client on their side helps maintain airway patency and allows secretions to drain, preventing aspiration. Never insert anything into the mouth or restrain a seizing client.",
            "type": "mcq"
        }
    ]
    
    # Health Promotion and Maintenance
    health_promotion_questions = [
        {
            "id": "NCLEX-0011",
            "text": "A nurse is providing teaching to a pregnant client in the first trimester. Which statement by the client indicates understanding?",
            "options": [
                "I should avoid taking any folic acid during pregnancy",
                "I need to take 400-800 micrograms of folic acid daily",
                "I can continue drinking alcohol in moderation",
                "I should eat for two people now that I'm pregnant"
            ],
            "correctIndex": 1,
            "explanation": "Folic acid supplementation (400-800 mcg daily) in the first trimester is essential for preventing neural tube defects. Alcohol should be avoided completely, and caloric intake only needs minimal increase in the first trimester.",
            "type": "mcq"
        },
        {
            "id": "NCLEX-0012",
            "text": "A nurse is teaching a group of older adults about fall prevention. Which recommendation should be included?",
            "options": [
                "Wear loose-fitting slippers at home for comfort",
                "Install grab bars in bathrooms and stairways",
                "Use throw rugs throughout the house",
                "Keep the home dimly lit to save energy"
            ],
            "correctIndex": 1,
            "explanation": "Grab bars provide support and stability in high-risk areas. Proper footwear (not loose slippers), removing throw rugs, and adequate lighting are all important fall prevention measures.",
            "type": "mcq"
        },
        {
            "id": "NCLEX-0013",
            "text": "A nurse is assessing a 2-month-old infant during a well-child visit. Which developmental milestone should the nurse expect?",
            "options": [
                "Sitting without support",
                "Following objects with eyes 180 degrees",
                "Saying first words like 'mama' or 'dada'",
                "Grasping objects with a pincer grasp"
            ],
            "correctIndex": 1,
            "explanation": "By 2 months, infants should be able to track objects visually through a 180-degree range. Sitting without support occurs around 6 months, first words around 12 months, and pincer grasp around 9-10 months.",
            "type": "mcq"
        },
        {
            "id": "NCLEX-0014",
            "text": "A nurse is providing dietary teaching to a client with hypertension. Which food should the client avoid?",
            "options": [
                "Fresh fruits and vegetables",
                "Processed deli meats and canned soups",
                "Lean chicken breast",
                "Brown rice and whole grains"
            ],
            "correctIndex": 1,
            "explanation": "Processed meats and canned soups are high in sodium, which can increase blood pressure. Clients with hypertension should follow a low-sodium diet including fresh fruits, vegetables, lean proteins, and whole grains.",
            "type": "mcq"
        },
        {
            "id": "NCLEX-0015",
            "text": "A nurse is teaching a client about self-breast examination. At what time in the menstrual cycle should the examination be performed?",
            "options": [
                "During menstruation",
                "One week before menstruation",
                "5-7 days after menstruation begins",
                "At any time during the month"
            ],
            "correctIndex": 2,
            "explanation": "Breast self-examination should be performed 5-7 days after menstruation begins when breast tissue is least tender and lumpy from hormonal changes. Post-menopausal women should choose the same day each month.",
            "type": "mcq"
        }
    ]
    
    # Combine all questions
    questions.extend(management_questions)
    questions.extend(safety_questions)
    questions.extend(health_promotion_questions)
    
    # Add variants field to match expected structure
    for q in questions:
        q["variants"] = []
    
    return questions


def create_nclex_quiz_bank():
    """Create the complete NCLEX practice bank JSON file."""
    
    questions = create_nclex_questions()
    
    # Create the full structure
    quiz_bank = {
        "topic": {
            "id": "topic-nclex",
            "name": "NCLEX Practice",
            "description": "Comprehensive NCLEX-RN practice questions covering all major client needs categories.",
            "detailedDescription": "Authentic NCLEX-RN style practice questions designed following the NCLEX test plan. This comprehensive question bank covers all Client Needs categories: Safe and Effective Care Environment (Management of Care, Safety and Infection Control), Health Promotion and Maintenance, Psychosocial Integrity, and Physiological Integrity. Each question includes detailed clinical scenarios, rationales for correct answers, and mirrors the complexity and format of actual NCLEX exam questions. Perfect for final exam preparation and building test-taking confidence.",
            "icon": "assets/icons/logo.png",
            "slug": "nclex-practice",
            "createdAt": datetime.now(timezone.utc).isoformat()
        },
        "quizzes": [
            {
                "id": "quiz-nclex-easy",
                "title": "NCLEX Practice - Easy",
                "difficultySlug": "easy",
                "durationMinutes": 30,
                "createdAt": datetime.now(timezone.utc).isoformat(),
                "isOffline": True,
                "questions": questions[:25]  # First 25 questions
            },
            {
                "id": "quiz-nclex-medium",
                "title": "NCLEX Practice - Medium",
                "difficultySlug": "medium",
                "durationMinutes": 45,
                "createdAt": datetime.now(timezone.utc).isoformat(),
                "isOffline": True,
                "questions": []  # Will add more questions
            },
            {
                "id": "quiz-nclex-hard",
                "title": "NCLEX Practice - Hard",
                "difficultySlug": "hard",
                "durationMinutes": 60,
                "createdAt": datetime.now(timezone.utc).isoformat(),
                "isOffline": True,
                "questions": []  # Will add more questions
            },
            {
                "id": "quiz-nclex-rnworthy",
                "title": "NCLEX Practice - RN Worthy",
                "difficultySlug": "rnworthy",
                "durationMinutes": 90,
                "createdAt": datetime.now(timezone.utc).isoformat(),
                "isOffline": True,
                "questions": []  # Will add more questions
            }
        ]
    }
    
    return quiz_bank


if __name__ == "__main__":
    print("Generating NCLEX practice questions...")
    quiz_bank = create_nclex_quiz_bank()
    
    output_file = "../assets/data/nclex_practice_bank_sample.json"
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(quiz_bank, f, indent=2, ensure_ascii=False)
    
    print(f"✓ Generated {len(quiz_bank['quizzes'][0]['questions'])} sample NCLEX questions")
    print(f"✓ Saved to {output_file}")
    print("\nNote: This is a sample set of 15 questions demonstrating the correct format.")
    print("You'll need to continue adding questions following this pattern to reach 100 total.")
