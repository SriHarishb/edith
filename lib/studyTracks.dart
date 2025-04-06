import 'package:flutter/material.dart';
import 'components/edithFButton.dart';

// Main StatefulWidget for Study Tracks screen
class studyTracks extends StatefulWidget {
  @override
  _StudyTracksState createState() => _StudyTracksState();
}

// State class for managing the Study Tracks screen
class _StudyTracksState extends State<studyTracks>
    with SingleTickerProviderStateMixin {
  late TabController _tabController; // Controller for TabBar
  final TextEditingController _searchController = TextEditingController(); // Controller for search TextField
  String searchQuery = ""; // Holds the current search query

  // List of topics with associated data (title, learning sets, gradient colors, and icons)
  final List<Map<String, dynamic>> topics = [
    {
      "title": "Science",
      "learningSets": 9,
      "gradient": [Colors.blueAccent, Colors.blue],
      "icon": Icons.science,
    },
    {
      "title": "Maths",
      "learningSets": 3,
      "gradient": [Colors.deepPurple, Colors.purple],
      "icon": Icons.calculate,
    },
    {
      "title": "Visual Arts",
      "learningSets": 3,
      "gradient": [Colors.teal, Colors.green],
      "icon": Icons.palette,
    },
    {
      "title": "Computer Science",
      "learningSets": 3,
      "gradient": [Colors.orangeAccent, Colors.deepOrange],
      "icon": Icons.computer,
    },
    {
      "title": "Financial Literacy",
      "learningSets": 3,
      "gradient": [Colors.green, Colors.lightGreen],
      "icon": Icons.attach_money,
    },
    {
      "title": "Performing Arts",
      "learningSets": 3,
      "gradient": [Colors.pinkAccent, Colors.redAccent],
      "icon": Icons.music_note,
    },
  ];

  // Initialize the TabController when the widget is created
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Two tabs: Major Topics and History
  }

  // Dispose of the TabController to avoid memory leaks
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Build method to construct the UI
  @override
  Widget build(BuildContext context) {
    double cardHeight = MediaQuery.of(context).size.height * 0.22; // Calculate card height based on screen size

    // Filter topics based on the search query
    List<Map<String, dynamic>> filteredTopics =
        topics
            .where(
              (topic) => topic["title"].toLowerCase().contains(
                searchQuery.toLowerCase(),
              ),
            )
            .toList();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 87, 108, 214), // Background color for the screen
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 87, 108, 214), // AppBar background color
        title: const Text(
          "Study Tracks",
          style: TextStyle(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController, // Attach the TabController
          tabs: [Tab(text: "Major Topics"), Tab(text: "History")], // Define the two tabs
          labelColor: Colors.white, // Active tab text color
          unselectedLabelColor: Colors.white70, // Inactive tab text color
          indicatorColor: Colors.white, // Tab indicator color
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController, // Attach the TabController
            children: [
              // Major Topics Tab
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      controller: _searchController, // Attach the search controller
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value; // Update search query on text change
                        });
                      },
                      style: TextStyle(color: Colors.white), // Text color for the TextField
                      decoration: InputDecoration(
                        hintText: "Search Topics", // Placeholder text
                        hintStyle: TextStyle(color: Colors.white70), // Placeholder text style
                        filled: true, // Fill the TextField with a color
                        fillColor: Colors.blue.shade300, // Background color for the TextField
                        prefixIcon: Icon(Icons.search, color: Colors.white), // Search icon
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12), // Rounded corners
                          borderSide: BorderSide.none, // No border
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(top: 30),
                        child: Column(
                          children: [
                            // Loop through filtered topics and display them in rows of two cards
                            for (int i = 0; i < filteredTopics.length; i += 2)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (i < filteredTopics.length)
                                      topicCard(
                                        context,
                                        filteredTopics[i]["title"],
                                        filteredTopics[i]["learningSets"],
                                        filteredTopics[i]["gradient"],
                                        filteredTopics[i]["icon"],
                                        cardHeight,
                                      ),
                                    if (i + 1 < filteredTopics.length)
                                      SizedBox(width: 20), // Add spacing between cards
                                    if (i + 1 < filteredTopics.length)
                                      topicCard(
                                        context,
                                        filteredTopics[i + 1]["title"],
                                        filteredTopics[i + 1]["learningSets"],
                                        filteredTopics[i + 1]["gradient"],
                                        filteredTopics[i + 1]["icon"],
                                        cardHeight,
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // History Tab
              Container(
                color: const Color.fromARGB(255, 87, 108, 214), // Background color for the History tab
                child: Center(
                  child: Text(
                    "Start Learning to Log Your History!", // Prompt text for the History tab
                    style: TextStyle(
                      color: Colors.black54, // Text color
                      fontSize: 18, // Font size
                      fontWeight: FontWeight.bold, // Bold font
                    ),
                    textAlign: TextAlign.center, // Center-align the text
                  ),
                ),
              ),
            ],
          ),
          // Floating action button for additional functionality
          Edithfbutton(onPressed: () {}),
        ],
      ),
    );
  }
}

// Topic Card Widget
Widget topicCard(
  BuildContext context,
  String title,
  int learningSets,
  List<Color> gradientColors,
  IconData icon,
  double height,
) {
  return GestureDetector(
    onTap: () {
      Navigator.pushNamed(context, '/subjectpage', arguments: title); // Navigate to subject page on tap
    },
    child: Container(
      width: 160, // Fixed width for the card
      height: height, // Dynamic height based on screen size
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors, // Gradient colors for the card
          begin: Alignment.topLeft, // Gradient start point
          end: Alignment.bottomRight, // Gradient end point
        ),
        borderRadius: BorderRadius.circular(16), // Rounded corners
      ),
      padding: EdgeInsets.all(16), // Padding inside the card
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: CircleAvatar(
              radius: 20, // Size of the circle avatar
              backgroundColor: Colors.white, // Background color for the icon
              child: Icon(
                icon, // Icon for the topic
                color: gradientColors[0], // Icon color
              ),
            ),
          ),
          SizedBox(height: 10), // Space between icon and title
          Text(
            title, // Title of the topic
            textAlign: TextAlign.center, // Center-align the text
            style: TextStyle(
              color: Colors.white, // Text color
              fontSize: 20, // Font size
              fontWeight: FontWeight.bold, // Bold font
            ),
          ),
          Spacer(), // Pushes the next widget to the bottom
          Text(
            "$learningSets Learning sets", // Number of learning sets
            style: TextStyle(color: Colors.white, fontSize: 12), // Text style
          ),
        ],
      ),
    ),
  );
}