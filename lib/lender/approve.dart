import 'package:flutter/material.dart';
// [REMOVED] Imports for Ldashboard and History (no longer needed here)

class Approve extends StatefulWidget {
  const Approve({super.key});

  @override
  State<Approve> createState() => _ApproveState();
}

class _ApproveState extends State<Approve> {
  // [REMOVED] _selectedIndex (now managed by ldashboard.dart)

  // Mock data (This state is kept locally in this widget)
  final List<Map<String, dynamic>> requests = [
    {
      "item": "Volleyball - 060101",
      "username": "LnwZa007",
      "borrowDate": "20/10/2025",
      "returnDate": "21/10/2025",
      "status": "pending",
      "image": "assets/images/volleyball.png", // Ensure this asset exists
    },
    {
      "item": "Badminton Racket - 050101",
      "username": "James",
      "borrowDate": "21/10/2025",
      "returnDate": "21/10/2025",
      "status": "pending",
      "image": "assets/images/badminton.png", // Ensure this asset exists
    },
  ];

  // Logic for handling approve/reject
  void handleAction(int index, String action) {
    final item = requests[index];
    setState(() {
      requests.removeAt(index);
    });

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          action == "approve"
              ? "Approved ${item["item"]} for ${item["username"]}"
              : "Rejected ${item["item"]} from ${item["username"]}",
        ),
        backgroundColor: action == "approve" ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // [REMOVED] _onItemTapped function (now managed by ldashboard.dart)

  @override
  Widget build(BuildContext context) {
    // [MODIFIED] Return only the body content, not a full Scaffold
    return requests.isEmpty
        ? const Center(
            child: Text(
              "No pending requests",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          req["image"],
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          // [ADDED] Error builder in case image fails
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 120,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey[600],
                                size: 40,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Item : ${req["item"]}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text("Borrower : ${req["username"]}"),
                      Text("Borrow date : ${req["borrowDate"]}"),
                      Text("Return on : ${req["returnDate"]}"),
                      const SizedBox(height: 12),

                      // ปุ่ม APPROVE / REJECT
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () => handleAction(index, "approve"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "APPROVE",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => handleAction(index, "reject"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "REJECT",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
