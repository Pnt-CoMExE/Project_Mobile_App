import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// --- Colors ---
const Color primaryPurple = Color(0xFF5C3C8E);
const Color statusApprovedColor = Color(0xFF4CAF50); // Green
const Color statusRejectedColor = Color(0xFFB33939); // Dark Red
const Color statusOverdueColor = Color(0xFFD9534F); // Red Text for Overdue

// --- Data Model สำหรับ History Item ---
class HistoryItem {
  final String itemName;
  final String imagePath;
  final String sport;
  final String status;
  final String dateBorrowed;
  final String dateReturn;
  final String returnStatus;
  final String reason;

  HistoryItem({
    required this.itemName,
    required this.imagePath,
    required this.sport,
    required this.status,
    required this.dateBorrowed,
    required this.dateReturn,
    required this.returnStatus,
    required this.reason,
  });

  // Factory constructor for creating a HistoryItem from JSON
  // *** [ปรับตรงนี้ตามโครงสร้าง JSON จริงจาก Backend ของคุณ] ***
  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      itemName: json['item_name'] ?? 'N/A', // ชื่อสินค้า
      imagePath: 'assets/default_item.png', // ใช้รูป default ก่อน หรือดึง path รูปจริง
      sport: json['sport'] ?? 'N/A', // กีฬา
      status: json['status'] ?? 'N/A', // สถานะการยืม (Approved/Rejected)
      dateBorrowed: json['date_borrowed'] ?? 'N/A',
      dateReturn: json['date_return'] ?? 'N/A',
      returnStatus: json['return_status'] ?? 'N/A', // สถานะการคืน (Overdue/On time/-)
      reason: json['reason'] ?? '', // เหตุผล
    );
  }
}

