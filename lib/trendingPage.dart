import 'dart:convert';
import 'package:edith/components/edithFButton.dart'; // Importing custom components
import 'package:flutter/material.dart'; // Flutter's Material Design library
import 'package:http/http.dart' as http; // For making HTTP requests
import 'package:chewie/chewie.dart'; // For video playback controls
import 'package:video_player/video_player.dart'; // For video playback

// Stateful widget for the Trending Page
class TrendingPage extends StatefulWidget {
  @override
  _TrendingPageState createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> {
  List<Map<String, dynamic>> videos = []; // List to store fetched videos
  bool isLoading = true; // Loading state for UI feedback
  bool _hasMore = true; // Tracks if more videos can be loaded
  int _page = 1; // Current page number for pagination
  final TextEditingController _searchController = TextEditingController(); // Controller for search input
  final ScrollController _scrollController = ScrollController(); // Controller for scroll detection

  @override
  void initState() {
    super.initState();
    fetchVideos(); // Fetch initial videos when the widget initializes
    _scrollController.addListener(_onScroll); // Add listener for infinite scrolling
  }

  @override
  void dispose() {
    _searchController.dispose(); // Clean up search controller
    _scrollController.dispose(); // Clean up scroll controller
    super.dispose();
  }

  // Detects when the user scrolls to the bottom to load more videos
  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      fetchMoreVideos();
    }
  }

  // Fetches data from the API (GET or POST request)
  Future<List<Map<String, dynamic>>> fetchFromApi(String url,
      {Map<String, dynamic>? body}) async {
    final response = body == null
        ? await http.get(Uri.parse(url)) // GET request
        : await http.post(Uri.parse(url),
            headers: {'Content-Type': 'application/json'}, body: jsonEncode(body)); // POST request
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData.containsKey('videos') &&
          responseData['videos'] is List &&
          responseData['videos'].isNotEmpty) {
        return List<Map<String, dynamic>>.from(responseData['videos']); // Return list of videos
      }
    }
    throw Exception('Failed to load data'); // Throw exception if data fetching fails
  }

  // Fetches initial set of videos from the backend
  Future<void> fetchVideos() async {
    try {
      final fetchedVideos = await fetchFromApi(
          'https://edithbackend-763539946053.us-central1.run.app/get_all_videos?page=$_page');
      setState(() {
        videos.addAll(fetchedVideos.take(25).toList()); // Add fetched videos to the list
        isLoading = false; // Update loading state
        _hasMore = fetchedVideos.length >= 25; // Check if more data is available
      });
    } catch (e) {
      print('Error fetching videos: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load videos. Please try again.')), // Show error message
      );
    }
  }

  // Fetches additional videos for infinite scrolling
  Future<void> fetchMoreVideos() async {
    if (!_hasMore || isLoading) return; // Prevent overlapping requests
    setState(() {
      isLoading = true;
    });
    try {
      _page++; // Increment page number
      final fetchedVideos = await fetchFromApi(
          'https://edithbackend-763539946053.us-central1.run.app/get_all_videos?page=$_page');
      setState(() {
        videos.addAll(fetchedVideos); // Add new videos to the list
        _hasMore = fetchedVideos.length >= 25; // Check if more data is available
        isLoading = false; // Update loading state
      });
    } catch (e) {
      print('Error fetching more videos: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load more videos. Please try again.')), // Show error message
      );
    }
  }

  // Searches videos based on a query
  Future<void> searchVideos(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        videos = []; // Clear videos if search query is empty
        isLoading = false;
      });
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedVideos = await fetchFromApi(
          'https://edithbackend-763539946053.us-central1.run.app/search',
          body: {'query': query}); // Send search query to backend
      setState(() {
        videos = fetchedVideos; // Update videos with search results
        isLoading = false;
      });
    } catch (e) {
      print('Error searching videos: $e');
      setState(() {
        videos = [];
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to search videos. Please try again.')), // Show error message
      );
    }
  }

  // Builds a single video card widget
  Widget buildVideoCard(int index, String link, int views) {
    return VideoCard(
      link: link,
      views: views,
      index: index,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 87, 108, 214), // Background color
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController, // Search input controller
                decoration: InputDecoration(
                  hintText: 'Search videos...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search, color: Colors.grey[700]),
                    onPressed: () {
                      searchVideos(_searchController.text.trim()); // Trigger search
                    },
                  ),
                ),
                style: TextStyle(fontSize: 16, color: Colors.black87),
                onSubmitted: (query) {
                  searchVideos(query.trim()); // Trigger search on submit
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: const Color.fromARGB(255, 87, 108, 214),
              child: isLoading && videos.isEmpty
                  ? Center(child: CircularProgressIndicator()) // Show loading indicator
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: videos.length + (_hasMore ? 1 : 0), // Add extra item for loading indicator
                      itemBuilder: (context, index) {
                        if (index < videos.length) {
                          final video = videos[index];
                          final link = video['link'];
                          final views = video['views'];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: buildVideoCard(index, link, views), // Build video card
                          );
                        } else {
                          return Center(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(), // Show loading indicator for more videos
                          ));
                        }
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// Stateful widget for individual video cards
class VideoCard extends StatefulWidget {
  final String link; // Video URL
  final int views; // Number of views
  final int index; // Index for ranking display

