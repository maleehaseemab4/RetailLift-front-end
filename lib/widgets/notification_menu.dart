import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoplifting_app/providers/app_state.dart';

//import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationMenu extends StatelessWidget {
  const NotificationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch AppState for notifications
    final appState = context.watch<AppState>();
    final notifications = appState.notifications;

    return PopupMenuButton<String>(
      icon: Stack(
        children: [
          const Icon(Icons.notifications_outlined),
          if (notifications.isNotEmpty)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                child: Text(
                  '${notifications.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 8),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      onSelected: (value) {
        if (value == 'clear') {
          appState.clearNotifications();
        }
      },
      itemBuilder: (BuildContext context) {
        if (notifications.isEmpty) {
          return [
            const PopupMenuItem<String>(
              enabled: false,
              child: Text('No new notifications'),
            ),
          ];
        }

        List<PopupMenuEntry<String>> items = notifications.map((notification) {
          return PopupMenuItem<String>(
            value: notification.id,
            child: Row(
              children: [
                Icon(
                  notification.type == 'warning'
                      ? Icons.warning_amber_rounded
                      : Icons.info_outline,
                  color: notification.type == 'warning'
                      ? Colors.orange
                      : const Color(0xFF001F3F),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    notification.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        }).toList();

        items.add(const PopupMenuDivider());
        items.add(
          const PopupMenuItem<String>(
            value: 'clear',
            child: Center(
              child: Text('Clear All', style: TextStyle(color: Colors.red)),
            ),
          ),
        );

        return items;
      },
    );
  }
}
