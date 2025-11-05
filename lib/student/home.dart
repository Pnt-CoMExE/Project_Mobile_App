import 'package:flutter/material.dart';
import 'package:project_mobile_app/lender/history.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'request.dart';
import 'history.dart';

// =======================================
// Enum และ Model
// =======================================
enum ItemStatus { available, disable, borrowed, pending }

class SportItem {
  final String name;
  final String image;
  final int quantity;
  final ItemStatus status;
  final List<Map<String, dynamic>>? subItems;

  SportItem({
    required this.name,
    required this.image,
    required this.quantity,
    required this.status,
    this.subItems,
  });
}

// =======================================
// Main Home Page
// =======================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool showItemList = false;
  bool showConfirmBar = false;
  String selectedCategory = '';

  late final List<SportItem> _items;

  @override
  void initState() {
    super.initState();
    _items = [
      SportItem(
        name: 'Badminton',
        image: 'assets/images/badminton.png',
        quantity: 5,
        status: ItemStatus.available,
        subItems: [
          {
            'name': 'Yonex Badminton Racket',
            'image': 'assets/images/badminton.png',
            'status': ItemStatus.available,
          },
          {
            'name': 'Yonex Badminton Racket',
            'image': 'assets/images/badminton.png',
            'status': ItemStatus.available,
          },
          {
            'name': 'Badminton Ball',
            'image': 'assets/images/shuttle.png',
            'status': ItemStatus.available,
          },
          {
            'name': 'Badminton Ball',
            'image': 'assets/images/shuttle.png',
            'status': ItemStatus.borrowed,
          },
        ],
      ),
      SportItem(
        name: 'Balls',
        image: 'assets/images/basketball.png',
        quantity: 0,
        status: ItemStatus.disable,
      ),
      SportItem(
        name: 'Tennis',
        image: 'assets/images/tennis.png',
        quantity: 6,
        status: ItemStatus.available,
      ),
    ];
  }

  Future<String> _getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? 'Guest';
  }

  Color _getColor(ItemStatus s) => {
        ItemStatus.available: Colors.green,
        ItemStatus.disable: Colors.red,
        ItemStatus.pending: Colors.yellow.shade700,
        ItemStatus.borrowed: Colors.blue,
      }[s]!;

  String _getText(ItemStatus s) => {
        ItemStatus.available: 'Available',
        ItemStatus.disable: 'Disable',
        ItemStatus.pending: 'Pending',
        ItemStatus.borrowed: 'Borrowed',
      }[s]!;

  // ===============================
  // return
  // ===============================
  void _showReturnDialog() {
    String selectedDay = 'Tomorrow';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose return day'),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedDay,
              items: const [
                DropdownMenuItem(value: 'Today', child: Text('Today')),
                DropdownMenuItem(value: 'Tomorrow', child: Text('Tomorrow')),
                DropdownMenuItem(value: 'Next Week', child: Text('Next Week')),
              ],
              onChanged: (v) => setState(() => selectedDay = v!),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => showConfirmBar = true);
                showItemList = false;
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, shape: const StadiumBorder()),
              child: const Text('OK'),
            )
          ],
        ),
      ),
    );
  }

  // ===============================
  // UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<String>(
            future: _getUsername(),
            builder: (context, snapshot) {
              final username = snapshot.data ?? '(username from database)';
              return Column(
                children: [
                  _buildHeader(username),
                  if (showConfirmBar) _buildConfirmBar(),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: showItemList
                          ? _buildItemList()
                          : _buildCategoryList(),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() => _selectedIndex = index);
            if (index == 1) {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const RequestPage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const History(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            }
          },
          backgroundColor: Colors.deepPurple,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications_outlined), label: 'Requests'),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined), label: 'History'),
          ],
        ),
      ),
    );
  }

  // ===============================
  // Header
  // ===============================
  Widget _buildHeader(String username) {
    return Container(
      color: Colors.deepPurple,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (showItemList)
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => setState(() => showItemList = false),
                )
              else
                const Icon(Icons.home, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                showItemList ? selectedCategory : "Hi !!, $username",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          GestureDetector(
  onTap: () async {
    // ล้างข้อมูลใน SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // กลับไปหน้า Login (ลบหน้าเก่าทั้งหมดออกจาก stack)
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  },
  child: const Icon(Icons.logout, color: Colors.white),
)
        ],
      ),
    );
  }

  // ===============================
  // Confirm Borrow Bar
  // ===============================
  Widget _buildConfirmBar() => Container(
        color: Colors.white,
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const Text(
              'Do you confirm borrow (item at choose before)?',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => showConfirmBar = false),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: const StadiumBorder()),
                  child: const Text('No'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() => showConfirmBar = false);
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const RequestPage(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: const StadiumBorder()),
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ],
        ),
      );

  // ===============================
  Widget _buildCategoryList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("What’s sport do you play??",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          _buildLegend(),
          const SizedBox(height: 20),
          Column(
            children: _items.map((item) {
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                child: InkWell(
                  onTap: item.status == ItemStatus.available
                      ? () {
                          setState(() {
                            showItemList = true;
                            selectedCategory = item.name;
                          });
                        }
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(item.image,
                              width: 80, height: 80, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.all(6),
                                width: 45,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Center(
                                  child: Text(item.quantity.toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: _getColor(item.status),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          child: Text(_getText(item.status),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  // ===============================
  Widget _buildItemList() {
    final category = _items.firstWhere(
        (e) => e.name == selectedCategory,
        orElse: () => _items[0]);
    final subItems = category.subItems ?? [];
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: subItems.length,
      itemBuilder: (context, i) {
        final item = subItems[i];
        final status = item['status'] as ItemStatus;
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(item['image'],
                  width: 60, height: 60, fit: BoxFit.cover),
            ),
            title: Text(item['name']),
            trailing: GestureDetector(
              onTap: status == ItemStatus.available ? _showReturnDialog : null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _getColor(status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getText(status),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ===============================
  Widget _buildLegend() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2))
            ]),
        child: Column(
          children: [
            const Text("Sports Item status.",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _dot("Available", Colors.green),
                _dot("Disable", Colors.red),
                _dot("Pending", Colors.yellow.shade700),
                _dot("Borrowed", Colors.blue),
              ],
            ),
          ],
        ),
      );

  Widget _dot(String text, Color color) => Row(
        children: [
          Container(
              width: 14,
              height: 14,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      );
}
