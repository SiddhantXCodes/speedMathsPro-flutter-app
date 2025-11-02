import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import 'level_select_screen.dart';
import 'tricks_vault_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final prog = Provider.of<ProgressProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Speed Maths')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: Text('Coins: ${prog.coins}'),
                subtitle: Text('Highest Level: ${prog.highestLevel}'),
                trailing: Icon(Icons.account_balance_wallet),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              icon: Icon(Icons.play_arrow),
              label: Text('Start / Continue'),
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => LevelSelectionScreen())),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              icon: Icon(Icons.lightbulb),
              label: Text('Tricks Vault'),
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => TricksVaultScreen())),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              icon: Icon(Icons.person),
              label: Text('Profile / Stats'),
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => ProfileScreen())),
            ),
            Spacer(),
            TextButton.icon(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => SettingsScreen())),
              icon: Icon(Icons.settings),
              label: Text('Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
