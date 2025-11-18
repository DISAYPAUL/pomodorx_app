import 'dart:convert';
import 'dart:io';
import 'dart:math';

void main() {
  QuizBankGenerator().generate();
}

class QuizBankGenerator {
  QuizBankGenerator();

  final _encoder = const JsonEncoder.withIndent('  ');
  final _random = Random(42);

  Future<void> generate() async {
    final now = DateTime.now().toUtc();
    await _writeStandaloneTopic(
      anatomyBlueprint,
      File('assets/data/anatomy_quiz.json'),
      now,
    );
    await _writeStandaloneTopic(
      medicationSafetyBlueprint,
      File('assets/data/pharmacology_quiz.json'),
      now,
    );
    await _writeNursingBundle(
      nursingBlueprints,
      File('assets/data/nursing_quizzes.json'),
      now,
    );
    stdout.writeln('Quiz banks regenerated at ${now.toIso8601String()}');
  }

  Future<void> _writeStandaloneTopic(
    TopicBlueprint blueprint,
    File file,
    DateTime generatedAt,
  ) async {
    final questions = _buildQuestions(blueprint, collapseDifficulties: true);
    final payload = {
      'topic': blueprint.topicMetadata,
      'quizzes': [
        {
          'id': 'quiz-${blueprint.id}-master',
          'title': '${blueprint.name} Mastery Bank',
          'durationMinutes': blueprint.durationMinutes,
          'createdAt': blueprint.createdAt,
          'isOffline': true,
          'questions': questions,
        },
      ],
    };
    await file.writeAsString(_encoder.convert(payload) + '\n');
  }

  Future<void> _writeNursingBundle(
    List<TopicBlueprint> blueprints,
    File file,
    DateTime generatedAt,
  ) async {
    final topicsPayload = blueprints.map((topic) {
      final quizzes = Difficulty.values.map((difficulty) {
        final questions = _buildQuestions(
          topic,
          collapseDifficulties: false,
          difficultyFilter: difficulty,
        );
        return {
          'id': 'quiz-${topic.id}-${difficulty.name}',
          'title': '${topic.name} - ${difficulty.displayLabel}',
          'durationMinutes': topic.durationMinutesFor(difficulty),
          'createdAt': topic.createdAt,
          'isOffline': true,
          'questions': questions,
        };
      }).toList();
      return {
        'topic': topic.topicMetadata,
        'quizzes': quizzes,
      };
    }).toList();

    final payload = {
      'generatedAt': generatedAt.toIso8601String(),
      'topics': topicsPayload,
    };
    await file.writeAsString(_encoder.convert(payload) + '\n');
  }

  List<Map<String, dynamic>> _buildQuestions(
    TopicBlueprint blueprint, {
    required bool collapseDifficulties,
    Difficulty? difficultyFilter,
  }) {
    final labels = blueprint.concepts.map((c) => c.label).toList();
    final questions = <Map<String, dynamic>>[];
    for (final concept in blueprint.concepts) {
      for (final difficulty in Difficulty.values) {
        if (!collapseDifficulties && difficultyFilter != difficulty) {
          continue;
        }
        final detail = concept.details[difficulty];
        if (detail == null || detail.isEmpty) continue;
        final parts = blueprint.templateFor(difficulty)(concept.label, detail);
        final seed = concept.id.hashCode ^ detail.hashCode ^ difficulty.index;
        final options = _makeOptions(concept.label, labels, seed);
        questions.add({
          'id': '${concept.id}-${difficulty.name}',
          'text': parts.question,
          'options': options,
          'correctIndex': options.indexOf(concept.label),
          'explanation': parts.explanation,
          'type': 'mcq',
        });
      }
    }
    if (collapseDifficulties) {
      questions.sort((a, b) => (a['id'] as String).compareTo(b['id'] as String));
    }
    return questions;
  }

  List<String> _makeOptions(String correct, List<String> pool, int seed) {
    final rand = Random(seed);
    final candidates = pool.where((item) => item != correct).toList();
    candidates.shuffle(rand);
    final selected = candidates.take(3).toList();
    selected.add(correct);
    selected.shuffle(rand);
    return selected;
  }
}

enum Difficulty { easy, medium, hard, rnworthy }

enum TopicKind { anatomy, medication, condition, skill }

extension on Difficulty {
  String get displayLabel {
    switch (this) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
      case Difficulty.rnworthy:
        return 'RN Worthy';
    }
  }
}

class QuestionParts {
  QuestionParts({required this.question, required this.explanation});

  final String question;
  final String explanation;
}

typedef QuestionTemplate = QuestionParts Function(String label, String detail);

class ConceptBlueprint {
  const ConceptBlueprint({
    required this.id,
    required this.label,
    required this.details,
  });

  final String id;
  final String label;
  final Map<Difficulty, String> details;
}

class TopicBlueprint {
  const TopicBlueprint({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.slug,
    required this.kind,
    required this.concepts,
    this.createdAt = '2025-01-10T00:00:00.000Z',
    this.durationMinutes = 20,
  });

  final String id;
  final String name;
  final String description;
  final String icon;
  final String slug;
  final TopicKind kind;
  final List<ConceptBlueprint> concepts;
  final String createdAt;
  final int durationMinutes;

  Map<String, dynamic> get topicMetadata => {
        'id': id,
        'name': name,
        'description': description,
        'icon': icon,
        'slug': slug,
        'createdAt': createdAt,
      };

  int durationMinutesFor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 12;
      case Difficulty.medium:
        return 18;
      case Difficulty.hard:
        return 22;
      case Difficulty.rnworthy:
        return 25;
    }
  }

  QuestionTemplate templateFor(Difficulty difficulty) {
    final templateSet = _templates[kind]!;
    return templateSet[difficulty]!;
  }
}

final Map<TopicKind, Map<Difficulty, QuestionTemplate>> _templates = {
  TopicKind.anatomy: {
    Difficulty.easy: (label, detail) => QuestionParts(
          question: 'Which structure primarily $detail?',
          explanation: '$label primarily $detail, making it the correct structure.',
        ),
    Difficulty.medium: (label, detail) => QuestionParts(
          question: 'Which structure is closely associated with $detail?',
          explanation: '$label is associated with $detail.',
        ),
    Difficulty.hard: (label, detail) => QuestionParts(
          question: 'Which structure features $detail?',
          explanation: '$label features $detail.',
        ),
    Difficulty.rnworthy: (label, detail) => QuestionParts(
          question: 'Injury described as $detail most likely involves which structure?',
          explanation: '$label is implicated when $detail.',
        ),
  },
  TopicKind.medication: {
    Difficulty.easy: (label, detail) => QuestionParts(
          question: 'Which medication or class $detail?',
          explanation: '$label $detail.',
        ),
    Difficulty.medium: (label, detail) => QuestionParts(
          question: 'Which medication requires the nurse to $detail?',
          explanation: '$label therapy requires nurses to $detail.',
        ),
    Difficulty.hard: (label, detail) => QuestionParts(
          question: 'Which medication is linked to $detail?',
          explanation: '$label is linked to $detail.',
        ),
    Difficulty.rnworthy: (label, detail) => QuestionParts(
          question: 'Which medication teaching plan includes $detail?',
          explanation: 'Clients on $label must remember to $detail.',
        ),
  },
  TopicKind.condition: {
    Difficulty.easy: (label, detail) => QuestionParts(
          question: 'Which condition commonly presents with $detail?',
          explanation: '$label commonly presents with $detail.',
        ),
    Difficulty.medium: (label, detail) => QuestionParts(
          question: 'Which condition requires the nurse to $detail?',
          explanation: '$label requires nurses to $detail.',
        ),
    Difficulty.hard: (label, detail) => QuestionParts(
          question: 'Which condition is associated with data such as $detail?',
          explanation: '$label often produces $detail.',
        ),
    Difficulty.rnworthy: (label, detail) => QuestionParts(
          question: 'Long-term teaching for which condition includes $detail?',
          explanation: 'Chronic management of $label includes teaching to $detail.',
        ),
  },
  TopicKind.skill: {
    Difficulty.easy: (label, detail) => QuestionParts(
          question: 'Which foundational skill $detail?',
          explanation: '$label $detail.',
        ),
    Difficulty.medium: (label, detail) => QuestionParts(
          question: 'Which skill requires nurses to $detail?',
          explanation: '$label is executed by $detail.',
        ),
    Difficulty.hard: (label, detail) => QuestionParts(
          question: 'Which policy focus addresses $detail?',
          explanation: '$label focuses on $detail.',
        ),
    Difficulty.rnworthy: (label, detail) => QuestionParts(
          question: 'Which delegation or safety teaching stresses $detail?',
          explanation: '$label stresses $detail.',
        ),
  },
};

