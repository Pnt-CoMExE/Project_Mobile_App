import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'approve.dart';
import 'history.dart';

class Ldashboard extends StatefulWidget {
  const Ldashboard({super.key});

  @override
  State<Ldashboard> createState() => _LdashboardState();
}

class _LdashboardState extends State<Ldashboard> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const _DashboardContent(),
    const Approve(),
    const History(),
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Are you sure to Logout?', textAlign: TextAlign.center),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                }
              },
            ),
          ],
        );
      },
    );
  }

  String get _appBarTitle => ['Dashboard', 'Approve List', 'History'][_selectedIndex];
  IconData get _appBarIcon =>
      [Icons.wifi_tethering, Icons.grid_view_rounded, Icons.calendar_today][_selectedIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Text(_appBarTitle,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: Icon(_appBarIcon, color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: _showLogoutDialog),
        ],
        centerTitle: true,
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF8E24AA), Color(0xFF4A148C)]),
          ),
        ),
      ),
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _bottomNav() {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF8E24AA), Color(0xFF4A148C)]),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.wifi_tethering), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// 📊 Dashboard Content (Connected to API)
// ==========================================================
class _DashboardContent extends StatefulWidget {
  const _DashboardContent();

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  bool loading = true;
  int available = 0, notAvailable = 0, pending = 0, borrowed = 0;
  int totalSports = 0, totalItems = 0;

  @override
  void initState() {
    super.initState();
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    try {
      final url = Uri.parse("http://192.168.1.4:3000/api/dashboard");
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final status = data['status_summary'];

        setState(() {
          available = int.tryParse(status['available'].toString()) ?? 0;
          borrowed = int.tryParse(status['borrowed'].toString()) ?? 0;
          pending = int.tryParse(status['pending'].toString()) ?? 0;
          notAvailable = int.tryParse(status['disable'].toString()) ?? 0;

          totalSports = data['total_sports'] ?? 0;
          totalItems = data['total_items'] ?? 0;
          loading = false;
        });
      } else {
        throw Exception("Failed to load dashboard");
      }
    } catch (e) {
      print("❌ Error fetching dashboard: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ===== donut chart card =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: Column(
              children: [
                SizedBox(
                  height: 220,
                  child: PieChart(
                    PieChartData(
                      startDegreeOffset: -90,
                      sectionsSpace: 2,
                      centerSpaceRadius: 55,
                      borderData: FlBorderData(show: false),
                      sections: [
                        _buildSection(Colors.green, available, "Available"),
                        _buildSection(Colors.red, notAvailable, "Not Available"),
                        _buildSection(Colors.yellow.shade700, pending, "Pending"),
                        _buildSection(Colors.blue, borrowed, "Borrowed"),
                      ],
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 1200), // 🔄 Animation
                    swapAnimationCurve: Curves.easeOutCubic,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Column(
                    children: const [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          LegendItem(color: Colors.green, text: "Available"),
                          LegendItem(color: Colors.red, text: "Not Available"),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          LegendItem(color: Colors.yellow, text: "Pending"),
                          LegendItem(color: Colors.blue, text: "Borrowed"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ===== item list today card =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Item Stock Today",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                _infoRow("Total Sports :", totalSports.toString()),
                const SizedBox(height: 8),
                _infoRow("Total Items Stock :", totalItems.toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(2, 2))
        ],
      );

  Widget _infoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.black38),
          ),
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // ✅ ฟังก์ชันสร้าง section ของกราฟ (สีตามสถานะ + animation)
  PieChartSectionData _buildSection(Color color, int value, String label) {
    return PieChartSectionData(
      color: color,
      value: value.toDouble(),
      radius: 50,
      showTitle: false,
      badgeWidget: value > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color, // กล่องสีตามสถานะ
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(1, 2))
                ],
              ),
              child: Text(
                value.toString(),
                style: const TextStyle(
                  color: Colors.white, // ตัวอักษรขาว
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            )
          : null,
      badgePositionPercentageOffset: 1.3,
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const LegendItem({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }
}