import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int _selectedIndex =
      3; // 0: network, 1: home, 2: clock, 3: history (this page)

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/dashboard');
      return;
    }
    if (index == 1) {
      Navigator.pushReplacementNamed(context, '/equipment');
      return;
    }
    if (index == 2) {
      Navigator.pushReplacementNamed(context, '/return');
      return;
    } //
    // index 3 = current
    setState(() => _selectedIndex = index);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Are you sure to Logout',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 52,
              color: Colors.grey[700],
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(c);
              Navigator.pushReplacementNamed(context, '/login');
            },
            icon: const Icon(Icons.logout, color: Colors.white, size: 20),
            label: const Text('Logout', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // === Gradient AppBar ===
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8E24AA), Color(0xFF4A148C)],
                begin: Alignment.topLeft,
                end: Alignment.topRight,
              ),
            ),
            child: AppBar(
              title: const Text('History'),
              leading: const Icon(Icons.calendar_today, color: Colors.white),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: _showLogoutDialog,
                ),
              ],
            ),
          ),
        ),
      ),

      // === Body: card UI like your image ===
      body: SingleChildScrollView(
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
                    _kvRow(
                      label: 'Item ID :',
                      valueWidget: _pillField('060101'),
                    ),
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
      ),

      // === Gradient BottomNavigationBar (routes wired) ===
      bottomNavigationBar: Container(
        height: 60,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8E24AA), Color(0xFF4A148C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.wifi_tethering),
                  label: '',
                ),
                BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
                BottomNavigationBarItem(
                  icon: Icon(Icons.access_time_filled),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today),
                  label: '',
                ), // History tab icon (4th)
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- small helpers ----------
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

