import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<dynamic> _historyList = [];
  bool _isLoading = false;

  // ✅ รหัส Lender ของคุณ (แก้ตามจริง)
  final int lenderId = 3;
  // ✅ URL ใหม่ของ Node.js API
  final String baseUrl = "http://192.168.1.4:3000/api/sport";

  // 📦 โหลดข้อมูลประวัติจาก Node.js backend
  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/lender/history/$lenderId"),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded["success"] == true) {
          setState(() {
            _historyList = decoded["data"];
            _isLoading = false;
          });
        } else {
          setState(() {
            _historyList = [];
            _isLoading = false;
          });
        }
      } else {
        debugPrint("❌ Server Error: ${response.statusCode}");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading history: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _historyList.isEmpty
              ? const Center(
                  child: Text(
                    "No history found.",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchHistory,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _historyList.length,
                    itemBuilder: (context, index) {
                      final item = _historyList[index];
                      final imageUrl = "http://192.168.1.4:3000/${item['item_image']}";


                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 3,
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.image),
                            ),
                          ),
                          title: Text(
                            item['item_name'] ?? 'Unknown Item',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Borrower: ${item['username'] ?? '-'}"),
                              Text("Borrow date: ${item['borrow_date'] ?? '-'}"),
                              Text("Return date: ${item['return_date'] ?? '-'}"),
                              if (item['reason'] != null &&
                                  item['reason'].toString().isNotEmpty)
                                Text("Reason: ${item['reason']}"),
                            ],
                          ),
                          trailing:
                              _buildStatusChip(item['request_status'] ?? 'Pending'),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  // 🔸 Widget แสดงสถานะ
  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Approved':
        color = Colors.green;
        break;
      case 'Rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }
    return Chip(
      label: Text(
        status,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }
}
