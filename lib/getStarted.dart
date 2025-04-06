import 'package:flutter/material.dart'; // Importing Flutter's material design components
import 'package:google_fonts/google_fonts.dart'; // Importing Google Fonts to use custom fonts

// Defining the StatelessWidget for the "Get Started" screen
class getStarted extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold provides the basic structure like app bar, body, and others
      body: Container(
        width: double.infinity, // Container takes the full width of the screen
        decoration: BoxDecoration(
          gradient: LinearGradient(
            // Linear gradient for the background from top to bottom
            colors: [Color(0xFF283593), Color(0xFF5C6BC0)], // Two shades of blue
            begin: Alignment.topCenter, // Gradient starts from the top center
            end: Alignment.bottomCenter, // Gradient ends at the bottom center
          ),
        ),
        child: Column(
          // Column widget to align the widgets vertically
          mainAxisAlignment: MainAxisAlignment.center, // Centering children vertically
          children: [
            // Image Section
            ClipRRect(
              // ClipRRect allows us to round the corners of the image
              borderRadius: BorderRadius.circular(20), // Circular border radius of 20
              child: Image.asset(
                'assets/images/getstartedd.png', // Image asset to display
                height: MediaQuery.of(context).size.height * 0.25, // Image height set to 25% of screen height
                fit: BoxFit.cover, // Ensuring the image covers the entire box
              ),
            ),

            SizedBox(height: 40), // Spacer between elements

            // App Name and Tagline
            Text(
              "Edith", // App name displayed
              style: GoogleFonts.tektur(
                fontSize: 36, // Font size for the app name
                fontWeight: FontWeight.bold, // Making the text bold
                color: Colors.white, // White color for the text
              ),
            ),
            SizedBox(height: 10), // Spacer between the app name and tagline
            Text(
              "The Education App", // Tagline displayed under the app name
              textAlign: TextAlign.center, // Center aligning the tagline text
              style: TextStyle(color: Colors.white70, fontSize: 16), // Light white color for the tagline
            ),

            SizedBox(height: 40), // Spacer between the tagline and buttons

            // LOGIN Button
            ElevatedButton(
              onPressed: () {
                // Navigating to the login page when the button is pressed
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent, // Transparent background for the button
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 60), // Padding for the button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners for the button
                  side: BorderSide(color: Colors.white, width: 2), // White border around the button
                ),
                elevation: 0, // No elevation (shadow) for the button
              ),
              child: Text(
                "LOGIN", // Button text
                style: TextStyle(
                  color: Colors.white, // White color for the text
                  fontSize: 18, // Font size for the text
                  fontWeight: FontWeight.bold, // Bold text style
                ),
              ),
            ),

            SizedBox(height: 15), // Spacer between the LOGIN and REGISTER buttons

            // REGISTER Button
            ElevatedButton(
              onPressed: () {
                // Navigating to the sign-up page when the button is pressed
                Navigator.pushNamed(context, '/signin');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // White background for the button
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 60), // Padding for the button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners for the button
                ),
                elevation: 0, // No elevation (shadow) for the button
              ),
              child: Text(
                "REGISTER", // Button text
                style: TextStyle(
                  color: Color(0xFF283593), // Dark blue color for the text
                  fontSize: 18, // Font size for the text
                  fontWeight: FontWeight.bold, // Bold text style
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
