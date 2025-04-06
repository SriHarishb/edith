import 'package:edith/edithGenVid.dart';
import 'package:flutter/material.dart';

class Edithfbutton extends StatelessWidget {
  // Constructor accepting the onPressed callback (though it's not being used in the current implementation)
  const Edithfbutton({Key? key, required Null Function() onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20, // Positioned 20 units from the bottom of the screen
      right: 20, // Positioned 20 units from the right edge of the screen
      child: GestureDetector(
        // When the button is tapped, it navigates to the EdithHomePage
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EdithHomePage(), // Navigate to EdithHomePage
            ),
          );
        },
        child: Container(
          width: 65, // Width of the container (Reduced size for typical FAB dimensions)
          height: 65, // Height of the container
          decoration: BoxDecoration(
            // Gradient background with sweeping color effect
            gradient: SweepGradient(
              colors: [
                Color.fromARGB(255, 255, 97, 0), // Bright orange
                Color.fromARGB(255, 255, 183, 0), // Light orange
                Color.fromARGB(255, 255, 0, 132), // Vibrant pink
                Color.fromARGB(255, 164, 38, 233), // Bright purple
              ],
              stops: [0.0, 0.25, 0.75, 1.0], // Smooth color transitions between the colors
              center: Alignment.center, // Center the gradient at the center of the button
            ),
            shape: BoxShape.circle, // Circular shape for the button
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(100, 0, 0, 0), // Shadow color
                blurRadius: 10, // Blur effect for the shadow
                spreadRadius: 2, // Spread radius of the shadow
                offset: Offset(0, 5), // Offset of the shadow
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center, // Align all children at the center
            children: [
              // Outer glow effect to make the button look more dynamic
              AnimatedContainer(
                duration: Duration(milliseconds: 300), // Duration of the animation
                curve: Curves.easeInOut, // Animation curve for smooth transition
                width: 75, // Slightly larger width for the glow effect
                height: 75, // Slightly larger height for the glow effect
                decoration: BoxDecoration(
                  shape: BoxShape.circle, // Circular shape for the glow
                  gradient: RadialGradient(
                    colors: [
                      Color.fromARGB(50, 255, 97, 0).withOpacity(0.5), // Outer glow color with opacity
                      Colors.transparent, // Transparent towards the center
                    ],
                    radius: 1.5, // Radius for the radial gradient to make the glow larger
                  ),
                ),
              ),
              // Main content of the button: Icon and text
              Column(
                mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically
                children: [
                  Icon(
                    Icons.star, // Icon to be displayed (can be changed)
                    color: Colors.white, // White color for the icon
                    size: 28, // Icon size adjusted for balance
                  ),
                  SizedBox(height: 4), // Small spacing between the icon and the text
                  Text(
                    "Edith", // Text label
                    textAlign: TextAlign.center, // Center the text
                    style: TextStyle(
                      color: Colors.white, // White color for the text
                      fontSize: 12, // Font size for the text
                      fontWeight: FontWeight.bold, // Bold font weight for emphasis
                      letterSpacing: 1.2, // Slight letter spacing for better readability
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
