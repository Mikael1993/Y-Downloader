import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  final Color currentAccentColor;
  final ValueChanged<Color> onAccentColorChanged;
  final VoidCallback onHistoryCleared;

  const SettingsScreen({
    super.key,
    required this.currentAccentColor,
    required this.onAccentColorChanged,
    required this.onHistoryCleared,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int _selectedColorHex;
  late int _concurrentThreads;
  late bool _wifiOnly;

  final List<Map<String, dynamic>> _accentColors = [
    {"name": "Crimson", "value": 0xFFFF1A1A},
    {"name": "Pink", "value": 0xFFF43F5E},
    {"name": "Purple", "value": 0xFF8B5CF6},
    {"name": "Blue", "value": 0xFF3B82F6},
    {"name": "Green", "value": 0xFF10B981},
    {"name": "Amber", "value": 0xFFF59E0B},
  ];

  @override
  void initState() {
    super.initState();
    _selectedColorHex = StorageService.getAccentColor();
    _concurrentThreads = StorageService.getConcurrentThreads();
    _wifiOnly = StorageService.getWifiOnly();
  }

  Future<void> _updateColor(int colorHex) async {
    setState(() {
      _selectedColorHex = colorHex;
    });
    await StorageService.setAccentColor(colorHex);
    widget.onAccentColorChanged(Color(colorHex));
  }

  Future<void> _updateThreads(int threads) async {
    setState(() {
      _concurrentThreads = threads;
    });
    await StorageService.setConcurrentThreads(threads);
  }

  Future<void> _updateWifiOnly(bool val) async {
    setState(() {
      _wifiOnly = val;
    });
    await StorageService.setWifiOnly(val);
  }

  void _showConfirmation({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161618),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text("CONFIRM", style: TextStyle(color: widget.currentAccentColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeAccent = widget.currentAccentColor;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "SETTINGS",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white70,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- ACCENT COLOR ---
              const Text(
                "THEME ACCENT",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white54),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF161618),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _accentColors.map((colorMap) {
                        final isSelected = _selectedColorHex == colorMap["value"];
                        final hex = colorMap["value"] as int;
                        return GestureDetector(
                          onTap: () => _updateColor(hex),
                          child: Container(
                            height: 36,
                            width: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(hex),
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 3)
                                  : null,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Color(hex).withOpacity(0.4),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      )
                                    ]
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- CONCURRENT DOWNLOADS ---
              const Text(
                "CONCURRENT DOWNLOADS",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white54),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF161618),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Max Download Threads", style: TextStyle(fontSize: 14)),
                        Text(
                          "$_concurrentThreads",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: activeAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _concurrentThreads.toDouble(),
                      min: 1,
                      max: 8,
                      divisions: 7,
                      activeColor: activeAccent,
                      inactiveColor: Colors.white10,
                      onChanged: (val) => _updateThreads(val.round()),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- CONNECTION LIMITATIONS ---
              const Text(
                "NETWORK",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white54),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF161618),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("WiFi Only Downloads", style: TextStyle(fontSize: 14)),
                          SizedBox(height: 2),
                          Text(
                            "Restrict active downloads to WiFi network only",
                            style: TextStyle(fontSize: 11, color: Colors.white38),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _wifiOnly,
                      activeTrackColor: activeAccent.withOpacity(0.5),
                      activeThumbColor: activeAccent,
                      onChanged: _updateWifiOnly,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- HISTORY AND RESET MANAGEMENT ---
              const Text(
                "HISTORY & SYSTEM",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white54),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF161618),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.history_rounded, color: Colors.white70),
                      title: const Text("Clear Search History"),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white30),
                      onTap: () => _showConfirmation(
                        title: "Clear Searches",
                        message: "Are you sure you want to delete all recent search query suggestions?",
                        onConfirm: () async {
                          await StorageService.clearSearchHistory();
                          widget.onHistoryCleared();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Search history cleared")),
                            );
                          }
                        },
                      ),
                    ),
                    const Divider(color: Colors.white12, height: 1),
                    ListTile(
                      leading: const Icon(Icons.delete_sweep_rounded, color: Colors.white70),
                      title: const Text("Clear Download History"),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white30),
                      onTap: () => _showConfirmation(
                        title: "Clear Downloads",
                        message: "Are you sure you want to delete the complete download history? Saved files on your phone won't be deleted.",
                        onConfirm: () async {
                          await StorageService.clearDownloads();
                          widget.onHistoryCleared();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Download history cleared")),
                            );
                          }
                        },
                      ),
                    ),
                    const Divider(color: Colors.white12, height: 1),
                    ListTile(
                      leading: const Icon(Icons.restart_alt_rounded, color: Colors.white70),
                      title: const Text("Reset Settings to Default"),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white30),
                      onTap: () => _showConfirmation(
                        title: "Reset Settings",
                        message: "Are you sure you want to restore all settings to their default values?",
                        onConfirm: () async {
                          await StorageService.resetSettings();
                          await _updateColor(0xFFFF1A1A);
                          await _updateThreads(1);
                          await _updateWifiOnly(false);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Settings reset successfully")),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
