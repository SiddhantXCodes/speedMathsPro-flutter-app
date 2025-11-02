import 'package:flutter/material.dart';

class TricksVaultScreen extends StatelessWidget {
  final List<String> tricks = [
    'Multiply near 100: 98×97 = (100-2)(100-3) => 100*(100) - 100*(2+3) + 6 = 9506',
    'Square trick: (x+1)^2 = x^2 + 2x +1. Use for quick squares.',
    'Percent trick: 15% of X = 10% of X + 5% of X.',
    'Complement trick for 99×: Use (100 - a)(100 - b) technique.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tricks Vault')),
      body: ListView.builder(
        itemCount: tricks.length,
        itemBuilder: (ctx, i) =>
            ListTile(title: Text('Tip ${i + 1}'), subtitle: Text(tricks[i])),
      ),
    );
  }
}
