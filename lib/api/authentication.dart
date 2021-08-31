import 'package:fastcheckout/api/firestore_api.dart';
import 'package:fastcheckout/model/userModel.dart';
import 'package:fastcheckout/ui/home.dart';
import 'package:fastcheckout/ui/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class Authentication {
  User? user = FirebaseAuth.instance.currentUser;
  FireStoreUser? fireStoreUser;
  FireStoreUser? get currentUser => fireStoreUser;
  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }

  Future<FirebaseApp> initializeFirebase({
    required BuildContext context,
  }) async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();

    if (user != null) {
      await _handleAuthenticationResponse(user!);
      if (currentUser != null) {
        navigateToHome(context: context);
      }
    }
    return firebaseApp;
  }

  Future<User?> signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential =
            await auth.signInWithPopup(authProvider);
        await _handleAuthenticationResponse(userCredential.user!);
        user = userCredential.user;
      } catch (e) {
        print(e);
      }
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential =
              await auth.signInWithCredential(credential);
          await _handleAuthenticationResponse(userCredential.user!);
          user = userCredential.user;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            ScaffoldMessenger.of(context).showSnackBar(
              Authentication.customSnackBar(
                content:
                    'The account already exists with a different credential',
              ),
            );
          } else if (e.code == 'invalid-credential') {
            ScaffoldMessenger.of(context).showSnackBar(
              Authentication.customSnackBar(
                content:
                    'Error occurred while accessing credentials. Try again.',
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            Authentication.customSnackBar(
              content: 'Error occurred using Google Sign In. Try again.',
            ),
          );
        }
      }
    }

    return user;
  }

  Future<void> signOut({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginView()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        Authentication.customSnackBar(
          content: 'Error signing out. Try again.',
        ),
      );
    }
  }

  void navigateToHome({required BuildContext context}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StreamProvider<List<Orders>>.value(
          value: FirestoreApi().streamuser(),
          initialData: [],
          child: Home(),
        ),
      ),
    );
  }

  Future<void> _handleAuthenticationResponse(User user) async {
    if (user != null) {
      await syncOrCreateUserAccount(user: user);
    } else {
      Exception('User is not Synced');
    }
  }

  Future<void> syncUserAccount({required String uid}) async {
    final userAccount = await FirestoreApi().getUser(id: uid);

    if (userAccount != null) {
      fireStoreUser = userAccount;
      print('user is synced ${currentUser!.id}');
    } else {
      fireStoreUser = null;
    }
  }

  Future<void> syncOrCreateUserAccount({required User user}) async {
    await syncUserAccount(uid: user.uid);

    if (fireStoreUser == null) {
      print('We have no user account. Create a new user ...');
      await FirestoreApi().createUser(id: user.uid);
      fireStoreUser = FireStoreUser(id: user.uid, orders: []);
    }
  }
}
