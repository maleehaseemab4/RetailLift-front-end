import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoplifting_app/providers/alert_provider.dart';

class AlertSettingsScreen extends StatelessWidget {
  const AlertSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alertProvider = Provider.of<AlertProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Alert Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Alert Type',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ...AlertType.values.map(
            (type) => RadioListTile<AlertType>(
              title: Text(type.name.toUpperCase()),
              value: type,
              groupValue: alertProvider.alertType,
              onChanged: (value) => alertProvider.setAlertType(value!),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Alarm Volume',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Slider(
            value: alertProvider.volume,
            min: 0,
            max: 100,
            divisions: 100,
            label: '${alertProvider.volume.round()}%',
            onChanged: (value) => alertProvider.setVolume(value),
          ),
          const SizedBox(height: 20),
          const Text(
            'Alert Tone',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          DropdownButton<String>(
            value: alertProvider.selectedTone,
            items: alertProvider.tones
                .map((tone) => DropdownMenuItem(value: tone, child: Text(tone)))
                .toList(),
            onChanged: (value) => alertProvider.setSelectedTone(value!),
          ),
          ElevatedButton(
            onPressed: alertProvider.previewTone,
            child: const Text('Preview Tone'),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text('Auto-Screenshot on Detection'),
            value: alertProvider.autoScreenshot,
            onChanged: (value) => alertProvider.setAutoScreenshot(value),
          ),
        ],
      ),
    );
  }
}
