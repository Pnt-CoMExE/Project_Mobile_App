//history.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'request.dart';

// [TODO] แก้ไข IP Address ให้ตรงกับ Server ของคุณ
const String _apiBaseUrl = 'http://192.168.1.4:3000/api/sport';
// [FIX] เพิ่ม Base URL สำหรับรูปภาพ (ไม่มี /api/sport)
const String _imageBaseUrl = 'http://192.168.1.4:3000/';

// =======================================
// [NEW] Data Model (สำหรับ history_view)
// =======================================
class HistoryItem {
  final int requestId;
  final String itemName;
  final String categoryName;
  final String itemImage;
  final String requestStatus;
  final DateTime borrowDate;
  final DateTime returnDate;
  final DateTime? actualReturnDate;
  final String returnStatus;
  final String? requestDescription;

  HistoryItem({
    required this.requestId,
    required this.itemName,
    required this.categoryName,
    required this.itemImage,
    required this.requestStatus,
    required this.borrowDate,
    required this.returnDate,
    this.actualReturnDate,
    required this.returnStatus,
    this.requestDescription,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      // [FIX] แปลง String (INT) เป็น int
      requestId: int.parse(json['request_id'].toString()),
      itemName: json['item_name'],
      categoryName: json['category_name'],
      itemImage: json['item_image'],
      requestStatus: json['request_status'],
      borrowDate: DateTime.parse(json['borrow_date']),
      returnDate: DateTime.parse(json['return_date']),
      actualReturnDate: json['actual_return_date'] != null
          ? DateTime.parse(json['actual_return_date'])
          : null,
      returnStatus: json['return_status'],
      requestDescription: json['request_description'],
    );
  }
}

// =======================================
// Main History Page
// =======================================
class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final int _selectedIndex = 2;
  bool _isLoading = true;
  List<HistoryItem> _historyItems = [];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getInt('u_id');

    if (studentId == null || studentId == 0) {
      _showErrorSnackBar("User not logged in.");
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/history/$studentId'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        setState(() {
          _historyItems = data
              .map((item) => HistoryItem.fromJson(item))
              .toList();
          _isLoading = false;
        });
      } else {
        _showErrorSnackBar('Failed to load history');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // =======================================
  // Navigation & Dialogs (เหมือนเดิม)
  // =======================================
  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomePage(),
          transitionDuration: Duration.zero,
        ),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const RequestPage(),
          transitionDuration: Duration.zero,
        ),
      );
    }
  }

  Future<void> _showLogoutConfirmDialog() async {
    // ... (โค้ด Dialog ยืนยัน Logout ของคุณ) ...
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

  // =======================================
  // UI Build
  // =======================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: const [
            Icon(Icons.calendar_today_outlined, size: 28),
            SizedBox(width: 10),
            Text('History', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: _showLogoutConfirmDialog,
          ),
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _historyItems.isEmpty
          ? const Center(
              child: Text(
                'No history found.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _historyItems.length,
              itemBuilder: (context, index) {
                final item = _historyItems[index];
                return _buildHistoryCard(item);
              },
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
            onTap: _onItemTapped,
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

  // =======================================
  // [NEW] Widget สร้าง Card (ดีไซน์ใหม่จาก .sql)
  // =======================================
  Widget _buildHistoryCard(HistoryItem item) {
    final borrowDateStr =
        "${item.borrowDate.day}/${item.borrowDate.month}/${item.borrowDate.year}";
    final returnDateStr =
        "${item.returnDate.day}/${item.returnDate.month}/${item.returnDate.year}";

    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                // [FIX] ต่อ Base URL
                _imageBaseUrl + item.itemImage,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.itemName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    'Sport:',
                    Text(
                      item.categoryName,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  _buildInfoRow(
                    'Status :',
                    _buildStatusChip(item.requestStatus),
                  ),
                  _buildInfoRow(
                    'Date Borrowed :',
                    Text(borrowDateStr, style: const TextStyle(fontSize: 16)),
                  ),
                  _buildInfoRow(
                    'Date Return :',
                    Text(returnDateStr, style: const TextStyle(fontSize: 16)),
                  ),
                  _buildInfoRow(
                    'Return status :',
                    _buildReturnStatus(item.returnStatus),
                  ),
                  if (item.requestStatus == 'Rejected' &&
                      item.requestDescription != null) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Reason',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.requestDescription!,
                      style: const TextStyle(fontSize: 14, color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widgets (จากดีไซน์ครั้งก่อน)
  Widget _buildInfoRow(String label, Widget valueWidget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(child: valueWidget),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status) {
      case 'Approved':
        chipColor = Colors.green;
        break;
      case 'Rejected':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.grey;
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Chip(
        label: Text(
          status,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: chipColor,
        padding: EdgeInsets.zero,
        labelPadding: const EdgeInsets.symmetric(horizontal: 12.0),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildReturnStatus(String status) {
    Color textColor;
    switch (status) {
      case 'Overdue':
        textColor = Colors.red;
        break;
      case 'On time':
        textColor = Colors.green;
        break;
      case '-':
      default:
        textColor = Colors.orange;
        break;
    }
    return Text(
      status,
      style: TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
