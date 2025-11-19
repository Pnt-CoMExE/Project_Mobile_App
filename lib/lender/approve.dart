import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_mobile_app/config/ip.dart';

class Approve extends StatefulWidget {
  const Approve({super.key});

  @override
  State<Approve> createState() => _ApproveState();
}

class _ApproveState extends State<Approve> {
  List<Map<String, dynamic>> requests = [];
  bool isLoading = true;

  // 🔹 IP ของเครื่องคุณ (แก้ตามจริง)
  final String baseUrl = kSportBorrowApiBaseUrl;

 int? lenderId ; // <-- รหัส Lender จริงจากตาราง user

  @override
  void initState() {
    super.initState();
    fetchRequests();
    _loadLenderAndFetch();
  }

  /// โหลด lenderId จาก SharedPreferences
  Future<void> _loadLenderAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    lenderId = prefs.getInt("u_id");

    print("✅ Loaded lenderId = $lenderId");

    if (lenderId == null) {
      print("❌ ERROR: lenderId not found");
      setState(() => isLoading = false);
      return;
    }

    fetchRequests();
  }
  
  /// ดึงรายการ Pending
  Future<void> fetchRequests() async {
    try {
      final url = "$baseUrl/get_pending_requests.php";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          requests = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ fetchRequests error: $e");
      setState(() => isLoading = false);
    }
  }

  /// อัปเดตสถานะ Approve / Reject
  Future<void> updateRequest({
    required int requestId,
    required String status,
    String? reason,
  }) async {
    if (lenderId == null) return;

    try {
      final bodyData = jsonEncode({
        "request_id": requestId,
        "status": status,
        "lender_id": lenderId,  // ⭐ ใช้ค่า Lender จริง
        "reason": reason ?? "",
      });

      final response = await http.post(
        Uri.parse("$baseUrl/update_request_status.php"),
        headers: {"Content-Type": "application/json"},
        body: bodyData,
      );

      final result = jsonDecode(response.body);

      if (result["success"] == true) {
        setState(() {
          requests.removeWhere(
              (r) => r["request_id"].toString() == requestId.toString());
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(status == "Approved"
              ? "✅ Approved successfully!"
              : "❌ Rejected successfully!"),
          backgroundColor:
              status == "Approved" ? Colors.green : Colors.redAccent,
        ));
      }
    } catch (e) {
      print("❌ updateRequest error: $e");
    }
  }

  /// Popup Approve
  Future<void> confirmApprove(int requestId) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Are you confirm to approve?",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green),
                  onPressed: () {
                    Navigator.pop(context);
                    updateRequest(requestId: requestId, status: "Approved");
                  },
                  child: const Text("Confirm",
                      style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  /// Popup Reject
  Future<void> showRejectDialog(int requestId) async {
    final reasonController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reason for rejection"),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Enter reason...",
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isNotEmpty) {
                Navigator.pop(context);
                updateRequest(
                    requestId: requestId, status: "Rejected", reason: reason);
              }
            },
            child: const Text("Reject"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (requests.isEmpty) {
      return const Center(child: Text("No pending requests"));
    }

    return RefreshIndicator(
      onRefresh: fetchRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final req = requests[index];
          final imageUrl =
              "assets/images/${req["item_image"]?.split('/')?.last ?? "no_image.png"}";

          return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          imageUrl,
                          height: 70,
                          width: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Username: ${req["username"]}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Text("Item: ${req["item_name"]}"),
                            Text("Sport: ${req["category_name"]}"),
                            Text("Borrow date: ${req["borrow_date"]}"),
                            Text("Return on: ${req["return_date"]}"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () => confirmApprove(
                            int.parse(req["request_id"].toString())),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text("APPROVE",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                      ElevatedButton(
                        onPressed: () => showRejectDialog(
                            int.parse(req["request_id"].toString())),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        child: const Text("REJECT",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}