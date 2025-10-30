import 'package:flutter/material.dart';

// [แก้ไข] ลบ Scaffold, AppBar, BottomNav ออก
// หน้านี้จะถูกแสดงใน IndexedStack ของ sdashboard.dart
class ReturnPage extends StatefulWidget {
  const ReturnPage({super.key});

  @override
  State<ReturnPage> createState() => _ReturnPageState();
}

class _ReturnPageState extends State<ReturnPage> {
  // [ลบ] _selectedIndex (ย้ายไป sdashboard.dart)

  // ---- Mock borrowed list (ยังคงเก็บไว้) ----
  final List<_BorrowItem> _borrowed = [
    _BorrowItem(
      title: 'Badminton Racket',
      id: '050102',
      username: 'James',
      borrowed: DateTime(2025, 10, 21),
      returnDate: DateTime(2025, 10, 21),
      image: 'assets/images/badminton.png',
    ),
    _BorrowItem(
      title: 'Volleyball',
      id: '060101',
      username: 'LnWZA007',
      borrowed: DateTime(2025, 10, 20),
      returnDate: DateTime(2025, 10, 21),
      image: 'assets/images/volleyball.png',
    ),
    _BorrowItem(
      title: 'Tennis Racket',
      id: '030103',
      username: 'Mike',
      borrowed: DateTime(2025, 10, 20),
      returnDate: DateTime(2025, 10, 21),
      image: 'assets/images/tennis.png',
    ),
  ];

  // [ลบ] _onItemTapped (ย้ายไป sdashboard.dart)
  // [ลบ] _showLogoutDialog (ย้ายไป sdashboard.dart)

  // ---- Helpers (ยังคงเก็บไว้) ----
  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final isEmpty = _borrowed.isEmpty;

    // [ลบ] Scaffold
    // [ลบ] AppBar
    // [ลบ] BottomNavigationBar

    // [แก้ไข] คืนค่า Body (เนื้อหา) ออกไปตรงๆ
    return isEmpty
        ? _EmptyState()
        : ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemBuilder: (_, i) {
              final item = _borrowed[i];
              return _ReturnCard(
                item: item,
                onReturn: () {
                  // Logic ของหน้านี้ยังทำงานได้เหมือนเดิม
                  setState(() {
                    _borrowed.removeAt(i); // remove this card
                  });
                },
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 18),
            itemCount: _borrowed.length,
          );
  }

  // ======= Card widget (ยังคงเก็บไว้) =======
  Widget _ReturnCard({
    required _BorrowItem item,
    required VoidCallback onReturn,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(2, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header + image
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, height: 1.4),
                      children: [
                        const TextSpan(
                          text: 'Equipment: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: '${item.title} - ${item.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _ImageThumb(
                  path: item.image,
                  fallbackIcon: Icons.sports_volleyball,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Username:  ${item.username}'),
            Text('Borrowed:  ${_fmt(item.borrowed)}'),
            Text('Return Date: ${_fmt(item.returnDate)}'),
            const SizedBox(height: 14),
            // RETURN button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: onReturn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF43A047), // green
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 1,
                ),
                child: const Text(
                  'RETURN',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======= Empty state (ยังคงเก็บไว้) =======
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'All Items have return',
              style: TextStyle(color: Colors.black54),
            ),
            SizedBox(height: 8),
            CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFEDE7F6),
              child: Icon(Icons.access_time, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}

// ======= small helpers / models (ยังคงเก็บไว้) =======
class _BorrowItem {
  final String title;
  final String id;
  final String username;
  final DateTime borrowed;
  final DateTime returnDate;
  final String image;

  _BorrowItem({
    required this.title,
    required this.id,
    required this.username,
    required this.borrowed,
    required this.returnDate,
    required this.image,
  });
}

class _ImageThumb extends StatelessWidget {
  final String path;
  final IconData fallbackIcon;
  const _ImageThumb({required this.path, required this.fallbackIcon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(1, 2)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Icon(fallbackIcon, size: 36, color: Colors.grey[600]),
      ),
    );
  }
}