const List<ConceptBlueprint> anatomyConcepts = [
  ConceptBlueprint(
    id: 'biceps-brachii',
    label: 'Biceps brachii',
    details: {
      Difficulty.easy:
          'produces elbow flexion when the forearm is supinated and assists with resisted supination',
      Difficulty.medium:
          'relies on the musculocutaneous nerve within the anterior compartment of the arm',
      Difficulty.hard:
          'originates from the coracoid process and supraglenoid tubercle before inserting on the radial tuberosity',
      Difficulty.rnworthy:
          'rupture causes a sudden “Popeye” bulge and weak supination after lifting an unexpected load',
    },
  ),
  ConceptBlueprint(
    id: 'triceps-brachii',
    label: 'Triceps brachii',
    details: {
      Difficulty.easy: 'extends the elbow and controls eccentric lowering from overhead presses',
      Difficulty.medium: 'receives innervation from the radial nerve along the posterior humerus',
      Difficulty.hard: 'has a long head originating on the infraglenoid tubercle crossing shoulder and elbow',
      Difficulty.rnworthy:
          'weak elbow extension with wrist drop after a midshaft humeral fracture points to this muscle',
    },
  ),
  ConceptBlueprint(
    id: 'deltoid',
    label: 'Deltoid',
    details: {
      Difficulty.easy: 'abducts the shoulder once the supraspinatus initiates motion beyond 15 degrees',
      Difficulty.medium: 'is innervated by the axillary nerve that wraps the surgical neck of the humerus',
      Difficulty.hard:
          'has anterior, middle, and posterior fibers arising from clavicle, acromion, and scapular spine',
      Difficulty.rnworthy:
          'loss of shoulder contour and abduction weakness after dislocation suggests injury here',
    },
  ),
  ConceptBlueprint(
    id: 'supraspinatus',
    label: 'Supraspinatus',
    details: {
      Difficulty.easy: 'initiates the first 15 degrees of glenohumeral abduction',
      Difficulty.medium: 'passes beneath the acromion where poor mechanics cause impingement',
      Difficulty.hard: 'originates in the supraspinous fossa and inserts on the superior facet of the greater tubercle',
      Difficulty.rnworthy: 'night pain with empty-can testing often implicates this tendon',
    },
  ),
  ConceptBlueprint(
    id: 'infraspinatus',
    label: 'Infraspinatus',
    details: {
      Difficulty.easy: 'externally rotates the shoulder during late-cocking motions',
      Difficulty.medium: 'shares suprascapular nerve supply with the supraspinatus',
      Difficulty.hard: 'attaches from the infraspinous fossa to the middle facet of the greater tubercle',
      Difficulty.rnworthy: 'posterior shoulder pain and weakness resisting external rotation implicate this muscle',
    },
  ),
  ConceptBlueprint(
    id: 'subscapularis',
    label: 'Subscapularis',
    details: {
      Difficulty.easy: 'provides internal rotation and anterior stability to the glenohumeral joint',
      Difficulty.medium: 'receives upper and lower subscapular nerves from the posterior cord',
      Difficulty.hard: 'originates on the subscapular fossa and inserts on the lesser tubercle',
      Difficulty.rnworthy: 'a positive lift-off test identifies tears of this anterior cuff muscle',
    },
  ),
  ConceptBlueprint(
    id: 'teres-minor',
    label: 'Teres minor',
    details: {
      Difficulty.easy: 'assists with external rotation and adduction of the humerus',
      Difficulty.medium: 'is innervated by the axillary nerve alongside the deltoid',
      Difficulty.hard: 'originates on the lateral scapular border and inserts on the inferior facet of the greater tubercle',
      Difficulty.rnworthy: 'quadrilateral space syndrome can atrophy this small cuff muscle',
    },
  ),
  ConceptBlueprint(
    id: 'latissimus-dorsi',
    label: 'Latissimus dorsi',
    details: {
      Difficulty.easy: 'extends, adducts, and internally rotates the humerus during pulling motions',
      Difficulty.medium: 'is supplied by the thoracodorsal nerve from the posterior cord',
      Difficulty.hard: 'originates from thoracolumbar fascia and inserts into the floor of the intertubercular groove',
      Difficulty.rnworthy: 'loss of power during swimming strokes suggests thoracodorsal nerve compromise',
    },
  ),
  ConceptBlueprint(
    id: 'pectoralis-major',
    label: 'Pectoralis major',
    details: {
      Difficulty.easy: 'horizontally adducts and flexes the shoulder during push-ups',
      Difficulty.medium: 'has clavicular fibers innervated by lateral pectoral nerve and sternal fibers by medial pectoral nerve',
      Difficulty.hard: 'converges from the sternum and clavicle to insert on the lateral lip of the intertubercular sulcus',
      Difficulty.rnworthy: 'bench-press ruptures cause anterior chest ecchymosis from this muscle tearing',
    },
  ),
  ConceptBlueprint(
    id: 'serratus-anterior',
    label: 'Serratus anterior',
    details: {
      Difficulty.easy: 'protracts and upwardly rotates the scapula for overhead reach',
      Difficulty.medium: 'is innervated by the long thoracic nerve along the lateral thorax',
      Difficulty.hard: 'attaches to the anterior medial border of the scapula through multiple slips',
      Difficulty.rnworthy: 'medial scapular winging after axillary surgery indicates dysfunction here',
    },
  ),
  ConceptBlueprint(
    id: 'diaphragm',
    label: 'Diaphragm',
    details: {
      Difficulty.easy: 'is the primary muscle of inspiration lowering intrathoracic pressure',
      Difficulty.medium: 'receives phrenic nerve fibers from C3 to C5',
      Difficulty.hard: 'contains the caval, esophageal, and aortic openings in its central tendon',
      Difficulty.rnworthy: 'hiccups and dyspnea after cervical trauma point to this muscle',
    },
  ),
  ConceptBlueprint(
    id: 'gluteus-maximus',
    label: 'Gluteus maximus',
    details: {
      Difficulty.easy: 'powerfully extends the hip when rising from a squat',
      Difficulty.medium: 'is innervated by the inferior gluteal nerve',
      Difficulty.hard: 'spans from ilium, sacrum, and coccyx to the IT band and gluteal tuberosity',
      Difficulty.rnworthy: 'difficulty climbing stairs after posterior hip surgery reflects weakness here',
    },
  ),
  ConceptBlueprint(
    id: 'gluteus-medius',
    label: 'Gluteus medius',
    details: {
      Difficulty.easy: 'abducts the hip and stabilizes the pelvis during single-leg stance',
      Difficulty.medium: 'is supplied by the superior gluteal nerve',
      Difficulty.hard: 'originates between anterior and posterior gluteal lines inserting on the greater trochanter',
      Difficulty.rnworthy: 'a Trendelenburg gait indicates failure of this muscle',
    },
  ),
  ConceptBlueprint(
    id: 'piriformis',
    label: 'Piriformis',
    details: {
      Difficulty.easy: 'laterally rotates the hip when extended and abducts the hip when flexed',
      Difficulty.medium: 'shares the greater sciatic foramen with the sciatic nerve',
      Difficulty.hard: 'originates from the anterior sacrum to insert on the greater trochanter',
      Difficulty.rnworthy: 'deep buttock pain radiating down the leg suggests this muscle compressing the sciatic nerve',
    },
  ),
  ConceptBlueprint(
    id: 'quadriceps',
    label: 'Quadriceps femoris',
    details: {
      Difficulty.easy: 'extends the knee and controls stair descent',
      Difficulty.medium: 'is innervated by the femoral nerve',
      Difficulty.hard: 'includes rectus femoris crossing the hip and inserting via the patellar tendon to the tibial tuberosity',
      Difficulty.rnworthy: 'loss of the patellar reflex after femoral neuropathy implicates this group',
    },
  ),
  ConceptBlueprint(
    id: 'hamstrings',
    label: 'Hamstring group',
    details: {
      Difficulty.easy: 'flexes the knee and extends the hip during running',
      Difficulty.medium: 'originates from the ischial tuberosity with tibial division sciatic innervation',
      Difficulty.hard: 'has a biceps femoris short head innervated by the common fibular branch',
      Difficulty.rnworthy: 'proximal avulsion with posterior thigh bruising implicates these muscles',
    },
  ),
  ConceptBlueprint(
    id: 'gastrocnemius',
    label: 'Gastrocnemius',
    details: {
      Difficulty.easy: 'plantarflexes the ankle during push-off and crosses the knee joint',
      Difficulty.medium: 'is innervated by the tibial nerve in the posterior compartment',
      Difficulty.hard: 'originates above the femoral condyles and contributes to the calcaneal tendon',
      Difficulty.rnworthy: 'tennis leg with an audible pop indicates strain of this muscle',
    },
  ),
  ConceptBlueprint(
    id: 'soleus',
    label: 'Soleus',
    details: {
      Difficulty.easy: 'maintains upright posture via tonic plantarflexion',
      Difficulty.medium: 'shares tibial nerve innervation deep to the gastrocnemius',
      Difficulty.hard: 'originates from posterior tibia and fibula forming most of the Achilles tendon',
      Difficulty.rnworthy: 'immobility reduces the calf pump of this muscle, predisposing to DVT',
    },
  ),
  ConceptBlueprint(
    id: 'tibialis-anterior',
    label: 'Tibialis anterior',
    details: {
      Difficulty.easy: 'dorsiflexes and inverts the foot to clear the toes during gait',
      Difficulty.medium: 'is innervated by the deep fibular nerve on the anterior leg',
      Difficulty.hard: 'originates on the lateral tibia and interosseous membrane inserting on the medial cuneiform',
      Difficulty.rnworthy: 'foot slap after fibular head injury indicates weakness of this muscle',
    },
  ),
  ConceptBlueprint(
    id: 'rectus-abdominis',
    label: 'Rectus abdominis',
    details: {
      Difficulty.easy: 'flexes the trunk and stabilizes the pelvis during sit-ups',
      Difficulty.medium: 'is enclosed by the rectus sheath formed by lateral abdominal aponeuroses',
      Difficulty.hard: 'features tendinous intersections that create the six-pack appearance',
      Difficulty.rnworthy: 'diastasis after pregnancy reflects stretching of this paired muscle',
    },
  ),
  ConceptBlueprint(
    id: 'transverse-abdominis',
    label: 'Transverse abdominis',
    details: {
      Difficulty.easy: 'compresses abdominal contents providing intrinsic core stability',
      Difficulty.medium: 'receives segmental thoracoabdominal nerve innervation',
      Difficulty.hard: 'runs horizontally from thoracolumbar fascia to the linea alba',
      Difficulty.rnworthy: 'pre-activating this muscle protects the lumbar spine during lifting',
    },
  ),
  ConceptBlueprint(
    id: 'iliopsoas',
    label: 'Iliopsoas',
    details: {
      Difficulty.easy: 'acts as the strongest hip flexor during marching or kicking',
      Difficulty.medium: 'combines psoas innervated by lumbar plexus with iliacus innervated by the femoral nerve',
      Difficulty.hard: 'passes anterior to the hip joint inserting on the lesser trochanter',
      Difficulty.rnworthy: 'pain with resisted hip flexion plus fever suggests an abscess involving this muscle',
    },
  ),
  ConceptBlueprint(
    id: 'sartorius',
    label: 'Sartorius',
    details: {
      Difficulty.easy: 'flexes, abducts, and externally rotates the hip to let you sit cross-legged',
      Difficulty.medium: 'forms the lateral border of the femoral triangle as it crosses the thigh',
      Difficulty.hard: 'runs from the ASIS to the pes anserinus on the medial tibia',
      Difficulty.rnworthy: 'pes anserine bursitis creates tenderness where this muscle inserts',
    },
  ),
  ConceptBlueprint(
    id: 'acl',
    label: 'Anterior cruciate ligament',
    details: {
      Difficulty.easy: 'prevents anterior translation of the tibia on the femur',
      Difficulty.medium: 'tightens during knee extension and internal rotation',
      Difficulty.hard: 'originates in the posterior lateral femoral notch and inserts on the anterior tibial plateau',
      Difficulty.rnworthy: 'noncontact pivoting injury with immediate swelling suggests damage to this ligament',
    },
  ),
  ConceptBlueprint(
    id: 'medial-meniscus',
    label: 'Medial meniscus',
    details: {
      Difficulty.easy: 'deepens the tibial plateau to stabilize the medial femoral condyle',
      Difficulty.medium: 'is tethered to the joint capsule and medial collateral ligament, limiting mobility',
      Difficulty.hard: 'receives perfusion only in its peripheral outer third',
      Difficulty.rnworthy: 'twisting injury with locking and joint line tenderness implicates this structure',
    },
  ),
];

