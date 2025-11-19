// return.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_mobile_app/config/ip.dart';

// TODO: แก้ให้ตรงกับเซิร์ฟเวอร์จริงของคุณ
final String _returnApiBaseUrl = kSportApiBaseUrl;
final String _imageBaseUrl = kImageBaseUrl;

class EquipmentItem {
  final int requestId;
  final String itemId;
  final String itemName;
  final String categoryName;
  final String itemImage;
  final String username;
  final DateTime borrowDate;
  final DateTime returnDate;

  EquipmentItem({
    required this.requestId,
    required this.itemId,
    required this.itemName,
    required this.categoryName,
    required this.itemImage,
    required this.username,
    required this.borrowDate,
    required this.returnDate,
  });

  factory EquipmentItem.fromJson(Map<String, dynamic> json) {
    DateTime _parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      return DateTime.parse(v.toString());
    }

    return EquipmentItem(
      requestId: json['request_id'] as int,
      itemId: json['item_id'] as String,
      itemName: json['item_name'] as String,
      categoryName: json['category_name'] as String,
      itemImage: json['item_image'] as String,
      username: json['username'] as String,
      borrowDate: _parseDate(json['borrow_date']),
      returnDate: _parseDate(json['return_date']),
    );
  }
}

class ReturnEquipmentScreen extends StatefulWidget {
  const ReturnEquipmentScreen({super.key});

  @override
  State<ReturnEquipmentScreen> createState() => _ReturnEquipmentScreenState();
}

class _ReturnEquipmentScreenState extends State<ReturnEquipmentScreen> {
  static const Color actionGreen = Color(0xFF4CAF50);

  bool _isLoading = true;
  bool _isSubmitting = false;
  List<EquipmentItem> _equipmentList = [];

  @override
  void initState() {
    super.initState();
    _fetchEquipmentList();
  }

  // ============================
  // Fetch list from API
  // ============================
  Future<void> _fetchEquipmentList() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('$_returnApiBaseUrl/return/list');
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['success'] == true) {
          final List data = body['data'] as List;
          setState(() {
            _equipmentList = data
                .map((e) => EquipmentItem.fromJson(e))
                .toList();
          });
        } else {
          _showSnack(body['message']?.toString() ?? 'Failed to load data');
        }
      } else {
        _showSnack('Server error: ${res.statusCode}');
      }
    } catch (e) {
      _showSnack('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ============================
  // Handle RETURN button
  // ============================
  Future<void> _handleReturn(EquipmentItem item) async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      // ดึง staff_id จาก SharedPreferences (ตอน login staff ให้เซฟ userId ไว้)
      final prefs = await SharedPreferences.getInstance();

      // ลองดึงจาก 'userId' ก่อน ถ้าไม่มีให้ fallback เป็น 'u_id'
      final staffId = prefs.getInt('userId') ?? prefs.getInt('u_id');

      debugPrint("👤 staffId from SharedPreferences = $staffId");

      if (staffId == null) {
        _showSnack('Cannot find staff ID. Please login again.');
        return;
      }
      final url = Uri.parse('$_returnApiBaseUrl/return/confirm');
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'request_id': item.requestId, 'staff_id': staffId}),
      );

      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['success'] == true) {
          _showSnack('Returned: ${item.itemName}');
          // โหลดรายการใหม่ หลังจากคืนของแล้ว
          await _fetchEquipmentList();
        } else {
          _showSnack(body['message']?.toString() ?? 'Return failed');
        }
      } else {
        _showSnack('Server error: ${res.statusCode}');
      }
    } catch (e) {
      _showSnack('Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // ============================
  // UI Helpers
  // ============================
  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd/$mm/$yyyy';
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label : ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentCard(EquipmentItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Container(
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // หัว + รูป
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ด้านซ้าย: details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Item: ${item.itemName}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow('Item ID', item.itemId),
                      _buildDetailRow('Sport', item.categoryName),
                      _buildDetailRow('Username', item.username),
                      _buildDetailRow('Borrowed', _formatDate(item.borrowDate)),
                      _buildDetailRow(
                        'Return Date',
                        _formatDate(item.returnDate),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // ด้านขวา: รูป
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    '$_imageBaseUrl${item.itemImage}',
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // ปุ่ม RETURN
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : () => _handleReturn(item),
                style: ElevatedButton.styleFrom(
                  backgroundColor: actionGreen,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'RETURN',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================
  // Build
  // ============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ถ้าใช้ใน sdashboard/ldashboard แล้ว จะมี AppBar จากข้างนอกให้แล้ว
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _equipmentList.isEmpty
          ? const Center(
              child: Text(
                'No items to return',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: _equipmentList
                    .map((item) => _buildEquipmentCard(item))
                    .toList(),
              ),
            ),
    );
  }
}
