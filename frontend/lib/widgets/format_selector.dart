import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FormatSelector extends StatefulWidget {
  final Function(String format, String quality) onSelect;
  final String? title;
  final String? thumbnailUrl;
  final String? uploader;
  final int? duration;
  final String? videoUrl;

  const FormatSelector({
    super.key,
    required this.onSelect,
    this.title,
    this.thumbnailUrl,
    this.uploader,
    this.duration,
    this.videoUrl,
  });

  @override
  State<FormatSelector> createState() => _FormatSelectorState();
}

class _FormatSelectorState extends State<FormatSelector> {
  String selectedFormat = "mp3";
  String selectedQuality = "192";
  
  Map<String, dynamic>? availableFormats;
  bool loadingFormats = true;
  String? errorMessage;

  final Map<String, Map<String, dynamic>> formatOptions = {
    "mp3": {
      "label": "MP3 AUDIO",
      "icon": Icons.music_note_rounded,
      "desc": "Audio only, universal compatibility",
      "qualities": ["128", "192", "256", "320"],
    },
    "m4a": {
      "label": "M4A AUDIO",
      "icon": Icons.audiotrack_rounded,
      "desc": "High-quality audio, smaller file",
      "qualities": ["128", "192", "256", "320"],
    },
    "mp4": {
      "label": "MP4 VIDEO",
      "icon": Icons.video_camera_back_rounded,
      "desc": "Video with audio, most compatible",
      "qualities": ["best", "720p", "480p", "360p"],
    },
    "webm": {
      "label": "WEBM VIDEO",
      "icon": Icons.videocam_rounded,
      "desc": "Modern format, smaller size",
      "qualities": ["best", "720p", "480p", "360p"],
    },
  };

  @override
  void initState() {
    super.initState();
    _fetchAvailableFormats();
  }

  Future<void> _fetchAvailableFormats() async {
    if (widget.videoUrl == null || widget.videoUrl!.isEmpty) {
      setState(() {
        loadingFormats = false;
      });
      return;
    }

    try {
      final formats = await ApiService.fetchAvailableFormats(widget.videoUrl!);
      if (mounted) {
        setState(() {
          availableFormats = formats;
          loadingFormats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "Could not load available formats";
          loadingFormats = false;
        });
      }
    }
  }

  String _estimateSize(String quality) {
    if (widget.duration == null || widget.duration! <= 0) {
      return "";
    }
    try {
      final bitrate = double.tryParse(quality) ?? 192;
      final sizeInMb = (bitrate * 1000 * widget.duration!) / (8 * 1024 * 1024);
      if (sizeInMb >= 1024) {
        final sizeInGb = sizeInMb / 1024;
        return "~${sizeInGb.toStringAsFixed(1)} GB";
      } else if (sizeInMb < 0.1) {
        return "~${(sizeInMb * 1024).toStringAsFixed(0)} KB";
      }
      return "~${sizeInMb.toStringAsFixed(1)} MB";
    } catch (_) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final cardColor = const Color(0xFF161618);
    final formatOpts = formatOptions[selectedFormat];
    final qualities = formatOpts?["qualities"] as List<String>? ?? [];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F11),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.tune_rounded, color: accent, size: 22),
                    const SizedBox(width: 8),
                    const Text(
                      "SELECT FORMAT & QUALITY",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Video info
                if (widget.title != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.04),
                      ),
                    ),
                    child: Row(
                      children: [
                        if (widget.thumbnailUrl != null && widget.thumbnailUrl!.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              widget.thumbnailUrl!,
                              width: 72,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 72,
                                height: 48,
                                color: Colors.white12,
                                child: const Icon(Icons.music_video_rounded, color: Colors.white54),
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 72,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.music_video_rounded, color: Colors.white54),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.uploader ?? "Unknown Creator",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Format selection tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: formatOptions.entries.map((entry) {
                      final format = entry.key;
                      final info = entry.value;
                      final isSelected = selectedFormat == format;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedFormat = format;
                            selectedQuality = (info["qualities"] as List<String>).first;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? accent : cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? accent : Colors.white.withValues(alpha: 0.1),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                info["icon"] as IconData,
                                color: isSelected ? Colors.black : accent,
                                size: 20,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                format.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.black : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // Format description
                if (formatOpts != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      formatOpts["desc"] as String,
                      style: TextStyle(
                        color: accent,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),

                // Quality options
                Text(
                  "QUALITY",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  children: qualities.map((quality) {
                    final isSelected = selectedQuality == quality;
                    final estSize = _estimateSize(quality);

                    return GestureDetector(
                      onTap: () => setState(() => selectedQuality = quality),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? accent.withValues(alpha: 0.1) : cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? accent : Colors.white.withValues(alpha: 0.1),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? accent : Colors.transparent,
                                border: Border.all(
                                  color: isSelected ? accent : Colors.white24,
                                  width: 1.5,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.black, size: 12)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                quality.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : Colors.white70,
                                ),
                              ),
                            ),
                            if (estSize.isNotEmpty)
                              Text(
                                estSize,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected ? accent : Colors.white54,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Download button
                ElevatedButton(
                  onPressed: () {
                    widget.onSelect(selectedFormat, selectedQuality);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.black,
                    elevation: 4,
                    shadowColor: accent.withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.download_rounded, color: Colors.black, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "DOWNLOAD ${selectedFormat.toUpperCase()}",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
