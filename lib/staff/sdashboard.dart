import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Sdashboard extends StatefulWidget {
  const Sdashboard({super.key});

  @override
  State<Sdashboard> createState() => _SdashboardState();
}

class _SdashboardState extends State<Sdashboard> {
  int _selectedIndex = 0; // 0: network, 1: home(equipment)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient AppBar
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
              title: const Text("Dashboard"),
              backgroundColor: Colors.transparent,
              elevation: 0,
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

      // Gradient BottomNavigationBar
      bottomNavigationBar: Container(
        height: 60,
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
          child: Theme(
            data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              currentIndex: _selectedIndex,
              onTap: (index) {
                if (index == 1) {
                  Navigator.pushReplacementNamed(context, '/equipment');
                  return;
                }
                if (index == 2) {
                  Navigator.pushReplacementNamed(context, '/return');
                  return;
                } //
                if (index == 3) {
                  Navigator.pushReplacementNamed(context, '/history');
                  return;
                }
                setState(() => _selectedIndex = index);
              },

              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.wifi_tethering),
                  label: '',
                ),
                BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
                BottomNavigationBarItem(
                  icon: Icon(Icons.access_time_filled),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today),
                  label: '',
                ),
              ],
            ),
          ),
        ),
      ),

      // Dashboard Content
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

            // === Item list today ===
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
