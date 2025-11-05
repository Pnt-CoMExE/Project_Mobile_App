import 'package:flutter/material.dart';
import 'package:project_mobile_app/lender/history.dart';
import 'home.dart';
import 'history.dart';

enum RequestStatus { pending, approved, rejected }

class RequestItem {
  final String name;
  final String dateRequested;
  final String timeRequested;
  final String returnOn;
  final RequestStatus status;

  const RequestItem({
    required this.name,
    required this.dateRequested,
    required this.timeRequested,
    required this.returnOn,
    required this.status,
  });
}

const List<RequestItem> mockRequests = [
  RequestItem(
    name: 'Petanque',
    dateRequested: '25 Oct 2568',
    timeRequested: '10:30:00',
    returnOn: '26 Oct 2568',
    status: RequestStatus.pending,
  ),
];

class RequestPage extends StatefulWidget {
  const RequestPage({super.key});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomePage(),
          transitionDuration: Duration.zero,
        ),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const History(),
          transitionDuration: Duration.zero,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const purpleColor = Color(0xFF673AB7); // สีเดียวกับในภาพ

    return Scaffold(
      backgroundColor: Colors.grey[50],

      appBar: AppBar(
        backgroundColor: purpleColor,
        automaticallyImplyLeading: false,
        title: Row(
          children: const [
            Icon(
              Icons.info_outline_rounded,
              color: Colors.white,
              size: 26,
            ),
            SizedBox(width: 8),
            Text(
              'Request Result',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Colors.white),
            onPressed: () {
              // เมื่อกด logout ให้กลับไปหน้า login
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: mockRequests.length,
        itemBuilder: (context, index) {
          final item = mockRequests[index];
          return RequestResultCard(item: item);
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: purpleColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: '',
          ),
        ],
      ),
    );
  }
}

// ================= Helper =================
String _getItemImageUrl(String name) {
  switch (name) {
    case 'Volleyball':
      return 'assets/images/volleyball.png';
    case 'Petanque':
      return 'assets/images/petanque.png';
    case 'Basketball':
      return 'assets/images/basketball.png';
    default:
      return 'assets/images/default.png';
  }
}

// ================= Request Card =================
class RequestResultCard extends StatelessWidget {
  final RequestItem item;
  const RequestResultCard({super.key, required this.item});

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
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.asset(
                    _getItemImageUrl(item.name),
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
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
            _buildInfoRow('Sport :', item.name),
            _buildInfoRow('Borrow :', item.dateRequested),
            _buildInfoRow('', item.timeRequested),
            _buildInfoRow('Date return :', item.returnOn),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoLabel('Status :'),
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) => Padding(
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

  Widget _buildInfoLabel(String label) => SizedBox(
        width: 100,
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
