import 'package:flutter/material.dart'; // Importing the Flutter Material package for UI components
import 'components/chapterCards.dart'; // Importing a custom widget that displays chapter cards

// Defining a StatelessWidget for the subject page
class subjectPage extends StatelessWidget {
  final String sub; // A final variable to store the subject name passed to the page
  const subjectPage({super.key, required this.sub}); // Constructor to receive the subject name (sub) as a parameter

  @override
  Widget build(BuildContext context) {
    // Using ModalRoute to get the subject name from the route's arguments
    final String sub = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      // Scaffold is the base layout structure for Flutter apps. It provides app bar, body, and other UI components.
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 87, 108, 214), // Setting a custom background color for the app bar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // An icon for going back
          onPressed: () {
            Navigator.pop(context); // Navigates back to the previous screen when the back button is pressed
          },
        ),
        title: Text(
          "${sub} Tracks", // Dynamically setting the title using the subject name
          style: const TextStyle(color: Colors.white), // Setting the text color to white
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 87, 108, 214), // Setting the background color for the body to match the app bar
      body: Chaptercards(
        subjectName: sub, // Passing the subject name to the Chaptercards widget to display relevant chapters
      ),
    );
  }
}
