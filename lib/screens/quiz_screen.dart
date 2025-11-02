import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/level_model.dart';
import '../providers/quiz_provider.dart';
import '../providers/progress_provider.dart';
import 'result_screen.dart';
import '../widgets/question_widget.dart';

class QuizScreen extends StatefulWidget {
  final Level level;
  const QuizScreen({required this.level, Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  void initState() {
    super.initState();
    // Delay to ensure Provider is ready before using context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuizProvider>(context, listen: false).startQuiz(widget.level);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Level ${widget.level.levelNumber}'),
        centerTitle: true,
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quiz, _) {
          if (quiz.questions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // ✅ Navigate to result when quiz completes
          // replace the old navigation block with this
          if (quiz.isCompleted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // unlock next level (optional)
              final prog = Provider.of<ProgressProvider>(
                context,
                listen: false,
              );
              prog.unlockNextLevel(widget.level.levelNumber, quiz.coinsEarned);

              // PASS the real values directly into ResultScreen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => ResultScreen(
                    level: widget.level,
                    score: quiz.score, // points (e.g. 70)
                    totalQuestions:
                        quiz.questions.length, // number of questions (e.g. 10)
                    coinsEarned: quiz.coinsEarned, // coins
                  ),
                ),
              );
            });
            return const Center(child: Text('Finishing...'));
          }

          final q = quiz.currentQuestion;

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: (quiz.currentIndex + 1) / quiz.questions.length,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Q ${quiz.currentIndex + 1}/${quiz.questions.length}'),
                    Text('Time: ${quiz.timeLeft}s'),
                  ],
                ),
                const SizedBox(height: 12),

                // ✅ Question widget (with correct callback)
                QuestionWidget(
                  question: q,
                  onSubmit: (val) {
                    final selectedIndex = quiz.currentQuestion.options.indexOf(
                      val,
                    );
                    quiz.answerQuestion(selectedIndex);
                  },
                ),

                const SizedBox(height: 12),
                Text('Score: ${quiz.score}  |  Coins: ${quiz.coinsEarned}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
