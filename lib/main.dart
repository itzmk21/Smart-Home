import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smart_home/pages/themes_page.dart';

import 'utils/colors.dart';
import 'pages/home_page.dart';

void main() async {
  await GetStorage.init();
  runApp(const MyApp());
  customColors();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const RootPage(),
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bg,
        navigationBarTheme: NavigationBarThemeData(
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          backgroundColor: bg,
          indicatorColor: inactiveTrack,
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(color: secondaryFg, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int currentPage = 0;

  List<Widget> pages = const [
    HomePage(),
    ThemesPage(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_rounded,
              color: secondaryFg,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.color_lens_rounded,
              color: secondaryFg,
            ),
            label: 'Themes',
          ),
        ],
        onDestinationSelected: (int index) {
          setState(() {
            currentPage = index;
          });
        },
        selectedIndex: currentPage,
      ),
      body: SafeArea(
        child: pages[currentPage],
      ),
    );
  }
}