const List<ConceptBlueprint> pharmacologyConcepts = [
  ConceptBlueprint(
    id: 'ace-inhibitors',
    label: 'ACE inhibitors',
    details: {
      Difficulty.easy:
          'reduce blood pressure by blocking angiotensin II formation and commonly trigger a nagging dry cough',
      Difficulty.medium:
          'require the nurse to monitor closely for first-dose hypotension when the client stands',
      Difficulty.hard: 'are linked to rising potassium and creatinine, so labs must be trended',
      Difficulty.rnworthy:
          'teaching stresses avoiding potassium-based salt substitutes and reporting facial swelling immediately',
    },
  ),
  ConceptBlueprint(
    id: 'arbs',
    label: 'ARBs',
    details: {
      Difficulty.easy: 'block angiotensin II receptors to lower blood pressure without provoking cough',
      Difficulty.medium:
          'require periodic assessment of blood pressure and renal perfusion when paired with diuretics',
      Difficulty.hard: 'carry hyperkalemia risk in clients with renal impairment',
      Difficulty.rnworthy: 'teaching includes limiting NSAID overuse that blunts the antihypertensive effect',
    },
  ),
  ConceptBlueprint(
    id: 'beta-blockers',
    label: 'Beta blockers',
    details: {
      Difficulty.easy: 'slow heart rate and reduce contractility to lower myocardial oxygen demand',
      Difficulty.medium: 'require nurses to hold the dose for marked bradycardia or symptomatic hypotension',
      Difficulty.hard: 'can mask early signs of hypoglycemia in insulin-dependent clients',
      Difficulty.rnworthy: 'counseling includes tapering rather than abruptly stopping therapy',
    },
  ),
  ConceptBlueprint(
    id: 'ccb-dihydropyridine',
    label: 'Calcium channel blockers',
    details: {
      Difficulty.easy: 'promote arterial dilation to treat hypertension and chronic angina',
      Difficulty.medium: 'require monitoring for peripheral edema and orthostatic hypotension',
      Difficulty.hard: 'can prolong PR interval when combined with beta blockers',
      Difficulty.rnworthy: 'teaching includes slow position changes and daily weights if swelling appears',
    },
  ),
  ConceptBlueprint(
    id: 'loop-diuretics',
    label: 'Loop diuretics',
    details: {
      Difficulty.easy: 'rapidly offload fluid to relieve pulmonary edema and heart failure symptoms',
      Difficulty.medium: 'require verifying potassium levels and supplementing losses',
      Difficulty.hard: 'at high doses may cause ototoxicity, especially with other ototoxic drugs',
      Difficulty.rnworthy: 'patient teaching includes taking in the morning and reporting ringing in the ears',
    },
  ),
  ConceptBlueprint(
    id: 'thiazide-diuretics',
    label: 'Thiazide diuretics',
    details: {
      Difficulty.easy: 'treat mild hypertension by reducing sodium reabsorption in the distal tubule',
      Difficulty.medium: 'require assessing for dehydration, dizziness, and orthostasis',
      Difficulty.hard: 'can elevate calcium and uric acid, worsening gout',
      Difficulty.rnworthy: 'teaching includes emphasizing foods rich in potassium to offset mild losses',
    },
  ),
  ConceptBlueprint(
    id: 'spironolactone',
    label: 'Spironolactone',
    details: {
      Difficulty.easy: 'spares potassium while antagonizing aldosterone in the distal nephron',
      Difficulty.medium: 'requires monitoring for hyperkalemia when combined with ACE inhibitors or ARBs',
      Difficulty.hard: 'is contraindicated in severe renal failure because potassium accumulates quickly',
      Difficulty.rnworthy: 'teaching includes avoiding salt substitutes and reporting endocrine changes such as gynecomastia',
    },
  ),
  ConceptBlueprint(
    id: 'digoxin',
    label: 'Digoxin',
    details: {
      Difficulty.easy: 'increases contractility while slowing AV conduction in heart failure',
      Difficulty.medium: 'requires counting the apical pulse for a full minute before dosing',
      Difficulty.hard: 'becomes toxic faster with hypokalemia or renal impairment',
      Difficulty.rnworthy: 'teaching highlights reporting anorexia, nausea, or visual halos immediately',
    },
  ),
  ConceptBlueprint(
    id: 'warfarin',
    label: 'Warfarin',
    details: {
      Difficulty.easy: 'blocks vitamin K-dependent clotting factors to prevent thrombosis',
      Difficulty.medium: 'requires reviewing INR results prior to each administration',
      Difficulty.hard: 'interacts with many antibiotics that raise INR to dangerous levels',
      Difficulty.rnworthy: 'teaching stresses consistent vitamin K intake and wearing medical identification',
    },
  ),
  ConceptBlueprint(
    id: 'heparin',
    label: 'Heparin',
    details: {
      Difficulty.easy: 'potentiates antithrombin III for rapid anticoagulation',
      Difficulty.medium: 'requires monitoring aPTT and adjusting infusions per protocol',
      Difficulty.hard: 'can precipitate heparin-induced thrombocytopenia requiring platelet surveillance',
      Difficulty.rnworthy: 'teaching includes reporting new bruising or bleeding gums right away',
    },
  ),
  ConceptBlueprint(
    id: 'doac',
    label: 'Direct oral anticoagulants',
    details: {
      Difficulty.easy: 'directly inhibit factor Xa without routine lab draws',
      Difficulty.medium: 'require renal function checks before dosing',
      Difficulty.hard: 'have limited reversal options, so bleeding risk counseling is essential',
      Difficulty.rnworthy: 'clients are instructed to take doses consistently and not double missed tablets',
    },
  ),
  ConceptBlueprint(
    id: 'insulin-glargine',
    label: 'Insulin glargine',
    details: {
      Difficulty.easy: 'provides 24-hour basal insulin coverage without pronounced peaks',
      Difficulty.medium: 'requires using a dedicated syringe and never mixing with other insulins',
      Difficulty.hard: 'is titrated based on fasting glucose patterns rather than meal counts',
      Difficulty.rnworthy: 'teaching stresses injecting at the same time daily even when skipping meals',
    },
  ),
  ConceptBlueprint(
    id: 'insulin-lispro',
    label: 'Insulin lispro',
    details: {
      Difficulty.easy: 'is rapid acting and should be given within 15 minutes of meals',
      Difficulty.medium: 'requires nurses to ensure a meal tray is present before administration',
      Difficulty.hard: 'is dosed based on carbohydrate ratios to blunt postprandial spikes',
      Difficulty.rnworthy: 'teaching includes carrying fast carbohydrates to correct sudden hypoglycemia',
    },
  ),
  ConceptBlueprint(
    id: 'metformin',
    label: 'Metformin',
    details: {
      Difficulty.easy: 'lowers hepatic glucose output without causing weight gain',
      Difficulty.medium: 'must be held before contrast imaging to protect kidneys',
      Difficulty.hard: 'rarely causes lactic acidosis, especially with renal or hepatic impairment',
      Difficulty.rnworthy: 'clients learn to take it with meals to minimize GI upset',
    },
  ),
  ConceptBlueprint(
    id: 'sulfonylurea',
    label: 'Sulfonylureas',
    details: {
      Difficulty.easy: 'stimulate pancreatic insulin secretion to lower glucose',
      Difficulty.medium: 'require screening for sulfa allergies and monitoring for hypoglycemia',
      Difficulty.hard: 'lose effectiveness as beta-cell reserve declines',
      Difficulty.rnworthy: 'teaching includes avoiding alcohol that provokes disulfiram-like reactions',
    },
  ),
  ConceptBlueprint(
    id: 'levothyroxine',
    label: 'Levothyroxine',
    details: {
      Difficulty.easy: 'replaces thyroid hormone in hypothyroidism',
      Difficulty.medium: 'must be taken each morning on an empty stomach for consistent absorption',
      Difficulty.hard: 'requires TSH monitoring every 6–8 weeks to fine-tune the dose',
      Difficulty.rnworthy: 'patients separate doses from calcium or iron supplements by several hours',
    },
  ),
  ConceptBlueprint(
    id: 'methimazole',
    label: 'Methimazole',
    details: {
      Difficulty.easy: 'suppresses thyroid hormone synthesis for hyperthyroidism',
      Difficulty.medium: 'requires clients to report fever or sore throat due to agranulocytosis risk',
      Difficulty.hard: 'may injure the liver, prompting periodic liver function tests',
      Difficulty.rnworthy: 'teaching includes contraception planning before therapy and adherence to dosing schedule',
    },
  ),
  ConceptBlueprint(
    id: 'lithium',
    label: 'Lithium',
    details: {
      Difficulty.easy: 'stabilizes mood by modulating neurotransmission',
      Difficulty.medium: 'requires monitoring sodium and hydration to avoid toxicity',
      Difficulty.hard: 'has a narrow therapeutic window of roughly 0.6–1.2 mEq/L',
      Difficulty.rnworthy: 'clients keep salt intake consistent and report tremors or diarrhea immediately',
    },
  ),
  ConceptBlueprint(
    id: 'ssri',
    label: 'SSRIs',
    details: {
      Difficulty.easy: 'increase synaptic serotonin to treat depression and anxiety',
      Difficulty.medium: 'require monitoring for serotonin syndrome when layered with other serotonergic agents',
      Difficulty.hard: 'take several weeks to reach full effect, so adherence coaching is essential',
      Difficulty.rnworthy: 'teaching covers daily dosing even when symptoms improve and vigilance for sexual side effects',
    },
  ),
  ConceptBlueprint(
    id: 'maoi',
    label: 'MAOIs',
    details: {
      Difficulty.easy: 'prevent monoamine breakdown but can cause hypertensive crisis',
      Difficulty.medium: 'require nurses to review for drug–drug interactions before new prescriptions',
      Difficulty.hard: 'demand tyramine restriction to prevent severe hypertension',
      Difficulty.rnworthy: 'teaching includes carrying a dietary list that excludes aged cheeses and cured meats',
    },
  ),
  ConceptBlueprint(
    id: 'benzodiazepines',
    label: 'Benzodiazepines',
    details: {
      Difficulty.easy: 'produce rapid anxiolysis by enhancing GABA',
      Difficulty.medium: 'require fall precautions due to sedation and ataxia',
      Difficulty.hard: 'can create dependence and need gradual tapering after long-term use',
      Difficulty.rnworthy: 'clients avoid concurrent alcohol or opioids that magnify respiratory depression',
    },
  ),
  ConceptBlueprint(
    id: 'opioids',
    label: 'Opioids',
    details: {
      Difficulty.easy: 'bind mu receptors for potent analgesia in severe pain',
      Difficulty.medium: 'require monitoring respiratory rate and sedation level before repeat dosing',
      Difficulty.hard: 'release histamine causing hypotension if pushed rapidly IV',
      Difficulty.rnworthy: 'teaching includes using stool softeners and avoiding driving while titrating doses',
    },
  ),
  ConceptBlueprint(
    id: 'naloxone',
    label: 'Naloxone',
    details: {
      Difficulty.easy: 'rapidly reverses opioid-induced respiratory depression',
      Difficulty.medium: 'may need repeat dosing when long-acting opioids are involved',
      Difficulty.hard: 'can precipitate acute withdrawal with hypertension and pain',
      Difficulty.rnworthy: 'caregivers keep devices accessible and call emergency services after use',
    },
  ),
  ConceptBlueprint(
    id: 'statins',
    label: 'Statins',
    details: {
      Difficulty.easy: 'lower LDL by inhibiting HMG-CoA reductase',
      Difficulty.medium: 'require baseline and periodic liver enzyme monitoring',
      Difficulty.hard: 'carry rhabdomyolysis risk, especially with concurrent fibrates',
      Difficulty.rnworthy: 'clients take the dose at night and report unexplained muscle pain',
    },
  ),
  ConceptBlueprint(
    id: 'vancomycin',
    label: 'Vancomycin',
    details: {
      Difficulty.easy: 'treats serious gram-positive infections including MRSA',
      Difficulty.medium: 'requires trough levels before the fourth dose to avoid toxicity',
      Difficulty.hard: 'infusing too quickly causes red man syndrome from histamine release',
      Difficulty.rnworthy: 'teaching includes reporting hearing changes or balance issues promptly',
    },
  ),
];

