// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AppAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Signs in the user with Google and returns the [UserCredential].
  /// Throws an exception if the user cancels the sign-in process.
  Future<UserCredential> signInWithGoogle() async {
    // Trigger the sign-in flow.
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    // If the user cancels the sign-in, throw an exception.
    if (googleUser == null) {
      throw Exception("Google sign-in was cancelled by the user.");
    }

    // Obtain the auth details from the request.
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential.
    final credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

    // Sign in to Firebase with the credential and return the UserCredential.
    return await _firebaseAuth.signInWithCredential(credential);
  }

  /// Signs out the current user from both Firebase and Google.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}
