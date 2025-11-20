import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:project_mobile_app/config/ip.dart';

final String _apiBaseUrl = kSportApiBaseUrl;
final String _imageBaseUrl = kImageBaseUrl;

class StaffSportCategory {
  final int categoryId;
  final String name;
  final String image;
  final int availableCount;
  final String status; // Available / Disable / Pending / Borrowed

  StaffSportCategory({
    required this.categoryId,
    required this.name,
    required this.image,
    required this.availableCount,
    required this.status,
  });

  factory StaffSportCategory.fromJson(Map<String, dynamic> json) {
    return StaffSportCategory(
      categoryId: int.parse(json['category_id'].toString()),
      name: json['category_name'] ?? '',
      image: json['category_image'] ?? '',
      availableCount: int.parse(json['available_count']?.toString() ?? '0'),
      status: json['category_status'] ?? 'Available',
    );
  }
}

class StaffItem {
  final String itemId;
  final int categoryId;
  final String name;
  final String image;
  final String status; // Available / Disable / Pending / Borrowed

  StaffItem({
    required this.itemId,
    required this.categoryId,
    required this.name,
    required this.image,
    required this.status,
  });

  factory StaffItem.fromJson(Map<String, dynamic> json) {
    return StaffItem(
      itemId: json['item_id'].toString(),
      categoryId: int.parse(json['category_id'].toString()),
      name: json['item_name'] ?? '',
      image: json['item_image'] ?? '',
      status: json['status'] ?? 'Available',
    );
  }
}

// =======================================
// Staff Equipment Page (Category + Item)
// =======================================
class EquipmentPage extends StatefulWidget {
  const EquipmentPage({super.key});

  @override
  State<EquipmentPage> createState() => _EquipmentPageState();

  // ย้าย StreamController มาไว้ที่นี่เพื่อให้เข้าถึงจากภายนอกได้ง่าย
  static final StreamController<void> updateStreamController =
      StreamController<void>.broadcast();
  static Stream<void> get updateStream => updateStreamController.stream;

  // Method สำหรับแจ้งเตือนการอัพเดท
  static void notifyUpdate() {
    updateStreamController.add(null);
  }
}

class _EquipmentPageState extends State<EquipmentPage> {
  bool _isLoading = true;
  String? _username;

  // category + item
  List<StaffSportCategory> _categories = [];
  List<StaffItem> _items = [];
  StaffSportCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _initData();

