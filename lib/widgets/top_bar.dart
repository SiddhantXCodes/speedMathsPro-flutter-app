import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final bool isDarkMode;
  final int userStreak;
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleToday;

  const TopBar({
    super.key,
    required this.isDarkMode,
    required this.userStreak,
    required this.onToggleTheme,
    required this.onToggleToday,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'SpeedMath',
        style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
      ),
      actions: [
        // Theme toggle (left-most)
        IconButton(
          icon: Icon(
            isDarkMode ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded,
            color: isDarkMode ? Colors.amber : Colors.black87,
          ),
          onPressed: onToggleTheme,
        ),

        // Streak + count
        GestureDetector(
          onTap: onToggleToday,
          child: Row(
            children: [
              Container(
                width: 20,
                height: 40,
                alignment: Alignment.center,

                child: Icon(
                  Icons.local_fire_department,
                  size: 25,
                  color: userStreak > 0
                      ? const Color.fromARGB(255, 255, 107, 66)
                      : Colors.grey,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '$userStreak',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: userStreak > 0
                      ? const Color.fromARGB(255, 255, 102, 64)
                      : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        // Elf icon / avatar image (right-most)
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: CircleAvatar(
            radius: 17,
            backgroundColor: Colors.transparent,
            backgroundImage: const AssetImage(
              'assets/images/elf_icon.png', // <-- your uploaded image
            ),
          ),
        ),
      ],
    );
  }
}
