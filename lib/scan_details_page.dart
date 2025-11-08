import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';


class ScanDetailsPage extends StatefulWidget {
  final String partName;
  final String status;
  final Color statusColor;
  final IconData icon;

  const ScanDetailsPage({
    super.key,
    required this.partName,
    required this.status,
    required this.statusColor,
    required this.icon,
  });

  @override
  State<ScanDetailsPage> createState() => _ScanDetailsPageState();
}

class _ScanDetailsPageState extends State<ScanDetailsPage> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.recycling, color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Text(
              "IDRenew",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.icon,
                      color: widget.statusColor, size: 32),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.partName,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(widget.status,
                        style: TextStyle(color: widget.statusColor)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ✅ Status Card
            Card(
              color: widget.statusColor == const Color(0xFF10B981)
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFEE2E2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(
                  widget.statusColor == const Color(0xFF10B981)
                      ? Icons.check_circle
                      : Icons.error,
                  color: widget.statusColor,
                ),
                title: Text(
                  widget.statusColor == const Color(0xFF10B981)
                      ? "This part can be reused!"
                      : "This part should be disposed!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.statusColor,
                  ),
                ),
                subtitle: Text(
                  widget.statusColor == const Color(0xFF10B981)
                      ? "Great for DIY projects and repairs"
                      : "Find nearby disposal centers",
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Why It's Reusable
            Card(
              elevation: 2,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Why It's Reusable",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const _BulletPoint("Still functional"),
                    const _BulletPoint("No physical damage detected"),
                    const _BulletPoint("Compatible with multiple models"),
                    const SizedBox(height: 8),

                    // ✅ Lifespan Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: "Typical Lifespan: ",
                              style: TextStyle(
                                color: Color(0xFF1E40AF),
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                            TextSpan(
                              text: "2–3 more years with proper care",
                              style: const TextStyle(
                                  color: Color(0xFF1E40AF), fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ How You Can Reuse
            Card(
              elevation: 2,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "How You Can Reuse This",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: const ListTile(
                        leading: Icon(Icons.build, color: Color(0xFF10B981)),
                        title: Text("DIY Projects"),
                        subtitle: Text(
                            "Power banks, LED lights, small electronics"),
                      ),
                    ),
                    Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: const ListTile(
                        leading:
                        Icon(Icons.settings, color: Color(0xFF10B981)),
                        title: Text("Repair & Upgrade"),
                        subtitle: Text("Replace in compatible devices"),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("View All Options",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Learn How To Reuse
            Card(
              elevation: 2,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Learn How To Reuse",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    // 🔹 Embedded YouTube player
                    const VideoPlayerWidget(
                      videoUrl: "https://www.youtube.com/watch?v=xvQ3RgetUEA",
                    ),
                    const SizedBox(height: 12),
                    const _BulletPoint("Battery replacement guide",
                        icon: Icons.file_copy),
                    const _BulletPoint("DIY power bank project",
                        icon: Icons.file_copy),
                    const _BulletPoint("Safety tips", icon: Icons.file_copy),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Expandable Disposal Section
            Card(
              elevation: 3,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() => _expanded = !_expanded);
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "If You Can't Reuse This Part",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "We'll help you dispose of it safely...",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            _expanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            _BulletPoint("Take it to a certified e-waste center",
                                icon: Icons.delete),
                            _BulletPoint("Do not throw in household trash",
                                icon: Icons.warning),
                            _BulletPoint("Check local recycling programs",
                                icon: Icons.recycling),
                          ],
                        ),
                      ),
                      crossFadeState: _expanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🔹 Custom bullet point widget
class _BulletPoint extends StatelessWidget {
  final String text;
  final IconData icon;

  const _BulletPoint(this.text, {this.icon = Icons.check_circle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF10B981), size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

// 🔹 YouTube video widget
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late YoutubePlayerController _controller;
  String? _videoId;

  @override
  void initState() {
    super.initState();
    _videoId = _extractYoutubeId(widget.videoUrl);

    if (_videoId != null && _videoId!.isNotEmpty) {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: _videoId!,
        autoPlay: false,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_videoId == null || _videoId!.isEmpty) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(Icons.error, color: Colors.white, size: 48),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: YoutubePlayerScaffold(
        controller: _controller,
        builder: (context, player) {
          return AspectRatio(
            aspectRatio: 16 / 9,
            child: player,
          );
        },
      ),
    );
  }

  String? _extractYoutubeId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    if (uri.queryParameters.containsKey('v')) {
      return uri.queryParameters['v'];
    }
    if (uri.pathSegments.contains('embed')) {
      final index = uri.pathSegments.indexOf('embed');
      if (index + 1 < uri.pathSegments.length) {
        return uri.pathSegments[index + 1];
      }
    }
    final match = RegExp(r'([A-Za-z0-9_-]{11})').firstMatch(url);
    return match?.group(1);
  }
}



