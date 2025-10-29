import 'package:flutter/material.dart';
import 'package:project_mobile_app/lender/approve.dart';
import 'package:project_mobile_app/lender/ldashboard.dart';

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  State<History> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<History> {
  int _selectedIndex = 2;

  final List<Map<String, String>> historyList = const [
    {
      "title": "Volleyball",
      "item": "Item : Volleyball",
      "borrowed": "Date Borrowed : 20 Oct 2568",
      "returned": "Date Returned : 21 Oct 2568",
      "id": "Item ID : 0601",
      "student": "Student : LnwZa007",
      "image": "assets/images/volleyball.png",
    },
    {
      "title": "Badminton",
      "item": "Item : Badminton Racket",
      "borrowed": "Date Borrowed : 21 Oct 2568",
      "returned": "Date Returned : 21 Oct 2568",
      "id": "Item ID : 0501",
      "student": "Student : LnwZa007",
      "image": "assets/images/badminton.png",
    },
  ];

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
                "SPORT EQUIPMENT BORROWING",

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

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: historyList.length,
        itemBuilder: (context, index) {
          final item = historyList[index];
          return Card(
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      item["image"]!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item["title"]!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(item["item"]!),
                        Text(item["borrowed"]!),
                        Text(item["returned"]!),
                        Text(item["id"]!),
                        Text(item["student"]!),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),

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
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });

              late Widget nextPage;

              if (index == 0) {
                nextPage = const Ldashboard();
              } else if (index == 1) {
                nextPage = const Approve();
              } else if (index == 2) {
                nextPage = const History();
              }

              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => nextPage,
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                  transitionsBuilder: (_, __, ___, child) => child,
                ),
              );
            },
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
    );
  }
}
