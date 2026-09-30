import 'package:flutter/material.dart';

/// TEMPORARY: an empty screen with a title and a back button, so the remaining
/// actions on a listing already lead somewhere. Each is replaced by its real
/// screen in steps 7.3 (edit), 7.4 (calendar) and 7.5 (bookings), and this file
/// is deleted with the last of them.
class HostPlaceholderScreen extends StatelessWidget {
  const HostPlaceholderScreen({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(title)));
  }
}
