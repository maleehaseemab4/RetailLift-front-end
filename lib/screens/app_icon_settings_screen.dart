import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoplifting_app/providers/app_icon_provider.dart';

class AppIconSettingsScreen extends StatelessWidget {
  const AppIconSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final iconProvider = Provider.of<AppIconProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('App Icon Selection')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: iconProvider.icons
            .map(
              (icon) => ListTile(
                leading: Icon(Icons.apps),
                title: Text(icon),
                trailing: iconProvider.selectedIcon == icon
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => iconProvider.setSelectedIcon(icon),
              ),
            )
            .toList(),
      ),
    );
  }
}
