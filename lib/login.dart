import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth_services.dart'; // Import your AuthService
import 'main.dart'; // Import MainScreen

// Login screen widget
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController(); // Controller for email input
  final TextEditingController _passwordController = TextEditingController(); // Controller for password input
  bool _isLoading = false; // Tracks loading state during login process

  // Function to handle email and password login
  Future<void> _signInWithEmail() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Validate email and password fields
      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter email and password")),
        );
        return;
      }

      // Sign in with Firebase using email and password
      await authService.value.signIn(email: email, password: password);

      // Convert email to username (e.g., remove '@' and domain)
      final username = email.split('@')[0];

      // Navigate to the main screen after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen(username: username)),
      );
    } catch (e) {
      // Show error message if login fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid email or password")),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  // Function to handle Google Sign-In
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // Sign in with Google using Firebase
      final userCredential = await authService.value.signInWithGoogle();
      final email = userCredential.user?.email ?? '';

      // Convert email to username (e.g., remove '@' and domain)
      final username = email.split('@')[0];

      // Navigate to the main screen after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen(username: username)),
      );
    } catch (e) {
      // Show error message if Google Sign-In fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In failed")),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 87, 108, 214), // Background color
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                // Top gradient background
                Container(
                  height: MediaQuery.of(context).size.height * 0.25, // Dynamic height
                  width: double.infinity + 50,
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(80), // Rounded bottom corners
                    ),
                  ),
                ),
                // Overlay image on the gradient background
                Positioned(
                  left: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(80), // Rounded bottom corners
                    ),
                    child: Image.asset(
                      'assets/images/loginpage.jpg',
                      height: MediaQuery.of(context).size.height * 0.25, // Dynamic height
                      fit: BoxFit.cover, // Cover the entire container
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 80), // Spacing between elements
            Text(
              "Welcome Back",
              style: TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Login to your account",
              style: TextStyle(fontSize: 20, color: Colors.white70),
            ),
            SizedBox(height: 60),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  // Email input field with gradient background
                  Container(
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
                        controller: _emailController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email, color: Colors.blue),
                          hintText: "Email",
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
                  ),
                  SizedBox(height: 15),
                  // Password input field with gradient background
                  Container(
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
                        controller: _passwordController,
                        obscureText: true, // Hide password text
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock, color: Colors.blue),
                          hintText: "Password",
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
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: true,
                            onChanged: (value) {},
                            activeColor: Colors.white,
                          ),
                          Text(
                            "Remember me",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 35),
                  // Login button with gradient background
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
                        onPressed: _isLoading ? null : _signInWithEmail, // Disable button while loading
                        child: _isLoading
                            ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              )
                            : Text(
                                "LOGIN",
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
                      "Login with Google",
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 13,
                        horizontal: 20,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  // Sign up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/signin'); // Navigate to sign-in screen
                        },
                        child: Text(
                          "Sign up",
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
}