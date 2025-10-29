// equipment.dart
import 'package:flutter/material.dart';

// Enum for managing item status
enum ItemStatus { available, disable, borrowed, pending }

ButtonStyle _greenBtn() {
  return ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    padding: const EdgeInsets.symmetric(vertical: 12),
    elevation: 2,
  );
}


class SportItem {
  String name;
  final IconData icon;
  int quantity;
  ItemStatus status;
  String? imagePath; // optional local image (for future use)
  String? itemId; // chosen ID

  SportItem({
    required this.name,
    required this.icon,
    required this.quantity,
    required this.status,
    this.imagePath,
    this.itemId,
  });
}

// ==========================================================
// Home (Equipment) Screen
// ==========================================================
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 1;
  final GlobalKey<__HomeScreenContentState> _contentKey =
      GlobalKey<__HomeScreenContentState>();

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/dashboard');
      return;
    }
    if (index == 2) {
      Navigator.pushReplacementNamed(context, '/return');
      return;
    } //
    if (index == 3) {
      Navigator.pushReplacementNamed(context, '/history');
      return;
    }
    setState(() => _selectedIndex = index);
  }

  String get _appBarTitle => _selectedIndex == 1 ? 'Home' : '';
  IconData get _appBarIcon =>
      _selectedIndex == 1 ? Icons.home : Icons.wifi_tethering;

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
            onPressed: () => Navigator.pop(c),
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
      // Gradient AppBar
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
              title: Text(_appBarTitle),
              leading: Icon(_appBarIcon, color: Colors.white),
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

      // Body
      body: _HomeScreenContent(key: _contentKey),

      // BottomNavigationBar
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
                ),
              ],
            ),
          ),
        ),
      ),

      // Green Add button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ElevatedButton(
        onPressed: () => _contentKey.currentState?.showAddItemDialog(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          elevation: 6,
        ),
        child: const Text(
          'Add',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ==========================================================
// Home Content (list + add overlay + edit overlay)
// ==========================================================
class _HomeScreenContent extends StatefulWidget {
  const _HomeScreenContent({super.key});

  @override
  State<_HomeScreenContent> createState() => __HomeScreenContentState();
}

class __HomeScreenContentState extends State<_HomeScreenContent> {
  final List<SportItem> _items = [
    SportItem(
      name: 'Volleyball',
      icon: Icons.sports_volleyball,
      quantity: 6,
      status: ItemStatus.available,
      itemId: '0601',
    ),
    SportItem(
      name: 'Badminton',
      icon: Icons.sports_tennis,
      quantity: 5,
      status: ItemStatus.disable,
      itemId: '0602',
    ),
    SportItem(
      name: 'Basketball',
      icon: Icons.sports_basketball,
      quantity: 2,
      status: ItemStatus.borrowed,
      itemId: '0603',
    ),
    SportItem(
      name: 'Tennis',
      icon: Icons.sports_tennis,
      quantity: 6,
      status: ItemStatus.available,
      itemId: '0604',
    ),
    SportItem(
      name: 'Petanque',
      icon: Icons.circle_outlined,
      quantity: 0,
      status: ItemStatus.pending,
      itemId: '0605',
    ),
    SportItem(
      name: 'Futsal',
      icon: Icons.sports_soccer,
      quantity: 6,
      status: ItemStatus.available,
      itemId: '0606',
    ),
  ];

  // ======= ADD OVERLAY (เดิม) =======
  void showAddItemDialog() {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    ItemStatus status = ItemStatus.available; // default
    List<String> errors = [];

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: StatefulBuilder(
            builder: (context, setLocal) {
              void validateAndSubmit() {
                final name = nameCtrl.text.trim();
                final qtyText = qtyCtrl.text.trim();

                final newErrors = <String>[];
                if (name.isEmpty) newErrors.add('Please fill item name');

                final qty = int.tryParse(qtyText);
                if (qty == null) {
                  newErrors.add('Quantity must be a number');
                } else if (qty < 1) {
                  newErrors.add('Quantity must more than or equal 1');
                }

                if (newErrors.isNotEmpty) {
                  setLocal(() => errors = newErrors);
                  return;
                }

                setState(() {
                  _items.add(
                    SportItem(
                      name: name,
                      icon: Icons.sports_soccer,
                      quantity: qty!,
                      status: status,
                      itemId: 'NEW', // mock
                    ),
                  );
                });
                Navigator.pop(context);
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (errors.isNotEmpty) _ErrorPanel(errors: errors),

                    // picture placeholder
                    GestureDetector(
                      onTap: () {},
                      child: _PictureBox(
                        child: const Text(
                          'Add picture',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Item name',
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameCtrl,
                      decoration: _input(''),
                      onChanged: (_) {
                        if (errors.isNotEmpty) setLocal(() => errors = []);
                      },
                    ),
                    const SizedBox(height: 14),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Quantity',
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                    ),
                    const SizedBox(height: 6),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Status',
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _StatusDropdown(
                      value: status,
                      onChanged: (v) => setLocal(() => status = v),
                    ),

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: validateAndSubmit,
                        style: _greenBtn(),
                        child: const Text(
                          'Add',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ======= EDIT OVERLAY =======
  void _openEditOverlay(SportItem item) {
    // 1) ถ้า borrowed -> แจ้งเตือนใน overlay และจบ
    if (item.status == ItemStatus.borrowed) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, size: 40, color: Colors.red),
                const SizedBox(height: 12),
                const Text(
                  "This item has borrow, can't edit for now",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    // mock: รายการ ID และสถานะของแต่ละ ID (รอเชื่อม DB)
    // เปลี่ยนได้ในภายหลังให้ดึงจากฐานข้อมูลจริง
    final Map<String, ItemStatus> idStatus = {
      '0601': ItemStatus.available,
      '0602': ItemStatus.disable,
      '0603': ItemStatus.disable,
      '0604': ItemStatus.available,
    };

    String selectedId = item.itemId ?? idStatus.keys.first;
    String name = item.name;
    ItemStatus status =
        (item.status == ItemStatus.available ||
            item.status == ItemStatus.disable)
        ? item.status
        : ItemStatus.available;

    List<String> errors = [];

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: StatefulBuilder(
            builder: (context, setLocal) {
              bool allDisabled = idStatus.values.every(
                (s) => s == ItemStatus.disable,
              );

              // ถ้า ID ทั้งหมด disable → บังคับ status = disable และเปลี่ยนปุ่ม Edit เป็นสีเขียว
              if (allDisabled) status = ItemStatus.disable;

              void onConfirm() {
                // ยืนยันจริงอีกชั้น
                showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Are you confirm to edit',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          const Icon(Icons.error_outline, size: 36),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: _greenBtn(),
                              onPressed: () {
                                // save changes
                                setState(() {
                                  item.name = name;
                                  item.itemId = selectedId;
                                  item.status = status;
                                });
                                Navigator.pop(context); // close confirm
                                Navigator.pop(context); // close edit
                              },
                              child: const Text('Confirm'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              void trySubmit() {
                final newErrors = <String>[];
                if (name.trim().isEmpty) newErrors.add('Please fill item name');

                // future place to add more validation (e.g., ID rules)

                if (newErrors.isNotEmpty) {
                  setLocal(() => errors = newErrors);
                  return;
                }
                onConfirm();
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Edit item',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    if (errors.isNotEmpty) _ErrorPanel(errors: errors),

                    // picture
                    GestureDetector(
                      onTap: () {
                        // TODO: image picker
                      },
                      child: _PictureBox(
                        child: item.imagePath == null
                            ? const Icon(
                                Icons.image,
                                size: 32,
                                color: Colors.black54,
                              )
                            : Image.asset(item.imagePath!, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Item name
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Item name',
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: TextEditingController(text: name),
                      onChanged: (v) {
                        name = v;
                        if (errors.isNotEmpty) setLocal(() => errors = []);
                      },
                      decoration: _input(''),
                    ),
                    const SizedBox(height: 14),

                    // Item ID (dropdown) - เชื่อมฐานข้อมูลทีหลัง
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Item ID',
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButton<String>(
                        value: selectedId,
                        isExpanded: true,
                        underline: const SizedBox.shrink(),
                        items: idStatus.keys
                            .map(
                              (id) =>
                                  DropdownMenuItem(value: id, child: Text(id)),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          setLocal(() {
                            selectedId = v;
                            // สามารถปรับ auto-status ตาม id ได้ถ้าต้องการ
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Status (2 ตัวเลือก)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Status',
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                    ),
                    const SizedBox(height: 6),
                    AbsorbPointer(
                      absorbing:
                          allDisabled, // ถ้า ID ทั้งหมด disable → ห้ามแก้สถานะ
                      child: Opacity(
                        opacity: allDisabled ? 0.7 : 1,
                        child: _StatusDropdown(
                          value: status,
                          onChanged: (v) => setLocal(() => status = v),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Edit button (แดงปกติ, เขียวเมื่อ allDisabled)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: trySubmit,
                        style: allDisabled
                            ? _greenBtn()
                            : ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                elevation: 2,
                              ),
                        child: const Text(
                          'Edit',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return Card(
          elevation: 3,
          shadowColor: Colors.grey.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            onTap: () => _openEditOverlay(item), // ✅ แตะเพื่อแก้ไข
            leading: Icon(item.icon, size: 40, color: Colors.grey[700]),
            title: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Qty: ${item.quantity} | ID: ${item.itemId ?? '-'}"),
            trailing: Chip(
              label: Text(
                item.status.name.toUpperCase(),
                style: TextStyle(
                  color: item.status == ItemStatus.pending
                      ? Colors.black
                      : Colors.white,
                ),
              ),
              backgroundColor: _getColor(item.status),
            ),
          ),
        );
      },
    );
  }

  Color _getColor(ItemStatus s) => switch (s) {
    ItemStatus.available => Colors.green.shade600,
    ItemStatus.disable => Colors.red.shade600,
    ItemStatus.borrowed => Colors.blue.shade600,
    ItemStatus.pending => Colors.yellow.shade700,
  };
}

// ---------- small UI helpers ----------
InputDecoration _input(String hint) => InputDecoration(
  hintText: hint, // '' for empty hint
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
);

class _StatusDropdown extends StatelessWidget {
  final ItemStatus value;
  final ValueChanged<ItemStatus> onChanged;
  const _StatusDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<ItemStatus>(
        value: value,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        items: const [
          DropdownMenuItem(
            value: ItemStatus.available,
            child: Text('Available'),
          ),
          DropdownMenuItem(value: ItemStatus.disable, child: Text('Disable')),
        ],
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

class _PictureBox extends StatelessWidget {
  final Widget child;
  const _PictureBox({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Center(child: child),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  final List<String> errors;
  const _ErrorPanel({required this.errors});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: errors
            .map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: Colors.red)),
                    Expanded(
                      child: Text(
                        e,
                        style: const TextStyle(color: Colors.red, height: 1.2),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
