import 'package:flutter/material.dart';

/// Placeholder shell. Step 2.6 replaces it with the bootstrap flow (runtime
/// config, theme, locales, router), and its temporary text with ARB copy.
class StaysApp extends StatelessWidget {
  const StaysApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('stays'))),
    );
  }
}
