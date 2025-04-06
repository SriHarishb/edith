import 'package:edith/edithGenVid.dart';
import 'package:flutter/material.dart';

class GradientCard extends StatelessWidget {
  final String text; // Variable to store the text passed to the GradientCard

  // Constructor to accept the text
  GradientCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // When the card is tapped, it navigates to the EdithHomePage
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EdithHomePage(), // Navigate to EdithHomePage
          ),
        );
      },
      child: Container(
        width: double.infinity, // Make the container take full width
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 24), // Padding inside the container
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), // Rounded corners for the card
          gradient: LinearGradient(
            colors: [
              Color(0xFF14B8A6), // Teal color at the start of the gradient
              Color(0xFF9333EA), // Purple color
              Color.fromARGB(255, 27, 37, 59), // Dark blue
              Color.fromARGB(255, 56, 92, 210), // Light blue
            ],
            begin: Alignment.topLeft, // Start the gradient from the top left
            end: Alignment.bottomRight, // End the gradient at the bottom right
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black38, // Shadow color
              blurRadius: 10, // Blur effect for the shadow
              spreadRadius: 2, // Spread of the shadow
              offset: Offset(0, 6), // Offset for the shadow to give a downward effect
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space out the elements within the row
          children: [
            Expanded(
              // Expanding the text to take up the remaining space in the row
              child: Text(
                text, // The text passed to the GradientCard is displayed here
                style: TextStyle(
                  color: Colors.white, // White color for the text
                  fontSize: 20, // Font size for the text
                  fontWeight: FontWeight.bold, // Bold font weight for emphasis
                ),
                maxLines: 2, // Allow up to 2 lines of text
                overflow: TextOverflow.ellipsis, // Add "..." if text overflows
              ),
            ),
            Icon(
              Icons.arrow_forward_ios, // Forward arrow icon indicating more content
              color: Colors.white, // White color for the icon
              size: 28, // Size of the arrow icon
            ),
          ],
        ),
      ),
    );
  }
}
