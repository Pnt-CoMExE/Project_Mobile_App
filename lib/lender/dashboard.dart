import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:project_mobile_app/lender/approve.dart';
import 'package:project_mobile_app/lender/history.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    late Widget nextPage;
    late String routeName;

    if (index == 0) {
      nextPage = const DashboardPage();
      routeName = '/dashboard';
    } else if (index == 1) {
      nextPage = const ApproveListPage();
      routeName = '/approve';
    } else if (index == 2) {
      nextPage = const HistoryPage();
       routeName = '/history';
    }
      Navigator.pushReplacement(
    context,
    PageRouteBuilder(
      settings: RouteSettings(name: routeName),
      pageBuilder: (_, __, ___) => nextPage,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      transitionsBuilder: (_, __, ___, child) => child, 
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //🔹 AppBar สีม่วงเข้ม
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          // ✅ ป้องกันล้นขอบบน
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
              title: const Text(
                "Dashboard",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // 🔹 BottomNavigationBar
      bottomNavigationBar: Container(
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
            onTap: _onItemTapped,
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

      // 🔹 เนื้อหาในหน้า
      body: SingleChildScrollView(
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
                        Positioned(
                          bottom: 30,
                          left: 25,
                          child: _numberBox("7"),
                        ),
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
                    children: [
                      const Text("All Items count :"),
                      _numberBox("43"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
