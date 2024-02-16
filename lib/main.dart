import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Future<UserCredential> signInWithGoogle() async {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      return await FirebaseAuth.instance.signInWithCredential(credential);
    }

    Future uploadFile(File file) async {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user')
          .child('5SKYwFBkpRMeFHq09AdULDGLbcl2')
          .child('card-id.jpg');
      try {
        await storageRef.putFile(file);
        final imageUrl = await storageRef.getDownloadURL();
        print('----imageUrl: $imageUrl');
      } catch (e) {
        print('error: $e');
      }
    }

    Future pickFile() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        File file = File(result.files.single.path!);
        uploadFile(file);
      }
    }

    Future<void> uploadObject() async {
      final user = <String, dynamic>{
        "first": "Ada",
        "last": "Lovelace",
        "born": 1815
      };

      await FirebaseFirestore.instance
          .collection('cards')
          .doc('5SKYwFBkpRMeFHq09AdULDGLbcl2')
          .set(user);

      await FirebaseFirestore.instance
          .collection('user-data')
          .doc('5SKYwFBkpRMeFHq09AdULDGLbcl2')
          .set(user);
    }

    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => {signInWithGoogle()},
                icon: const Icon(Icons.login),
                label: const Text('Login with Google'),
              ),
              OutlinedButton.icon(
                onPressed: () => {pickFile()},
                icon: const Icon(Icons.file_upload),
                label: const Text('File picker & upload'),
              ),
              OutlinedButton.icon(
                onPressed: () => {uploadObject()},
                icon: const Icon(Icons.upload_file_outlined),
                label: const Text('upload object to firestore'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
