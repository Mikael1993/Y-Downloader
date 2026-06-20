import 'package:flutter/material.dart';
import 'download_detail_screen.dart';

class DownloadsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> downloads;
  final Function(String) onCancelDownload;
  final Function(Map<String, dynamic>) onDeleteDownload;

  const DownloadsScreen({
    super.key,
    required this.downloads,
    required this.onCancelDownload,
    required this.onDeleteDownload,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "DOWNLOADS",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 20),
              
              if (downloads.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_download_outlined,
                          size: 64,
                          color: theme.textTheme.bodySmall!.color!.withOpacity(0.3),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "No downloads in history",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyMedium!.color!.withOpacity(0.8),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Your downloaded files will appear here.",
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textTheme.bodySmall!.color!.withOpacity(0.6),
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
                          margin: EdgeInsets.only(bottom: 16),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                height: 75,
                                width: 75,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      value: job["progress"] ?? 0.0,
                                      strokeWidth: 5,
                                      backgroundColor:
                                          theme.scaffoldBackgroundColor,
                                      valueColor: AlwaysStoppedAnimation(
                                          theme.colorScheme.primary),
                                    ),
                                    AnimatedSwitcher(
                                      duration: Duration(milliseconds: 300),
                                      child: Text(
                                        "${((job["progress"] ?? 0.0) * 100).toStringAsFixed(0)}%",
                                        key: ValueKey(job["progress"]),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      job["title"] ?? "No Title",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      status.toUpperCase(),
                                      style: TextStyle(
                                        color: status == "completed" 
                                            ? Colors.greenAccent 
                                            : theme.textTheme.bodySmall!.color!.withOpacity(0.7),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    if (job["save_status"] != null)
                                      Padding(
                                        padding: EdgeInsets.only(top: 6),
                                        child: Text(
                                          job["save_status"] == "saving_to_phone"
                                              ? "Saving to phone..."
                                              : job["save_status"] == "saved_to_phone"
                                                  ? "Saved to phone"
                                                  : (job["save_error"] ??
                                                      "Phone save failed"),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: job["save_status"] == "saved_to_phone"
                                                ? Colors.greenAccent
                                                : theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    if (isActive && job["speed"] != null && job["speed"] > 0)
                                      Padding(
                                        padding: EdgeInsets.only(top: 6),
                                        child: Text(
                                          "${(job["speed"] / (1024 * 1024)).toStringAsFixed(1)} MB/s",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: theme.textTheme.bodySmall!.color,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  if (isActive) {
                                    onCancelDownload(job["job_id"]);
                                  } else {
                                    onDeleteDownload(job);
                                  }
                                },
                                icon: Icon(
                                  isActive
                                      ? Icons.close_rounded
                                      : Icons.delete_outline_rounded,
                                ),
                                color: theme.colorScheme.primary,
                              ),
                            ],
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