  VideoCard({required this.link, required this.views, required this.index});

  @override
  _VideoCardState createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  late ChewieController _chewieController; // Controller for Chewie video player
  bool _hasIncrementedViews = false; // Tracks if views have been incremented

  @override
  void initState() {
    super.initState();
    _chewieController = ChewieController(
      videoPlayerController: VideoPlayerController.network(widget.link), // Initialize video player
      autoPlay: false,
      looping: false,
      showControls: true,
    );
    // Listen to playback state to increment views when video starts playing
    _chewieController.videoPlayerController.addListener(() {
      if (!_hasIncrementedViews &&
          _chewieController.videoPlayerController.value.isPlaying) {
        _incrementViews(widget.link); // Increment views
        _hasIncrementedViews = true; // Mark views as incremented
      }
    });
  }

  @override
  void dispose() {
    _chewieController.dispose(); // Dispose of the video player controller
    super.dispose();
  }

  // Extracts user_id from the video URL
  String _extractUserIdFromUrl(String videoUrl) {
    try {
      final uri = Uri.parse(videoUrl);
      final pathSegments = uri.pathSegments;
      print('Path segments: $pathSegments'); // Debugging path segments
      // Ensure there are enough segments and the second segment is 'users'
      if (pathSegments.length >= 3 && pathSegments[1] == 'users') {
        return pathSegments[2]; // Extract 'kumar' (user_id)
      } else {
        print('Unexpected path segments: $pathSegments');
        return ''; // Return empty string if format is invalid
      }
    } catch (e) {
      print('Error extracting user_id from URL: $e');
      return ''; // Return empty string in case of exception
    }
  }

  // Sends a POST request to increment video views
  Future<void> _incrementViews(String videoUrl) async {
    try {
      final userId = _extractUserIdFromUrl(videoUrl); // Extract user_id
      if (userId.isEmpty) {
        print('Failed to extract user_id for video: $videoUrl');
        return;
      }
      // Send POST request with video_url and user_id
      final response = await http.post(
        Uri.parse('https://edithbackend-763539946053.us-central1.run.app/increment_views'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'video_url': videoUrl,
          'user_id': userId,
        }),
      );
      if (response.statusCode == 200) {
        print('Views incremented successfully for video: $videoUrl');
      } else {
        print('Failed to increment views for video: $videoUrl. Status code: ${response.statusCode}');
        print('Response body: ${response.body}'); // Log response body for debugging
      }
    } catch (e) {
      print('Error incrementing views for video: $videoUrl. Error: $e');
    }
  }

  // Returns color based on video ranking
  Color _getRankingColor(int index) {
    switch (index) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.yellow;
      case 2:
        return Colors.green;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.grey[800]!, Colors.grey[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.2, 0.8],
          ),
        ),
        child: Stack(
          children: [
            if (widget.index < 3)
              Positioned(
                top: 10,
                left: 10,
                child: Text(
                  '#${widget.index + 1}',
                  style: TextStyle(
                    color: _getRankingColor(widget.index), // Display ranking color
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Center(
              child: SizedBox(
                width: 410,
                height: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Chewie(controller: _chewieController), // Display video player
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: Text(
                '${widget.views} views',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}