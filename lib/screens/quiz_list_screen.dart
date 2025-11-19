import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_constants.dart';
import '../constants/design_tokens.dart';
import '../models/question.dart';
import '../models/quiz.dart';
import '../providers/quiz_provider.dart';
import '../providers/topic_provider.dart';
import '../routes.dart';
import '../widgets/app_bar.dart';
import '../widgets/loader.dart';

class QuizListScreen extends StatefulWidget {
  const QuizListScreen({super.key, required this.topicId});

  final String topicId;

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  static const int _allDifficultyMaxQuestions = 100;

  String? _selectedDifficulty;
  int? _selectedQuestionCount;
  double? _selectedQuestionCountDouble;
  bool _includeAllDifficulties = false;

  @override
  void initState() {
    super.initState();
    final quizProvider = context.read<QuizProvider>();
    quizProvider.loadQuizzes(widget.topicId);
  }

  bool get _isNursingTopic =>
      AppConstants.nursingTopicIds.contains(widget.topicId);

  String _difficultyLabel(String slug) {
    switch (slug) {
      case 'easy':
        return 'Easy';
      case 'medium':
        return 'Medium';
      case 'hard':
        return 'Hard';
      case 'rnworthy':
        return 'RN Worthy';
      default:
        return slug
            .split(RegExp(r'[-_ ]+'))
            .map(
              (part) => part.isEmpty
                  ? part
                  : part[0].toUpperCase() + part.substring(1),
            )
            .join(' ');
    }
  }

  int _snapToStep(num value) {
    if (value < 5) return value.round();
    return ((value / 5).round() * 5).round();
  }

  List<Question> _combineAllDifficultyQuestions(List<Quiz> quizzes) {
    if (quizzes.isEmpty) return [];
    const slugPriority = ['easy', 'medium', 'hard', 'rnworthy'];
    int priorityFor(Quiz quiz) {
      final index = slugPriority.indexOf(quiz.difficultySlug);
      return index == -1 ? slugPriority.length : index;
    }

    final ordered = [...quizzes]
      ..sort(
        (a, b) {
          final cmp = priorityFor(a).compareTo(priorityFor(b));
          if (cmp != 0) return cmp;
          return a.title.compareTo(b.title);
        },
      );

    final combined = <Question>[];
    for (final quiz in ordered) {
      for (final question in quiz.questions) {
        if (combined.length >= _allDifficultyMaxQuestions) {
          break;
        }
        combined.add(question);
      }
      if (combined.length >= _allDifficultyMaxQuestions) {
        break;
      }
    }
    return combined;
  }

