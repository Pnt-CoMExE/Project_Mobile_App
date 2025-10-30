import 'package:flutter/material.dart';

// [แก้ไข] ลบ Scaffold, AppBar, BottomNav ออก
// หน้านี้จะถูกแสดงใน IndexedStack ของ sdashboard.dart
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // [ลบ] _selectedIndex (ย้ายไป sdashboard.dart)
  // [ลบ] _onItemTapped (ย้ายไป sdashboard.dart)
  // [ลบ] _showLogoutDialog (ย้ายไป sdashboard.dart)

  @override
  Widget build(BuildContext context) {
    // [ลบ] Scaffold
    // [ลบ] AppBar
    // [ลบ] BottomNavigationBar

    // [แก้ไข] คืนค่า Body (เนื้อหา) ออกไปตรงๆ
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(2, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item image
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(1, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/volleyball.png', //  replace with real asset
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.sports_volleyball,
                    size: 42,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Right column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Padding(
                    padding: EdgeInsets.only(top: 6, bottom: 12),
                    child: Text(
                      'Volleyball',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _kvRow(label: 'Item :', value: 'Volleyball'),
                  const SizedBox(height: 8),
                  _kvRow(label: 'Item ID :', valueWidget: _pillField('060101')),
                  const SizedBox(height: 8),
                  _kvRow(label: 'Date Borrowed :', value: '20 Oct 2568'),
                  const SizedBox(height: 8),
                  _kvRow(label: 'Date Returned :', value: '21 Oct 2568'),
                  const SizedBox(height: 8),
                  _kvRow(
                    label: 'Student :',
                    valueWidget: _pillField('LnwZa007'),
                  ),
                  const SizedBox(height: 8),
                  _kvRow(
                    labelWidget: const Text(
                      'Approve by :',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    valueWidget: _pillField('thanawit'),
                  ),
                  const SizedBox(height: 8),
                  _kvRow(
                    label: 'Return item by :',
                    valueWidget: _pillField('teerasak'),
                  ),

                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- small helpers (ยังคงเก็บไว้) ----------
  Widget _kvRow({
    String? label,
    Widget? labelWidget,
    String? value,
    Widget? valueWidget,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child:
              labelWidget ??
              Text(
                label ?? '',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: valueWidget ?? Text(value ?? '', textAlign: TextAlign.left),
        ),
      ],
    );
  }

  Widget _pillField(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text),
    );
  }
}
