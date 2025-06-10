import 'package:first_flutter/ui/theme_notifier.dart';
import 'package:flutter/material.dart';

class MySettingPage extends StatelessWidget {
  final String title;
  final ThemeNotifier themeNotifier;

  const MySettingPage({super.key, required this.title, required this.themeNotifier});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.surface
          : Theme.of(context).colorScheme.primary,
         title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: themeNotifier.isDarkMode,
              onChanged: (value) {
                themeNotifier.toggleTheme(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
