//history.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'request.dart';
import 'package:project_mobile_app/config/ip.dart';

String _apiBaseUrl = kSportApiBaseUrl;
String _imageBaseUrl = kImageBaseUrl;

// -------------------- MODEL --------------------
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

// --------------------------------------------------

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

  // --------------------- BUILD ---------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),

      appBar: AppBar(
        title: const Text("History"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _historyItems.isEmpty
          ? const Center(
              child: Text(
                "No history found",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchHistory,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _historyItems.length,
                itemBuilder: (_, i) => _buildHistoryCard(_historyItems[i]),
              ),
            ),

      // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: 2,
            onTap: (i) {
              if (i == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              } else if (i == 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const RequestPage()),
                );
              }
            },
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_outlined),
                label: "Requests",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_outlined),
                label: "History",
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------- UI -------------------
  Widget _buildHistoryCard(HistoryItem item) {
    final borrow =
        "${item.borrowDate.day}/${item.borrowDate.month}/${item.borrowDate.year}";
    final ret =
        "${item.returnDate.day}/${item.returnDate.month}/${item.returnDate.year}";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _imageBaseUrl + item.itemImage,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image_not_supported, size: 60),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _statusChip(item.requestStatus),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          _info("Sport :", item.categoryName),
          const SizedBox(height: 6),
          _info("Borrowed :", borrow),
          const SizedBox(height: 6),
          _info("Return :", ret),
          const SizedBox(height: 6),

          // 🔹 แสดง Return status เฉพาะตอน Approved
          if (item.requestStatus == "Approved") ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Text(
                  "Return status :",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 6),
                Text(
                  item.returnStatus,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: item.returnStatus == "Overdue"
                        ? Colors.red
                        : item.returnStatus == "On time"
                        ? Colors.green
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ],

          // 🔹 แสดง Reason เฉพาะกรณี Rejected (เหมือนที่แก้ไว้แล้ว)
          if (item.requestStatus == "Rejected") ...[
            const SizedBox(height: 12),
            const Text(
              "Reason :",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black26),
              ),
              child: Text(
                item.requestDescription ?? "-",
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _info(String title, String value) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 6),
        Expanded(child: Text(value)),
      ],
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status) {
      case "Approved":
        color = Colors.green;
        break;
      case "Rejected":
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
