import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/level_provider.dart';
import 'quiz_screen.dart';
import '../models/level_model.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final levelProvider = Provider.of<LevelProvider>(context);
    final levels = levelProvider.levels;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🏆 Speed Maths Levels',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: levels.length,
        itemBuilder: (context, index) {
          final Level level = levels[index];
          final bool canPlay = levelProvider.canPlayLevel(level.levelNumber);

          return GestureDetector(
            onTap: canPlay
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizScreen(level: level),
                      ),
                    );
                  }
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: canPlay
                    ? (level.isCompleted
                          ? Colors.greenAccent.shade700
                          : Colors.blueAccent)
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          level.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          level.difficulty,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (level.bestScore > 0)
                          Text(
                            'Best: ${level.bestScore}/${level.totalQuestions}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!canPlay)
                    const Positioned(
                      right: 8,
                      top: 8,
                      child: Icon(Icons.lock, color: Colors.white, size: 22),
                    ),
                  if (level.isCompleted)
                    const Positioned(
                      right: 8,
                      top: 8,
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
