import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera/camera.dart';
import 'services/classifier_service.dart';

import 'dashboard_page.dart';
import 'scan_page.dart';
import 'history_page.dart';
import 'locations_page.dart';
import 'onboarding_page.dart';

late List<CameraDescription> cameras;

final ClassifierService classifierService = ClassifierService();

final GlobalKey<_MainPageState> mainPageKey = GlobalKey<_MainPageState>();

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize cameras
  cameras = await availableCameras();

  // Preload the model
  await classifierService.initialize();

  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding =  false;
  //prefs.getBool('hasSeenOnboarding') ??

  runApp(IDRenewApp(showOnboarding: !hasSeenOnboarding));
}

class IDRenewApp extends StatelessWidget {
  final bool showOnboarding;
  const IDRenewApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IDRenew',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(),
        primaryColor: const Color(0xFF10B981),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: showOnboarding
          ? const OnboardingPage()
          : MainPage(key: mainPageKey),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    ScanPage(),
    HistoryPage(),
    LocationsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void navigateTo(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF10B981),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner), label: "Scan"),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(
              icon: Icon(Icons.location_on), label: "Locations"),
        ],
      ),
    );
  }
}