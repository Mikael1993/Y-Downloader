import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QualitySelector extends StatefulWidget {
  final Function(String quality) onSelect;
  final String? title;
<<<<<<< Updated upstream
  final String? thumbnailUrl;
  final String? uploader;
=======
  final String? uploader;
  final String? thumbnail;
>>>>>>> Stashed changes
  final int? duration;

  const QualitySelector({
    super.key,
    required this.onSelect,
    this.title,
<<<<<<< Updated upstream
    this.thumbnailUrl,
    this.uploader,
=======
    this.uploader,
    this.thumbnail,
>>>>>>> Stashed changes
    this.duration,
  });

  @override
  State<QualitySelector> createState() => _QualitySelectorState();
}

class _QualitySelectorState extends State<QualitySelector> {
  String selected = "192";

<<<<<<< Updated upstream
  final List<Map<String, dynamic>> _options = [
    {
      "value": "320",
      "label": "320 KBPS",
      "badge": "ULTRA",
      "desc": "High-fidelity audio, largest file size",
      "icon": Icons.high_quality_rounded,
    },
    {
      "value": "256",
      "label": "256 KBPS",
      "badge": "HIGH",
      "desc": "Excellent quality, great for music",
      "icon": Icons.music_note_rounded,
    },
    {
      "value": "192",
      "label": "192 KBPS",
      "badge": "RECOMMENDED",
      "desc": "Balanced quality and file size",
      "icon": Icons.headphones_rounded,
    },
    {
      "value": "128",
      "label": "128 KBPS",
      "badge": "ECO",
      "desc": "Standard quality, saves storage",
      "icon": Icons.audiotrack_rounded,
    },
  ];

