import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _RingPainter({required this.progress, required this.color, this.strokeWidth = 16});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bgPaint = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, 2 * math.pi, false, bgPaint);

    final start = -math.pi / 2;
    final sweep = (progress.clamp(0.0, 1.0)) * 2 * math.pi;
    canvas.drawArc(rect, start, sweep, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}

class DownloadDetailScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const DownloadDetailScreen({super.key, required this.job});

  @override
  State<DownloadDetailScreen> createState() => _DownloadDetailScreenState();
}

class _DownloadDetailScreenState extends State<DownloadDetailScreen> {
  late Map<String, dynamic> jobState;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    // Bind directly to the passed reference so updates propagate to the parent list
    jobState = widget.job;
    startPolling();
  }

  @override
  void didUpdateWidget(covariant DownloadDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.job != oldWidget.job) {
      setState(() {
        jobState = widget.job;
      });
    }
  }

  void startPolling() {
    final status = jobState["status"]?.toString().toLowerCase() ?? "";
    if (status == "completed" || status == "error" || status == "cancelled") {
      return;
    }

    timer = Timer.periodic(Duration(milliseconds: 600), (_) async {
      try {
        final data = await ApiService.getProgress(jobState["job_id"]);

        if (!mounted) return;

        setState(() {
          jobState["progress"] = (data["progress"] ?? 0) / 100;

          if (data["status"] == "processing") {
            jobState["progress"] = 0.95;
          }

          jobState["status"] = data["status"];
          jobState["speed"] = data["speed"] ?? 0;
          jobState["eta"] = data["eta"] ?? 0;
          jobState["downloaded"] = data["downloaded"] ?? 0;
          jobState["total"] = data["total"] ?? 0;
          if (data["error"] != null) {
            jobState["error_message"] = data["error"].toString();
          } else if (data["error_message"] != null) {
            jobState["error_message"] = data["error_message"].toString();
          }
        });

        if (data["status"] == "completed" ||
            data["status"] == "error" ||
            data["status"] == "cancelled") {
          timer?.cancel();
        }
      } catch (e) {
        if (!mounted) return;
        // Handle 404 or other errors gracefully
        if (e.toString().contains("404") || e.toString().contains("not found")) {
          setState(() {
            jobState["status"] = "error";
            jobState["error_message"] = "Job not found on server";
          });
          timer?.cancel();
        }
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final progress = jobState["progress"] ?? 0.0;
    final status = jobState["status"]?.toString().toLowerCase() ?? "";
    final speedMbps = ((jobState["speed"] ?? 0) / (1024 * 1024)).toDouble();
    final screenWidth = MediaQuery.of(context).size.width;
    final progressSize = math.min(320.0, math.max(260.0, screenWidth - 72));
    final innerSize = progressSize - 56;

    final isActive = status == "starting" || 
        status == "downloading" || 
        status == "processing";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "DOWNLOAD DETAILS",
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
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 80),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      SizedBox(height: 12),

                      /// RADIAL PROGRESS
                      SizedBox(
                        height: progressSize,
                        width: progressSize,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: Size(progressSize, progressSize),
                              painter: _RingPainter(
                                progress: progress,
                                color: accent,
                                strokeWidth: 16,
                              ),
                            ),
                            Container(
                              height: innerSize,
                              width: innerSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF101010),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "${(progress * 100).toInt()}",
                                      style: TextStyle(
                                        fontSize: 82,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "PERCENT",
                                    style: TextStyle(
                                      letterSpacing: 2,
                                      color: accent,
                                      fontSize: 10,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        height: 6,
                                        width: 6,
                                        decoration: BoxDecoration(
                                          color: status == "completed" 
                                              ? Colors.greenAccent 
                                              : status == "error" 
                                                  ? Colors.redAccent 
                                                  : accent,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          status.toUpperCase(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white54,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),

                      SizedBox(height: 32),

                      /// DETAILS CARD
                      Container(
                        padding: EdgeInsets.all(20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: Color(0xFF161618),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              jobState["title"] ?? "No Title",
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 16),
                            
                            if (isActive) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${speedMbps.toStringAsFixed(1)} MB/s",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "CURRENT SPEED",
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.white54,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "${jobState["eta"] ?? 0}s",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: accent,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "TIME REMAINING",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.white54,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ] else ...[
                              Divider(color: Colors.white12, height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("FORMAT", style: TextStyle(color: Colors.white54, fontSize: 12)),
                                  Text(
                                    (jobState["format_type"] ?? "mp3").toString().toUpperCase(),
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("STORAGE STATUS", style: TextStyle(color: Colors.white54, fontSize: 12)),
                                  Text(
                                    status == "error"
                                        ? "Failed"
                                        : status == "cancelled"
                                            ? "Cancelled"
                                            : jobState["save_status"] == "saved_to_phone"
                                                ? "Saved to Phone"
                                                : jobState["save_status"] == "saving_to_phone"
                                                    ? "Saving..."
                                                    : "Cached on Server",
                                    style: TextStyle(
                                      color: status == "error"
                                          ? Colors.redAccent
                                          : status == "cancelled"
                                              ? Colors.white38
                                              : jobState["save_status"] == "saved_to_phone" 
                                                  ? Colors.greenAccent 
                                                  : Colors.white70, 
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              if (status == "error") ...[
                                SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.red.withOpacity(0.2)),
                                  ),
                                  child: Text(
                                    (jobState["error_message"] ?? jobState["error"] ?? "The download failed on the server. Make sure cookies are configured if YouTube requires verification.")
                                        .toString(),
                                    style: TextStyle(color: Colors.redAccent, fontSize: 11, height: 1.4),
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  /// ACTION BUTTON
                  Padding(
                    padding: EdgeInsets.only(bottom: 16, top: 24),
                    child: GestureDetector(
                      onTap: () async {
                        if (isActive) {
                          try {
                            await ApiService.cancel(jobState["job_id"]);
                            if (!context.mounted) return;
                            setState(() {
                              jobState["status"] = "cancelled";
                            });
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Cancel failed: ${ApiService.formatErrorMessage(e)}")),
                            );
                          }
                        } else {
                          // Pop with "delete" so parent deletes it
                          Navigator.pop(context, "delete");
                        }
                      },
                      child: Container(
                        height: 56,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: isActive ? Colors.white10 : accent,
                          border: isActive ? Border.all(color: Colors.white24) : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isActive ? Icons.close_rounded : Icons.delete_outline_rounded,
                              color: isActive ? Colors.white : Colors.black,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              isActive ? "CANCEL DOWNLOAD" : "DELETE FROM HISTORY",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isActive ? Colors.white : Colors.black,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
