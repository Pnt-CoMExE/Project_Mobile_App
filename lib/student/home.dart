//home.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'history.dart';
import 'request.dart';
import 'package:project_mobile_app/config/ip.dart';

// [TODO] แก้ไข IP Address ให้ตรงกับ Server ของคุณ
String _apiBaseUrl = kSportApiBaseUrl;
String _imageBaseUrl = kImageBaseUrl;

// =======================================
// Data Models (เหมือนเดิม)
// =======================================
class SportCategory {
  final int categoryId;
  final String name;
  final String image;
  final int availableCount;
  final String status;

  SportCategory({
    required this.categoryId,
    required this.name,
    required this.image,
    required this.availableCount,
    required this.status,
  });

  factory SportCategory.fromJson(Map<String, dynamic> json) {
    return SportCategory(
      categoryId: int.parse(json['category_id'].toString()),
      name: json['category_name'],
      image: json['category_image'],
      // [FIX] แก้ไขกรณี available_count เป็น null (ถ้า GROUP BY ไม่มีแถว)
      availableCount: int.parse(json['available_count']?.toString() ?? '0'),
      status: json['category_status'],
    );
  }
}

class SportItem {
  final String itemId;
  final int categoryId;
  final String name;
  final String image;
  final String status;

  SportItem({
    required this.itemId,
    required this.categoryId,
    required this.name,
    required this.image,
    required this.status,
  });

