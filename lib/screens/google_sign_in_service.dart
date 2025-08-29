import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer' as developer;

class GoogleSignInService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );

  static Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      return await _googleSignIn.signIn();
    } catch (error) {
      developer.log(
        "Google Sign-In error: $error",
        name: "GoogleSignInService",
        level: 1000, // Severe error
      );
      return null;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
