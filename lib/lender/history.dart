import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int _selectedIndex = 0;

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
      backgroundColor: const Color(0xFFF3F4F6),

      // 🔹 AppBar สีม่วง พร้อมปุ่ม Logout ด้านขวา
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF8E24AA),
        centerTitle: true,
        title: const Text(
          "SPORT EQUIPMENT\nBORROWING",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            height: 1.2,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () {
                // ✅ เมื่อกด Logout -> กลับไปหน้า Login
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ),
        ],
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
            colors: [
              Color(0xFF8E24AA),
              Color(0xFF4A148C),
            ],
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

              if (index == 0) {
                Navigator.pushReplacementNamed(context, '/dashboard');
              } else if (index == 1) {
                Navigator.pushReplacementNamed(context, '/approve');
              } else if (index == 2) {
                Navigator.pushReplacementNamed(context, '/history');
              }
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
