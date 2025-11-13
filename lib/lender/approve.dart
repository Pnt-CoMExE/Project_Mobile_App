import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Approve extends StatefulWidget {
  const Approve({super.key});

  @override
  State<Approve> createState() => _ApproveState();
}

class _ApproveState extends State<Approve> {
  List<Map<String, dynamic>> requests = [];
  bool isLoading = true;

  // 🔹 IP ของเครื่องคุณ (แก้ตามจริง)
  final String baseUrl = "http://172.27.11.229/sport_borrow_api";

  final int lenderId = 3; // <-- รหัส Lender จริงจากตาราง user

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  /// 🔸 ดึงรายการ Pending
  Future<void> fetchRequests() async {
  try {
    final url = "$baseUrl/get_pending_requests.php";
    print("🔍 Fetching from: $url");
    final response = await http.get(Uri.parse(url));
    print("📥 Status: ${response.statusCode}");
    print("📦 Body: ${response.body}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        requests = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } else {
      throw Exception("Failed to load requests (code: ${response.statusCode})");
    }
  } catch (e) {
    print("❌ fetchRequests error: $e");
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Error: $e")));
  }
}

  /// 🔸 ฟังก์ชันอัปเดตสถานะ Approve / Reject
  Future<void> updateRequest({
    required int requestId,
    required String status,
    String? reason,
  }) async {
    try {
      final bodyData = jsonEncode({
        "request_id": requestId,
        "status": status,
        "lender_id": lenderId,
        "reason": reason ?? "",
      });

      debugPrint("📤 Sending JSON: $bodyData");

      final response = await http.post(
        Uri.parse("$baseUrl/update_request_status.php"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: bodyData,
      );

      debugPrint("📥 Response: ${response.body}");

      final result = jsonDecode(response.body);
if (result["success"] == true) {
  setState(() {
    // 🔥 เอา request นี้ออกจาก list ทันที
    requests.removeWhere((r) => r["request_id"].toString() == requestId.toString());
  });

  // ✅ แจ้งเตือนผลลัพธ์
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(status == "Approved"
        ? "✅ Approved successfully!"
        : "❌ Rejected successfully!"),
    backgroundColor: status == "Approved" ? Colors.green : Colors.redAccent,
  ));
} else {
  throw Exception(result["message"]);
}
    } catch (e) {
      debugPrint("❌ updateRequest error: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error updating request: $e")));
    }
  }

  /// 🔸 Popup Confirm (แบบภาพแรก)
  Future<void> confirmApprove(int requestId) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                const Text(
                  "Are you confirm to approve?",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Icon(
                  Icons.info_outline,
                  color: Colors.green,
                  size: 40,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    updateRequest(requestId: requestId, status: "Approved");
                  },
                  child: const Text(
                    "Confirm",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 🔸 ป้อนเหตุผล Reject
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
            hintText: "Enter reason...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isNotEmpty) {
                Navigator.pop(context);
                updateRequest(
                    requestId: requestId, status: "Rejected", reason: reason);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter reason")));
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
      return const Center(
        child: Text("No pending requests",
            style: TextStyle(fontSize: 18, color: Colors.grey)),
      );
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          errorBuilder: (_, __, ___) => Container(
                            height: 70,
                            width: 70,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported),
                          ),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
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