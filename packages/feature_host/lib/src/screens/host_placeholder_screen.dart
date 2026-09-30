import 'package:flutter/material.dart';

/// TEMPORARY: an empty screen with a title and a back button, so the last
/// action on a listing (bookings) already leads somewhere. It is replaced by the
/// real screen in step 7.5, and this file is deleted with it.
class HostPlaceholderScreen extends StatelessWidget {
  const HostPlaceholderScreen({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(title)));
  }
}
