import 'dart:io'; // For file and system-related functionalities
import 'package:flutter/material.dart'; // Flutter's material design components
import 'package:flutter/services.dart'; // For SystemChrome (to control system UI)
import 'package:youtube_player_flutter/youtube_player_flutter.dart'; // For YouTube video player widget
import 'components/edithCard.dart'; // Importing a custom EdithCard component (for generating video)

class ChapterDetails extends StatefulWidget {
  final String chapterId; // ID of the chapter (passed from the previous screen)
  final String chapterTitle; // Title of the chapter (passed from the previous screen)
  final String videoUrl; // URL of the YouTube video (passed from the previous screen)

  // Constructor to receive chapterId, chapterTitle, and videoUrl
  ChapterDetails({
    required this.chapterId,
    required this.chapterTitle,
    required this.videoUrl,
  });

  @override
  _ChapterDetailsState createState() => _ChapterDetailsState(); // Creating state for the ChapterDetails widget
}

class _ChapterDetailsState extends State<ChapterDetails> {
  late YoutubePlayerController _controller; // Controller for managing YouTube player
  bool _isFullscreen = false; // To track whether the video is in fullscreen mode

  @override
  void initState() {
    super.initState();

    // Lock the screen to portrait mode (prevents rotating the screen)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp, // Lock to portrait mode (portraitUp and portraitDown)
      DeviceOrientation.portraitDown,
    ]);

    // Extract video ID from the YouTube URL and initialize the player
    String videoId = _getVideoIdFromUrl(widget.videoUrl);
    _initializePlayer(videoId);
  }

  // Helper function to extract YouTube video ID from a URL
  String _getVideoIdFromUrl(String url) {
    Uri uri = Uri.parse(url); // Parse the URL
    String videoId = ''; // Default to an empty string if no video ID is found

    // Check if the URL is a valid YouTube URL
    if (uri.host.contains('youtube.com') || uri.host.contains('youtu.be')) {
      // Extract video ID from YouTube URLs
      if (uri.host.contains('youtube.com')) {
        videoId = uri.queryParameters['v'] ?? ''; // Extract video ID from 'v' parameter
      } else if (uri.host.contains('youtu.be')) {
        videoId = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : ''; // Extract ID from path
      }
    }

    return videoId;
  }

  // Initialize the YouTube player with the video ID
  void _initializePlayer(String videoId) {
    if (videoId.isNotEmpty) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId, // Set the initial video to play
        flags: YoutubePlayerFlags(autoPlay: true, mute: false), // Flags for autoplay and unmute
      );

      // Listen for changes in the player's fullscreen state
      _controller.addListener(() {
        if (_controller.value.isFullScreen != _isFullscreen) {
          setState(() {
            _isFullscreen = _controller.value.isFullScreen; // Update the fullscreen state
          });
        }
      });
    } else {
      // If no valid video ID, load a default video
      _controller = YoutubePlayerController(
        flags: YoutubePlayerFlags(autoPlay: true, mute: false),
        initialVideoId: 'di3rHkEZuUw', // Default video ID (a placeholder video)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 87, 108, 214), // Set the background color
      appBar: _isFullscreen
          ? null // Hide the app bar in fullscreen mode
          : AppBar(
              backgroundColor: const Color.fromARGB(255, 87, 108, 214),
              title: Text(
                widget.chapterTitle, // Display the chapter title in the app bar
                style: TextStyle(fontSize: 20),
              ),
            ),
      body: SingleChildScrollView(
        // Scrollable body to allow content overflow in portrait mode
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align content to the start (left)
          children: [
            // YouTube player widget displaying the video
            YoutubePlayer(
              controller: _controller,
              liveUIColor: Colors.amber, // Set the color for the live video UI
            ),
            SizedBox(height: 50), // Spacer for better layout

            // Padding for the EdithCard widget (custom card component)
            Padding(
              padding: EdgeInsets.all(20), // Add padding around the card
              child: GradientCard(
                text: "Ask Edith To Generate A Video For Your Doubts!", // Card text
              ),
            ),
            SizedBox(height: 50), // Spacer between content
            // More content can be added here as needed
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the YouTube player controller when the widget is destroyed

    // Restore system's default orientation settings after disposing of the screen lock
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp, // Allow both portrait and landscape orientations
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose(); // Call super.dispose to ensure the parent class is disposed
  }
}
