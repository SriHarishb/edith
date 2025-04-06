import 'dart:convert'; // For JSON encoding and decoding
import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication
import 'package:flutter/material.dart'; // Flutter Material widgets
import 'package:google_sign_in/google_sign_in.dart'; // Google sign-in package
import 'package:http/http.dart' as http; // HTTP package for making API requests

// ValueNotifier to observe and manage authentication state
ValueNotifier<AuthService> authService = ValueNotifier(AuthService());
// Instance of GoogleSignIn for handling Google sign-in
final GoogleSignIn _googleSignIn = GoogleSignIn();

class AuthService {
  // Firebase authentication instance for handling authentication tasks
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // Getter for current user
  User? get currentUser => firebaseAuth.currentUser;

  // Stream to listen to authentication state changes
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  // Method to create a user in the backend (using a REST API)
  Future<void> createUserInBackend(String username) async {
    // URL of the backend API to create a user
    const String backendUrl =
        "https://edithbackend-763539946053.us-central1.run.app/create_user";

    try {
      // Send a POST request to the backend to create the user
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {
          "Content-Type": "application/json", // Set content type to JSON
        },
        body: jsonEncode({"user_id": username}), // Send username as the request body
      );

      // Check if the response status code is 200 (success)
      if (response.statusCode == 200) {
        print("User created in backend: ${response.body}");
      } else {
        // If the request fails, throw an exception
        throw Exception("Failed to create user in backend: ${response.body}");
      }
    } catch (e) {
      // Catch any errors and print them
      print("Error calling backend API: $e");
      rethrow; // Rethrow the error to handle it in the calling function
    }
  }

  // Sign-in method using email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    // Call Firebase Authentication to sign in the user with email and password
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign-in method using Google Sign-In
  Future<UserCredential> signInWithGoogle() async {
    // Trigger Google Sign-In flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception("Google Sign-In canceled");
    }

    // Get Google authentication tokens
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a credential using the Google tokens
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Use the credential to sign in with Firebase Authentication
    return await firebaseAuth.signInWithCredential(credential);
  }

  // Method to create an account with email and password
  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    try {
      // Create the user with email and password in Firebase Authentication
      final UserCredential userCredential =
          await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Extract the username from the email (before the '@' symbol)
      final String username = email.split('@')[0];

      // Call the backend API to create the user in the backend
      await createUserInBackend(username);

      return userCredential;
    } catch (e) {
      // Catch errors during account creation
      print("Error during account creation: $e");
      rethrow; // Rethrow the error to handle it in the calling function
    }
  }

  // Method to sign out the user
  Future<void> signOut() async {
    // Sign out from both Firebase Authentication and Google Sign-In
    await firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

  // Method to send a password reset email to the user's email address
  Future<void> resetPassword({required String email}) async {
    // Send the reset email using Firebase Authentication
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  // Method to update the user's display name (username)
  Future<void> updateUsername({required String username}) async {
    // Update the display name of the current user
    await currentUser?.updateDisplayName(username);
  }

  // Method to delete the user's account
  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    // Create a credential using the user's email and password
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    // Re-authenticate the user with the provided credentials
    await currentUser?.reauthenticateWithCredential(credential);

    // Delete the user's account and sign them out
    await currentUser?.delete();
    await firebaseAuth.signOut();
  }

  // Method to reset the user's password using their current password and new password
  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    // Create a credential using the current password
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    // Re-authenticate the user with the provided credentials
    await currentUser?.reauthenticateWithCredential(credential);

    // Update the password to the new password
    await currentUser?.updatePassword(newPassword);
  }
}