const List<ConceptBlueprint> medSurgConcepts = [
  ConceptBlueprint(
    id: 'acute-heart-failure',
    label: 'Acute heart failure',
    details: {
      Difficulty.easy: 'presents with pink frothy sputum, S3 heart sound, and severe orthopnea',
      Difficulty.medium: 'requires the nurse to sit the patient upright, apply oxygen, and push IV loop diuretics',
      Difficulty.hard: 'often shows BNP values above 1000 pg/mL with pulmonary congestion on x-ray',
      Difficulty.rnworthy: 'teaching stresses daily weights and calling for a gain over 2 pounds in 24 hours',
    },
  ),
  ConceptBlueprint(
    id: 'copd-exacerbation',
    label: 'COPD exacerbation',
    details: {
      Difficulty.easy: 'presents with barrel chest, pursed-lip breathing, and chronic cough',
      Difficulty.medium: 'requires titrating oxygen cautiously to keep saturation roughly 88–92%',
      Difficulty.hard: 'often displays compensated respiratory acidosis with elevated CO₂ on ABG',
      Difficulty.rnworthy: 'teaching emphasizes smoking cessation and seasonal influenza vaccination',
    },
  ),
  ConceptBlueprint(
    id: 'myocardial-infarction',
    label: 'Myocardial infarction',
    details: {
      Difficulty.easy: 'causes crushing chest pain radiating to the jaw with diaphoresis',
      Difficulty.medium: 'requires immediate MONA therapy and rapid 12-lead ECG transmission',
      Difficulty.hard: 'shows troponin trending upward over the first 3–6 hours',
      Difficulty.rnworthy: 'teaching includes nitroglycerin use and cardiac rehabilitation enrollment',
    },
  ),
  ConceptBlueprint(
    id: 'pulmonary-embolism',
    label: 'Pulmonary embolism',
    details: {
      Difficulty.easy: 'presents with sudden pleuritic chest pain, dyspnea, and tachycardia',
      Difficulty.medium: 'requires rapid anticoagulation while maintaining oxygenation',
      Difficulty.hard: 'is associated with elevated D-dimer and ventilation-perfusion mismatch',
      Difficulty.rnworthy: 'teaching highlights compression devices and early ambulation after surgery',
    },
  ),
  ConceptBlueprint(
    id: 'deep-vein-thrombosis',
    label: 'Deep vein thrombosis',
    details: {
      Difficulty.easy: 'presents with unilateral leg swelling, warmth, and calf tenderness',
      Difficulty.medium: 'requires initiating anticoagulation and avoiding limb massage',
      Difficulty.hard: 'is confirmed via venous duplex ultrasound',
      Difficulty.rnworthy: 'teaching includes hydrating and avoiding prolonged immobility during travel',
    },
  ),
  ConceptBlueprint(
    id: 'acute-pancreatitis',
    label: 'Acute pancreatitis',
    details: {
      Difficulty.easy: 'produces severe epigastric pain radiating to the back with elevated lipase',
      Difficulty.medium: 'requires making the patient NPO, providing IV fluids, and managing pain aggressively',
      Difficulty.hard: 'may show Cullen or Grey Turner signs indicating hemorrhage',
      Difficulty.rnworthy: 'teaching stresses abstaining from alcohol and fatty meals after discharge',
    },
  ),
  ConceptBlueprint(
    id: 'cholecystitis',
    label: 'Cholecystitis',
    details: {
      Difficulty.easy: 'causes right upper quadrant pain after fatty meals with a positive Murphy sign',
      Difficulty.medium: 'requires NPO status, IV fluids, and possible antibiotics while awaiting surgery',
      Difficulty.hard: 'often shows elevated bilirubin and alkaline phosphatase',
      Difficulty.rnworthy: 'teaching includes following a low-fat diet and reporting clay-colored stools',
    },
  ),
  ConceptBlueprint(
    id: 'appendicitis',
    label: 'Appendicitis',
    details: {
      Difficulty.easy: 'presents with periumbilical pain migrating to McBurney point with rebound tenderness',
      Difficulty.medium: 'requires withholding laxatives or analgesics that could mask rupture signs until evaluated',
      Difficulty.hard: 'shows mild leukocytosis and ultrasound evidence of inflammation',
      Difficulty.rnworthy: 'teaching includes avoiding heat to the abdomen which may precipitate rupture',
    },
  ),
  ConceptBlueprint(
    id: 'bowel-obstruction',
    label: 'Bowel obstruction',
    details: {
      Difficulty.easy: 'presents with abdominal distention, cramping, and high-pitched bowel sounds',
      Difficulty.medium: 'requires NG tube decompression and aggressive fluid/electrolyte replacement',
      Difficulty.hard: 'shows dilated loops with air-fluid levels on imaging',
      Difficulty.rnworthy: 'teaching includes reporting inability to pass flatus or stool promptly',
    },
  ),
  ConceptBlueprint(
    id: 'upper-gi-bleed',
    label: 'Upper GI bleed',
    details: {
      Difficulty.easy: 'presents with coffee-ground emesis or melena',
      Difficulty.medium: 'requires large-bore IV access and proton pump inhibitor infusion',
      Difficulty.hard: 'often has dropping hemoglobin with elevated BUN from digested blood',
      Difficulty.rnworthy: 'teaching stresses avoiding NSAIDs and limiting alcohol intake',
    },
  ),
  ConceptBlueprint(
    id: 'dka',
    label: 'Diabetic ketoacidosis',
    details: {
      Difficulty.easy: 'causes polyuria, fruity breath, and Kussmaul respirations',
      Difficulty.medium: 'requires IV insulin plus isotonic fluids and electrolyte replacement',
      Difficulty.hard: 'shows metabolic acidosis with elevated anion gap and positive ketones',
      Difficulty.rnworthy: 'teaching includes never skipping basal insulin even when ill',
    },
  ),
  ConceptBlueprint(
    id: 'hhs',
    label: 'Hyperosmolar hyperglycemic state',
    details: {
      Difficulty.easy: 'presents with profound dehydration and neurologic changes without ketosis',
      Difficulty.medium: 'requires aggressive fluid resuscitation before insulin infusion',
      Difficulty.hard: 'often shows glucose levels above 600 mg/dL with normal pH',
      Difficulty.rnworthy: 'teaching focuses on early recognition of polydipsia and seeking care',
    },
  ),
  ConceptBlueprint(
    id: 'siadh',
    label: 'SIADH',
    details: {
      Difficulty.easy: 'presents with hyponatremia, low serum osmolality, and concentrated urine',
      Difficulty.medium: 'requires fluid restriction and hypertonic saline when neurologic symptoms appear',
      Difficulty.hard: 'labs show high urine sodium despite low serum sodium',
      Difficulty.rnworthy: 'teaching includes daily weights and reporting sudden weight gain or confusion',
    },
  ),
  ConceptBlueprint(
    id: 'diabetes-insipidus',
    label: 'Diabetes insipidus',
    details: {
      Difficulty.easy: 'causes massive dilute urine output and intense thirst',
      Difficulty.medium: 'requires vasopressin or desmopressin plus strict intake/output monitoring',
      Difficulty.hard: 'shows low urine specific gravity with high serum osmolality',
      Difficulty.rnworthy: 'teaching covers wearing medical alert identification and carrying water',
    },
  ),
  ConceptBlueprint(
    id: 'acute-kidney-injury',
    label: 'Acute kidney injury',
    details: {
      Difficulty.easy: 'presents with rising creatinine and decreased urine output',
      Difficulty.medium: 'requires avoiding nephrotoxic medications and optimizing perfusion',
      Difficulty.hard: 'labs reveal hyperkalemia and metabolic acidosis',
      Difficulty.rnworthy: 'teaching stresses avoiding over-the-counter NSAIDs and reporting decreased urine',
    },
  ),
  ConceptBlueprint(
    id: 'chronic-kidney-disease',
    label: 'Chronic kidney disease',
    details: {
      Difficulty.easy: 'presents with uremic pruritus, anemia, and edema',
      Difficulty.medium: 'requires fluid restrictions, phosphate binders, and dialysis scheduling',
      Difficulty.hard: 'labs show elevated phosphorus with low calcium necessitating binders and calcitriol',
      Difficulty.rnworthy: 'dietary teaching emphasizes low sodium, low potassium meals and medication timing around dialysis',
    },
  ),
  ConceptBlueprint(
    id: 'cirrhosis-ascites',
    label: 'Cirrhosis with ascites',
    details: {
      Difficulty.easy: 'presents with abdominal girth increase and caput medusae',
      Difficulty.medium: 'requires sodium restriction, diuretics, and possible paracentesis',
      Difficulty.hard: 'labs reveal prolonged INR and low albumin',
      Difficulty.rnworthy: 'teaching includes absolute alcohol cessation and daily weight tracking',
    },
  ),
  ConceptBlueprint(
    id: 'ischemic-stroke',
    label: 'Ischemic stroke',
    details: {
      Difficulty.easy: 'causes sudden unilateral weakness and facial droop',
      Difficulty.medium: 'requires rapid thrombolytic screening within the treatment window',
      Difficulty.hard: 'initial CT scan is negative yet rules out hemorrhage',
      Difficulty.rnworthy: 'teaching covers FAST warning signs and activating EMS immediately',
    },
  ),
  ConceptBlueprint(
    id: 'hemorrhagic-stroke',
    label: 'Hemorrhagic stroke',
    details: {
      Difficulty.easy: 'presents with thunderclap headache, vomiting, and photophobia',
      Difficulty.medium: 'requires strict blood pressure control and neurosurgical consultation',
      Difficulty.hard: 'shows intracranial bleeding on emergent CT imaging',
      Difficulty.rnworthy: 'teaching stresses hypertension control and cautious use of anticoagulants',
    },
  ),
  ConceptBlueprint(
    id: 'sepsis',
    label: 'Sepsis',
    details: {
      Difficulty.easy: 'presents with fever, tachycardia, and possible confusion',
      Difficulty.medium: 'requires obtaining blood cultures before broad-spectrum antibiotics',
      Difficulty.hard: 'elevated lactate above 2 mmol/L indicates tissue hypoperfusion',
      Difficulty.rnworthy: 'teaching emphasizes early reporting of infection signs and keeping vaccinations current',
    },
  ),
  ConceptBlueprint(
    id: 'septic-shock',
    label: 'Septic shock',
    details: {
      Difficulty.easy: 'leads to persistent hypotension despite fluid boluses',
      Difficulty.medium: 'requires vasopressors via central line and continuous MAP monitoring',
      Difficulty.hard: 'shows high lactate and metabolic acidosis despite aggressive fluids',
      Difficulty.rnworthy: 'family teaching addresses early goals-of-care discussions during refractory shock',
    },
  ),
  ConceptBlueprint(
    id: 'aortic-dissection',
    label: 'Aortic dissection',
    details: {
      Difficulty.easy: 'presents with tearing chest pain radiating to the back',
      Difficulty.medium: 'requires immediate beta blockade and rapid blood pressure reduction',
      Difficulty.hard: 'often shows mediastinal widening on imaging',
      Difficulty.rnworthy: 'teaching includes lifelong strict blood pressure control',
    },
  ),
  ConceptBlueprint(
    id: 'sickle-cell-crisis',
    label: 'Sickle cell crisis',
    details: {
      Difficulty.easy: 'presents with severe bone pain and low-grade fever',
      Difficulty.medium: 'requires aggressive hydration, oxygen therapy, and opioid analgesia',
      Difficulty.hard: 'labs show elevated bilirubin and reticulocyte count from hemolysis',
      Difficulty.rnworthy: 'teaching stresses hydration, avoiding high altitudes, and seeking care for fever',
    },
  ),
  ConceptBlueprint(
    id: 'thyroid-storm',
    label: 'Thyroid storm',
    details: {
      Difficulty.easy: 'produces high fever, tachycardia, and agitation',
      Difficulty.medium: 'requires beta blockers, antithyroid drugs, and cooling measures',
      Difficulty.hard: 'labs reveal extremely low TSH with markedly elevated T3 and T4',
      Difficulty.rnworthy: 'teaching stresses medication adherence and avoiding iodine overload',
    },
  ),
  ConceptBlueprint(
    id: 'myxedema-coma',
    label: 'Myxedema coma',
    details: {
      Difficulty.easy: 'presents with hypothermia, bradycardia, and altered mental status',
      Difficulty.medium: 'requires airway support, IV levothyroxine, and gradual rewarming',
      Difficulty.hard: 'labs show high TSH with low free T4',
      Difficulty.rnworthy: 'teaching includes taking thyroid hormone daily and seeking care for infections promptly',
    },
  ),
];

