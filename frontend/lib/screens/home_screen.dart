import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'download_detail_screen.dart';
import 'settings_screen.dart';
import '../widgets/quality_selector.dart';

class HomeScreen extends StatefulWidget {
  final List<Map<String, dynamic>> downloads;
  final Color accentColor;
  final ValueChanged<Color> onAccentColorChanged;
  final Function(Map<String, dynamic>) onAddDownload;
  final Function(Map<String, dynamic>) onDeleteDownload;
  final VoidCallback onViewAllDownloads;
  final VoidCallback onHistoryCleared;

  const HomeScreen({
    super.key,
    required this.downloads,
    required this.accentColor,
    required this.onAccentColorChanged,
    required this.onAddDownload,
    required this.onDeleteDownload,
    required this.onViewAllDownloads,
    required this.onHistoryCleared,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController controller = TextEditingController();

  Map<String, dynamic>? latestJob;
  Map<String, dynamic>? selectedVideo;
  List results = [];
  bool loading = false;
  String? statusMessage;

  Timer? clipboardTimer;
  String lastClipboardContent = "";
  String? detectedClipboardLink;
  List lastResults = [];
  List<String> searchHistory = [];
  List<String> suggestions = [];
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    startClipboardMonitoring();
    _loadSearchHistory();
  }

  @override
  void dispose() {
    clipboardTimer?.cancel();
    _debounceTimer?.cancel();
    controller.dispose();
    super.dispose();
  }

  void _loadSearchHistory() {
    setState(() {
      searchHistory = StorageService.getSearchHistory();
    });
  }

  void _onSearchTextChanged(String text) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      final query = text.trim();
      if (query.isEmpty) {
        setState(() {
          suggestions = [];
        });
        return;
      }

      try {
        final list = await ApiService.getSuggestions(query);
        if (!mounted) return;
        setState(() {
          suggestions = list;
        });
      } catch (_) {
        // Ignore errors
      }
    });
  }

  void startClipboardMonitoring() {
    clipboardTimer = Timer.periodic(Duration(seconds: 2), (_) async {
      try {
        final data = await Clipboard.getData('text/plain');
        if (data == null || data.text == null) return;

        final text = data.text!.trim();

        // Only process if content changed and it's a YouTube URL
        if (text != lastClipboardContent && ApiService.isYoutubeUrl(text)) {
          lastClipboardContent = text;
          
          if (!mounted) return;

          // update detected link in the state
          setState(() {
            detectedClipboardLink = text;
          });

          Future.microtask(() {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("YouTube link ready in clipboard"),
                  duration: Duration(seconds: 2),
                  backgroundColor: widget.accentColor,
                ),
              );
            }
          });
        }
      } catch (e) {
        // Silently ignore errors reading clipboard
      }
    });
  }

  Future<void> openDetailScreen(Map<String, dynamic> job) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DownloadDetailScreen(job: job),
      ),
    );
    if (result == "delete" && mounted) {
      widget.onDeleteDownload(job);
    }
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    if (widget.downloads.isNotEmpty) {
      latestJob = widget.downloads.last;
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> handleInput() async {
    final input = controller.text.trim();
    if (input.isEmpty) return;

    _debounceTimer?.cancel();
    setState(() {
      suggestions = [];
      loading = true;
      selectedVideo = null;
      results = [];
      statusMessage = null;
    });

    try {
      if (ApiService.isYoutubeUrl(input)) {
        final data = await ApiService.fetchInfo(input);

        if (!mounted) return;
        setState(() {
          selectedVideo = data;
        });
      } else {
        // Add to search history and save
        await StorageService.addSearchQuery(input);
        _loadSearchHistory();

        final res = await ApiService.search(input);

        if (!mounted) return;
        setState(() {
          results = res;
          lastResults = res;
          if (res.isEmpty) {
            statusMessage = 'No results found for "$input".';
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst("Exception: ", "");

      setState(() {
        statusMessage = message;
      });
    }

    if (!mounted) return;
    setState(() {
      loading = false;
    });
  }

  Future<void> pasteFromClipboard() async {
    // Use detected link if available, otherwise read from clipboard
    String? text = detectedClipboardLink;
    
    if (text == null) {
      final data = await Clipboard.getData('text/plain');
      if (data == null || data.text == null) return;
      text = data.text!.trim();
    }

    if (!mounted) return;

    if (!ApiService.isYoutubeUrl(text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No valid YouTube link in clipboard")),
      );
      return;
    }

    setState(() {
      controller.text = text!;
    });
    
    await handleInput();
  }

  Future<void> startDownload(String url, String title,
      {String quality = "192"}) async {
    print("START DOWNLOAD: $url");

    // Check WiFi only restriction
    final isWifiOnly = StorageService.getWifiOnly();
    if (isWifiOnly) {
      final isWifi = await ApiService.isWifiConnected();
      if (!isWifi) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF161618),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text("WiFi Only Enabled", style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text(
              "Your settings restrict downloads to WiFi networks only. Please connect to a WiFi network or disable this option in settings.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK", style: TextStyle(color: widget.accentColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
        return;
      }
    }

    final concurrentThreads = StorageService.getConcurrentThreads();

    try {
      final jobId = await ApiService.startDownload(
        url,
        quality: quality,
        concurrentThreads: concurrentThreads,
      );

      widget.onAddDownload({
        "job_id": jobId,
        "title": title,
        "progress": 0.0,
        "status": "starting",
        "saved": false,
        "format_type": "mp3",
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to start download: ${ApiService.formatErrorMessage(e)}"),
          backgroundColor: widget.accentColor,
        ),
      );
    }
  }

  Widget fallbackThumb() {
    return Container(
      width: 80,
      height: 50,
      color: Colors.grey[800],
      child: Icon(Icons.image, color: Colors.white54),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.menu, color: Colors.white),
                  Column(
                    children: [
                      Text("YUUTOOB",
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3)),
                      Text("DOWNLOADER",
                          style: TextStyle(
                              fontSize: 10,
                              color: accent,
                              letterSpacing: 2))
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsScreen(
                            currentAccentColor: widget.accentColor,
                            onAccentColorChanged: widget.onAccentColorChanged,
                            onHistoryCleared: () {
                              widget.onHistoryCleared();
                              _loadSearchHistory();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 30),

              Text("SEARCH OR PASTE",
                  style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 2,
                      color: Colors.white54)),

              SizedBox(height: 18),

              /// SEARCH BAR
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A1A1A), Color(0xFF242424)],
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.white54),
                    SizedBox(width: 12),

                    Expanded(
                      child: TextField(
                        controller: controller,
                        style: TextStyle(color: Colors.white),
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => handleInput(),
                        onChanged: _onSearchTextChanged,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter YouTube link or search term...",
                          hintStyle: TextStyle(color: Colors.white38),
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: handleInput,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text("SEARCH",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.black)),
                      ),
                    )
                  ],
                ),
              ),

              SizedBox(height: 20),

              if (loading) CircularProgressIndicator(color: accent),

              if (!loading && statusMessage != null)
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 20),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    statusMessage!,
                    style: TextStyle(color: Colors.white70),
                  ),
                ),

              /// SEARCH SUGGESTIONS OVERLAY
              if (selectedVideo == null &&
                  results.isEmpty &&
                  statusMessage == null &&
                  controller.text.trim().isNotEmpty &&
                  suggestions.isNotEmpty)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161618),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: ListView.builder(
                        itemCount: suggestions.length,
                        itemBuilder: (context, idx) {
                          final suggestion = suggestions[idx];
                          return ListTile(
                            leading: const Icon(Icons.search_rounded, color: Colors.white38, size: 20),
                            title: Text(
                              suggestion,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            trailing: const Icon(Icons.arrow_outward_rounded, size: 16, color: Colors.white24),
                            onTap: () {
                              controller.text = suggestion;
                              handleInput();
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),

              /// SEARCH HISTORY SUGGESTIONS CHIPS
              if (selectedVideo == null &&
                  results.isEmpty &&
                  statusMessage == null &&
                  searchHistory.isNotEmpty &&
                  (controller.text.trim().isEmpty || suggestions.isEmpty)) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "RECENT SEARCHES",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.white38,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: searchHistory.length,
                    itemBuilder: (context, idx) {
                      final query = searchHistory[idx];
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          backgroundColor: const Color(0xFF161618),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          label: Text(
                            query,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          onPressed: () {
                            controller.text = query;
                            handleInput();
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],

              /// SEARCH RESULTS
              if (results.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, i) {
                      final v = results[i];

                      final thumbnail = v["thumbnail"];
                      final title = v["title"] ?? "No title";
                      final uploader = v["uploader"] ?? "Unknown";

                      return ListTile(
                        leading: thumbnail != null && thumbnail != ""
                            ? Image.network(
                                thumbnail,
                                width: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    fallbackThumb(),
                              )
                            : fallbackThumb(),

                        title: Text(title,
                            style: TextStyle(color: Colors.white)),

                        subtitle: Text(uploader,
                            style: TextStyle(color: Colors.white54)),

                        onTap: () {
                          print("SELECTED VIDEO: $v");

                          setState(() {
                            selectedVideo = v;
                            results = [];
                            statusMessage = null;
                          });
                        },
                      );
                    },
                  ),
                ),

              /// SELECTED VIDEO VIEW
              if (selectedVideo != null)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedVideo = null;
                              // Restore search results if they exist
                              if (lastResults.isNotEmpty) {
                                results = lastResults;
                              }
                            });
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.arrow_back, color: Colors.white54, size: 20),
                                  SizedBox(width: 4),
                                  Text("BACK", style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.network(
                            selectedVideo!["thumbnail"] ?? "",
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              height: 220,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        Text(
                          selectedVideo!["title"] ?? "No title",
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        SizedBox(height: 14),

                        GestureDetector(
                          onTap: () {
                            final url = selectedVideo!["url"];

                            print("DOWNLOAD URL: $url");

                            if (url == null || url.toString().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Invalid video URL")),
                              );
                              return;
                            }

                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.black,
                              builder: (_) => QualitySelector(
                                onSelect: (quality) {
                                  startDownload(
                                    url,
                                    selectedVideo!["title"] ?? "video",
                                    quality: quality,
                                  );
                                },
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 12),
                            padding: EdgeInsets.symmetric(vertical: 12),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                "DOWNLOAD",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),

              /// DEFAULT VIEW (No active search or selection)
              if (selectedVideo == null &&
                  results.isEmpty &&
                  statusMessage == null &&
                  (controller.text.trim().isEmpty || suggestions.isEmpty))
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (detectedClipboardLink != null) ...[
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: accent.withOpacity(0.4), width: 1.5),
                              gradient: LinearGradient(
                                colors: [Color(0xFF251010), Color(0xFF140808)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.link, color: accent, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      "LINK DETECTED",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    Spacer(),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          detectedClipboardLink = null;
                                        });
                                      },
                                      child: Icon(Icons.close, color: Colors.white38, size: 18),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  detectedClipboardLink!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                                SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: pasteFromClipboard,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(vertical: 10),
                                          decoration: BoxDecoration(
                                            color: accent,
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "PASTE & SEARCH",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24),
                        ],

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "RECENT DOWNLOADS",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                color: Colors.white54,
                              ),
                            ),
                            if (widget.downloads.isNotEmpty)
                              GestureDetector(
                                onTap: widget.onViewAllDownloads,
                                child: Text(
                                  "VIEW ALL",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: accent,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        SizedBox(height: 16),

                        if (widget.downloads.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Color(0xFF161618),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.library_music_rounded, color: Colors.white24, size: 48),
                                SizedBox(height: 16),
                                Text(
                                  "No downloads yet",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Search or paste a YouTube URL to get started.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Column(
                            children: widget.downloads.reversed.take(3).map((job) {
                              final progress = job["progress"] ?? 0.0;
                              final status = job["status"]?.toString() ?? "unknown";
                              
                              return GestureDetector(
                                onTap: () => openDetailScreen(job),
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 12),
                                  padding: EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF161618),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        height: 36,
                                        width: 36,
                                        child: CircularProgressIndicator(
                                          value: progress,
                                          strokeWidth: 3.5,
                                          color: accent,
                                          backgroundColor: Colors.white10,
                                        ),
                                      ),
                                      SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              job["title"] ?? "No Title",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              status.toUpperCase(),
                                              style: TextStyle(
                                                color: status == "completed" 
                                                    ? Colors.greenAccent 
                                                    : Colors.white54,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 20),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
