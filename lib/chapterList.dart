import 'package:flutter/material.dart'; // Importing Flutter's material design components
import 'package:edith/chapterDetails.dart'; // Importing the ChapterDetails page for navigation

class ChapterList extends StatelessWidget {
  final String subtopicTitle; // Subtopic title to be displayed in the app bar
  final List<Map<String, dynamic>> chapters; // List of chapters with details

  // Constructor to receive the subtopic title and chapters
  const ChapterList({
    super.key,
    required this.subtopicTitle,
    required this.chapters,
  });

  @override
  Widget build(BuildContext context) {
    // Getting screen width to calculate positioning of vertical line
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // Scaffold provides the base structure of the page
      backgroundColor: const Color.fromARGB(255, 87, 108, 214), // Setting the background color
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 87, 108, 214), // Matching app bar color to background
        title: Text(subtopicTitle), // Displaying the subtopic title in the app bar
      ),
      body: SingleChildScrollView(
        // SingleChildScrollView allows scrolling of content
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding around the body content
          child: Stack(
            children: [
              // Continuous vertical line drawn through the center
              Positioned(
                left: (screenWidth / 2) - 20, // Positioning the line at the center
                top: 15, // Starting from the top
                bottom: 40, // Ending 40px from the bottom
                width: 4, // Line width
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      height: chapters.length * 10, // Adjust height based on the number of chapters
                      color: Colors.black, // Line color set to black
                    );
                  },
                ),
              ),

              // ListView for displaying the chapter cards
              ListView.builder(
                shrinkWrap: true, // Prevents the ListView from expanding beyond its required height
                physics: const NeverScrollableScrollPhysics(), // Disable the ListView's default scrolling
                itemCount: chapters.length, // Number of items (chapters) in the list
                itemBuilder: (context, index) {
                  // Generate unique chapter ID based on the index
                  String chapterId = 'chapter_${index + 1}';

                  // Safely extracting data from each chapter
                  String chapterTitle = chapters[index]['title'] ?? 'Untitled Chapter'; // Default to 'Untitled Chapter' if missing
                  String videoUrl = chapters[index]['video_url'] ?? ''; // Video URL or empty string if not provided
                  List<String> pdfUrls = [];

                  // Checking if PDFs are provided as a list
                  if (chapters[index]['pdfs'] is List) {
                    pdfUrls = List<String>.from(chapters[index]['pdfs']); // Extracting the list of PDFs
                  } else {
                    print('Warning: "pdfs" is not a list for chapter "$chapterTitle".');
                  }

                  // Returning the chapter card UI
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0), // Vertical padding between cards
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start, // Aligning the card content at the top
                      children: [
                        const SizedBox(width: 10), // Space between the line and the card

                        // GestureDetector to handle taps on the chapter card
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // Navigating to the ChapterDetails page on tap
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChapterDetails(
                                    chapterId: chapterId, // Passing the chapter ID
                                    chapterTitle: chapterTitle, // Passing the chapter title
                                    videoUrl: videoUrl, // Passing the video URL
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 133, 145, 209), // Background color for the card
                                borderRadius: BorderRadius.circular(12), // Rounded corners for the card
                              ),
                              padding: const EdgeInsets.all(16), // Padding inside the card
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start, // Aligning children at the top
                                children: [
                                  // Circular icon (folder icon)
                                  CircleAvatar(
                                    radius: 20, // Icon size
                                    backgroundColor: const Color.fromARGB(255, 255, 255, 255), // White background for the icon
                                    child: Icon(
                                      Icons.folder_open_outlined, // Folder icon
                                      color: const Color.fromARGB(255, 159, 40, 40), // Red color for the icon
                                      size: 20, // Icon size
                                    ),
                                  ),
                                  const SizedBox(width: 20), // Space between the icon and text

                                  // Chapter title text
                                  Expanded(
                                    child: Text(
                                      chapterTitle, // Display the chapter title
                                      style: TextStyle(
                                        fontSize: 18.0, // Font size for the title
                                        fontWeight: FontWeight.bold, // Making the title bold
                                        color: Colors.black, // Text color set to black
                                      ),
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
      ),
    );
  }
}