    // ฟังการแจ้งเตือนการอัพเดทจากหน้าอื่น
    EquipmentPage.updateStream.listen((_) {
      if (mounted) {
        _refreshData();
      }
    });
  }

  Future<void> _initData() async {
    await _loadUser();
    await _fetchCategories();
    setState(() => _isLoading = false);
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('u_username') ?? 'Staff';
    });
  }

  Future<void> _refreshData() async {
    if (_selectedCategory != null) {
      await _fetchItemsForCategory(_selectedCategory!);
    }
    await _fetchCategories();
    _showSnackBar('Equipment data updated automatically ✅');
  }

  // -----------------------------
  // API: โหลดรายการกีฬา (Staff)
  // -----------------------------
  Future<void> _fetchCategories() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.get(Uri.parse('$_apiBaseUrl/staff/categories'));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        final List data = body['data'] as List;
        setState(() {
          _categories = data
              .map((e) => StaffSportCategory.fromJson(e))
              .toList();
        });
      } else {
        final body = json.decode(res.body);
        _showSnackBar(
          'Failed to load sports: ${body['message']}',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
    setState(() => _isLoading = false);
  }

  // -----------------------------
  // API: โหลด item ใน category
  // -----------------------------
  Future<void> _fetchItemsForCategory(StaffSportCategory cat) async {
    setState(() {
      _isLoading = true;
      _selectedCategory = cat;
      _items = [];
    });

    try {
      final res = await http.get(
        Uri.parse('$_apiBaseUrl/staff/items/${cat.categoryId}'),
      );

      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        final List data = body['data'] as List;
        setState(() {
          _items = data.map((e) => StaffItem.fromJson(e)).toList();
        });
      } else {
        final body = json.decode(res.body);
        _showSnackBar(
          'Failed to load items: ${body['message']}',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }

    setState(() => _isLoading = false);
  }

  // -----------------------------
  // API: เพิ่มประเภทกีฬาใหม่
  // -----------------------------
  Future<void> _addCategory({
    required String name,
    required String imagePath,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_apiBaseUrl/staff/category'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'category_name': name, 'category_image': imagePath}),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        _showSnackBar('Add sport success ✅');
        await _fetchCategories();
      } else {
        final body = json.decode(res.body);
        _showSnackBar('Add failed: ${body['message']}', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }

  // แก้ไขชื่อ/รูป Category
  Future<void> _updateCategory({
    required int categoryId,
    required String name,
    required String imagePath,
  }) async {
    try {
      final res = await http.put(
        Uri.parse('$_apiBaseUrl/staff/category/$categoryId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'category_name': name, 'category_image': imagePath}),
      );

      if (res.statusCode != 200) {
        final body = json.decode(res.body);
        _showSnackBar('Update failed: ${body['message']}', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }

  // API: เปลี่ยนสถานะ Category Available / Disable
  Future<void> _updateCategoryStatus({
    required int categoryId,
    required String status,
  }) async {
    try {
      final res = await http.put(
        Uri.parse('$_apiBaseUrl/staff/category/$categoryId/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );

      if (res.statusCode != 200) {
        final body = json.decode(res.body);
        _showSnackBar(
          'Change status failed: ${body['message']}',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }

  // API: Add Item
  Future<void> _addItem({
    required StaffSportCategory cat,
    required String name,
    required String imagePath,
    required String status,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_apiBaseUrl/staff/item'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'category_id': cat.categoryId,
          'item_name': name,
          'item_image': imagePath,
        }),
      );

      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        final String newItemId = body['item_id'].toString();

        if (status == 'Disable') {
          await _updateItemStatus(itemId: newItemId, status: 'Disable');
        }

        _showSnackBar('Item added ✅');
        await _fetchItemsForCategory(cat);
        await _fetchCategories();
      } else {
        final body = json.decode(res.body);
        _showSnackBar('Add item failed: ${body['message']}', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }

  // API: Edit Item
  Future<void> _updateItem({
    required StaffItem item,
    required String name,
    required String imagePath,
    required String status,
  }) async {
    try {
      await http.put(
        Uri.parse('$_apiBaseUrl/staff/item/${item.itemId}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'item_name': name, 'item_image': imagePath}),
      );

      await _updateItemStatus(itemId: item.itemId, status: status);

      _showSnackBar('Item updated ✅');
      if (_selectedCategory != null) {
        await _fetchItemsForCategory(_selectedCategory!);
        await _fetchCategories();
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }

  // API: เปลี่ยนสถานะ Item
  Future<void> _updateItemStatus({
    required String itemId,
    required String status,
  }) async {
    try {
      await http.put(
        Uri.parse('$_apiBaseUrl/staff/item/$itemId/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }

  // SnackBar helper
  void _showSnackBar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // Dialog: ยืนยัน
  Future<bool> _showConfirmDialog(String message) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 18),
                const Icon(Icons.info_outline, size: 48, color: Colors.black54),
                const SizedBox(height: 22),
                SizedBox(
                  width: 140,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    return result ?? false;
  }

  // Dialog: Add Sport (Category)
  Future<void> _showAddCategoryDialog() async {
    final nameCtrl = TextEditingController();
    String imagePath = '';

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 40,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 1,
                          ),
                          color: Colors.grey.shade100,
                        ),
                        child: imagePath.isEmpty
                            ? const Center(
                                child: Text(
                                  'Add picture',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  _imageBaseUrl + imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => const Center(
                                    child: Icon(Icons.image_not_supported),
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Image path (ex. images/swim.png)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (val) {
                          setStateDialog(() => imagePath = val.trim());
                        },
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Sport Name',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () async {
                            final ok = await _showConfirmDialog(
                              'Are you confirm to add new sport?',
                            );
                            if (!ok) return;

                            if (nameCtrl.text.trim().isEmpty ||
                                imagePath.isEmpty) {
                              _showSnackBar(
                                'Please fill name and image path',
                                isError: true,
                              );
                              return;
                            }
                            Navigator.pop(context);
                            await _addCategory(
                              name: nameCtrl.text.trim(),
                              imagePath: imagePath,
                            );
                          },
                          child: const Text(
                            'Add',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Dialog: Edit Sport (Category) — ลบ status radio ตามข้อ 1
  Future<void> _showEditCategoryDialog(StaffSportCategory cat) async {
    final nameCtrl = TextEditingController(text: cat.name);
    String imagePath = cat.image;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 40,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 1,
                          ),
                          color: Colors.grey.shade100,
                        ),
                        child: imagePath.isEmpty
                            ? const Center(
                                child: Text(
                                  'Add picture',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  _imageBaseUrl + imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => const Center(
                                    child: Icon(Icons.image_not_supported),
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'You can change image.',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Image path (ex. images/swim.png)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        controller: TextEditingController(text: imagePath),
                        onChanged: (val) {
                          setStateDialog(() => imagePath = val.trim());
                        },
                      ),
                      const SizedBox(height: 18),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Sport name',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () async {
                            final ok = await _showConfirmDialog(
                              'Are you confirm to edit?',
                            );
                            if (!ok) return;

                            if (nameCtrl.text.trim().isEmpty ||
                                imagePath.isEmpty) {
                              _showSnackBar(
                                'Please fill name and image path',
                                isError: true,
                              );
                              return;
                            }

                            Navigator.pop(context);

                            await _updateCategory(
                              categoryId: cat.categoryId,
                              name: nameCtrl.text.trim(),
                              imagePath: imagePath,
                            );

                            await _fetchCategories();
                            _showSnackBar('Edit sport success ✅');
                          },
                          child: const Text(
                            'Edit',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Dialog: Add Item
  Future<void> _showAddItemDialog(StaffSportCategory cat) async {
    final nameCtrl = TextEditingController();
    String imagePath = '';
    String status = 'Available';

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 40,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 1,
                          ),
                          color: Colors.grey.shade100,
                        ),
                        child: imagePath.isEmpty
                            ? const Center(
                                child: Text(
                                  'Add picture',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  _imageBaseUrl + imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => const Center(
                                    child: Icon(Icons.image_not_supported),
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Image path (ex. images/badminton.png)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (val) {
                          setStateDialog(() => imagePath = val.trim());
                        },
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Item name',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Status',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      RadioListTile<String>(
                        title: const Text('Available'),
                        value: 'Available',
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        groupValue: status,
                        onChanged: (v) {
                          setStateDialog(() => status = v!);
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('Disable'),
                        value: 'Disable',
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        groupValue: status,
                        onChanged: (v) {
                          setStateDialog(() => status = v!);
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () async {
                            if (nameCtrl.text.trim().isEmpty ||
                                imagePath.isEmpty) {
                              _showSnackBar(
                                'Please fill item name and image path',
                                isError: true,
                              );
                              return;
                            }
                            final ok = await _showConfirmDialog(
                              'Are you confirm to add new item?',
                            );
                            if (!ok) return;

                            Navigator.pop(context);
                            await _addItem(
                              cat: cat,
                              name: nameCtrl.text.trim(),
                              imagePath: imagePath,
                              status: status,
                            );
                          },
                          child: const Text(
                            'Add Item',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Dialog: Edit Item
  Future<void> _showEditItemDialog(StaffItem item) async {
    // ❗ ตามข้อ 2: บล็อกถ้า Borrowed หรือ Pending
    if (item.status == 'Borrowed' || item.status == 'Pending') {
      _showSnackBar(
        "Can't edit this item at borrowed or pending",
        isError: true,
      );
      return;
    }

    final nameCtrl = TextEditingController(text: item.name);
    String imagePath = item.image;
    String status = (item.status == 'Disable' || item.status == 'Available')
        ? item.status
        : 'Available';

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 40,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 1,
                          ),
                          color: Colors.grey.shade100,
                        ),
                        child: imagePath.isEmpty
                            ? const Center(
                                child: Text(
                                  'Add picture',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  _imageBaseUrl + imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => const Center(
                                    child: Icon(Icons.image_not_supported),
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Image path (ex. images/badminton.png)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        controller: TextEditingController(text: imagePath),
                        onChanged: (val) {
                          setStateDialog(() => imagePath = val.trim());
                        },
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Item name',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Status',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      RadioListTile<String>(
                        title: const Text('Available'),
                        value: 'Available',
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        groupValue: status,
                        onChanged: (v) {
                          setStateDialog(() => status = v!);
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('Disable'),
                        value: 'Disable',
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        groupValue: status,
                        onChanged: (v) {
                          setStateDialog(() => status = v!);
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () async {
                            if (nameCtrl.text.trim().isEmpty ||
                                imagePath.isEmpty) {
                              _showSnackBar(
                                'Please fill item name and image path',
                                isError: true,
                              );
                              return;
                            }
                            final ok = await _showConfirmDialog(
                              'Are you confirm to edit item?',
                            );
                            if (!ok) return;

                            Navigator.pop(context);
                            await _updateItem(
                              item: item,
                              name: nameCtrl.text.trim(),
                              imagePath: imagePath,
                              status: status,
                            );
                          },
                          child: const Text(
                            'Save Edit',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // -----------------------------
  // UI
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    final bool showItemList = _selectedCategory != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Column(
        children: [
          _buildHeader(showItemList),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: showItemList
                        ? _buildItemList()
                        : _buildCategoryList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool showItemList) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            if (showItemList)
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
                onPressed: () {
                  setState(() {
                    _selectedCategory = null;
                    _items = [];
                  });
                },
              )
            else
              const SizedBox(width: 8),
            Text(
              showItemList ? _selectedCategory?.name ?? '' : "",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
              ),
              onPressed: _showAddCategoryDialog,
              child: const Text(
                'Add Sport',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildLegend(),
          const SizedBox(height: 18),
          if (_categories.isEmpty)
            const Center(child: Text('No sports found.'))
          else
            Column(
              children: _categories.map((c) => _buildCategoryCard(c)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildLegend() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        const Text(
          "Sports Item status.",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _dot("Available", Colors.green),
            _dot("Disable", Colors.red),
            _dot("Pending", Colors.yellow.shade700),
            _dot("Borrowed", Colors.blue),
          ],
        ),
      ],
    ),
  );

  Widget _dot(String text, Color color) => Row(
    children: [
      Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 5),
      Text(text, style: const TextStyle(fontSize: 13)),
    ],
  );

  Color _statusColor(String status) {
    switch (status) {
      case 'Available':
        return Colors.green;
      case 'Disable':
        return Colors.red;
      case 'Pending':
        return Colors.yellow.shade700;
      case 'Borrowed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildCategoryCard(StaffSportCategory cat) {
    return InkWell(
      onTap: () => _fetchItemsForCategory(cat),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        clipBehavior: Clip.antiAlias,
        child: Container(
          color: const Color(0xFFF4F1F7),
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  _imageBaseUrl + cat.image,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(6),
                      width: 45,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Text(
                          cat.availableCount.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 80,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () => _showEditCategoryDialog(cat),
                      child: const Text(
                        'Edit',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: _statusColor(cat.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    child: Text(
                      cat.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemList() {
    final cat = _selectedCategory;
    if (cat == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
              ),
              onPressed: () => _showAddItemDialog(cat),
              child: const Text(
                'Add Item',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: _items.isEmpty
              ? const Center(child: Text('No items in this category.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _items.length,
                  itemBuilder: (context, i) {
                    final item = _items[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () => _showEditItemDialog(item),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          color: const Color(0xFFF4F1F7),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  _imageBaseUrl + item.image,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 70,
                                    height: 70,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.broken_image),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    width: 80,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      ),
                                      onPressed: () =>
                                          _showEditItemDialog(item),
                                      child: const Text(
                                        'Edit',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _statusColor(item.status),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      item.status,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
