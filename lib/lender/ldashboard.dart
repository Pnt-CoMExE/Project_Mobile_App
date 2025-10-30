import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Make sure you ran 'flutter pub get' for this
import 'package:shared_preferences/shared_preferences.dart'; // For Logout

// [IMPORTANT] Import the other pages as "content"
import 'approve.dart';
import 'history.dart';

// This is the "Main" (Wrapper) page for Lender
// It controls the BottomNavBar and IndexedStack
class Ldashboard extends StatefulWidget {
  const Ldashboard({super.key});

  @override
  State<Ldashboard> createState() => _LdashboardState();
}

class _LdashboardState extends State<Ldashboard> {
  int _selectedIndex = 0; // 0: Dashboard, 1: Approve, 2: History

  // [MODIFIED] Create a list of "content" pages to display
  final List<Widget> _widgetOptions = <Widget>[
    const _DashboardContent(), // 0: The graph content (defined below)
    const Approve(), // 1: Content from approve.dart
    const History(), // 2: Content from history.dart
  ];

  // [MODIFIED] Correct Logout function
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Text(
            'Are you sure to Logout',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 52,
                color: Colors.grey[700],
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.white, size: 20),
              label: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              onPressed: () async {
                // 1. Clear Token
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear(); // Clear token, role

                // 2. Close Dialog
                if (mounted) Navigator.of(dialogContext).pop();

                // 3. Go back to Login page
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login', // Go back to Login (from student/main.dart)
                    (Route<dynamic> route) => false, // Clear all old pages
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // [MODIFIED] Function to switch tabs
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // [MODIFIED] Helper for dynamic AppBar title
  String get _appBarTitle {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Approve List';
      case 2:
        return 'History';
      default:
        return 'Lender';
    }
  }

  // [MODIFIED] Helper for dynamic AppBar icon
  IconData get _appBarIcon {
    switch (_selectedIndex) {
      case 0:
        return Icons.wifi_tethering;
      case 1:
        return Icons.grid_view_rounded;
      case 2:
        return Icons.calendar_today;
      default:
        return Icons.shield;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // [ADDED] Added background color from approve.dart
      backgroundColor: const Color(0xFFF3F4F6),

      //🔹 AppBar สีม่วงเข้ม
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8E24AA), Color(0xFF4A148C)],
                begin: Alignment.topLeft,
                end: Alignment.topRight,
              ),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              // [FIX] Title color
              title: Text(
                _appBarTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: Icon(_appBarIcon, color: Colors.white), // Dynamic icon
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: _showLogoutDialog, // [FIX] Call correct logout
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // 🔹 BottomNavigationBar
      // [FIX] Wrapped in SafeArea to fix bottom overflow
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 60, // ลดความสูง
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8E24AA), Color(0xFF4A148C)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped, // [FIX] Call tab switch function
              items: const [
                BottomNavigationBarItem(
                  icon: Center(child: Icon(Icons.wifi_tethering)),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Center(child: Icon(Icons.grid_view_rounded)),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Center(child: Icon(Icons.calendar_today)),
                  label: '',
                ),
              ],
            ),
          ),
        ),
      ),

      // [MODIFIED] Use IndexedStack to switch "content"
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
    );
  }
}

// ==========================================================
// Dashboard Content (The content for Tab 0)
// Your original dashboard UI (graph, etc.) is moved here
// ==========================================================
class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // === donut chart card ===
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 180,
                  child: Stack(
                    children: [
                      PieChart(
                        PieChartData(
                          centerSpaceRadius: 35,
                          sectionsSpace: 2,
                          sections: [
                            PieChartSectionData(
                              color: Colors.green,
                              value: 17,
                              title: '',
                            ),
                            PieChartSectionData(
                              color: Colors.red,
                              value: 9,
                              title: '',
                            ),
                            PieChartSectionData(
                              color: Colors.yellow,
                              value: 10,
                              title: '',
                            ),
                            PieChartSectionData(
                              color: Colors.blue,
                              value: 7,
                              title: '',
                            ),
                          ],
                        ),
                      ),
                      Positioned(top: 10, left: 25, child: _numberBox("17")),
                      Positioned(top: 15, right: 40, child: _numberBox("9")),
                      Positioned(
                        bottom: 25,
                        right: 40,
                        child: _numberBox("10"),
                      ),
                      Positioned(bottom: 30, left: 25, child: _numberBox("7")),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // === legend section ===
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    LegendItem(color: Colors.green, text: "Available :"),
                    LegendItem(color: Colors.red, text: "Not Available :"),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    LegendItem(color: Colors.yellow, text: "Pending :"),
                    LegendItem(color: Colors.blue, text: "Borrowed :"),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // === item list today card ===
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Item list Today",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [const Text("All items :"), _numberBox("7")],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [const Text("All Items count :"), _numberBox("43")],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _numberBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black38),
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}

// --- Helpers ---
class LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const LegendItem({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 15, height: 15, color: color),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
