//staff/history.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_mobile_app/config/ip.dart';

class StaffHistory extends StatefulWidget {
  const StaffHistory({super.key});

  @override
  State<StaffHistory> createState() => _StaffHistoryState();
}

class _StaffHistoryState extends State<StaffHistory> {
  List<dynamic> _history = [];
  bool _loading = false;

  int? staffId;
  final String baseUrl = kSportApiBaseUrl;

  Timer? autoTimer;

  @override
  void initState() {
    super.initState();
    _loadID();

    autoTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _fetchHistory(silent: true);
    });
  }

  @override
  void dispose() {
    autoTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadID() async {
    final prefs = await SharedPreferences.getInstance();
    staffId = prefs.getInt("u_id");

    if (staffId != null) _fetchHistory();
  }

  Future<void> _fetchHistory({bool silent = false}) async {
  if (!silent) setState(() => _loading = true);

  try {
    if (staffId == null) {
      debugPrint("❌ StaffHistory: staffId is null");
      return;
    }

    final url = "$baseUrl/history/staff/$staffId"; // ✅ ใช้ Node route ใหม่
    debugPrint("📥 Fetch StaffHistory from: $url");

    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      final jsonRes = jsonDecode(res.body);
      if (jsonRes['success'] == true) {
        setState(() => _history = jsonRes['data']);
      } else {
        debugPrint("❌ StaffHistory: success = false, message = ${jsonRes['message']}");
      }
    } else {
      debugPrint("❌ StaffHistory HTTP error: ${res.statusCode}");
    }
  } catch (e) {
    debugPrint("❌ Staff History Error: $e");
  }

  if (!silent) setState(() => _loading = false);
}


  String _fmt(dynamic raw) {
    if (raw == null) return '-';
    try {
      return DateFormat("dd MMM yyyy", "en")
          .format(DateTime.parse(raw.toString()));
    } catch (_) {
      return raw.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: () => _fetchHistory(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _history.length,
              itemBuilder: (_, i) {
                final item = _history[i];

                final img = "$kImageBaseUrl${item['item_image'] ?? 'images/default.png'}";

                return Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(2, 3),
                      )
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---------- รูปอุปกรณ์ ----------
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(2, 3))
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            img,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.image_not_supported,
                              size: 35,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      // ---------- ข้อมูลด้านขวา ----------
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // TITLE
                            Text(
                              item['item_name'] ?? '-',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 14),

                            _kv("Sport :", item['category_name']),
                            const SizedBox(height: 6),

                            _kvPill("Item ID :", item['item_id'] ?? "-"),
                            const SizedBox(height: 6),

                            _kv("Date Borrowed :", _fmt(item['borrow_date'])),
                            const SizedBox(height: 6),

                            _kv("Date Returned :", _fmt(item['actual_return_date'])),
                            const SizedBox(height: 6),

                            _kvPill("Student :", item['username']),
                            const SizedBox(height: 6),

                            // Approve by
                            Row(
                              children: [
                                const SizedBox(
                                  width: 120,
                                  child: Text(
                                    "Approve by :",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: _pill(item['lender_name'] ?? '-'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Return item by
                            _kvPill("Return item by :", item['staff_name']),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
  }

  // ================= UI Helpers =================

  Widget _kv(String title, String? value) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(value ?? '-', textAlign: TextAlign.left),
        ),
      ],
    );
  }

  Widget _kvPill(String title, String? value) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: _pill(value ?? '-')),
      ],
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text),
    );
  }
}