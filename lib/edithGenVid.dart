import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart'; // Core video player package
import 'package:chewie/chewie.dart'; // Enhanced video player UI
import 'main.dart';

// Home page widget for Edith app
class EdithHomePage extends StatefulWidget {
  const EdithHomePage({Key? key}) : super(key: key);

  @override
  _EdithHomePageState createState() => _EdithHomePageState();
}

class _EdithHomePageState extends State<EdithHomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs: Generate Video and Clarify With Edith
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Edith',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          backgroundColor: const Color.fromARGB(255, 87, 108, 214),
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Colors.white, // White underline for the selected tab
            labelColor: Colors.white, // Selected tab text color
            unselectedLabelColor: Colors.grey, // Unselected tab text color
            tabs: const [
              Tab(text: 'Generate Video'),
              Tab(text: 'Clarify With Edith'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            GenerateVideoPage(), // First tab: Generate Video
            ClarifyWithEdithPage(), // Second tab: Clarify With Edith
          ],
        ),
      ),
    );
  }
}

// Widget for the "Generate Video" tab
class GenerateVideoPage extends StatefulWidget {
  const GenerateVideoPage({Key? key}) : super(key: key);

  @override
  _GenerateVideoPageState createState() => _GenerateVideoPageState();
}

class _GenerateVideoPageState extends State<GenerateVideoPage> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false; // Tracks loading state
  String _responseMessage = ''; // Stores response messages
  String? _videoUrl; // To store the generated video URL
  VideoPlayerController? _videoController; // For playing the video
  ChewieController? _chewieController; // Enhanced video player controller

  // Fun texts to display while generating the video
  final List<String> _funTexts = [
    "Edith is brainstorming...",
    "Fetching some creative ideas...",
    "Cooking up a masterpiece...",
    "Edith is hard at work...",
    "Almost there...",
    "Polishing the final touches...",
  ];

  int _currentFunTextIndex = 0; // Tracks the current fun text index

  // Function to generate a video based on user input
  Future<void> _generateVideo(String prompt) async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    const url = 'https://edithbackend-763539946053.us-central1.run.app';
    final userId = globalUsername;

    try {
      // Start cycling through fun texts
      _startFunTextCycle();

      // Make POST request to backend API
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer ${await _getIdToken()}',
        },
        body: jsonEncode({'text': prompt, 'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final videoLink = responseData['link'];

        if (videoLink != null && Uri.tryParse(videoLink)?.hasAbsolutePath == true) {
          // Valid video URL received
          setState(() {
            _videoUrl = videoLink; // Store the video URL
            _responseMessage = ''; // Clear any previous messages
          });

          // Initialize the video player controller
          _videoController = VideoPlayerController.network(_videoUrl!);
          _chewieController = ChewieController(
            videoPlayerController: _videoController!,
            autoPlay: true,
            looping: false,
          );
        } else {
          setState(() {
            _responseMessage = 'Invalid video URL received.';
          });
        }
      } else {
        setState(() {
          _responseMessage = 'Failed to generate video. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  // Cycle through fun texts during loading
  void _startFunTextCycle() {
    Future.delayed(const Duration(seconds: 12), () {
      if (_isLoading) {
        setState(() {
          _currentFunTextIndex = (_currentFunTextIndex + 1) % _funTexts.length;
        });
        _startFunTextCycle(); // Recursively call to cycle through texts
      }
    });
  }

  // Placeholder function to get an identity token
  Future<String> _getIdToken() async {
    // Replace this with your actual token generation logic
    return 'YOUR_IDENTITY_TOKEN'; // Temporary placeholder
  }

  // Handle send button press
  void _onSendPressed() {
    final prompt = _textController.text.trim();
    if (prompt.isNotEmpty) {
      _generateVideo(prompt);
      _textController.clear(); // Clear the text field
    } else {
      setState(() {
        _responseMessage = 'Please enter a valid prompt.';
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose(); // Dispose of the video player controller
    _chewieController?.dispose(); // Dispose of the Chewie controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 87, 108, 214),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_videoUrl == null) ...[
                      Text(
                        _isLoading
                            ? _funTexts[_currentFunTextIndex]
                            : 'Welcome to Edith!\nType in your doubt below to generate your personalized video.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: _isLoading ? 16 : 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ] else ...[
                      Text(
                        'Here\'s your personalized video!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: Chewie(
                          controller: _chewieController!,
                        ), // Display the video with controls
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Your video has been saved!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                    if (_responseMessage.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        _responseMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: _responseMessage.contains('success')
                              ? Colors.white
                              : Colors.red,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type in your doubt...',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isLoading ? null : _onSendPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 87, 108, 214),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    elevation: 2, // Slight shadow for depth
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : const Text(
                          'SEND',
                          style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget for the "Clarify With Edith" tab
class ClarifyWithEdithPage extends StatefulWidget {
  const ClarifyWithEdithPage({Key? key}) : super(key: key);

  @override
  _ClarifyWithEdithPageState createState() => _ClarifyWithEdithPageState();
}

class _ClarifyWithEdithPageState extends State<ClarifyWithEdithPage> {
  final TextEditingController _textController = TextEditingController();
  final List<Map<String, dynamic>> _messages = []; // Stores chat messages
  bool _isLoading = false; // Tracks loading state

  // Function to send a message to the backend
  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user's message to the chat
    setState(() {
      _messages.add({'type': 'user', 'text': message});
      _textController.clear(); // Clear the input field
    });

    _scrollToBottom(); // Scroll to the latest message

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    const url = 'https://edithbackend-763539946053.us-central1.run.app/chat';
    final userId = globalUsername;

    try {
      // Make POST request to backend API
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer ${await _getIdToken()}',
        },
        body: jsonEncode({'message': message, 'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final edithResponse = responseData['response'];

        // Add Edith's response to the chat
        setState(() {
          _messages.add({'type': 'edith', 'text': edithResponse});
        });
      } else {
        setState(() {
          _messages.add({
            'type': 'error',
            'text': 'Failed to get a response from Edith.',
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({'type': 'error', 'text': 'An error occurred: $e'});
      });
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
      _scrollToBottom(); // Scroll to the latest message
    }
  }

  // Placeholder function to get an identity token
  Future<String> _getIdToken() async {
    // Replace this with your actual token generation logic
    return 'YOUR_IDENTITY_TOKEN'; // Temporary placeholder
  }

  final ScrollController _scrollController = ScrollController();

  // Scroll to the bottom of the chat
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 87, 108, 214),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['type'] == 'user';
                final isError = message['type'] == 'error';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser
                            ? const Color.fromARGB(255, 46, 66, 165)
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        message['text'],
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _sendMessage(_textController.text.trim());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 87, 108, 214),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}