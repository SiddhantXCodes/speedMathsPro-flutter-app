import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prog = Provider.of<ProgressProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Profile & Stats')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Coins: ${prog.coins}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 12),
            Text('Highest Level Unlocked: ${prog.highestLevel}'),
            SizedBox(height: 24),
            Text('Progress charts will be here (future).'),
          ],
        ),
      ),
    );
  }
}