  String _estimateSize(String bitrateStr) {
    if (widget.duration == null || widget.duration! <= 0) {
      return "";
    }
    try {
      final bitrate = double.parse(bitrateStr);
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
                // Drag handle indicator
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
=======
  final List<Map<String, String>> _qualities = [
    {
      "value": "128",
      "label": "STANDARD QUALITY",
      "kbps": "128 KBPS",
      "desc": "Saves device storage, faster downloads",
      "icon": "speed_rounded"
    },
    {
      "value": "192",
      "label": "HIGH QUALITY",
      "kbps": "192 KBPS",
      "desc": "Optimal audio fidelity, recommended balance",
      "icon": "equalizer_rounded"
    },
    {
      "value": "320",
      "label": "ULTRA QUALITY",
      "kbps": "320 KBPS",
      "desc": "Maximum audio resolution, larger file size",
      "icon": "music_video_rounded"
    },
  ];

  IconData _getQualityIcon(String? iconName) {
    switch (iconName) {
      case "speed_rounded":
        return Icons.speed_rounded;
      case "music_video_rounded":
        return Icons.music_video_rounded;
      case "equalizer_rounded":
      default:
        return Icons.equalizer_rounded;
    }
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return "0:00";
    final hrs = seconds ~/ 3600;
    final mins = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    final secsStr = secs.toString().padLeft(2, '0');
    if (hrs > 0) {
      final minsStr = mins.toString().padLeft(2, '0');
      return "$hrs:$minsStr:$secsStr";
    } else {
      return "$mins:$secsStr";
    }
  }

  String _getEstimatedSize(int kbps) {
    if (widget.duration == null || widget.duration! <= 0) return "";
    final bytes = widget.duration! * (kbps * 1000) / 8;
    final mb = bytes / (1024 * 1024);
    return "~${mb.toStringAsFixed(1)} MB";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F11),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(
            color: Colors.white12,
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- Drag Handle Pill ---
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 20),
            height: 5,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),

          // --- Video Preview Card ---
          if (widget.title != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF151517),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withOpacity(0.06),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  if (widget.thumbnail != null && widget.thumbnail!.isNotEmpty)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            widget.thumbnail!,
                            width: 76,
                            height: 52,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 76,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.music_note_rounded, color: Colors.white24, size: 24),
                            ),
                          ),
                        ),
                        if (widget.duration != null && widget.duration! > 0)
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.75),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _formatDuration(widget.duration!),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  else
                    Container(
                      width: 76,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.music_note_rounded, color: Colors.white24, size: 24),
                    ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                        if (widget.uploader != null && widget.uploader!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.uploader!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // --- Header ---
          Row(
            children: [
              Icon(Icons.tune_rounded, color: accent, size: 18),
              const SizedBox(width: 8),
              Text(
                "SELECT AUDIO QUALITY",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 1.5,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // --- Quality Options List ---
          Column(
            children: _qualities.map((item) {
              final val = item["value"]!;
              final isSelected = selected == val;
              final estSize = _getEstimatedSize(int.parse(val));

              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => selected = val);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  decoration: BoxDecoration(
                    color: isSelected ? accent.withOpacity(0.06) : const Color(0xFF141416),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? accent : Colors.white.withOpacity(0.04),
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: accent.withOpacity(0.04),
                              blurRadius: 10,
                              spreadRadius: 1,
                            )
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Icon Container
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? accent.withOpacity(0.15) : Colors.white.withOpacity(0.04),
                        ),
                        child: Icon(
                          _getQualityIcon(item["icon"]),
                          color: isSelected ? accent : Colors.white38,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Quality Text & Badges
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  item["label"]!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 1.1,
                                    color: isSelected ? Colors.white : Colors.white70,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isSelected ? accent.withOpacity(0.2) : Colors.white10,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item["kbps"]!,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected ? accent : Colors.white38,
                                    ),
                                  ),
                                ),
                                if (estSize.isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isSelected ? accent.withOpacity(0.12) : Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      estSize,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected ? accent.withOpacity(0.8) : Colors.white38,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              item["desc"]!,
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected ? Colors.white54 : Colors.white38,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Radio Selection Indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? accent : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? accent : Colors.white24,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.black,
                                size: 14,
                              )
                            : null,
                      ),
                    ],
>>>>>>> Stashed changes
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
                      "SELECT QUALITY",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Video info card if details are passed
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

                // Quality list options
                Column(
                  children: _options.map((opt) {
                    final isSelected = selected == opt["value"];
                    final optionIcon = opt["icon"] as IconData;
                    final estSize = _estimateSize(opt["value"]!);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => setState(() => selected = opt["value"]),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? accent.withValues(alpha: 0.08) : cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? accent : Colors.white.withValues(alpha: 0.06),
                              width: isSelected ? 1.5 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: accent.withValues(alpha: 0.12),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              // Selection/Quality Icon
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isSelected ? accent : Colors.white.withValues(alpha: 0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  optionIcon,
                                  color: isSelected ? Colors.black : Colors.white70,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Text content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          opt["label"]!,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected ? Colors.white : Colors.white70,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? accent.withValues(alpha: 0.2)
                                                : Colors.white.withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            opt["badge"]!,
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                              color: isSelected ? accent : Colors.white54,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                        if (estSize.isNotEmpty) ...[
                                          const Spacer(),
                                          Text(
                                            estSize,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected ? Colors.white : Colors.white54,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      opt["desc"]!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isSelected ? Colors.white70 : Colors.white38,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Checkmark indicator
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? accent : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected ? accent : Colors.white24,
                                    width: 1.5,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.black,
                                        size: 14,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Download Button
                ElevatedButton(
                  onPressed: () {
                    widget.onSelect(selected);
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
                      const Text(
                        "START DOWNLOAD",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
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
<<<<<<< Updated upstream
        ),
=======
          const SizedBox(height: 14),

          // --- Action Button ---
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              widget.onSelect(selected);
              Navigator.pop(context);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 56,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: accent,
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.3),
                    blurRadius: 16,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download_rounded, color: Colors.black, size: 22),
                  SizedBox(width: 8),
                  Text(
                    "START DOWNLOAD",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Colors.black,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
>>>>>>> Stashed changes
      ),
    );
  }
}