import 'package:flutter/material.dart';

class NotificationMenu extends StatelessWidget {
  const NotificationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.notifications_outlined),
      onSelected: (value) {
        // Handle notification click
      },
      itemBuilder: (BuildContext context) {
        return [
          const PopupMenuItem<String>(
            value: '1',
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Text('Suspicious activity at Aisle 3'),
              ],
            ),
          ),
          const PopupMenuItem<String>(
            value: '2',
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text('System check complete'),
              ],
            ),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem<String>(
            value: 'clear',
            child: Center(child: Text('Clear All')),
          ),
        ];
      },
    );
  }
}