const List<ConceptBlueprint> pediatricsConcepts = [
  ConceptBlueprint(
    id: 'croup',
    label: 'Croup',
    details: {
      Difficulty.easy: 'presents with barking cough, inspiratory stridor, and hoarseness after a viral illness',
      Difficulty.medium: 'requires cool mist, racemic epinephrine, and corticosteroids while monitoring airway',
      Difficulty.hard: 'may show a steeple sign from subglottic narrowing on neck x-ray',
      Difficulty.rnworthy: 'teaching includes humidified air at home and seeking care for stridor at rest',
    },
  ),
  ConceptBlueprint(
    id: 'epiglottitis',
    label: 'Epiglottitis',
    details: {
      Difficulty.easy: 'presents with drooling, dysphagia, and tripod positioning',
      Difficulty.medium: 'requires keeping the child calm and preparing for emergent airway support',
      Difficulty.hard: 'is often caused by Haemophilus influenzae type b when vaccinations are missed',
      Difficulty.rnworthy: 'teaching emphasizes completing the Hib vaccine series',
    },
  ),
  ConceptBlueprint(
    id: 'rsv-bronchiolitis',
    label: 'RSV bronchiolitis',
    details: {
      Difficulty.easy: 'causes wheezing, nasal flaring, and retractions in infants during winter months',
      Difficulty.medium: 'requires suctioning secretions frequently and maintaining hydration',
      Difficulty.hard: 'may require high-flow oxygen when apnea episodes develop',
      Difficulty.rnworthy: 'teaching includes strict hand hygiene and palivizumab for high-risk infants',
    },
  ),
  ConceptBlueprint(
    id: 'pertussis',
    label: 'Pertussis',
    details: {
      Difficulty.easy: 'presents with paroxysmal whooping cough and posttussive vomiting',
      Difficulty.medium: 'requires droplet precautions and macrolide antibiotics for the child and contacts',
      Difficulty.hard: 'often shows marked lymphocytosis despite being bacterial',
      Difficulty.rnworthy: 'teaching stresses current immunizations and limiting exposure to newborns',
    },
  ),
  ConceptBlueprint(
    id: 'kawasaki',
    label: 'Kawasaki disease',
    details: {
      Difficulty.easy: 'presents with five-day fever, strawberry tongue, and desquamating rash',
      Difficulty.medium: 'requires IV immunoglobulin and high-dose aspirin within ten days',
      Difficulty.hard: 'can produce coronary aneurysms, so echocardiogram follow-up is essential',
      Difficulty.rnworthy: 'teaching includes avoiding live vaccines for eleven months after IVIG',
    },
  ),
  ConceptBlueprint(
    id: 'tetralogy-fallot',
    label: 'Tetralogy of Fallot',
    details: {
      Difficulty.easy: 'causes cyanotic spells relieved by knee-chest positioning',
      Difficulty.medium: 'requires calming the infant and providing oxygen during tet spells',
      Difficulty.hard: 'echo shows VSD, overriding aorta, pulmonary stenosis, and RV hypertrophy',
      Difficulty.rnworthy: 'teaching includes encouraging squatting during play to improve perfusion',
    },
  ),
  ConceptBlueprint(
    id: 'coarctation',
    label: 'Coarctation of the aorta',
    details: {
      Difficulty.easy: 'presents with bounding brachial pulses and weak femoral pulses',
      Difficulty.medium: 'requires blood pressure measurements in all extremities',
      Difficulty.hard: 'older children may show rib notching from collateral vessels on x-ray',
      Difficulty.rnworthy: 'teaching includes postoperative blood pressure monitoring at home',
    },
  ),
  ConceptBlueprint(
    id: 'hirschsprung',
    label: 'Hirschsprung disease',
    details: {
      Difficulty.easy: 'presents with delayed meconium, abdominal distention, and bilious vomiting',
      Difficulty.medium: 'requires bowel rest and rectal irrigations before surgery',
      Difficulty.hard: 'biopsy reveals absence of ganglion cells in the distal colon',
      Difficulty.rnworthy: 'teaching includes ostomy care instructions if staged repair is needed',
    },
  ),
  ConceptBlueprint(
    id: 'intussusception',
    label: 'Intussusception',
    details: {
      Difficulty.easy: 'causes intermittent severe pain with knees drawn up and currant jelly stools',
      Difficulty.medium: 'requires air or contrast enema reduction under fluoroscopy',
      Difficulty.hard: 'a sausage-shaped mass may be palpable in the right upper quadrant',
      Difficulty.rnworthy: 'teaching involves monitoring for recurrence after successful reduction',
    },
  ),
  ConceptBlueprint(
    id: 'pyloric-stenosis',
    label: 'Pyloric stenosis',
    details: {
      Difficulty.easy: 'presents with projectile nonbilious vomiting and failure to thrive',
      Difficulty.medium: 'requires correcting dehydration and electrolytes before pyloromyotomy',
      Difficulty.hard: 'labs reveal hypochloremic metabolic alkalosis',
      Difficulty.rnworthy: 'teaching includes offering small frequent feedings after surgery',
    },
  ),
  ConceptBlueprint(
    id: 'cystic-fibrosis',
    label: 'Cystic fibrosis',
    details: {
      Difficulty.easy: 'presents with salty-tasting skin, chronic cough, and steatorrhea',
      Difficulty.medium: 'requires airway clearance therapy and pancreatic enzymes with every meal',
      Difficulty.hard: 'diagnosis is confirmed with sweat chloride greater than 60 mmol/L',
      Difficulty.rnworthy: 'teaching emphasizes high-calorie diet, infection avoidance, and daily chest physiotherapy',
    },
  ),
  ConceptBlueprint(
    id: 'rheumatic-fever',
    label: 'Rheumatic fever',
    details: {
      Difficulty.easy: 'develops after untreated strep throat with migratory polyarthritis',
      Difficulty.medium: 'requires anti-inflammatory therapy and prophylactic penicillin',
      Difficulty.hard: 'carditis may lead to murmurs and cardiomegaly',
      Difficulty.rnworthy: 'teaching includes completing antibiotics for every sore throat and follow-up echocardiograms',
    },
  ),
  ConceptBlueprint(
    id: 'scoliosis',
    label: 'Scoliosis screening',
    details: {
      Difficulty.easy: 'is noted by rib hump on Adam’s forward bend test',
      Difficulty.medium: 'requires bracing for curves between 25 and 45 degrees',
      Difficulty.hard: 'severe curves can impair lung expansion causing restrictive disease',
      Difficulty.rnworthy: 'teaching stresses wearing the brace 18–23 hours daily and skin checks',
    },
  ),
  ConceptBlueprint(
    id: 'hip-dysplasia',
    label: 'Developmental hip dysplasia',
    details: {
      Difficulty.easy: 'presents with uneven gluteal folds and positive Ortolani/Barlow signs',
      Difficulty.medium: 'requires Pavlik harness to maintain hip flexion and abduction',
      Difficulty.hard: 'untreated cases progress to early osteoarthritis and limp',
      Difficulty.rnworthy: 'teaching includes not removing the harness and checking skin under straps daily',
    },
  ),
  ConceptBlueprint(
    id: 'otitis-media',
    label: 'Otitis media',
    details: {
      Difficulty.easy: 'presents with ear pulling, fever, and bulging tympanic membrane',
      Difficulty.medium: 'requires analgesics and, when severe, appropriate antibiotics',
      Difficulty.hard: 'recurrent infections may necessitate tympanostomy tubes',
      Difficulty.rnworthy: 'teaching includes feeding upright and avoiding bottle propping',
    },
  ),
  ConceptBlueprint(
    id: 'acute-glomerulonephritis',
    label: 'Acute glomerulonephritis',
    details: {
      Difficulty.easy: 'follows strep throat with cola-colored urine and periorbital edema',
      Difficulty.medium: 'requires blood pressure control and sodium restriction',
      Difficulty.hard: 'labs show elevated ASO titer and reduced GFR',
      Difficulty.rnworthy: 'teaching includes completing antibiotics and monitoring urine color daily',
    },
  ),
  ConceptBlueprint(
    id: 'nephrotic-syndrome',
    label: 'Nephrotic syndrome',
    details: {
      Difficulty.easy: 'presents with massive proteinuria, edema, and hyperlipidemia',
      Difficulty.medium: 'requires corticosteroids and albumin plus diuretics',
      Difficulty.hard: 'urine appears frothy with a high protein-to-creatinine ratio',
      Difficulty.rnworthy: 'teaching emphasizes daily weights and infection prevention',
    },
  ),
  ConceptBlueprint(
    id: 'lead-poisoning',
    label: 'Lead poisoning',
    details: {
      Difficulty.easy: 'presents with developmental delay and pica in toddlers',
      Difficulty.medium: 'requires chelation therapy when venous lead exceeds 45 mcg/dL',
      Difficulty.hard: 'labs may show microcytic anemia with basophilic stippling',
      Difficulty.rnworthy: 'teaching includes wet-mopping floors and frequent handwashing',
    },
  ),
  ConceptBlueprint(
    id: 'varicella',
    label: 'Varicella',
    details: {
      Difficulty.easy: 'presents with pruritic vesicles in various stages concentrated on the trunk',
      Difficulty.medium: 'requires airborne and contact precautions until every lesion crusts',
      Difficulty.hard: 'immunocompromised children may need varicella-zoster immune globulin',
      Difficulty.rnworthy: 'teaching includes trimming nails to prevent scratching and secondary infection',
    },
  ),
  ConceptBlueprint(
    id: 'measles',
    label: 'Measles',
    details: {
      Difficulty.easy: 'causes cough, coryza, conjunctivitis, high fever, and Koplik spots',
      Difficulty.medium: 'requires airborne isolation and vitamin A supplementation',
      Difficulty.hard: 'complications include encephalitis and pneumonia',
      Difficulty.rnworthy: 'teaching reinforces the two-dose MMR vaccination schedule',
    },
  ),
  ConceptBlueprint(
    id: 'infant-dehydration',
    label: 'Infant dehydration',
    details: {
      Difficulty.easy: 'presents with sunken fontanel, dry mucosa, and decreased wet diapers',
      Difficulty.medium: 'requires oral rehydration solution for mild cases and IV fluids if severe',
      Difficulty.hard: 'labs show elevated specific gravity and possible sodium shifts',
      Difficulty.rnworthy: 'teaching includes continuing breastfeeding and offering ORS after each stool',
    },
  ),
  ConceptBlueprint(
    id: 'six-month-milestones',
    label: 'Six-month milestone',
    details: {
      Difficulty.easy: 'includes sitting with support, rolling both ways, and transferring objects hand to hand',
      Difficulty.medium: 'requires introducing single-ingredient solids while monitoring for allergies',
      Difficulty.hard: 'weight should be about double the birth weight by this age',
      Difficulty.rnworthy: 'teaching includes starting fluoride drops if the water supply lacks supplementation',
    },
  ),
  ConceptBlueprint(
    id: 'febrile-seizure',
    label: 'Febrile seizure',
    details: {
      Difficulty.easy: 'occurs in toddlers with rapid temperature rise and resolves quickly',
      Difficulty.medium: 'requires ensuring airway safety and positioning on the side without restraints',
      Difficulty.hard: 'typically leaves no neurologic deficits and normal EEG findings between events',
      Difficulty.rnworthy: 'teaching covers antipyretic use and when to call emergency services',
    },
  ),
  ConceptBlueprint(
    id: 'jia',
    label: 'Juvenile idiopathic arthritis',
    details: {
      Difficulty.easy: 'presents with morning stiffness and swollen, warm joints',
      Difficulty.medium: 'requires NSAIDs and scheduled exercises to maintain mobility',
      Difficulty.hard: 'labs may show elevated ESR and positive ANA',
      Difficulty.rnworthy: 'teaching includes warm baths before activity and adherence to prescribed biologics',
    },
  ),
  ConceptBlueprint(
    id: 'down-syndrome',
    label: 'Down syndrome',
    details: {
      Difficulty.easy: 'presents with hypotonia, flat nasal bridge, and single palmar crease',
      Difficulty.medium: 'requires screening for cardiac defects and atlantoaxial instability',
      Difficulty.hard: 'carries increased risk for leukemia and hypothyroidism requiring surveillance',
      Difficulty.rnworthy: 'teaching includes enrolling in early intervention and regular vision/hearing checks',
    },
  ),
];

