// lib/features/learn_daily/learn_daily_screen.dart
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../learn_tile.dart';
import 'learn_detail_screen.dart';

class LearnDailyScreen extends StatefulWidget {
  const LearnDailyScreen({super.key});

  @override
  State<LearnDailyScreen> createState() => _LearnDailyScreenState();
}

class _LearnDailyScreenState extends State<LearnDailyScreen> {
  @override
  Widget build(BuildContext context) {
    final textColor = AppTheme.adaptiveText(context);
    final width = MediaQuery.of(context).size.width;

    final isPhone = width < 600;
    final isTablet = width >= 600 && width < 900;
    final isBigTablet = width >= 900;

    final double horizontalPad = isBigTablet ? width * 0.18 : 16;
    final double topSpacing = isPhone ? 12 : 20;

    final topics = [
      {'title': 'Tables', 'subtitle': 'Multiplication tables 1–100'},
      {'title': 'Squares', 'subtitle': 'Squares 1–100'},
      {'title': 'Cubes', 'subtitle': 'Cubes 1–100'},
      {'title': 'Square Roots', 'subtitle': '√1–100'},
      {'title': 'Cube Roots', 'subtitle': '∛1–100'},
      {
        'title': 'Percentage',
        'subtitle': 'Quick percent tricks & improvements',
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Revise Daily'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.adaptiveAccent(context),
      ),

      // Removed RefreshIndicator because it creates pending pull UI
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: topSpacing),

            /// Header Title
            Text(
              'Daily revision & quick learning',
              style: TextStyle(
                color: textColor.withOpacity(0.85),
                fontSize: isPhone ? 14 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            /// Animated Divider
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: 3,
              width: 60,
              decoration: BoxDecoration(
                color: AppTheme.adaptiveAccent(context).withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 20),

            /// Topic List
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: topics.length,
                itemBuilder: (context, index) {
                  final t = topics[index];

                  return Padding(
                    padding: EdgeInsets.only(bottom: isPhone ? 14 : 20),
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                LearnDetailScreen(topic: t['title']!),
                          ),
                        );
                        setState(() {});
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            /// Icon Bubble
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.adaptiveAccent(
                                  context,
                                ).withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.menu_book_rounded,
                                color: AppTheme.adaptiveAccent(
                                  context,
                                ).withOpacity(0.8),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 16),

                            /// Texts
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t['title']!,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: isPhone ? 16 : 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    t['subtitle']!,
                                    style: TextStyle(
                                      color: textColor.withOpacity(0.65),
                                      fontSize: isPhone ? 13 : 14,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 18,
                              color: textColor.withOpacity(0.6),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
