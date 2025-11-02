import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        padding: EdgeInsets.all(12),
        children: [
          ListTile(
            title: Text('Sound'),
            trailing: Switch(value: true, onChanged: (v) {}),
          ),
          ListTile(
            title: Text('Dark Mode (coming soon)'),
            trailing: Switch(value: false, onChanged: (v) {}),
          ),
          ListTile(
            title: Text('Clear Progress'),
            onTap: () {
              // implement if needed
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Not implemented'),
                  content: Text('You can add clear progress logic here.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
