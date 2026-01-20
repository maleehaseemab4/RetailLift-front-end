import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shoplifting_app/providers/app_state.dart';
import 'package:shoplifting_app/widgets/app_drawer.dart';
import 'package:shoplifting_app/widgets/notification_menu.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch app state
    final appState = context.watch<AppState>();
    final isDarkMode =
        appState.themeMode == ThemeMode.dark ||
        (appState.themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: InkWell(
          onTap: () => Navigator.pushReplacementNamed(context, '/'),
          child: Text(
            'RetailLift',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [const NotificationMenu(), const SizedBox(width: 8)],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          // Appearance Section
          _buildSectionHeader(context, 'Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Use a darker color palette'),
            secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            value: isDarkMode,
            onChanged: (value) {
              appState.toggleTheme(value);
            },
          ),

          const Divider(),

          // Notifications Section
          _buildSectionHeader(context, 'Notifications'),
          SwitchListTile(
            title: const Text('Enable Alerts'),
            subtitle: const Text('Receive notifications for new incidents'),
            secondary: const Icon(Icons.notifications_active),
            value: appState.notificationsEnabled,
            onChanged: (value) {
              appState.toggleNotifications(value);
            },
          ),

          const Divider(),

          // About Section
          _buildSectionHeader(context, 'About'),
          ListTile(
            title: const Text('Version'),
            trailing: const Text('1.0.0'),
            leading: const Icon(Icons.info_outline),
          ),
          ListTile(
            title: const Text('Terms of Service'),
            leading: const Icon(Icons.description_outlined),
            onTap: () {
              // Mock navigation
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
