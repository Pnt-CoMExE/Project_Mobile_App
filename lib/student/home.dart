import 'package:flutter/material.dart';
import 'request.dart'; // Import the Request screen
import 'history.dart'; // Import the History screen

// Enum for managing item status (Kept here for main logic)
enum ItemStatus { available, disable, borrowed, pending }

// Model class for item data (Kept here for main logic)
class SportItem {
  final String name;
  final IconData icon;
  int quantity;
  ItemStatus status;

  SportItem({
    required this.name,
    required this.icon,
    required this.quantity,
    required this.status,
  });
}

// ==========================================================
// Main Widget: HomeScreen (Now acts as the Navigator and Home Content)
// ==========================================================

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0; // For BottomNavBar: 0=Home, 1=Request, 2=History

  // Define the list of pages to be navigated
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    // Initialize the list of pages. Note: _HomeScreenContent is the actual content of the Home tab.
    _widgetOptions = <Widget>[
      const _HomeScreenContent(), // 0: The actual Home content (as a sub-widget)
      const Request(), // 1: Request screen (from request.dart)
      const History(), // 2: History screen (from history.dart)
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Function to show the Logout confirmation dialog (Logic remains the same)
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Text(
            'Are you sure to Logout',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.white, size: 20),
              label: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              onPressed: () {
                print("User logged out!");
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Helper to determine the title based on selected index
  String get _appBarTitle {
    switch (_selectedIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'My Requests';
      case 2:
        return 'Borrow History';
      default:
        return 'App';
    }
  }

  // Helper to determine the icon based on selected index
  IconData get _appBarIcon {
    switch (_selectedIndex) {
      case 0:
        return Icons.home;
      case 1:
        return Icons.notifications;
      case 2:
        return Icons.calendar_today;
      default:
        return Icons.home;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        leading: Icon(_appBarIcon, color: Colors.white, size: 30),
        title: Text(
          _appBarTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 30),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      // Use IndexedStack to display the selected page
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      // Bottom Navigation Bar (The link to other pages)
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          // 1. Home Tab (Icon: The first one)
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _selectedIndex == 0
                    ? Colors.white.withOpacity(0.3)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.home_outlined),
            ),
            label: 'Home',
          ),
          // 2. Request Tab (Icon: The middle one)
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _selectedIndex == 1
                    ? Colors.white.withOpacity(0.3)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_outlined),
            ),
            label: 'Requests',
          ),
          // 3. History Tab (Icon: The last one)
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _selectedIndex == 2
                    ? Colors.white.withOpacity(0.3)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calendar_today_outlined),
            ),
            label: 'History',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.7),
        backgroundColor: Colors.deepPurple,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: _onItemTapped, // This function changes _selectedIndex
      ),
    );
  }
}

// ==========================================================
// Home Content (Moved from _HomeScreenState.build() to a separate widget)
// ==========================================================

class _HomeScreenContent extends StatefulWidget {
  const _HomeScreenContent();

  @override
  State<_HomeScreenContent> createState() => __HomeScreenContentState();
}

class __HomeScreenContentState extends State<_HomeScreenContent> {
  bool _showConfirmationCard = false; // Toggle confirmation card visibility
  SportItem? _selectedItem; // Track the item being borrowed
  String _selectedReturnDay = 'Tomorrow'; // Default value for the dropdown

  // Mock-up data list
  final List<SportItem> _items = [
    SportItem(
      name: 'Volleyball',
      icon: Icons.sports_volleyball,
      quantity: 6,
      status: ItemStatus.available,
    ),
    SportItem(
      name: 'Badminton',
      icon: Icons.sports_tennis,
      quantity: 5,
      status: ItemStatus.disable,
    ),
    SportItem(
      name: 'Basketball',
      icon: Icons.sports_basketball,
      quantity: 0,
      status: ItemStatus.borrowed,
    ),
    SportItem(
      name: 'Tennis',
      icon: Icons.sports_tennis,
      quantity: 6,
      status: ItemStatus.available,
    ),
    SportItem(
      name: 'Petanque',
      icon: Icons.circle_outlined,
      quantity: 0,
      status: ItemStatus.pending,
    ),
    SportItem(
      name: 'Futsal',
      icon: Icons.sports_soccer,
      quantity: 6,
      status: ItemStatus.available,
    ),
  ];

  // Check if user already has an active borrow or pending request
  bool _hasActiveBorrow() {
    return _items.any(
      (item) =>
          item.status == ItemStatus.borrowed ||
          item.status == ItemStatus.pending,
    );
  }

