import 'package:flutter/material.dart';
// [REMOVED] Imports for Ldashboard and Approve (no longer needed here)

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<History> {
  // [REMOVED] _selectedIndex (now managed by ldashboard.dart)

  // Mock data (This state is kept locally in this widget)
  final List<Map<String, String>> historyList = const [
    {
      "title": "Volleyball",
      "item": "Item : Volleyball",
      "borrowed": "Date Borrowed : 20 Oct 2568",
      "returned": "Date Returned : 21 Oct 2568",
      "id": "Item ID : 0601",
      "student": "Student : LnwZa007",
      "image": "assets/images/volleyball.png", // Ensure this asset exists
    },
    {
      "title": "Badminton",
      "item": "Item : Badminton Racket",
      "borrowed": "Date Borrowed : 21 Oct 2568",
      "returned": "Date Returned : 21 Oct 2568",
      "id": "Item ID : 0501",
      "student": "Student : LnwZa007",
      "image": "assets/images/badminton.png", // Ensure this asset exists
    },
  ];

  // [REMOVED] _onItemTapped function (now managed by ldashboard.dart)

  @override
  Widget build(BuildContext context) {
    // [MODIFIED] Return only the body content, not a full Scaffold
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: historyList.length,
      itemBuilder: (context, index) {
        final item = historyList[index];
        return Card(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    item["image"]!,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                    // [ADDED] Error builder in case image fails
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 100,
                        width: 100,
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
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["title"]!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(item["item"]!),
                      Text(item["borrowed"]!),
                      Text(item["returned"]!),
                      Text(item["id"]!),
                      Text(item["student"]!),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