  factory SportItem.fromJson(Map<String, dynamic> json) {
    return SportItem(
      itemId: json['item_id'],
      categoryId: int.parse(json['category_id'].toString()),
      name: json['item_name'],
      image: json['item_image'],
      status: json['status'],
    );
  }
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
  bool _isLoading = true;
  String? _username;
  int? _studentId;
  List<SportCategory> _categories = [];
  List<SportItem> _items = [];
  SportCategory? _selectedCategory;
  int? _hoveredCategoryIndex;
  int? _hoveredItemIndex;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _fetchUserData();
    if ((_studentId ?? 0) != 0) {
      await _fetchCategories();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('u_username') ?? 'Guest';
      _studentId = prefs.getInt('u_id') ?? 0;
    });
    if (_studentId == 0) {
      _showErrorSnackBar("User ID not found. Please re-login.");
      setState(() => _isLoading = false);
    }
  }

  // [FIX] แก้ไข URL ให้ส่ง ?studentId=...
  Future<void> _fetchCategories() async {
    if (_studentId == 0) return; // ป้องกันการเรียก API ถ้า studentId ไม่มี
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/categories?studentId=$_studentId'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        setState(() {
          _categories = data
              .map((item) => SportCategory.fromJson(item))
              .toList();
        });
      } else {
        final data = json.decode(response.body);
        _showErrorSnackBar('Failed to load categories: ${data['message']}');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  // [FIX] แก้ไข URL ให้ส่ง ?studentId=...
  Future<void> _fetchItemsForCategory(SportCategory category) async {
    if (_studentId == 0) return;
    setState(() {
      _isLoading = true;
      _selectedCategory = category;
    });
    try {
      final response = await http.get(
        Uri.parse(
          '$_apiBaseUrl/items/${category.categoryId}?studentId=$_studentId',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        setState(() {
          _items = data.map((item) => SportItem.fromJson(item)).toList();
        });
      } else {
        final data = json.decode(response.body);
        _showErrorSnackBar('Failed to load items: ${data['message']}');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    }
    setState(() => _isLoading = false);
  }

  // ... (โค้ดส่วนที่เหลือทั้งหมดเหมือนเดิม) ...
  // ... ( _createBorrowRequest, _calculateReturnDate, _showErrorSnackBar, _onBackToCategories, _onBottomNavTapped, ... )
  // ... ( _showLogoutConfirmDialog, _showBorrowDialog, build, _buildHeader, _buildCategoryList, _buildItemList, _buildLegend, _dot, _getCategoryColor )

  // (ฟังก์ชันที่เหลือคัดลอกมาจากโค้ดเดิมที่คุณมี)

  Future<void> _createBorrowRequest(String itemId, String returnDateStr) async {
    if (_studentId == 0) {
      _showErrorSnackBar("Invalid user. Please log in again.");
      return;
    }

    final returnDate = _calculateReturnDate(returnDateStr);
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/borrow/request'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'student_id': _studentId,
          'item_id': itemId,
          'return_date': returnDate,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Borrow request submitted!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RequestPage()),
        );
        _onBackToCategories();
      } else {
        final data = json.decode(response.body);
        _showErrorSnackBar('Error: ${data['message']}');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    }
    setState(() => _isLoading = false);
  }

  String _calculateReturnDate(String selection) {
    DateTime now = DateTime.now();
    DateTime returnDate;
    switch (selection) {
      case 'Today':
        returnDate = now;
        break;
      case 'Tomorrow':
      default:
        returnDate = now.add(const Duration(days: 1));
        break;
    }
    return returnDate.toIso8601String().split('T')[0];
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _onBackToCategories() {
    setState(() {
      _selectedCategory = null;
      _items = [];
      _fetchCategories();
    });
  }

  void _onBottomNavTapped(int index) {
    if (index == 0) {
      setState(() {
        _selectedIndex = index;
        _onBackToCategories();
      });
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RequestPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const History()),
      );
    }
  }

  Future<void> _showLogoutConfirmDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Logout Confirm',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.deepPurple[700],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Are you sure to Logout',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.black54,
                  size: 50,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

 void _showBorrowDialog(SportItem item) {
  String selectedDay = 'Tomorrow';

  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Borrow: ${item.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Choose return day:'),
              const SizedBox(height: 8),

              // ⭐ เปลี่ยนจาก Dropdown เป็น Radio
              RadioListTile<String>(
                title: const Text('Today'),
                value: 'Today',
                groupValue: selectedDay,
                onChanged: (v) {
                  setDialogState(() => selectedDay = v!);
                },
              ),
              RadioListTile<String>(
                title: const Text('Tomorrow'),
                value: 'Tomorrow',
                groupValue: selectedDay,
                onChanged: (v) {
                  setDialogState(() => selectedDay = v!);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _createBorrowRequest(item.itemId, selectedDay);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    bool showItemList = (_selectedCategory != null);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Column(
        children: [
          _buildHeader(showItemList),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isLoading
                  ? const Center(
                      key: ValueKey('loading'),
                      child: CircularProgressIndicator(),
                    )
                  : showItemList
                  ? _buildItemList(key: const ValueKey('items'))
                  : _buildCategoryList(key: const ValueKey('categories')),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          bottom: true,
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onBottomNavTapped,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_outlined),
                label: 'Requests',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                label: 'History',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool showItemList) {
    return Container(
      color: Colors.deepPurple,
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (showItemList)
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: _onBackToCategories,
                    )
                  else
                    const Icon(Icons.home, color: Colors.white, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    showItemList
                        ? _selectedCategory?.name ?? 'Items'
                        : "Welcome !!, ${_username ?? 'Guest'}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: _showLogoutConfirmDialog,
                tooltip: 'Logout',
                hoverColor: Colors.white.withOpacity(0.25),
                splashRadius: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList({Key? key}) {
    if (_categories.isEmpty) {
      return const Center(
        key: ValueKey('empty'),
        child: Text('No sport categories found.'),
      );
    }

    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What’s sport do you play??",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          _buildLegend(),
          const SizedBox(height: 20),
          Column(
            children: _categories.asMap().entries.map((entry) {
              int index = entry.key;
              SportCategory category = entry.value;

              // [FIX] Logic การกดปุ่มเปลี่ยนไปตามสถานะใหม่
              final bool isClickable =
                  category.status == 'Available' ||
                  category.status == 'Pending';
              final bool isHovered = _hoveredCategoryIndex == index;

              return MouseRegion(
                cursor: isClickable
                    ? SystemMouseCursors.click
                    : SystemMouseCursors.basic,
                onEnter: (_) {
                  if (isClickable)
                    setState(() => _hoveredCategoryIndex = index);
                },
                onExit: (_) {
                  if (isClickable) setState(() => _hoveredCategoryIndex = null);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  transform: isHovered
                      ? (Matrix4.identity()..scale(1.03))
                      : Matrix4.identity(),
                  transformAlignment: Alignment.center,
                  child: Card(
                    elevation: isHovered ? 8.0 : 3.0,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: isClickable
                          ? () => _fetchItemsForCategory(category)
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                _imageBaseUrl + category.image,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    width: 45,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        category.availableCount.toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: _getCategoryColor(category.status),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              child: Text(
                                category.status,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildItemList({Key? key}) {
  if (_items.isEmpty) {
    return const Center(
      key: ValueKey('empty_items'),
      child: Text('No items available in this category.'),
    );
  }

  return ListView.builder(
    key: key,
    padding: const EdgeInsets.all(12),
    itemCount: _items.length,
    itemBuilder: (context, i) {
      final item = _items[i];

      // กดได้เฉพาะ Available (สถานะอื่นยังโชว์ตาม DB เหมือนเดิม)
      final bool isClickable = item.status == 'Available';
      final bool isMyPending = item.status == 'Pending';
      final bool isHovered = _hoveredItemIndex == i;

      return MouseRegion(
        cursor: isClickable ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) {
          if (isClickable) setState(() => _hoveredItemIndex = i);
        },
        onExit:   (_) {
          if (isClickable) setState(() => _hoveredItemIndex = null);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: (isHovered && isClickable)
              ? (Matrix4.identity()..scale(1.03))
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          child: Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: isHovered ? 6 : 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              // ✅ กดได้ทั้งบาร์
              onTap: isClickable ? () => _showBorrowDialog(item) : null,
              hoverColor: Colors.black.withOpacity(0.03),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                color: const Color(0xFFF4F1F7), // โทนเทา-ม่วงอ่อนเหมือนภาพตัวอย่าง
                child: Row(
                  children: [
                    // รูป
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        _imageBaseUrl + item.image,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // ชื่อไอเท็ม
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    // ป้ายสถานะ (ยังอ่านจาก DB เหมือนเดิม)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(item.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.status,
                        style: TextStyle(
                          color: isMyPending ? Colors.black87 : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

  Widget _buildLegend() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        const Text(
          "Sports Item status.",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 5),
      Text(text, style: const TextStyle(fontSize: 13)),
    ],
  );

  Color _getCategoryColor(String status) {
    switch (status) {
      case 'Available':
        return Colors.green;
      case 'Disable':
        return Colors.red;
      case 'Pending':
        return Colors.yellow.shade700;
      case 'Borrowed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}