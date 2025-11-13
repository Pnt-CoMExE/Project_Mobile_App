import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'history.dart';

// [TODO] แก้ไข IP Address ให้ตรงกับ Server ของคุณ
const String _apiBaseUrl = 'http://10.10.0.25:3000/api/sport';
// [FIX] เพิ่ม Base URL สำหรับรูปภาพ (ไม่มี /api/sport)
const String _imageBaseUrl = 'http://10.10.0.25:3000/';

// =======================================
// [NEW] Data Model (สำหรับ request_result_view)
// =======================================
class RequestItem {
  final int requestId;
  final String itemName;
  final String categoryName;
  final String itemImage;
  final DateTime borrowDate;
  final DateTime returnDate;
  final String requestStatus;

  RequestItem({
    required this.requestId,
    required this.itemName,
    required this.categoryName,
    required this.itemImage,
    required this.borrowDate,
    required this.returnDate,
    required this.requestStatus,
  });

  factory RequestItem.fromJson(Map<String, dynamic> json) {
    return RequestItem(
      // [FIX] แปลง String (INT) เป็น int
      requestId: int.parse(json['request_id'].toString()),
      itemName: json['item_name'],
      categoryName: json['category_name'],
      itemImage: json['item_image'],
      borrowDate: DateTime.parse(json['borrow_date']),
      returnDate: DateTime.parse(json['return_date']),
      requestStatus: json['request_status'],
    );
  }
}

// =======================================
// Main Request Page
// =======================================
class RequestPage extends StatefulWidget {
  const RequestPage({super.key});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  final int _selectedIndex = 1;
  bool _isLoading = true;
  List<RequestItem> _requestItems = [];

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
  setState(() => _isLoading = true);

  final prefs = await SharedPreferences.getInstance();
  final studentId = prefs.getInt('u_id');

  if (studentId == null || studentId == 0) {
    _showErrorSnackBar("User not logged in.");
    setState(() => _isLoading = false);
    return;
  }

  try {
    final url = '$_apiBaseUrl/requests/$studentId';
    debugPrint("📡 GET $url");

    final response = await http.get(Uri.parse(url));

    debugPrint("📡 Status: ${response.statusCode}");
    debugPrint("📡 Body: ${response.body}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded["success"] == true) {
        final List list = decoded["data"] ?? [];

        setState(() {
          _requestItems = list
              .map((item) => RequestItem.fromJson(item))
              .toList();
        });
      } else {
        _showErrorSnackBar("Failed: ${decoded["message"]}");
      }
    } else {
      _showErrorSnackBar("HTTP Error ${response.statusCode}");
    }
  } catch (e) {
    _showErrorSnackBar("Error: $e");
  } finally {
    // ❗ สำคัญสุด: ปิด loading เสมอ
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // =======================================
  // Navigation & Dialogs
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
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const History(),
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
    const purpleColor = Colors.deepPurple;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: purpleColor,
        automaticallyImplyLeading: false,
        title: Row(
          children: const [
            Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
            SizedBox(width: 10),
            Text(
              'Request Result',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Colors.white),
            onPressed: _showLogoutConfirmDialog,
          ),
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requestItems.isEmpty
          ? const Center(
              child: Text(
                'No pending requests.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _requestItems.length,
              itemBuilder: (context, index) {
                final item = _requestItems[index];
                return _buildRequestCard(item);
              },
            ),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: purpleColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          bottom: true,
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_outlined),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                label: '',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =======================================
  // [NEW] Widget สร้าง Card (ตามดีไซน์เดิม)
  // =======================================
  Widget _buildRequestCard(RequestItem item) {
    final borrowDateStr =
        "${item.borrowDate.day}/${item.borrowDate.month}/${item.borrowDate.year}";
    final returnDateStr =
        "${item.returnDate.day}/${item.returnDate.month}/${item.returnDate.year}";

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    // [FIX] ต่อ Base URL
                    _imageBaseUrl + item.itemImage,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item.itemName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            _buildInfoRow('Sport :', item.categoryName),
            _buildInfoRow('Borrow :', borrowDateStr),
            _buildInfoRow('Date return :', returnDateStr),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoLabel('Status :'),
                Chip(
                  label: Text(
                    item.requestStatus, // 'Pending'
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  backgroundColor: Colors.yellow.shade700, // สี Pending
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoLabel(label),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildInfoLabel(String label) => SizedBox(
    width: 100,
    child: Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
    ),
  );
}
