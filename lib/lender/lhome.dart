// --- START OF lib/lender/lhome.dart ---
// (กรุณาลบโค้ดเก่าใน lhome.dart ทั้งหมด แล้ววางโค้ดนี้แทน)
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // For Dashboard charts
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_mobile_app/config/api_config.dart';
import 'approve.dart';
import 'history.dart';
import 'ldashboard.dart'; // [FIX] Import ldashboard

// [FIX] กำหนด URL จาก Config (ต้องมี http://)
const String _apiBaseUrl = 'http://${ApiConfig.baseUrl}/api/sport';
const String _imageBaseUrl = 'http://${ApiConfig.baseUrl}/';
// const String _dashboardApiUrl = 'http://${ApiConfig.baseUrl}/api/dashboard'; // (ย้ายไป ldashboard.dart)

// ==========================================================
// 🚀 LENDER HOME PAGE (MAIN CONTAINER + TAB 1)
// ==========================================================
class LhomePage extends StatefulWidget {
  const LhomePage({super.key});

  @override
  State<LhomePage> createState() => _LhomePageState();
}

class _LhomePageState extends State<LhomePage> {
  int _selectedIndex = 0;

  // [FIX] อัปเดต List ของ "ไส้ใน"
  final List<Widget> _widgetOptions = <Widget>[
    const _EquipmentListPage(), // 1. หน้ารายการอุปกรณ์ (อยู่ในไฟล์นี้)
    const LdashboardContent(), // 2. หน้ากราฟ (จาก ldashboard.dart)
    const ApprovePage(), // 3. หน้า Approve (จาก approve.dart)
    const History(), // 4. หน้า History (จาก history.dart)
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Are you sure to Logout?',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (_) => false,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // [FIX] อัปเดต Title และ Icon
  String get _appBarTitle =>
      ['Equipment', 'Dashboard', 'Approve List', 'History'][_selectedIndex];
  IconData get _appBarIcon => [
    Icons.list_alt_rounded, // 1. Equipment
    Icons.pie_chart_rounded, // 2. Dashboard
    Icons.notifications_rounded, // 3. Approve
    Icons.history_rounded, // 4. History
  ][_selectedIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Text(
          _appBarTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Icon(_appBarIcon, color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _showLogoutDialog,
          ),
        ],
        centerTitle: true,
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8E24AA), Color(0xFF4A148C)],
            ),
          ),
        ),
      ),
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: _bottomNav(),
    );
  }

  // [!!!] นี่คือ Bottom Nav ที่แก้ไขแล้ว [!!!]
  Widget _bottomNav() {
    // [FIX 1] นำ Container กลับมาเพื่อให้มีสีม่วง Gradient
    // [FIX 2] ลบ height: 60 ออกเพื่อแก้ปัญหา Overflow
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8E24AA), Color(0xFF4A148C)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        // ใช้ ClipRRect เพื่อให้ขอบมน
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent, // [สำคัญ] ต้องโปร่งใส
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_outlined),
              activeIcon: Icon(Icons.list_alt_rounded),
              label: 'Equipment',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart_outline),
              activeIcon: Icon(Icons.pie_chart_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications_rounded),
              label: 'Requests',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history_rounded),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// 📦 TAB 1: EQUIPMENT LIST PAGE (ไส้ในของแท็บ Home)
// (นี่คือ "ไส้ใน" ที่แก้ "Missing studentId" แล้ว)
// ==========================================================

// --- Data Models (จำเป็นสำหรับหน้านี้) ---
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
      availableCount: int.parse(json['available_count']?.toString() ?? '0'),
      status: json['category_status'] ?? 'N/A',
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
// --- End of Data Models ---

class _EquipmentListPage extends StatefulWidget {
  const _EquipmentListPage();

  @override
  State<_EquipmentListPage> createState() => __EquipmentListPageState();
}

class __EquipmentListPageState extends State<_EquipmentListPage> {
  bool _isLoading = true;
  int? _lenderId;
  List<SportCategory> _categories = [];
  List<SportItem> _items = [];
  SportCategory? _selectedCategory;
  int? _hoveredCategoryIndex;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _fetchUserData();
    if ((_lenderId ?? 0) != 0) {
      await _fetchCategories();
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _lenderId = prefs.getInt('u_id') ?? 0;
      });
    }
    if (_lenderId == 0) {
      _showErrorSnackBar("User ID not found. Please re-login.");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // [!!!] นี่คือจุดที่แก้ "Missing studentId" [!!!]
  Future<void> _fetchCategories() async {
    if (_lenderId == 0) return;
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/categories'), // [FIX] ไม่มี studentId
      );
      if (!mounted) return;
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

  // [!!!] นี่คือจุดที่แก้ "Missing studentId" [!!!]
  Future<void> _fetchItemsForCategory(SportCategory category) async {
    if (_lenderId == 0) return;
    if (mounted) {
      setState(() {
        _isLoading = true;
        _selectedCategory = category;
      });
    }
    try {
      final response = await http.get(
        Uri.parse(
          '$_apiBaseUrl/items/${category.categoryId}', // [FIX] ไม่มี studentId
        ),
      );
      if (!mounted) return;
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
    if (mounted) {
      setState(() => _isLoading = false);
    }
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

  @override
  Widget build(BuildContext context) {
    // [FIX] ไม่มี Scaffold/AppBar
    bool showItemList = (_selectedCategory != null);

    return Column(
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
    );
  }

  Widget _buildHeader(bool showItemList) {
    return Container(
      // [FIX] ใช้ gradient เดียวกับ AppBar
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8E24AA), Color(0xFF4A148C)],
        ),
        // [FIX] ทำให้ขอบด้านล่างของ Header ไม่คมเกินไป
        border: Border(bottom: BorderSide(color: Color(0xFF4A148C), width: 1)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (showItemList)
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: _onBackToCategories,
                  ),
                Text(
                  showItemList
                      ? _selectedCategory?.name ?? 'Items'
                      : "All Equipment",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
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
          _buildLegend(),
          const SizedBox(height: 20),
          Column(
            children: _categories.asMap().entries.map((entry) {
              int index = entry.key;
              SportCategory category = entry.value;
              final bool isHovered = _hoveredCategoryIndex == index;

              return MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) {
                  setState(() => _hoveredCategoryIndex = index);
                },
                onExit: (_) {
                  setState(() => _hoveredCategoryIndex = null);
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
                      onTap: () => _fetchItemsForCategory(category),
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
        final bool isMyPending = item.status == 'Pending';

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: const Color(0xFFF4F1F7),
            child: Row(
              children: [
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
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
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
// --- END OF lib/lender/lhome.dart ---