const List<ConceptBlueprint> maternalConcepts = [
  ConceptBlueprint(
    id: 'hyperemesis',
    label: 'Hyperemesis gravidarum',
    details: {
      Difficulty.easy: 'presents with severe vomiting, weight loss, and ketonuria in early pregnancy',
      Difficulty.medium: 'requires IV hydration, electrolyte replacement, and antiemetics',
      Difficulty.hard: 'labs show metabolic alkalosis with hypokalemia and ketones',
      Difficulty.rnworthy: 'teaching includes small frequent meals and separating liquids from solids',
    },
  ),
  ConceptBlueprint(
    id: 'gestational-diabetes',
    label: 'Gestational diabetes',
    details: {
      Difficulty.easy: 'raises risk for macrosomia and polyhydramnios later in pregnancy',
      Difficulty.medium: 'requires diet management and insulin if fasting glucose exceeds 95 mg/dL',
      Difficulty.hard: 'is diagnosed via abnormal oral glucose tolerance testing at 24–28 weeks',
      Difficulty.rnworthy: 'teaching includes checking blood glucose four times daily and postpartum screening',
    },
  ),
  ConceptBlueprint(
    id: 'preeclampsia',
    label: 'Preeclampsia',
    details: {
      Difficulty.easy: 'presents with hypertension, proteinuria, and edema after 20 weeks',
      Difficulty.medium: 'requires seizure precautions and antihypertensives with reflex monitoring',
      Difficulty.hard: 'labs may show elevated liver enzymes and low platelets',
      Difficulty.rnworthy: 'teaching stresses daily fetal movement counts and reporting headaches or visual changes',
    },
  ),
  ConceptBlueprint(
    id: 'eclampsia',
    label: 'Eclampsia',
    details: {
      Difficulty.easy: 'includes tonic-clonic seizures with severe hypertension',
      Difficulty.medium: 'requires airway protection and a magnesium sulfate bolus',
      Difficulty.hard: 'can lead to DIC and HELLP syndrome needing lab monitoring',
      Difficulty.rnworthy: 'teaching includes postpartum seizure risk within 48 hours',
    },
  ),
  ConceptBlueprint(
    id: 'hellp',
    label: 'HELLP syndrome',
    details: {
      Difficulty.easy: 'presents with right upper quadrant pain, hemolysis, elevated liver enzymes, and low platelets',
      Difficulty.medium: 'requires expedited delivery once the mother is stabilized',
      Difficulty.hard: 'labs reveal schistocytes and platelets below 100,000',
      Difficulty.rnworthy: 'teaching includes postpartum follow-up for liver recovery',
    },
  ),
  ConceptBlueprint(
    id: 'placenta-previa',
    label: 'Placenta previa',
    details: {
      Difficulty.easy: 'causes painless bright red bleeding in the second or third trimester',
      Difficulty.medium: 'requires avoiding vaginal exams and planning a cesarean birth',
      Difficulty.hard: 'ultrasound shows placenta covering the internal os',
      Difficulty.rnworthy: 'teaching stresses pelvic rest and immediate reporting of bleeding',
    },
  ),
  ConceptBlueprint(
    id: 'placental-abruption',
    label: 'Placental abruption',
    details: {
      Difficulty.easy: 'presents with painful vaginal bleeding and a rigid uterus',
      Difficulty.medium: 'requires rapid delivery and management of maternal shock',
      Difficulty.hard: 'concealed bleeding may drop fibrinogen leading to DIC',
      Difficulty.rnworthy: 'teaching includes controlling hypertension and avoiding cocaine use',
    },
  ),
  ConceptBlueprint(
    id: 'preterm-labor',
    label: 'Preterm labor',
    details: {
      Difficulty.easy: 'occurs when contractions with cervical change begin before 37 weeks',
      Difficulty.medium: 'requires tocolytics, corticosteroids, and magnesium for neuroprotection',
      Difficulty.hard: 'fetal fibronectin testing helps predict imminent delivery',
      Difficulty.rnworthy: 'teaching includes hydration, rest, and reporting more than six contractions per hour',
    },
  ),
  ConceptBlueprint(
    id: 'pprom',
    label: 'PPROM',
    details: {
      Difficulty.easy: 'is rupture of membranes before 37 weeks and before labor onset',
      Difficulty.medium: 'requires avoiding vaginal exams, administering antibiotics, and monitoring for infection',
      Difficulty.hard: 'nitrazine and ferning tests confirm amniotic fluid leakage',
      Difficulty.rnworthy: 'teaching includes daily temperature checks and fetal movement counts at home',
    },
  ),
  ConceptBlueprint(
    id: 'postpartum-hemorrhage',
    label: 'Postpartum hemorrhage',
    details: {
      Difficulty.easy: 'presents with saturated pads, boggy uterus, and hypotension',
      Difficulty.medium: 'requires firm uterine massage, uterotonics, and large-bore IV access',
      Difficulty.hard: 'labs track rapid hemoglobin drops and possible coagulopathy',
      Difficulty.rnworthy: 'teaching includes demonstrating fundal massage and reporting heavy lochia',
    },
  ),
  ConceptBlueprint(
    id: 'endometritis',
    label: 'Endometritis',
    details: {
      Difficulty.easy: 'presents with foul-smelling lochia and uterine tenderness postpartum',
      Difficulty.medium: 'requires IV broad-spectrum antibiotics',
      Difficulty.hard: 'labs show leukocytosis and elevated C-reactive protein',
      Difficulty.rnworthy: 'teaching emphasizes perineal hygiene and early ambulation',
    },
  ),
  ConceptBlueprint(
    id: 'mastitis',
    label: 'Mastitis',
    details: {
      Difficulty.easy: 'presents with unilateral breast redness, warmth, and flu-like symptoms',
      Difficulty.medium: 'requires antibiotics and continued breastfeeding or pumping',
      Difficulty.hard: 'untreated infections can progress to abscess needing drainage',
      Difficulty.rnworthy: 'teaching includes alternating feeding positions and fully draining breasts',
    },
  ),
  ConceptBlueprint(
    id: 'shoulder-dystocia',
    label: 'Shoulder dystocia',
    details: {
      Difficulty.easy: 'presents with turtle sign when the head retracts against the perineum',
      Difficulty.medium: 'requires McRoberts maneuver and suprapubic pressure',
      Difficulty.hard: 'prolonged impaction risks brachial plexus injury and hypoxia',
      Difficulty.rnworthy: 'teaching addresses planning earlier delivery if future fetus estimated to be large',
    },
  ),
  ConceptBlueprint(
    id: 'cord-prolapse',
    label: 'Umbilical cord prolapse',
    details: {
      Difficulty.easy: 'presents with sudden fetal bradycardia after membrane rupture',
      Difficulty.medium: 'requires relieving pressure by elevating the presenting part and preparing for emergency delivery',
      Difficulty.hard: 'causes rapid fetal hypoxia if uncorrected',
      Difficulty.rnworthy: 'teaching includes seeking immediate care when membranes rupture before engagement',
    },
  ),
  ConceptBlueprint(
    id: 'magnesium-toxicity',
    label: 'Magnesium sulfate toxicity',
    details: {
      Difficulty.easy: 'presents with diminished reflexes, respiratory depression, and hypotension',
      Difficulty.medium: 'requires stopping the infusion and administering calcium gluconate antidote',
      Difficulty.hard: 'occurs when serum magnesium levels exceed roughly 8 mEq/L',
      Difficulty.rnworthy: 'teaching includes reporting flushing, blurred vision, or difficulty breathing during infusion',
    },
  ),
  ConceptBlueprint(
    id: 'rh-isoimmunization',
    label: 'Rh isoimmunization',
    details: {
      Difficulty.easy: 'occurs when an Rh-negative mother carries an Rh-positive fetus',
      Difficulty.medium: 'requires Rho(D) immune globulin at 28 weeks and within 72 hours postpartum',
      Difficulty.hard: 'indirect Coombs tests monitor antibody titers throughout pregnancy',
      Difficulty.rnworthy: 'teaching includes notifying providers after any bleeding or trauma events',
    },
  ),
  ConceptBlueprint(
    id: 'late-decelerations',
    label: 'Late decelerations',
    details: {
      Difficulty.easy: 'show gradual FHR decreases after contractions indicating uteroplacental insufficiency',
      Difficulty.medium: 'require repositioning, oxygen, stopping oxytocin, and notifying the provider',
      Difficulty.hard: 'persistent patterns may signal fetal acidemia requiring expedited birth',
      Difficulty.rnworthy: 'teaching explains why continuous monitoring is needed when patterns occur',
    },
  ),
  ConceptBlueprint(
    id: 'category-one',
    label: 'Category I tracing',
    details: {
      Difficulty.easy: 'features moderate variability with accelerations and no decelerations',
      Difficulty.medium: 'requires only routine observation without interventions',
      Difficulty.hard: 'predicts normal fetal acid-base status',
      Difficulty.rnworthy: 'teaching reassures families when tracings show expected variability',
    },
  ),
  ConceptBlueprint(
    id: 'uterine-rupture',
    label: 'Uterine rupture',
    details: {
      Difficulty.easy: 'presents with sudden abdominal pain, loss of fetal station, and cessation of contractions',
      Difficulty.medium: 'requires immediate laparotomy and maternal resuscitation',
      Difficulty.hard: 'is more likely in scarred uteri after prior cesarean',
      Difficulty.rnworthy: 'teaching includes spacing pregnancies and reviewing VBAC risks',
    },
  ),
  ConceptBlueprint(
    id: 'postpartum-depression',
    label: 'Postpartum depression',
    details: {
      Difficulty.easy: 'presents with persistent sadness and loss of interest beyond two weeks postpartum',
      Difficulty.medium: 'requires screening tools and referral for therapy or medication',
      Difficulty.hard: 'untreated cases risk impaired bonding and self-harm',
      Difficulty.rnworthy: 'teaching emphasizes accepting help and contacting providers early',
    },
  ),
  ConceptBlueprint(
    id: 'postpartum-psychosis',
    label: 'Postpartum psychosis',
    details: {
      Difficulty.easy: 'presents with hallucinations, delusions, and disorganized behavior soon after birth',
      Difficulty.medium: 'requires emergency hospitalization and antipsychotic therapy',
      Difficulty.hard: 'is a psychiatric emergency due to suicide or infanticide risk',
      Difficulty.rnworthy: 'teaching ensures family members know warning signs and when to call 911',
    },
  ),
  ConceptBlueprint(
    id: 'neonatal-hypoglycemia',
    label: 'Neonatal hypoglycemia',
    details: {
      Difficulty.easy: 'presents with jitteriness, weak cry, and poor feeding within hours of birth',
      Difficulty.medium: 'requires immediate feeding or IV dextrose to keep glucose above 45 mg/dL',
      Difficulty.hard: 'infants of diabetic mothers are at highest risk',
      Difficulty.rnworthy: 'teaching includes early breastfeeding and skin-to-skin contact',
    },
  ),
  ConceptBlueprint(
    id: 'neonatal-jaundice',
    label: 'Neonatal jaundice',
    details: {
      Difficulty.easy: 'presents with yellowing of skin and sclera after day two',
      Difficulty.medium: 'requires bilirubin monitoring and possible phototherapy',
      Difficulty.hard: 'kernicterus risk rises when bilirubin exceeds 25 mg/dL',
      Difficulty.rnworthy: 'teaching includes frequent feeding to promote stooling',
    },
  ),
  ConceptBlueprint(
    id: 'gbs-prophylaxis',
    label: 'Group B strep prophylaxis',
    details: {
      Difficulty.easy: 'is indicated when maternal cultures are positive at 35–37 weeks',
      Difficulty.medium: 'requires IV penicillin at least four hours before delivery',
      Difficulty.hard: 'dramatically reduces early-onset neonatal sepsis',
      Difficulty.rnworthy: 'teaching includes notifying the hospital promptly if membranes rupture before antibiotics',
    },
  ),
  ConceptBlueprint(
    id: 'neonatal-sepsis',
    label: 'Neonatal sepsis',
    details: {
      Difficulty.easy: 'presents with temperature instability, lethargy, and poor perfusion',
      Difficulty.medium: 'requires broad-spectrum antibiotics after cultures are drawn',
      Difficulty.hard: 'labs show elevated CRP and possible neutropenia',
      Difficulty.rnworthy: 'teaching emphasizes hand hygiene and early evaluation for lethargy or feeding refusal',
    },
  ),
];

