import 'package:flutter/material.dart';
import 'download_detail_screen.dart';

class DownloadsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> downloads;
  final Function(String) onCancelDownload;
  final Function(Map<String, dynamic>) onDeleteDownload;
  final Function(String) onPauseDownload;
  final Function(String) onResumeDownload;

  const DownloadsScreen({
    super.key,
    required this.downloads,
    required this.onCancelDownload,
    required this.onDeleteDownload,
    required this.onPauseDownload,
    required this.onResumeDownload,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final cardColor = const Color(0xFF161618);

    // Calculate active vs completed counts
    final activeCount = downloads.where((job) {
      final s = job["status"]?.toString().toLowerCase() ?? "";
      return s == "starting" || s == "downloading" || s == "processing";
    }).length;

    final pausedCount = downloads.where((job) {
      final s = job["status"]?.toString().toLowerCase() ?? "";
      return s == "paused";
    }).length;

    final completedCount = downloads.where((job) {
      final s = job["status"]?.toString().toLowerCase() ?? "";
      return s == "completed";
    }).length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "DOWNLOADS",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (downloads.isNotEmpty)
                    Text(
                      "${downloads.length} ${downloads.length == 1 ? 'item' : 'items'} • $activeCount active • ${pausedCount > 0 ? '$pausedCount paused • ' : ''}$completedCount completed",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                        letterSpacing: 0.5,
                      ),
                    )
                  else
                    const Text(
                      "No items in download list",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white38,
                        letterSpacing: 0.5,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Content
              if (downloads.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.02),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.05),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.download_for_offline_rounded,
                            size: 64,
                            color: accent.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "No downloads yet",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            "Search for videos or paste a YouTube link on the search tab to start downloading.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white38,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: downloads.length,
                    itemBuilder: (context, index) {
                      // Show latest downloads first in the list
                      final job = downloads[downloads.length - 1 - index];
                      final status = job["status"]?.toString().toLowerCase() ?? "";
                      final isActive = status == "starting" || 
                          status == "downloading" || 
                          status == "processing";
                      final isPaused = status == "paused";
                      final progress = (job["progress"] as num?)?.toDouble() ?? 0.0;
                      final title = job["title"] ?? "No Title";
                      final uploader = job["uploader"] ?? "Unknown Creator";
                      final thumbnail = job["thumbnail"] ?? "";
                      final speedBytes = (job["speed"] as num?)?.toDouble() ?? 0.0;
                      final formatType = job["format_type"] ?? "mp3";
                      final downloaded = (job["downloaded"] as num?)?.toDouble() ?? 0.0;
                      final total = (job["total"] as num?)?.toDouble() ?? 0.0;

                      String progressText = "";
                      if (downloaded > 0 && total > 0) {
                        final downloadedMb = downloaded / (1024 * 1024);
                        final totalMb = total / (1024 * 1024);
                        progressText = "${downloadedMb.toStringAsFixed(1)} MB / ${totalMb.toStringAsFixed(1)} MB";
                      }

                      return GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DownloadDetailScreen(job: job),
                            ),
                          );
                          if (result == "delete") {
                            onDeleteDownload(job);
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.05),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left side: Thumbnail with fallback
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      width: 85,
                                      height: 60,
                                      color: Colors.white.withValues(alpha: 0.04),
                                      child: thumbnail.isNotEmpty
                                          ? Image.network(
                                              thumbnail,
                                              width: 85,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => const Center(
                                                child: Icon(Icons.music_video_rounded, color: Colors.white30, size: 28),
                                              ),
                                            )
                                          : const Center(
                                              child: Icon(Icons.music_video_rounded, color: Colors.white30, size: 28),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Middle side: Metadata & progress details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Title
                                        Text(
                                          title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        // Uploader
                                        Text(
                                          uploader,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.5),
                                            fontSize: 11,
                                          ),
                                        ),
                                        const SizedBox(height: 8),

                                        // Dynamic layouts based on status
                                        if (isActive || isPaused) ...[
                                          // Progress bar row
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                status == "starting"
                                                    ? "STARTING..."
                                                    : status == "processing"
                                                        ? "CONVERTING..."
                                                        : status == "paused"
                                                            ? "PAUSED"
                                                            : "DOWNLOADING...",
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: isPaused ? Colors.amber : accent,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              Text(
                                                "${(progress * 100).toStringAsFixed(0)}%",
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: isPaused ? Colors.amber : accent,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: LinearProgressIndicator(
                                              value: progress,
                                              minHeight: 4,
                                              backgroundColor: Colors.white.withValues(alpha: 0.05),
                                              valueColor: AlwaysStoppedAnimation<Color>(isPaused ? Colors.amber : accent),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          // Speed and Byte progress
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              if (speedBytes > 0)
                                                Text(
                                                  "${(speedBytes / (1024 * 1024)).toStringAsFixed(1)} MB/s",
                                                  style: const TextStyle(fontSize: 10, color: Colors.white38),
                                                )
                                              else
                                                const SizedBox.shrink(),
                                              if (progressText.isNotEmpty)
                                                Text(
                                                  progressText,
                                                  style: const TextStyle(fontSize: 10, color: Colors.white38),
                                                ),
                                            ],
                                          ),
                                        ] else ...[
                                          // Inactive / Finished statuses
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: status == "completed"
                                                      ? Colors.greenAccent.withValues(alpha: 0.1)
                                                      : status == "cancelled"
                                                          ? Colors.white.withValues(alpha: 0.05)
                                                          : Colors.redAccent.withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  status.toUpperCase(),
                                                  style: TextStyle(
                                                    color: status == "completed"
                                                        ? Colors.greenAccent
                                                        : status == "cancelled"
                                                            ? Colors.white54
                                                            : Colors.redAccent,
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                formatType.toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white30,
                                                ),
                                              ),
                                            ],
                                          ),
                                          // Save status text
                                          if (job["save_status"] != null) ...[
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Icon(
                                                  job["save_status"] == "saved_to_phone"
                                                      ? Icons.check_circle_outline_rounded
                                                      : job["save_status"] == "saving_to_phone"
                                                          ? Icons.hourglass_empty_rounded
                                                          : Icons.error_outline_rounded,
                                                  size: 12,
                                                  color: job["save_status"] == "saved_to_phone"
                                                      ? Colors.greenAccent
                                                      : job["save_status"] == "saving_to_phone"
                                                          ? accent
                                                          : Colors.redAccent,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    job["save_status"] == "saving_to_phone"
                                                        ? "Saving to device..."
                                                        : job["save_status"] == "saved_to_phone"
                                                            ? "Saved to Music"
                                                            : (job["save_error"] ?? "Failed to save"),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: job["save_status"] == "saved_to_phone"
                                                        ? Colors.greenAccent
                                                        : job["save_status"] == "saving_to_phone"
                                                            ? accent
                                                            : Colors.redAccent,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Right side: Action Buttons
                                  Align(
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isActive || isPaused) ...[
                                          IconButton(
                                            onPressed: () {
                                              if (isPaused) {
                                                onResumeDownload(job["job_id"]);
                                              } else {
                                                onPauseDownload(job["job_id"]);
                                              }
                                            },
                                            icon: Icon(
                                              isPaused
                                                  ? Icons.play_arrow_rounded
                                                  : Icons.pause_rounded,
                                              size: 22,
                                            ),
                                            color: isPaused ? Colors.amber : accent,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        IconButton(
                                          onPressed: () {
                                            if (isActive || isPaused) {
                                              onCancelDownload(job["job_id"]);
                                            } else {
                                              onDeleteDownload(job);
                                            }
                                          },
                                          icon: Icon(
                                            (isActive || isPaused)
                                                ? Icons.close_rounded
                                                : Icons.delete_outline_rounded,
                                            size: 20,
                                          ),
                                          color: (isActive || isPaused)
                                              ? Colors.white38
                                              : Colors.white24,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
