import 'package:flutter/material.dart';
import 'auth_services.dart'; // Import your AuthService for authentication logic
import 'main.dart'; // Import MainScreen for navigation after login/registration

// SignIn widget allows users to create an account or sign in with Google
class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _emailController = TextEditingController(); // Controller for email input
  final TextEditingController _passwordController = TextEditingController(); // Controller for password input
  final TextEditingController _confirmPasswordController = TextEditingController(); // Controller for confirm password input
  bool _isLoading = false; // Loading state to disable buttons during async operations

  // Validate user inputs before proceeding with registration
  bool _validateInputs() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Check if passwords match
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match")),
      );
      return false;
    }

    // Check if all fields are filled
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required")),
      );
      return false;
    }
    return true;
  }

  // Register a new user with email and password using Firebase and backend API
  Future<void> _registerWithEmail() async {
    setState(() {
      _isLoading = true; // Start loading state
    });

    try {
      if (!_validateInputs()) {
        return; // Stop if validation fails
      }

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Call Firebase and backend API to create the account
      await authService.value.createAccount(email: email, password: password);

      // Navigate to the main screen after successful registration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(username: email.split('@')[0]),
        ),
      );
    } catch (e) {
      // Show error message if registration fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed. Please try again.")),
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading state
      });
    }
  }

  // Sign in with Google using Firebase and backend API
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true; // Start loading state
    });

    try {
      // Authenticate with Google using Firebase
      final userCredential = await authService.value.signInWithGoogle();
      final email = userCredential.user?.email ?? '';

      // Extract username from email and call backend API to create the user
      final String username = email.split('@')[0];
      await authService.value.createUserInBackend(username);

      // Navigate to the main screen after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(username: username),
        ),
      );
    } catch (e) {
      // Show error message if Google Sign-In fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In failed")),
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 87, 108, 214), // Set background color
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header image container
            Container(
              height: MediaQuery.of(context).size.height * 0.15,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color.fromARGB(0, 141, 158, 176),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(80),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(10),
                ),
                child: Image.asset(
                  'assets/images/registerpage.png',
                  height: MediaQuery.of(context).size.height * 0.15,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 50),

            // Title text
            Text(
              "Create an Account",
              style: TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Register to get started",
              style: TextStyle(fontSize: 20, color: Colors.white70),
            ),
            SizedBox(height: 60),

            // Input fields and buttons container
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  // Email input field
                  _buildTextField(
                    controller: _emailController,
                    hintText: "Email",
                    prefixIcon: Icons.email,
                  ),
                  SizedBox(height: 15),

                  // Password input field
                  _buildTextField(
                    controller: _passwordController,
                    hintText: "Password",
                    obscureText: true,
                    prefixIcon: Icons.lock,
                  ),
                  SizedBox(height: 15),

                  // Confirm password input field
                  _buildTextField(
                    controller: _confirmPasswordController,
                    hintText: "Confirm Password",
                    obscureText: true,
                    prefixIcon: Icons.lock,
                  ),
                  SizedBox(height: 60),

                  // Register button
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        gradient: LinearGradient(
                          colors: [
                            Color.fromRGBO(40, 56, 84, 1),
                            Color.fromRGBO(62, 84, 159, 1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 20),
                        ),
                        onPressed: _isLoading ? null : _registerWithEmail, // Disable button while loading
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                "REGISTER",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),

                  // Google Sign-In button
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _signInWithGoogle, // Disable button while loading
                    icon: Image.asset(
                      'assets/images/Google.webp',
                      width: 24,
                      height: 24,
                    ),
                    label: Text(
                      "Sign in with Google",
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),

                  // Already have an account? Login text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login'); // Navigate to login screen
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.yellow,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build consistent text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 197, 205, 240),
            Color.fromARGB(255, 137, 153, 227),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: TextField(
          controller: controller,
          obscureText: obscureText, // Hide text for password fields
          decoration: InputDecoration(
            prefixIcon: Icon(prefixIcon, color: Colors.blue),
            hintText: hintText,
            filled: true,
            fillColor: Colors.transparent,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ),
    );
  }
}