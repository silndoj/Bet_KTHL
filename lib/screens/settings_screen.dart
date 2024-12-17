import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/arbitrage_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  String _refreshInterval = '5';
  String _currency = 'USD';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable dark theme'),
            value: _darkMode,
            onChanged: (bool value) {
              setState(() {
                _darkMode = value;
              });
              // TODO: Implement theme switching
            },
          ),
          const Divider(),
          const _SectionHeader(title: 'Notifications'),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Get notified about new opportunities'),
            value: _notifications,
            onChanged: (bool value) {
              setState(() {
                _notifications = value;
              });
              // TODO: Implement notification settings
            },
          ),
          const Divider(),
          const _SectionHeader(title: 'Arbitrage Settings'),
          ListTile(
            title: const Text('Default Currency'),
            subtitle: Text(_currency),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    title: const Text('Select Currency'),
                    children: ['USD', 'EUR', 'GBP', 'AUD'].map((currency) {
                      return SimpleDialogOption(
                        onPressed: () {
                          setState(() {
                            _currency = currency;
                          });
                          Navigator.pop(context);
                        },
                        child: Text(currency),
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),
          ListTile(
            title: const Text('Refresh Interval'),
            subtitle: Text('$_refreshInterval minutes'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    title: const Text('Select Interval'),
                    children: ['1', '5', '10', '15', '30'].map((interval) {
                      return SimpleDialogOption(
                        onPressed: () {
                          setState(() {
                            _refreshInterval = interval;
                          });
                          Navigator.pop(context);
                        },
                        child: Text('$interval minutes'),
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),
          Consumer<ArbitrageProvider>(
            builder: (context, arbitrageProvider, child) {
              return ListTile(
                title: const Text('Default Stake'),
                subtitle: Text('\$${arbitrageProvider.totalStake}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  final controller = TextEditingController(
                    text: arbitrageProvider.totalStake.toString(),
                  );
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Set Default Stake'),
                        content: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            prefixText: '\$',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              final newStake = double.tryParse(controller.text);
                              if (newStake != null && newStake > 0) {
                                arbitrageProvider.setTotalStake(newStake);
                                Navigator.pop(context);
                              }
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