const List<ConceptBlueprint> mentalHealthConcepts = [
  ConceptBlueprint(
    id: 'major-depression',
    label: 'Major depressive disorder',
    details: {
      Difficulty.easy: 'presents with anhedonia, sleep changes, and low energy persisting at least two weeks',
      Difficulty.medium: 'requires suicide risk assessment plus antidepressants and psychotherapy',
      Difficulty.hard: 'may show elevated PHQ-9 scores and hypothalamic-pituitary axis dysregulation',
      Difficulty.rnworthy: 'teaching includes medication adherence despite delayed onset of benefit',
    },
  ),
  ConceptBlueprint(
    id: 'bipolar-mania',
    label: 'Bipolar mania',
    details: {
      Difficulty.easy: 'presents with pressured speech, decreased need for sleep, and risky behavior',
      Difficulty.medium: 'requires firm limit-setting and ensuring mood stabilizer adherence',
      Difficulty.hard: 'labs monitor lithium levels plus renal and thyroid function',
      Difficulty.rnworthy: 'teaching stresses sleep hygiene and recognizing early warning signs',
    },
  ),
  ConceptBlueprint(
    id: 'schizophrenia',
    label: 'Schizophrenia',
    details: {
      Difficulty.easy: 'presents with hallucinations, flat affect, and disorganized thinking',
      Difficulty.medium: 'requires antipsychotic therapy and minimizing environmental stimuli during episodes',
      Difficulty.hard: 'second-generation antipsychotics increase metabolic syndrome risk needing labs',
      Difficulty.rnworthy: 'teaching includes medication adherence and reporting extrapyramidal symptoms promptly',
    },
  ),
  ConceptBlueprint(
    id: 'ocd',
    label: 'Obsessive-compulsive disorder',
    details: {
      Difficulty.easy: 'presents with intrusive thoughts and compulsive rituals that reduce anxiety temporarily',
      Difficulty.medium: 'requires CBT with exposure/response prevention plus SSRIs',
      Difficulty.hard: 'neurobiology implicates abnormal cortico-striatal circuits',
      Difficulty.rnworthy: 'teaching includes practicing relaxation techniques to lower ritual frequency',
    },
  ),
  ConceptBlueprint(
    id: 'ptsd',
    label: 'PTSD',
    details: {
      Difficulty.easy: 'presents with nightmares, hypervigilance, and flashbacks after trauma',
      Difficulty.medium: 'requires trauma-focused therapy and sometimes prazosin for nightmares',
      Difficulty.hard: 'screening uses the PCL-5 to assess severity',
      Difficulty.rnworthy: 'teaching includes grounding exercises and avoiding trigger stimuli when possible',
    },
  ),
  ConceptBlueprint(
    id: 'panic-disorder',
    label: 'Panic disorder',
    details: {
      Difficulty.easy: 'presents with sudden chest tightness, palpitations, and fear of dying',
      Difficulty.medium: 'requires coaching on slow breathing and short-term benzodiazepines when indicated',
      Difficulty.hard: 'long-term control usually involves SSRIs or SNRIs',
      Difficulty.rnworthy: 'teaching includes daily relaxation practices between attacks',
    },
  ),
  ConceptBlueprint(
    id: 'gad',
    label: 'Generalized anxiety disorder',
    details: {
      Difficulty.easy: 'presents with chronic worry, fatigue, and muscle tension for more than six months',
      Difficulty.medium: 'requires CBT plus medications such as buspirone or SSRIs',
      Difficulty.hard: 'severity can be quantified with the GAD-7 scale',
      Difficulty.rnworthy: 'teaching includes journaling triggers and scheduling dedicated “worry time”',
    },
  ),
  ConceptBlueprint(
    id: 'borderline-personality',
    label: 'Borderline personality disorder',
    details: {
      Difficulty.easy: 'presents with unstable relationships, splitting, and impulsivity',
      Difficulty.medium: 'requires consistent limit-setting and dialectical behavior therapy',
      Difficulty.hard: 'self-harm behavior necessitates safety planning and documentation',
      Difficulty.rnworthy: 'teaching includes mindfulness skills to tolerate distress',
    },
  ),
  ConceptBlueprint(
    id: 'antisocial',
    label: 'Antisocial personality disorder',
    details: {
      Difficulty.easy: 'presents with disregard for rules, deceit, and lack of remorse',
      Difficulty.medium: 'requires setting clear boundaries and legal consequences',
      Difficulty.hard: 'often coexists with substance misuse requiring integrated treatment',
      Difficulty.rnworthy: 'teaching focuses on accountability and consistent follow-up expectations',
    },
  ),
  ConceptBlueprint(
    id: 'anorexia',
    label: 'Anorexia nervosa',
    details: {
      Difficulty.easy: 'presents with severe weight loss, amenorrhea, and distorted body image',
      Difficulty.medium: 'requires nutritional rehabilitation and monitoring for refeeding syndrome',
      Difficulty.hard: 'labs show electrolyte disturbances such as hypokalemia',
      Difficulty.rnworthy: 'teaching includes structured meal plans and cognitive reframing of body image',
    },
  ),
  ConceptBlueprint(
    id: 'bulimia',
    label: 'Bulimia nervosa',
    details: {
      Difficulty.easy: 'presents with binge eating followed by purging, parotid swelling, and dental erosion',
      Difficulty.medium: 'requires CBT and SSRIs while monitoring electrolytes',
      Difficulty.hard: 'commonly produces metabolic alkalosis and hypokalemia',
      Difficulty.rnworthy: 'teaching emphasizes journaling triggers and interrupting the binge–purge cycle',
    },
  ),
  ConceptBlueprint(
    id: 'binge-eating',
    label: 'Binge eating disorder',
    details: {
      Difficulty.easy: 'involves recurrent binges without compensatory behaviors causing distress',
      Difficulty.medium: 'requires therapy focused on mindful eating and emotional regulation',
      Difficulty.hard: 'is associated with metabolic syndrome requiring screening labs',
      Difficulty.rnworthy: 'teaching includes structured meal schedules and support groups',
    },
  ),
  ConceptBlueprint(
    id: 'alcohol-withdrawal',
    label: 'Alcohol withdrawal',
    details: {
      Difficulty.easy: 'presents with tremors, diaphoresis, and tachycardia within 12 hours of last drink',
      Difficulty.medium: 'requires CIWA monitoring and benzodiazepine dosing',
      Difficulty.hard: 'risks seizures and delirium tremens by 48–72 hours',
      Difficulty.rnworthy: 'teaching includes referral to rehabilitation and thiamine supplementation',
    },
  ),
  ConceptBlueprint(
    id: 'opioid-withdrawal',
    label: 'Opioid withdrawal',
    details: {
      Difficulty.easy: 'presents with yawning, lacrimation, and piloerection when opioids are stopped',
      Difficulty.medium: 'requires supportive care plus methadone or buprenorphine as ordered',
      Difficulty.hard: 'causes tachycardia but rarely life-threatening hypertension',
      Difficulty.rnworthy: 'teaching includes adherence to medication-assisted treatment and counseling',
    },
  ),
  ConceptBlueprint(
    id: 'delirium',
    label: 'Delirium',
    details: {
      Difficulty.easy: 'presents with acute fluctuating confusion and inattention',
      Difficulty.medium: 'requires treating underlying causes and providing frequent reorientation',
      Difficulty.hard: 'EEG often shows generalized slowing differentiating it from dementia',
      Difficulty.rnworthy: 'teaching includes bringing glasses and hearing aids to reduce sensory deprivation',
    },
  ),
  ConceptBlueprint(
    id: 'dementia',
    label: 'Dementia',
    details: {
      Difficulty.easy: 'presents with progressive memory loss and impaired executive functioning',
      Difficulty.medium: 'requires structured routines and environmental safety modifications',
      Difficulty.hard: 'neuroimaging may reveal cortical atrophy depending on subtype',
      Difficulty.rnworthy: 'teaching includes caregiver respite resources and advance care planning',
    },
  ),
  ConceptBlueprint(
    id: 'autism',
    label: 'Autism spectrum disorder',
    details: {
      Difficulty.easy: 'presents with delayed social reciprocity and restricted interests',
      Difficulty.medium: 'requires early speech therapy and applied behavior analysis',
      Difficulty.hard: 'screening uses the M-CHAT at 18 and 24 months',
      Difficulty.rnworthy: 'teaching includes visual schedules and maintaining predictable routines',
    },
  ),
  ConceptBlueprint(
    id: 'adhd',
    label: 'ADHD',
    details: {
      Difficulty.easy: 'presents with inattention, hyperactivity, and impulsivity across settings',
      Difficulty.medium: 'requires behavioral therapy plus stimulant medication when indicated',
      Difficulty.hard: 'monitoring includes height, weight, and blood pressure on stimulants',
      Difficulty.rnworthy: 'teaching emphasizes consistent structure and positive reinforcement',
    },
  ),
  ConceptBlueprint(
    id: 'conduct-disorder',
    label: 'Conduct disorder',
    details: {
      Difficulty.easy: 'presents with aggression toward people or animals and rule violations',
      Difficulty.medium: 'requires family therapy and addressing comorbid substance use',
      Difficulty.hard: 'untreated cases may progress to antisocial personality disorder',
      Difficulty.rnworthy: 'teaching includes clear rules, immediate consequences, and school collaboration',
    },
  ),
  ConceptBlueprint(
    id: 'suicide-risk',
    label: 'Suicide risk',
    details: {
      Difficulty.easy: 'presents with hopelessness, giving away belongings, or sudden calm',
      Difficulty.medium: 'requires direct questioning and one-to-one observation if high risk',
      Difficulty.hard: 'safety planning addresses lethal means restriction and follow-up calls',
      Difficulty.rnworthy: 'teaching includes crisis hotline numbers and involving support networks',
    },
  ),
  ConceptBlueprint(
    id: 'ect-therapy',
    label: 'Electroconvulsive therapy',
    details: {
      Difficulty.easy: 'is indicated for severe depression with psychosis or suicidality',
      Difficulty.medium: 'requires NPO status and informed consent before treatment',
      Difficulty.hard: 'causes temporary memory loss and headache after sessions',
      Difficulty.rnworthy: 'teaching includes expecting multiple treatments each week and arranging transportation',
    },
  ),
  ConceptBlueprint(
    id: 'clozapine',
    label: 'Clozapine therapy',
    details: {
      Difficulty.easy: 'treats refractory schizophrenia but can cause agranulocytosis',
      Difficulty.medium: 'requires weekly CBC monitoring initially',
      Difficulty.hard: 'may lead to myocarditis or seizures at high doses',
      Difficulty.rnworthy: 'teaching includes reporting sore throat, fever, or chest pain immediately',
    },
  ),
  ConceptBlueprint(
    id: 'serotonin-syndrome',
    label: 'Serotonin syndrome',
    details: {
      Difficulty.easy: 'presents with agitation, clonus, and diaphoresis after serotonergic drug combinations',
      Difficulty.medium: 'requires stopping offending agents and providing benzodiazepines for agitation',
      Difficulty.hard: 'severe cases may need cyproheptadine antidote',
      Difficulty.rnworthy: 'teaching warns against combining MAOIs, SSRIs, and linezolid',
    },
  ),
  ConceptBlueprint(
    id: 'nms',
    label: 'Neuroleptic malignant syndrome',
    details: {
      Difficulty.easy: 'presents with lead-pipe rigidity, hyperthermia, and unstable blood pressure',
      Difficulty.medium: 'requires stopping antipsychotics and giving dantrolene or bromocriptine',
      Difficulty.hard: 'labs show markedly elevated creatine kinase and leukocytosis',
      Difficulty.rnworthy: 'teaching includes reporting high fever or muscle stiffness while on antipsychotics',
    },
  ),
  ConceptBlueprint(
    id: 'crisis-intervention',
    label: 'Crisis intervention',
    details: {
      Difficulty.easy: 'focuses on resolving acute situational stress within four to six weeks',
      Difficulty.medium: 'requires active listening, problem solving, and linking to resources',
      Difficulty.hard: 'goal is restoration of pre-crisis functioning and prevention of chronic issues',
      Difficulty.rnworthy: 'teaching includes building coping toolkits and contact lists before crises recur',
    },
  ),
];

