import 'dart:convert'; // For JSON encoding and decoding
import 'package:edith/components/edithFButton.dart'; // Custom button widget
import 'package:edith/main.dart'; // Global variables and main settings
import 'package:flutter/material.dart'; // Core Flutter library
import 'package:http/http.dart' as http; // For making HTTP requests
import 'package:video_player/video_player.dart'; // Core video player package
import 'package:chewie/chewie.dart'; // Enhanced video player UI

// The main widget for the "Your Videos" page
class YourVideosPage extends StatefulWidget {
  const YourVideosPage({super.key});

  @override
  _YourVideosPageState createState() => _YourVideosPageState();
}

class _YourVideosPageState extends State<YourVideosPage> {
  List<String> _videoUrls = []; // List to hold video URLs
  bool _isLoading = true; // Flag to show loading indicator
  String _errorMessage = ''; // String to hold error message in case of failure

  @override
  void initState() {
    super.initState();
    _fetchUserVideos(); // Fetch the user's videos when the page is initialized
  }

  // Function to fetch user videos from the server
  Future<void> _fetchUserVideos() async {
    setState(() {
      _isLoading = true; // Set loading state to true
      _errorMessage = ''; // Clear any previous error message
    });

    const url = 'https://edithbackend-763539946053.us-central1.run.app/get_user_videos'; // API endpoint for fetching videos
    final userId = globalUsername; // Get the global username (assumed to be set elsewhere)

    try {
      // Make a POST request to fetch videos
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer ${await _getIdToken()}', // Get token for authorization
        },
        body: jsonEncode({
          'user_id': userId, // Send user ID in the request body
        }),
      );

      print('Backend Response: ${response.body}'); // Log the raw response from the server

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body); // Parse the response body
        print('Parsed Response Data: $responseData'); // Log the parsed data

        // Check if 'videos' exists and is a list
        if (responseData['videos'] is List) {
          final videoList = List<Map<String, dynamic>>.from(responseData['videos']);
          final videoUrls = videoList.map((video) => video['link'] as String).toList(); // Extract video URLs
          setState(() {
            _videoUrls = videoUrls; // Update the state with the list of video URLs
          });
        } else {
          setState(() {
            _errorMessage = "Unexpected response format from server."; // Error message if response format is wrong
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch videos. Please try again.'; // Error message if the status code is not 200
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e'; // Handle exceptions
      });
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator once the request is complete
      });
    }
  }

  // Function to get the user ID token (to be replaced with actual implementation)
  Future<String> _getIdToken() async {
    return 'YOUR_IDENTITY_TOKEN'; // Placeholder for actual identity token
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content of the page (handles loading state and error messages)
        _isLoading
            ? const Center(child: CircularProgressIndicator()) // Show loading indicator
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Text(
                      _errorMessage, // Display error message if there is any
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _videoUrls.length, // List of video URLs
                    itemBuilder: (context, index) {
                      final videoUrl = _videoUrls[index];
                      return _buildVideoCard(videoUrl); // Build a video card for each video URL
                    },
                  ),

        // Add the floating button (to handle actions like navigating to the video generation page)
        Edithfbutton(
          onPressed: () {
            // Handle button press (e.g., navigate to video generation page)
          },
        ),
      ],
    );
  }

  // Function to build a video card for each video
  Widget _buildVideoCard(String videoUrl) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners for the card
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[800]!, Colors.grey[300]!], // Gradient color for background
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Video ${_videoUrls.indexOf(videoUrl) + 1}', // Display video index (e.g., "Video 1")
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            VideoPlayerWidget(videoUrl: videoUrl), // Custom widget for video player
          ],
        ),
      ),
    );
  }
}

// Custom widget for displaying a video player
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController; // Video player controller
  ChewieController? _chewieController; // Enhanced video player UI controller

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer(); // Initialize video player when the widget is created
  }

  // Function to initialize the video player
  Future<void> _initializeVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl); // Initialize with the video URL
    await _videoPlayerController.initialize(); // Wait for the video player to initialize
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController, // Use the video player controller
      autoPlay: false, // Start paused
      looping: false, // Don't loop the video
      showControls: true, // Show controls (play, pause, etc.)
    );
    setState(() {}); // Trigger a rebuild once the video player is ready
  }

  @override
  void dispose() {
    _videoPlayerController.dispose(); // Dispose the video controller when the widget is destroyed
    _chewieController?.dispose(); // Dispose the Chewie controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _videoPlayerController.value.aspectRatio, // Maintain the aspect ratio of the video
      child: _chewieController != null
          ? Chewie(controller: _chewieController!) // Use the Chewie controller for enhanced UI
          : const Center(child: CircularProgressIndicator()), // Show a loading indicator if video is not ready
    );
  }
}
