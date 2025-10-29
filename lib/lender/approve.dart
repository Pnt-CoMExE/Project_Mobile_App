import 'package:flutter/material.dart';
import 'package:project_mobile_app/lender/dashboard.dart';
import 'package:project_mobile_app/lender/history.dart';

class ApproveListPage extends StatefulWidget {
  const ApproveListPage({Key? key}) : super(key: key);

  @override
  State<ApproveListPage> createState() => _ApproveListPageState();
}

class _ApproveListPageState extends State<ApproveListPage> {
  int _selectedIndex = 1;

  final List<Map<String, dynamic>> requests = [
    {
      "item": "Volleyball - 060101",
      "username": "LnwZa007",
      "borrowDate": "20/10/2025",
      "returnDate": "21/10/2025",
      "status": "pending",
      "image": "assets/images/volleyball.png",
    },
    {
      "item": "Badminton Racket - 050101",
      "username": "James",
      "borrowDate": "21/10/2025",
      "returnDate": "21/10/2025",
      "status": "pending",
      "image": "assets/images/badminton.png",
    },
  ];

  void handleAction(int index, String action) {
    final item = requests[index];
    setState(() {
      requests.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          action == "approve"
              ? "Approved ${item["item"]} for ${item["username"]}"
              : "Rejected ${item["item"]} from ${item["username"]}",
        ),
        backgroundColor: action == "approve" ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }
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
      backgroundColor: const Color(0xFFF3F4F6),

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF8E24AA),
                  Color(0xFF4A148C),
                ],
                begin: Alignment.topLeft,
                end: Alignment.topRight,
              ),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                "Approve List",
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

      body: requests.isEmpty
          ? const Center(
              child: Text(
                "No pending requests",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            req["image"],
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Item : ${req["item"]}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text("Borrower : ${req["username"]}"),
                        Text("Borrow date : ${req["borrowDate"]}"),
                        Text("Return on : ${req["returnDate"]}"),
                        const SizedBox(height: 12),

                        // ปุ่ม APPROVE / REJECT
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              onPressed: () => handleAction(index, "approve"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "APPROVE",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => handleAction(index, "reject"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "REJECT",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
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
    );
  }
}
