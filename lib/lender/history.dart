import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_mobile_app/config/ip.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<dynamic> _historyList = [];
  bool _isLoading = false;

  int? lenderId;
  final String baseUrl = kSportApiBaseUrl;

  Timer? autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _loadAndFetch();

    // ⭐ Auto-refresh ทุก 3 วินาที
    autoRefreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _fetchHistory(silent: true); // silent = ไม่โชว์ loading
    });
  }

  @override
  void dispose() {
    autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    lenderId = prefs.getInt("u_id");

    if (lenderId == null) return;

    _fetchHistory();
  }

  Future<void> _fetchHistory({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);

    try {
      final res =
          await http.get(Uri.parse("$baseUrl/lender/history/$lenderId"));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["success"] == true) {
          setState(() {
            _historyList = data["data"];
          });
        }
      }
    } catch (e) {
      debugPrint("❌ Error: $e");
    }

    if (!silent) setState(() => _isLoading = false);
  }

  String _formatDate(dynamic raw) {
    if (raw == null) return '-';
    try {
      final date = DateTime.parse(raw.toString());
      return DateFormat('dd MMM yyyy', 'en').format(date);
    } catch (e) {
      return raw.toString().split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchHistory,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _historyList.length,
                itemBuilder: (context, index) {
                  final item = _historyList[index];
                  final imageUrl =
                      "$kBaseHost/${item['item_image'] ?? 'images/default.png'}";

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(2, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imageUrl,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['item_name'] ?? '-',
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  _buildStatusChip(item['request_status']),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow("Sport :", item['category_name']),
                        const SizedBox(height: 6),
                        _buildInfoRow("Student :", item['username']),
                        const SizedBox(height: 6),
                        _buildInfoRow("Date Borrowed :",
                            _formatDate(item['borrow_date'])),
                        const SizedBox(height: 6),
                        _buildInfoRow("Date Returned :",
                            _formatDate(item['return_date'])),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildInfoRow(String title, String? value) {
    return Row(
      children: [
        Text(title,
            style:
                const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(width: 6),
        Expanded(
          child:
              Text(value ?? '-', style: const TextStyle(color: Colors.black87)),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String? status) {
    Color color;
    String label;
    switch (status) {
      case "Approved":
        color = Colors.green.shade600;
        label = "Approved";
        break;
      case "Rejected":
        color = Colors.red.shade600;
        label = "Rejected";
        break;
      default:
        color = Colors.orange.shade700;
        label = "Pending";
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}
