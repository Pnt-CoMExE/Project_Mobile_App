import 'package:flutter/material.dart';

// Redefine Status for this screen's context
enum RequestStatus { pending, approved, rejected }

class RequestItem {
  final String name;
  final String dateRequested; // วันที่ยืม (Borrow Date)
  final String timeRequested; // เวลาที่ยืม
  final String returnOn; // วันที่คืน (Return Date)
  final RequestStatus status;

  const RequestItem({
    required this.name,
    required this.dateRequested,
    required this.timeRequested,
    required this.returnOn,
    required this.status,
  });
}

// --- CONST MOCK DATA (MOVED OUTSIDE CLASS) ---
const List<RequestItem> mockRequests = [
  //RequestItem(
   // name: 'Volleyball',
   // dateRequested: '20 Oct 2568',
   // timeRequested: '17:00:50',
    //returnOn: '21 Oct 2568',
   // status: RequestStatus.approved,
 // ),
  RequestItem(
    name: 'Petanque',
    dateRequested: '25 Oct 2568',
    timeRequested: '10:30:00',
    returnOn: '26 Oct 2568',
    status: RequestStatus.pending,
  ),
  //RequestItem(
  //  name: 'Basketball',
  //  dateRequested: '15 Oct 2568',
  //  timeRequested: '09:00:00',
   // returnOn: '18 Oct 2568',
  //  status: RequestStatus.rejected,
  //),
];
// ---------------------------------------------

class RequestPage extends StatelessWidget {
  const RequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the data using the top-level const variable
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: mockRequests.length,
      itemBuilder: (context, index) {
        final item = mockRequests[index];
        // Use the new RequestResultCard widget for the detailed view
        return RequestResultCard(item: item);
      },
    );
  }
}

// Helper for image URLs based on item name (for demonstration)
String _getItemImageUrl(String name) {
  switch (name) {
    case 'Volleyball':
      return 'assets/images/volleyball.png';
    case 'Petanque':
      return 'assets/images/petanque.png';
    case 'Basketball':
      return 'assets/images/basketball.png';
    default:
      return 'https://placehold.co/70x70/F2F2F2/000000?text=Item';
  }
}

class RequestResultCard extends StatelessWidget {
  final RequestItem item;
  const RequestResultCard({super.key, required this.item});

  // Function to get the status background color
  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return Colors.yellow.shade700;
      case RequestStatus.approved:
        return Colors.green.shade600;
      case RequestStatus.rejected:
        return Colors.red.shade600;
    }
  }

  // Function to get the status text
  String _getStatusText(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.approved:
        return 'Approved';
      case RequestStatus.rejected:
        return 'Rejected';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(item.status);
    final statusText = _getStatusText(item.status);

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
                  child: Image.asset(
                    _getItemImageUrl(item.name),
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
                    item.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            // Info Row: Item Type
            _buildInfoRow('Sport :', item.name),
            // Info Row: Borrow Date and Time (รวมกันตามภาพ)
            _buildInfoRow('Borrow :', '${item.dateRequested}'),
            _buildInfoRow(
              '',
              item.timeRequested,
            ), // Displaying time on its own line
            // Info Row: Return Date
            _buildInfoRow('Date return :', item.returnOn),
            // Info Row: Status (Chip)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoLabel('Status :'),
                // Status Chip (Aligned right)
                Chip(
                  label: Text(
                    statusText,
                    style: TextStyle(
                      color: item.status == RequestStatus.pending
                          ? Colors.black87
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  backgroundColor: statusColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                ),
              ],
            ),
            // *** REMOVED: Cancel button is removed from here ***
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
      width: 100, // Fixed width for alignment
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
