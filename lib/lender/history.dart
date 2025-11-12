// history.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'approve.dart';

// [TODO] เปลี่ยน IP ให้ตรงเซิร์ฟเวอร์ของคุณ
const String _apiBaseUrl = 'http://10.10.0.25:3000/api/sport';
const String _imageBaseUrl = 'http://10.10.0.25:3000/';

// =======================================
// Data Model (ไม่มี return_status แล้ว)
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
      requestDescription: json['request_description'],
    );
  }
}

// =======================================
// Main History Content (ใช้ใน Ldashboard — ไม่มี AppBar/BottomNav)
// =======================================
class History extends StatefulWidget {
  const History({super.key});
  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
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
      final response = await http.get(Uri.parse('$_apiBaseUrl/history/$studentId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        setState(() {
          _historyItems = data.map((item) => HistoryItem.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        _showErrorSnackBar('Failed to load history');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _historyItems.isEmpty
            ? const Center(child: Text('No history found.',
                style: TextStyle(fontSize: 16, color: Colors.grey)))
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _historyItems.length,
                itemBuilder: (context, index) => _buildHistoryCard(_historyItems[index]),
              );

    return Container(color: const Color(0xFFF3F4F6), child: body);
  }

  // ===== Card & Helpers =====
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
                _imageBaseUrl + item.itemImage,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.itemName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black)),
                  const SizedBox(height: 10),
                  _buildInfoRow('Sport:',
                      Text(item.categoryName, style: const TextStyle(fontSize: 16))),
                  _buildInfoRow('Status :', _buildStatusChip(item.requestStatus)),
                  _buildInfoRow('Date Borrowed :',
                      Text(borrowDateStr, style: const TextStyle(fontSize: 16))),
                  _buildInfoRow('Date Return :',
                      Text(returnDateStr, style: const TextStyle(fontSize: 16))),
                  if (item.requestStatus == 'Rejected' && item.requestDescription != null) ...[
                    const SizedBox(height: 8),
                    const Text('Reason',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text(item.requestDescription!,
                        style: const TextStyle(fontSize: 14, color: Colors.red)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, Widget valueWidget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54)),
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
        label: Text(status,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: chipColor,
        padding: EdgeInsets.zero,
        labelPadding: const EdgeInsets.symmetric(horizontal: 12.0),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
