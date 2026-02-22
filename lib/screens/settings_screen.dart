import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset('assets/icons/logo.svg', width: 32, height: 32),
              const SizedBox(width: 8),
              Text(
                'RetailLift',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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

          // Account Section
          _buildSectionHeader(context, 'Account'),
          ListTile(
            title: const Text('Add Account'),
            leading: const Icon(Icons.person_add_outlined),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/login',
                arguments: {'canBack': true},
              );
            },
          ),
          ListTile(
            title: const Text('Log Out'),
            leading: const Icon(Icons.logout, color: Colors.red),
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () {
              appState.logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
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
          ListTile(
            title: const Text('Test Notification'),
            subtitle: const Text('Triggers a test alert tone'),
            leading: const Icon(Icons.volume_up_outlined),
            onTap: () {
              appState.addNotification(
                'Test Notification ${DateTime.now().second}',
                'info',
              );
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