  void _ensureSelections(Map<String, Quiz> difficultyMap) {
    if (_selectedDifficulty == null && difficultyMap.isNotEmpty) {
      if (difficultyMap.containsKey('easy')) {
        _selectedDifficulty = 'easy';
      } else {
        _selectedDifficulty = difficultyMap.keys.first;
      }
    }
    final quiz =
        _selectedDifficulty != null ? difficultyMap[_selectedDifficulty!] : null;
    if (quiz == null) return;

    final available = quiz.questions.length;
    if (available == 0) return;

    final int maxSelectable = available > 100 ? 100 : available;
    final int minSelectable = available < 5 ? available : 5;
    if (minSelectable == 0) return;

    final int defaultCount = maxSelectable >= 10 ? 10 : maxSelectable;
    _selectedQuestionCount ??= defaultCount;
    _selectedQuestionCountDouble ??= _selectedQuestionCount!.toDouble();

    final int clamped =
        _selectedQuestionCount!.clamp(minSelectable, maxSelectable);
    if (clamped != _selectedQuestionCount) {
      final snapped =
          _snapToStep(clamped).clamp(minSelectable, maxSelectable).toInt();
      _selectedQuestionCount = snapped;
      _selectedQuestionCountDouble = snapped.toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = DesignTokens.spacing;
    final topic = context.read<TopicProvider>().findById(widget.topicId);

    return Scaffold(
      appBar: PomodoRxAppBar(
        title: topic?.name ?? 'Quizzes',
        showBack: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(spacing.s4),
        child: Consumer<QuizProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const CenteredLoader();
            }

            if (provider.quizzes.isEmpty) {
              return CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(
                    child: Center(child: Text('No quizzes yet.')),
                  ),
                ],
              );
            }

            if (!_isNursingTopic) {
              return CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final quiz = provider.quizzes[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: spacing.s2),
                          child: ListTile(
                            tileColor: DesignTokens.colors.card,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                DesignTokens.radius.rMd,
                              ),
                            ),
                            title: Text(quiz.title),
                            subtitle: Text(
                              '${quiz.questions.length} questions • '
                              '${quiz.durationMinutes ?? 0} mins',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              context.read<QuizProvider>().startQuiz(quiz);
                              Navigator.pushNamed(
                                context,
                                AppRoutes.quizPlay,
                                arguments: QuizPlayArgs(quiz: quiz),
                              );
                            },
                          ),
                        );
                      },
                      childCount: provider.quizzes.length,
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: spacing.s4)),
                ],
              );
            }

            final difficultyMap = {
              for (final quiz in provider.quizzes) quiz.difficultySlug: quiz,
            };
            _ensureSelections(difficultyMap);
            final selectedQuiz = _selectedDifficulty != null
                ? difficultyMap[_selectedDifficulty!]
                : null;

            final List<Question>? aggregatedQuestions = _includeAllDifficulties
              ? _combineAllDifficultyQuestions(provider.quizzes)
              : null;
            final usingAggregated =
                aggregatedQuestions != null && aggregatedQuestions.isNotEmpty;

            final availableQuestions = usingAggregated
              ? aggregatedQuestions.length
              : (selectedQuiz?.questions.length ?? 0);
            final int sliderMax = usingAggregated
              ? (availableQuestions > _allDifficultyMaxQuestions
                ? _allDifficultyMaxQuestions
                : availableQuestions)
              : (availableQuestions > _allDifficultyMaxQuestions
                ? _allDifficultyMaxQuestions
                : availableQuestions);
            final int minSelectable = availableQuestions < 5
              ? availableQuestions
              : 5;

            if (availableQuestions > 0) {
              final int defaultCount = usingAggregated
                ? sliderMax
                : (sliderMax >= 10 ? 10 : sliderMax);
              _selectedQuestionCount ??= defaultCount;
              _selectedQuestionCountDouble ??=
                  _selectedQuestionCount!.toDouble();
              final int clamped =
                  _selectedQuestionCount!
                      .clamp(minSelectable == 0 ? 1 : minSelectable, sliderMax);
              if (clamped != _selectedQuestionCount) {
                _selectedQuestionCount = clamped;
                _selectedQuestionCountDouble = clamped.toDouble();
              }
            }

            int? sliderDivisions;
            if (sliderMax > minSelectable && minSelectable > 0) {
              final diff = sliderMax - minSelectable;
              sliderDivisions = diff >= 5 ? (diff ~/ 5) : diff;
              if (sliderDivisions < 1) {
                sliderDivisions = 1;
              }
            }

            final displayMin = minSelectable == 0 ? 1 : minSelectable;
            final displayMax = sliderMax == 0 ? displayMin : sliderMax;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Difficulty',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: spacing.s2),
                      Wrap(
                        spacing: spacing.s2,
                        children: difficultyMap.entries.map((entry) {
                          final slug = entry.key;
                          return ChoiceChip(
                            label: Text(_difficultyLabel(slug)),
                            selected: slug == _selectedDifficulty,
                            onSelected: (_) {
                              setState(() {
                                _selectedDifficulty = slug;
                                _selectedQuestionCount = null;
                                _selectedQuestionCountDouble = null;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      SizedBox(height: spacing.s4),
                      Text(
                        'Question count ($displayMin–$displayMax)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: spacing.s2),
                      Row(
                        children: [
                          Checkbox(
                            value: _includeAllDifficulties,
                            onChanged: (val) {
                              setState(() {
                                _includeAllDifficulties = val ?? false;
                                // Reset selections when toggling to force recalculation
                                _selectedQuestionCount = null;
                                _selectedQuestionCountDouble = null;
                              });
                            },
                          ),
                          const Text('Use all difficulties'),
                        ],
                      ),
                      SizedBox(height: spacing.s1),
                      if ((selectedQuiz != null || usingAggregated) &&
                          minSelectable >= 1 &&
                          sliderMax >= minSelectable)
                        Slider(
                          value: _selectedQuestionCountDouble ??
                              (_selectedQuestionCount ?? minSelectable)
                                  .toDouble(),
                          min: minSelectable.toDouble(),
                          max: sliderMax.toDouble(),
                          divisions: sliderDivisions,
                          label:
                              '${_selectedQuestionCount ?? minSelectable} questions',
                          onChanged: (value) {
                            final snapped = _snapToStep(value)
                                .clamp(minSelectable, sliderMax)
                                .toInt();
                            setState(() {
                              _selectedQuestionCount = snapped;
                              _selectedQuestionCountDouble = value;
                            });
                          },
                        )
                      else if (availableQuestions > 0)
                        Text(
                          'This bank includes $availableQuestions questions.',
                        ),
                      if (usingAggregated)
                        Text(
                          'Aggregated bank includes $availableQuestions questions across all difficulties.',
                        )
                      else if (selectedQuiz != null)
                        Text(
                          'Available in bank: ${selectedQuiz.questions.length} questions',
                        ),
                      SizedBox(height: spacing.s4),
                      ElevatedButton.icon(
                        onPressed: availableQuestions == 0 ||
                                (_selectedQuestionCount ?? 0) == 0
                            ? null
                            : () {
                                final quizProvider =
                                    context.read<QuizProvider>();
                                final Quiz baseQuiz = usingAggregated
                                    ? Quiz(
                                        id:
                                            '${widget.topicId}-aggregated-${DateTime.now().millisecondsSinceEpoch}',
                                        topicId: widget.topicId,
                                        title:
                                            '${topic?.name ?? 'Topic'} - All Difficulties',
                                        durationMinutes:
                                            selectedQuiz?.durationMinutes ?? 0,
                                    questions: aggregatedQuestions,
                                        createdAt: DateTime.now(),
                                      )
                                    : selectedQuiz!;
                                final customQuiz =
                                    quizProvider.buildCustomQuiz(
                                  baseQuiz,
                                  _selectedQuestionCount!,
                                );
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.quizPlay,
                                  arguments: QuizPlayArgs(quiz: customQuiz),
                                );
                              },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Quiz'),
                      ),
                      SizedBox(height: spacing.s4),
                      Text(
                        'Question banks',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: spacing.s1),
                      ...difficultyMap.values.map(
                        (quiz) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(quiz.title),
                          subtitle: Text(
                            '${quiz.questions.length} questions • '
                            '${quiz.durationMinutes ?? 0} mins',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: spacing.s4)),
              ],
            );
          },
        ),
      ),
    );
  }
}
