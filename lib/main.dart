import 'package:first_flutter/repositories/contact_repository.dart';
import 'package:first_flutter/ui/setting_page.dart';
import 'package:first_flutter/ui/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'ui/home_page.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('contactsBox');
  await Hive.openBox('settingsBox'); // <-- tambahkan ini
  await ContactRepository.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ThemeNotifier themeNotifier = ThemeNotifier();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: themeNotifier,
      builder: (context, ThemeMode currentMode, _) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: currentMode,
          debugShowCheckedModeBanner: false,
          home: MainPage(themeNotifier: themeNotifier),
        );
      },
    );
  }
}

class MainPage extends StatelessWidget {
  final ThemeNotifier themeNotifier;

  const MainPage({super.key, required this.themeNotifier});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: TabBarView(
          children: [
            const MyHomePage(title: 'My Contacts'),
            const Center(child: Text('Favorites page placeholder')),
            MySettingPage(
              title: 'Settings',
              themeNotifier: themeNotifier, // <-- kirim ke Settings
            ),
          ],
        ),
        bottomNavigationBar: Container(
          color: Theme.of(context).primaryColor,
          child: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Home'),
              Tab(icon: Icon(Icons.image), text: 'Images'),
              Tab(icon: Icon(Icons.settings), text: 'Settings'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