  // Show borrow limit dialog
  void _showBorrowLimitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const Text(
                'You can borrow only 1 item!!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Icon(
                Icons.warning_amber_rounded,
                size: 52,
                color: Colors.grey[700],
              ),
              const SizedBox(height: 16),
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Show return day chooser
  void _showReturnDayDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // Use a local variable to hold the dialog's state
        String dialogSelectedDay = _selectedReturnDay;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              title: const Text('Choose return day'),
              content: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: dialogSelectedDay,
                    items: <String>['Tomorrow', 'In 2 days', 'In 3 days'].map((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setDialogState(() {
                          dialogSelectedDay = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    // This is the final confirmation
                    setState(() {
                      if (_selectedItem != null) {
                        // Find the actual item in the list and update its status
                        final itemToUpdate = _items.firstWhere(
                          (item) => item.name == _selectedItem!.name,
                        );

                        itemToUpdate.status = ItemStatus.pending;
                        itemToUpdate.quantity = 0; // Item is now pending

                        _selectedReturnDay =
                            dialogSelectedDay; // Save the choice
                      }
                      _hideConfirmation(); // Hide the confirmation card
                    });
                    Navigator.of(dialogContext).pop(); // Close this dialog
                    print(
                      'Item ${_selectedItem?.name} borrow request sent, return: $_selectedReturnDay',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Function to show the confirmation card
  void _triggerConfirmation(SportItem item) {
    setState(() {
      _selectedItem = item;
      _showConfirmationCard = true;
    });
  }

  // Function to hide the confirmation card (when 'No' or 'Confirm' is pressed)
  void _hideConfirmation() {
    setState(() {
      _showConfirmationCard = false;
      _selectedItem = null; // Clear selection
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: _items.length + (_showConfirmationCard ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (_showConfirmationCard) {
          if (index == 0) {
            // Show the confirmation card as the first item
            return ConfirmationCard(
              onConfirm: () {
                _showReturnDayDialog();
              },
              onNo: () {
                _hideConfirmation();
              },
            );
          }
          // Adjust the index for the sport item list
          final itemIndex = index - 1;
          return SportItemCard(
            item: _items[itemIndex],
            onTap: () {
              if (_items[itemIndex].status == ItemStatus.available) {
                if (_hasActiveBorrow()) {
                  _showBorrowLimitDialog();
                } else {
                  _triggerConfirmation(_items[itemIndex]);
                }
              }
            },
          );
        } else {
          // Show the list normally
          return SportItemCard(
            item: _items[index],
            onTap: () {
              if (_items[index].status == ItemStatus.available) {
                if (_hasActiveBorrow()) {
                  _showBorrowLimitDialog();
                } else {
                  _triggerConfirmation(_items[index]);
                }
              }
            },
          );
        }
      },
    );
  }
}

// ==========================================================
// Helper Widgets (ItemCard and ConfirmationCard - remain the same)
// ==========================================================

// Widget for the item card
class SportItemCard extends StatelessWidget {
  final SportItem item;
  final VoidCallback onTap;

  const SportItemCard({super.key, required this.item, required this.onTap});

  // Helper to get color based on status
  Color _getStatusColor(ItemStatus status) {
    switch (status) {
      case ItemStatus.available:
        return Colors.green.shade600;
      case ItemStatus.disable:
        return Colors.red.shade600;
      case ItemStatus.borrowed:
        return Colors.blue.shade600;
      case ItemStatus.pending:
        return Colors.yellow.shade700;
    }
  }

  // Helper to get text based on status
  String _getStatusText(ItemStatus status) {
    switch (status) {
      case ItemStatus.available:
        return 'Available';
      case ItemStatus.disable:
        return 'Disable';
      case ItemStatus.borrowed:
        return 'Borrowed';
      case ItemStatus.pending:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: Colors.grey.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Image/Icon
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[200],
                  child: Icon(item.icon, size: 40, color: Colors.grey[600]),
                ),
              ),
              const SizedBox(width: 16),
              // Name and Quantity
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 50,
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                        child: Text(
                          item.quantity.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Status
              Chip(
                label: Text(
                  _getStatusText(item.status),
                  style: TextStyle(
                    color: item.status == ItemStatus.pending
                        ? Colors.black87
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: _getStatusColor(item.status),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget for the borrow confirmation card
class ConfirmationCard extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onNo;

  const ConfirmationCard({
    super.key,
    required this.onConfirm,
    required this.onNo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: Colors.grey.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Do you confirm borrow (item at choose before)?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: onNo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text(
                    'No',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
