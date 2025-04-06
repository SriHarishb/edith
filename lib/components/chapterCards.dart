import 'dart:convert';
import 'package:edith/chapterList.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Chaptercards extends StatefulWidget {
  final String subjectName;

  const Chaptercards({super.key, required this.subjectName});

  @override
  _ChaptercardsState createState() => _ChaptercardsState();
}

class _ChaptercardsState extends State<Chaptercards> {
  List<String> subtopicTitles = [];
  List<Map<String, dynamic>> subtopicsData = [];
  bool isLoading = true;
  String? errorMessage;

  // Define a list of colors for the icons
  final List<Color> iconColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.red,
  ];

  Future<void> loadSubtopics() async {
    try {
      // Fetch JSON data from the URL
      final response = await http.get(
        Uri.parse('https://edithbackend-763539946053.us-central1.run.app/get_path'),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
      // Decode the JSON response
      Map<String, dynamic> jsonData = json.decode(response.body);
      // Log the entire JSON response for debugging
      print('Fetched JSON Data: $jsonData');
      // Check if the "Domains" key exists
      if (!jsonData.containsKey("Domains")) {
        print('Key "Domains" not found in JSON.');
        throw Exception('Key "Domains" not found in JSON.');
      }
      // Access the "Domains" key
      var domains = jsonData["Domains"];
      // Check if the subject exists under "Domains"
      if (!domains.containsKey(widget.subjectName)) {
        print('Subject "${widget.subjectName}" not found under "Domains".');
        print('Available subjects under "Domains": ${domains.keys.toList()}');
        throw Exception('Subject ${widget.subjectName} not found under "Domains".');
      }
      var subjectData = domains[widget.subjectName];
      // Validate structure
      if (subjectData is! Map<String, dynamic>) {
        print('Invalid JSON structure: Subject data is not a map.');
        throw Exception('Invalid JSON structure for ${widget.subjectName}.');
      }
      if (!subjectData.containsKey('Subtopics')) {
        print('Invalid JSON structure: "Subtopics" key is missing.');
        throw Exception('Invalid JSON structure for ${widget.subjectName}.');
      }
      var subtopics = subjectData['Subtopics'];
      if (subtopics is! List) {
        print('Invalid JSON structure: "Subtopics" is not a list.');
        throw Exception('"Subtopics" is not a list for ${widget.subjectName}.');
      }
      // Log the subtopics for debugging
      print('Subtopics for "${widget.subjectName}": $subtopics');
      // Process subtopics
      setState(() {
        subtopicsData = List<Map<String, dynamic>>.from(
          subtopics.map((subtopic) => Map<String, dynamic>.from(subtopic)),
        );
        subtopicTitles =
            subtopics.map((subtopic) => subtopic['title'] as String).toList();
        isLoading = false; // Data loaded successfully
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString(); // Capture error message
        isLoading = false; // Stop loading even if there's an error
      });
      print('Error loading subtopics: $e'); // Log the error
    }
  }

  @override
  void initState() {
    super.initState();
    loadSubtopics();
  }

  @override
  Widget build(BuildContext context) {
    return errorMessage != null
        ? Center(
            child: Text(
              errorMessage!,
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          )
        : isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Stack(
                    children: [
                      // Continuous vertical line
                      Positioned(
                        left: MediaQuery.of(context).size.width / 2 - 20,
                        top: 15,
                        bottom: 45,
                        width: 4, // Thickness of the line
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Container(
                              height:
                                  subtopicTitles.length * 120, // Adjusted height per card
                              color: Colors.black, // Line color
                            );
                          },
                        ),
                      ),
                      // ListView for subtopics
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: subtopicTitles.length,
                        itemBuilder: (context, index) {
                          // Determine the group index (every 3 cards)
                          final groupIndex = index ~/ 3;

                          // Assign a color based on the group index
                          final iconColor = iconColors[groupIndex % iconColors.length];

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: 10,
                                ), // Space between line and card
                                // GestureDetector for tapping the card
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      var chapters = subtopicsData[index]['chapters'];
                                      if (chapters != null && chapters is List) {
                                        var typedChapters =
                                            List<Map<String, dynamic>>.from(
                                          chapters.map(
                                            (chapter) =>
                                                Map<String, dynamic>.from(
                                              chapter,
                                            ),
                                          ),
                                        );
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChapterList(
                                              subtopicTitle: subtopicTitles[index],
                                              chapters: typedChapters,
                                            ),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'No chapters available for ${subtopicTitles[index]}',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                          255,
                                          133,
                                          145,
                                          209,
                                        ), // Light blue card background
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Circular icon with a white background
                                          CircleAvatar(
                                            radius: 20, // Icon size
                                            backgroundColor: Colors.white,
                                            child: Icon(
                                              Icons.folder_open_outlined,
                                              color: iconColor, // Use the dynamic color
                                              size: 24, // Icon size
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ), // Space between icon and text
                                          // Subtopic title
                                          Expanded(
                                            child: Text(
                                              subtopicTitles[index],
                                              style: TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                              textAlign: TextAlign.left, // Ensures text is left-aligned
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
  }
}