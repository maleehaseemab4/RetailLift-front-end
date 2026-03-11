import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:shoplifting_app/providers/app_state.dart';
import 'package:shoplifting_app/widgets/notification_menu.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final appState = context.watch<AppState>();
    final colorScheme = Theme.of(context).colorScheme;
    final initials = _getInitials(user);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: const [NotificationMenu(), SizedBox(width: 8)],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        children: [
          // Avatar
          Center(
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withOpacity(0.15),
                border: Border.all(color: colorScheme.primary, width: 2),
              ),
              child: initials.isNotEmpty
                  ? Center(
                      child: Text(
                        initials,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    )
                  : Icon(
                      HugeIcons.strokeRoundedUser,
                      size: 44,
                      color: colorScheme.primary,
                    ),
            ),
          ),
          const SizedBox(height: 14),
          if (user?.displayName?.isNotEmpty == true)
            Center(
              child: Text(
                user!.displayName!,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (user?.email?.isNotEmpty == true)
            Center(
              child: Text(
                user!.email!,
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.55),
                  fontSize: 13,
                ),
              ),
            ),
          const SizedBox(height: 32),
          const Divider(),
          ListTile(
            leading: Icon(
              HugeIcons.strokeRoundedMail01,
              color: colorScheme.primary,
            ),
            title: const Text('Email'),
            subtitle: Text(user?.email ?? 'Not signed in'),
          ),
          ListTile(
            leading: Icon(
              HugeIcons.strokeRoundedShieldEnergy,
              color: colorScheme.primary,
            ),
            title: const Text('Auth Provider'),
            subtitle: Text(
              user?.providerData.isNotEmpty == true
                  ? user!.providerData.first.providerId
                  : 'Guest',
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              HugeIcons.strokeRoundedMoon02,
              color: colorScheme.primary,
            ),
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle app appearance'),
            trailing: Switch(
              value:
                  appState.themeMode == ThemeMode.dark ||
                  (appState.themeMode == ThemeMode.system &&
                      MediaQuery.platformBrightnessOf(context) ==
                          Brightness.dark),
              onChanged: appState.toggleTheme,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              HugeIcons.strokeRoundedLogoutCircle01,
              color: Colors.red,
            ),
            title: const Text('Log Out', style: TextStyle(color: Colors.red)),
            onTap: () {
              appState.logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  String _getInitials(User? user) {
    if (user?.displayName?.isNotEmpty == true) {
      final parts = user!.displayName!.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return parts[0][0].toUpperCase();
    }
    if (user?.email?.isNotEmpty == true) {
      return user!.email![0].toUpperCase();
    }
    return '';
  }
}