const List<ConceptBlueprint> fundamentalsConcepts = [
  ConceptBlueprint(
    id: 'hand-hygiene',
    label: 'Hand hygiene',
    details: {
      Difficulty.easy: 'remains the most effective way to prevent client-to-client infection spread',
      Difficulty.medium: 'requires washing with soap and water for at least 20 seconds when hands are visibly soiled',
      Difficulty.hard: 'policy expects cleansing before patient contact, after exposure, and after glove removal',
      Difficulty.rnworthy: 'teaching includes reminding visitors to sanitize hands when entering rooms',
    },
  ),
  ConceptBlueprint(
    id: 'ppe-sequence',
    label: 'PPE sequence',
    details: {
      Difficulty.easy: 'ensures pathogens remain contained when caring for isolation patients',
      Difficulty.medium: 'requires donning gown, mask, goggles, then gloves before entry',
      Difficulty.hard: 'doffing sequence removes gloves first to avoid contaminating skin or clothing',
      Difficulty.rnworthy: 'teaching includes removing PPE before exiting airborne isolation rooms',
    },
  ),
  ConceptBlueprint(
    id: 'sterile-field',
    label: 'Sterile field',
    details: {
      Difficulty.easy: 'maintains asepsis during invasive procedures like catheter insertion',
      Difficulty.medium: 'requires keeping sterile objects above waist level and within view',
      Difficulty.hard: 'the one-inch outer border is considered contaminated and must be avoided',
      Difficulty.rnworthy: 'teaching includes asking observers not to reach over sterile setups',
    },
  ),
  ConceptBlueprint(
    id: 'fall-prevention',
    label: 'Fall prevention',
    details: {
      Difficulty.easy: 'reduces injury risk by screening clients with tools like the Morse scale',
      Difficulty.medium: 'requires keeping call lights within reach and answering promptly',
      Difficulty.hard: 'post-fall protocols mandate neuro checks and documentation of circumstances',
      Difficulty.rnworthy: 'teaching includes wearing nonskid footwear during ambulation',
    },
  ),
  ConceptBlueprint(
    id: 'restraints',
    label: 'Restraint safety',
    details: {
      Difficulty.easy: 'protects clients and staff when less restrictive measures fail',
      Difficulty.medium: 'requires provider orders renewed every 24 hours and frequent circulatory checks',
      Difficulty.hard: 'two-finger spacing must remain between restraint and skin to prevent injury',
      Difficulty.rnworthy: 'teaching includes explaining the necessity and documenting alternatives tried',
    },
  ),
  ConceptBlueprint(
    id: 'delegate-uap',
    label: 'Delegation to UAP',
    details: {
      Difficulty.easy: 'includes tasks like vital signs for stable patients',
      Difficulty.medium: 'requires providing specific instructions and verifying understanding',
      Difficulty.hard: 'accountability remains with the RN even after delegation',
      Difficulty.rnworthy: 'teaching includes encouraging UAP to report abnormal findings immediately',
    },
  ),
  ConceptBlueprint(
    id: 'delegate-lpn',
    label: 'Delegation to LPN',
    details: {
      Difficulty.easy: 'covers routine medication administration for stable clients',
      Difficulty.medium: 'requires the RN to supply a clear care plan and supervise outcomes',
      Difficulty.hard: 'initial assessments, teaching, and IV pushes for high-alert meds remain RN duties',
      Difficulty.rnworthy: 'teaching clarifies scope before assigning new responsibilities',
    },
  ),
  ConceptBlueprint(
    id: 'vital-signs',
    label: 'Vital sign review',
    details: {
      Difficulty.easy: 'provides baseline data for detecting deterioration',
      Difficulty.medium: 'requires verifying abnormal readings manually before notifying the provider',
      Difficulty.hard: 'narrowing pulse pressure may signal impending shock',
      Difficulty.rnworthy: 'teaching includes obtaining vitals prior to antihypertensive therapy',
    },
  ),
  ConceptBlueprint(
    id: 'pain-assessment',
    label: 'Pain assessment',
    details: {
      Difficulty.easy: 'relies on patient self-report using numeric or faces scales',
      Difficulty.medium: 'requires reassessing 30–60 minutes after interventions',
      Difficulty.hard: 'documentation must include location, quality, and aggravating factors',
      Difficulty.rnworthy: 'teaching encourages requesting analgesia before pain escalates',
    },
  ),
  ConceptBlueprint(
    id: 'sbar',
    label: 'SBAR communication',
    details: {
      Difficulty.easy: 'structures dialogue into Situation, Background, Assessment, Recommendation',
      Difficulty.medium: 'requires gathering objective data before contacting providers',
      Difficulty.hard: 'standardized handoffs improve patient safety metrics',
      Difficulty.rnworthy: 'teaching includes rehearsing key points before urgent calls',
    },
  ),
  ConceptBlueprint(
    id: 'oxygen-safety',
    label: 'Oxygen safety',
    details: {
      Difficulty.easy: 'prevents combustion by keeping sources away from open flames and sparks',
      Difficulty.medium: 'requires checking humidifiers and cylinder fill levels each shift',
      Difficulty.hard: 'static electricity from wool blankets should be avoided near oxygen equipment',
      Difficulty.rnworthy: 'teaching includes posting “No Smoking” signage per policy',
    },
  ),
  ConceptBlueprint(
    id: 'wound-care',
    label: 'Wound care',
    details: {
      Difficulty.easy: 'promotes healing by removing exudate and protecting granulation tissue',
      Difficulty.medium: 'requires sterile technique for fresh surgical incisions',
      Difficulty.hard: 'negative-pressure therapy must maintain ordered suction levels',
      Difficulty.rnworthy: 'teaching includes protein-rich diet and adequate hydration',
    },
  ),
  ConceptBlueprint(
    id: 'enteral-feeding',
    label: 'Enteral feeding',
    details: {
      Difficulty.easy: 'delivers nutrition via NG or PEG tubes when oral intake is inadequate',
      Difficulty.medium: 'requires verifying placement and checking residuals per protocol',
      Difficulty.hard: 'pump rates must match orders to prevent aspiration',
      Difficulty.rnworthy: 'teaching includes flushing tubes before and after medications',
    },
  ),
  ConceptBlueprint(
    id: 'blood-transfusion',
    label: 'Blood transfusion',
    details: {
      Difficulty.easy: 'treats anemia quickly but carries reaction risk',
      Difficulty.medium: 'requires two-nurse verification of identifiers before starting',
      Difficulty.hard: 'vital signs taken 15 minutes after initiation detect acute hemolysis',
      Difficulty.rnworthy: 'teaching includes reporting chills, back pain, or dyspnea immediately',
    },
  ),
  ConceptBlueprint(
    id: 'iv-infiltration',
    label: 'IV infiltration',
    details: {
      Difficulty.easy: 'presents with cool, swollen site and slowed infusion',
      Difficulty.medium: 'requires stopping the infusion, removing the catheter, and elevating the extremity',
      Difficulty.hard: 'vesicant extravasation may require antidote infiltration and provider notification',
      Difficulty.rnworthy: 'teaching includes reporting tightness or burning at IV sites promptly',
    },
  ),
  ConceptBlueprint(
    id: 'clabsi-prevention',
    label: 'Central line infection prevention',
    details: {
      Difficulty.easy: 'relies on chlorhexidine scrub and sterile technique during dressing changes',
      Difficulty.medium: 'requires daily necessity review and prompt removal when no longer needed',
      Difficulty.hard: 'bundle compliance significantly reduces CLABSI rates',
      Difficulty.rnworthy: 'teaching includes keeping the site dry and avoiding unnecessary cap manipulation',
    },
  ),
  ConceptBlueprint(
    id: 'isolation',
    label: 'Isolation precautions',
    details: {
      Difficulty.easy: 'prevent pathogen spread via airborne, droplet, or contact measures',
      Difficulty.medium: 'require cohorting appropriate patients and dedicating equipment',
      Difficulty.hard: 'airborne diseases necessitate negative pressure rooms and fit-tested respirators',
      Difficulty.rnworthy: 'teaching includes reminding families to don PPE before entering rooms',
    },
  ),
  ConceptBlueprint(
    id: 'race',
    label: 'Fire safety (RACE)',
    details: {
      Difficulty.easy: 'directs staff to Rescue, Alarm, Contain, Extinguish/Evacuate during fires',
      Difficulty.medium: 'requires keeping hallways clear for rapid evacuation',
      Difficulty.hard: 'facilities conduct drills at least annually to evaluate compliance',
      Difficulty.rnworthy: 'teaching includes PASS steps for extinguisher use',
    },
  ),
  ConceptBlueprint(
    id: 'med-reconciliation',
    label: 'Medication reconciliation',
    details: {
      Difficulty.easy: 'prevents errors when patients transition across care settings',
      Difficulty.medium: 'requires comparing home meds with current orders and resolving discrepancies',
      Difficulty.hard: 'Joint Commission mandates documentation at admission and discharge',
      Difficulty.rnworthy: 'teaching includes carrying updated medication lists to appointments',
    },
  ),
  ConceptBlueprint(
    id: 'high-alert',
    label: 'High-alert medications',
    details: {
      Difficulty.easy: 'carry heightened risk of harm if used incorrectly',
      Difficulty.medium: 'require independent double-checks before administration',
      Difficulty.hard: 'examples include insulin, heparin, and concentrated electrolytes needing safeguards',
      Difficulty.rnworthy: 'teaching stresses using smart pumps and barcode scanning consistently',
    },
  ),
  ConceptBlueprint(
    id: 'documentation',
    label: 'Documentation standards',
    details: {
      Difficulty.easy: 'provide legal records and continuity of care',
      Difficulty.medium: 'require real-time charting using objective language',
      Difficulty.hard: 'late entries must note actual time care occurred plus reason for delay',
      Difficulty.rnworthy: 'teaching includes avoiding copy-forward shortcuts that propagate errors',
    },
  ),
  ConceptBlueprint(
    id: 'cultural-competence',
    label: 'Cultural competence',
    details: {
      Difficulty.easy: 'respects beliefs influencing health decisions',
      Difficulty.medium: 'requires assessing preferred language and involving interpreters',
      Difficulty.hard: 'regulators expect individualized plans reflecting cultural practices',
      Difficulty.rnworthy: 'teaching includes asking about rituals before procedures',
    },
  ),
  ConceptBlueprint(
    id: 'patient-id',
    label: 'Patient identification',
    details: {
      Difficulty.easy: 'prevents errors by using two identifiers before care',
      Difficulty.medium: 'requires comparing wristband data with orders and asking patients to state name/DOB',
      Difficulty.hard: 'barcode scanning systems log compliance for audits',
      Difficulty.rnworthy: 'teaching includes ensuring ID bands stay intact during stay',
    },
  ),
  ConceptBlueprint(
    id: 'hourly-rounding',
    label: 'Hourly rounding',
    details: {
      Difficulty.easy: 'anticipates needs using the four Ps: pain, potty, position, possessions',
      Difficulty.medium: 'requires documenting rounds and interventions',
      Difficulty.hard: 'evidence links structured rounding to fewer falls and call lights',
      Difficulty.rnworthy: 'teaching includes explaining to patients why frequent checks occur',
    },
  ),
  ConceptBlueprint(
    id: 'incident-reporting',
    label: 'Incident reporting',
    details: {
      Difficulty.easy: 'captures adverse events or near misses for quality improvement',
      Difficulty.medium: 'requires completing reports promptly with factual language',
      Difficulty.hard: 'forms are nonpunitive and kept separate from the medical record',
      Difficulty.rnworthy: 'teaching includes notifying supervisors immediately after safety events',
    },
  ),
];

final TopicBlueprint anatomyBlueprint = TopicBlueprint(
  id: 'topic-anatomy',
  name: 'Human Anatomy',
  description: 'Fundamentals of the musculoskeletal and organ systems.',
  icon: 'assets/icons/anatomy.png',
  slug: 'human-anatomy',
  kind: TopicKind.anatomy,
  concepts: anatomyConcepts,
);

final TopicBlueprint medicationSafetyBlueprint = TopicBlueprint(
  id: 'topic-medication-safety',
  name: 'Medication Safety Drills',
  description: 'Rapid-fire pharmacology prompts that reinforce safe administration.',
  icon: 'assets/icons/pharm.png',
  slug: 'medication-safety',
  kind: TopicKind.medication,
  concepts: pharmacologyConcepts,
);

final List<TopicBlueprint> nursingBlueprints = [
  TopicBlueprint(
    id: 'topic-pharm',
    name: 'Pharmacology',
    description: 'High-yield medication cues for bedside safety.',
    icon: 'assets/icons/logo.png',
    slug: 'pharmacology',
    kind: TopicKind.medication,
    concepts: pharmacologyConcepts,
  ),
  TopicBlueprint(
    id: 'topic-med-surg',
    name: 'Medical-Surgical',
    description: 'Adult health situations across major body systems.',
    icon: 'assets/icons/logo.png',
    slug: 'medical-surgical',
    kind: TopicKind.condition,
    concepts: medSurgConcepts,
  ),
  TopicBlueprint(
    id: 'topic-pediatrics',
    name: 'Pediatrics',
    description: 'Growth, development, and common pediatric crises.',
    icon: 'assets/icons/logo.png',
    slug: 'pediatrics',
    kind: TopicKind.condition,
    concepts: pediatricsConcepts,
  ),
  TopicBlueprint(
    id: 'topic-maternal',
    name: 'Maternal-Newborn',
    description: 'Antepartum, intrapartum, and postpartum priorities.',
    icon: 'assets/icons/logo.png',
    slug: 'maternal-newborn',
    kind: TopicKind.condition,
    concepts: maternalConcepts,
  ),
  TopicBlueprint(
    id: 'topic-mental',
    name: 'Mental Health',
    description: 'Psychiatric safety, therapeutic communication, and crisis planning.',
    icon: 'assets/icons/logo.png',
    slug: 'mental-health',
    kind: TopicKind.condition,
    concepts: mentalHealthConcepts,
  ),
  TopicBlueprint(
    id: 'topic-fundamentals',
    name: 'Fundamentals',
    description: 'Core nursing foundations: delegation, infection control, and safety.',
    icon: 'assets/icons/logo.png',
    slug: 'fundamentals',
    kind: TopicKind.skill,
    concepts: fundamentalsConcepts,
  ),
];
