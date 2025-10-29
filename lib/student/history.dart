import 'package:flutter/material.dart';

// Redefine Status for this screen's context
enum HistoryStatus { returned, overdue, lost }

class HistoryRecord {
  final String name;
  final String itemType;
  final String dateBorrowed;
  final String dateReturned;
  final String approver; // ผู้อนุมัติ
  final String receiver; // ผู้รับคืน (ตอนคืนแล้ว)
  final HistoryStatus status;

  const HistoryRecord({
    required this.name,
    required this.itemType,
    required this.dateBorrowed,
    required this.dateReturned,
    required this.approver,
    required this.receiver,
    required this.status,
  });
}

// --- CONST MOCK DATA (MOVED OUTSIDE CLASS) ---
const List<HistoryRecord> mockHistory = [
  HistoryRecord(
    name: 'Badminton',
    itemType: 'Badminton Racket',
    dateBorrowed: '10 Oct 2568',
    dateReturned: '11 Oct 2568',
    approver: 'Admin A',
    receiver: 'Staff 1',
    status: HistoryStatus.returned,
  ),
  HistoryRecord(
    name: 'Tennis',
    itemType: 'Tennis Racket',
    dateBorrowed: '08 Oct 2568',
    dateReturned: '09 Oct 2568',
    approver: 'Admin B',
    receiver: 'Staff 2',
    status: HistoryStatus.returned,
  ),
  HistoryRecord(
    name: 'Futsal',
    itemType: 'Futsal Ball',
    dateBorrowed: '01 Sep 2568',
    dateReturned: 'N/A', // ยังไม่คืน
    approver: 'Admin C',
    receiver: 'N/A',
    status: HistoryStatus.overdue,
  ),
];
// ---------------------------------------------

class History extends StatelessWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the data using the top-level const variable
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: mockHistory.length,
      itemBuilder: (context, index) {
        final record = mockHistory[index];
        // Use the new HistoryResultCard widget
        return HistoryResultCard(record: record);
      },
    );
  }
}

// Helper for image URLs based on item name (for demonstration)
String _getItemImageUrl(String name) {
  switch (name) {
    case 'Badminton':
      return 'https://placehold.co/70x70/F2F2F2/000000?text=Badminton';
    case 'Tennis':
      return 'https://placehold.co/70x70/F2F2F2/000000?text=Tennis';
    case 'Futsal':
      return 'https://placehold.co/70x70/F2F2F2/000000?text=Futsal';
    default:
      return 'https://placehold.co/70x70/F2F2F2/000000?text=Item';
  }
}

class HistoryResultCard extends StatelessWidget {
  final HistoryRecord record;
  const HistoryResultCard({super.key, required this.record});

  // Function to get the status text (using simpler text for history)
  String _getStatusText(HistoryStatus status) {
    switch (status) {
      case HistoryStatus.returned:
        return 'Returned';
      case HistoryStatus.overdue:
        return 'Overdue';
      case HistoryStatus.lost:
        return 'Lost/Damaged';
    }
  }

  // Function to get the status color
  Color _getStatusColor(HistoryStatus status) {
    switch (status) {
      case HistoryStatus.returned:
        return Colors.green.shade600;
      case HistoryStatus.overdue:
        return Colors.orange.shade700;
      case HistoryStatus.lost:
        return Colors.red.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(record.status);
    final statusText = _getStatusText(record.status);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item Image Placeholder
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    _getItemImageUrl(record.name),
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[200],
                      child: const Center(child: Text('Img')),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Item Name
                Expanded(
                  child: Text(
                    record.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                // Status Chip (Only show for non-returned items for visual simplicity)
                if (record.status != HistoryStatus.returned)
                  Chip(
                    label: Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    backgroundColor: statusColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            // Info Row: Item Type
            _buildInfoRow('Item :', record.itemType),
            // Info Row: Borrow Date
            _buildInfoRow('Date Borrowed :', record.dateBorrowed),
            // Info Row: Return Date
            _buildInfoRow('Date Returned :', record.dateReturned),
            // Info Row: Approver
            _buildInfoRow('Approved by :', record.approver),
            // Info Row: Receiver (Only show if returned)
            if (record.status == HistoryStatus.returned)
              _buildInfoRow('Received by :', record.receiver),
          ],
        ),
      ),
    );
  }

  // Helper widget to build a labeled info row
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoLabel(label),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for fixed width labels
  Widget _buildInfoLabel(String label) {
    return SizedBox(
      width: 120, // Adjusted width for history details
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}