// ------------------------------------------------------------------
// --- HISTORY SCREEN (STATEFUL) ---
// ------------------------------------------------------------------

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryItem> _historyList = [];
  bool _isLoading = true;
  String? _errorMessage;

  // *** [ตั้งค่า IP และ Port ของ Backend] ***
  final String _baseUrl = 'http://10.10.0.25:3000'; 
  // สมมติว่า Route สำหรับ History คือ /api/user/history

  @override
  void initState() {
    super.initState();
    _fetchHistoryData();
  }

  // --- ⚙️ ฟังก์ชันดึงข้อมูล History จาก API ---
  Future<void> _fetchHistoryData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _errorMessage = 'User not logged in. Token not found.';
        // อาจจะต้องนำผู้ใช้ไปหน้า Login
        if (mounted) Navigator.pushReplacementNamed(context, '/'); 
        return;
      }

      final url = Uri.parse('$_baseUrl/api/history/user'); // *** [แก้ไข Route API ตามจริง] ***
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // ส่ง Token ไปกับ Header
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['history'] != null) {
          // แปลง List ของ JSON เป็น List ของ HistoryItem
          List<HistoryItem> fetchedList = (data['history'] as List)
              .map((item) => HistoryItem.fromJson(item))
              .toList();
              
          // [Logic: จัดกลุ่มรายการ]
          // ถ้าต้องการให้มี 'History 2' คั่น, อาจจะต้องใช้ Logic จัดกลุ่มข้อมูลตรงนี้
          // แต่ในโค้ดตัวอย่างนี้ จะแสดงรายการทั้งหมดเรียงต่อกัน
          
          setState(() {
            _historyList = fetchedList;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Failed to load history data.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'API Error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Connection Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryPurple,
        automaticallyImplyLeading: false,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            Icon(Icons.arrow_forward, color: Colors.white, size: 24),
          ],
        ),
      ),
      body: _buildBody(), // ใช้ _buildBody เพื่อแสดงสถานะ Loading/Error/Data
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
  
  // --- Widget for Body Content (Loading/Error/Data) ---
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: primaryPurple));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _fetchHistoryData,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_historyList.isEmpty) {
      return const Center(child: Text('No history found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      itemCount: _historyList.length,
      itemBuilder: (context, index) {
        final item = _historyList[index];
        // Note: Logic เพื่อใส่ "History 2" header จะต้องซับซ้อนขึ้น 
        // ในตัวอย่างนี้ ผมจะแสดงแค่ Card เรียงกันตามข้อมูลที่ดึงมา
        return _buildHistoryCard(context, item: item);
      },
    );
  }


  // --- Widget for each History Card Item ---
  Widget _buildHistoryCard(BuildContext context, {required HistoryItem item}) {
    // กำหนดสีตามสถานะ
    Color statusBgColor = Colors.transparent;
    Color statusColor = Colors.black;
    Color returnStatusColor = Colors.black;

    if (item.status == 'Approved') {
      statusBgColor = statusApprovedColor;
      statusColor = Colors.white;
    } else if (item.status == 'Rejected') {
      statusBgColor = statusRejectedColor;
      statusColor = Colors.white;
    }

    if (item.returnStatus == 'Overdue') {
      returnStatusColor = statusOverdueColor; 
    } else if (item.returnStatus == 'On time') {
      returnStatusColor = statusApprovedColor; 
    }

    // -------------------------------------------------------------
    // UI Card ตามดีไซน์ที่คุณต้องการ
    // -------------------------------------------------------------
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image (Item Picture)
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                item.imagePath, // ใช้ path จากข้อมูลที่ดึงมา
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 15),
            // Item Details (Right side)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item Name
                  Text(
                    item.itemName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryPurple,
                    ),
                  ),
                  
                  const SizedBox(height: 5),

                  // Detail Rows
                  _buildDetailRow('Sport :', item.sport),
                  _buildDetailRow('Status :', item.status, isStatus: true, statusBgColor: statusBgColor, statusColor: statusColor),
                  _buildDetailRow('Date Borrowed :', item.dateBorrowed),
                  _buildDetailRow('Date Return :', item.dateReturn),
                  _buildDetailRow('Return status :', item.returnStatus, isReturnStatus: true, returnStatusColor: returnStatusColor),
                  
                  const SizedBox(height: 8),
                  
                  // Reason Section
                  const Text(
                    'Reason',
                    style: TextStyle(fontSize: 12, color: statusOverdueColor),
                  ),
                  TextField( // แสดง Reason ที่ดึงมา หรือเป็นช่องว่างให้กรอก
                    controller: TextEditingController(text: item.reason),
                    readOnly: true, // ทำให้เป็น Read Only ถ้าเป็นข้อมูล History
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: primaryPurple),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget for Detail Row (Label : Value) ---
  Widget _buildDetailRow(
    String label,
    String value, {
    bool isStatus = false,
    Color statusBgColor = Colors.transparent,
    Color statusColor = Colors.black,
    bool isReturnStatus = false,
    Color returnStatusColor = Colors.black,
  }) {
    const TextStyle labelStyle = TextStyle(fontSize: 13, color: Colors.black54);
    const TextStyle valueStyle = TextStyle(fontSize: 13, fontWeight: FontWeight.w500);

    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Row(
        children: [
          SizedBox(
            width: 110, // Fixed width for alignment
            child: Text(label, style: labelStyle),
          ),
          // Value or Status Badge
          isStatus 
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Text(
                  value,
                  style: isReturnStatus 
                      ? valueStyle.copyWith(color: returnStatusColor, fontWeight: FontWeight.bold) 
                      : valueStyle,
                ),
        ],
      ),
    );
  }

  // --- Bottom Navigation Bar ---
  Widget _buildBottomNavigationBar() {
    return Container(
      height: 60,
      color: primaryPurple,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home
          Icon(Icons.home, color: Colors.white70, size: 28),
          // Notification
          Icon(Icons.notifications, color: Colors.white70, size: 28),
          // History (Active)
          Icon(Icons.assignment, color: Colors.white, size: 28),
        ],
      ),
    );
  }
}