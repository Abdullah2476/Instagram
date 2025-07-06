// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PostServies {
  // To hold selected image
  static Future<({Uint8List? bytes, Uint8List? extension, String? name})>
  pickFile({
    List<String> allowedExtensions = const ['jpg', 'jpeg', 'png', 'mp4', 'mov'],
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      Uint8List? fileBytes = result.files.single.bytes;
      // ignore: unused_local_variable
      String fileName = result.files.single.name;
      return (bytes: fileBytes, extension: fileBytes, name: fileName);
    }
    return (bytes: null, extension: null, name: null);
  }

  //upload method to cloudinary
  Future<String?> uploadProfileImageToCloudinary(
    Uint8List imageBytes,
    String filename,
  ) async {
    final isVideo =
        filename.toLowerCase().endsWith('.mp4') ||
        filename.toLowerCase().endsWith('.mov');
    String cloudName = 'dwum3i6lj';
    String uploadPreset = 'public';
    Uri url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/${isVideo ? 'video' : 'image'}/upload',
    );

    var request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        http.MultipartFile.fromBytes('file', imageBytes, filename: filename),
      );

    final response = await request.send();
    if (response.statusCode == 200) {
      final res = await response.stream.bytesToString();
      final data = json.decode(res);
      //image url
      return data['secure_url'];
    } else {
      return null;
    }
  }

  //creates a post document
  Future<void> uploadPost(
    String mediaUrl,
    String caption, {
    required String mediaType,
  }) async {
    final user = FirebaseAuth.instance.currentUser!;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final username = userDoc.data()?['username'] ?? '';
    final profileimage =
        userDoc.data()?['profileImage'] ?? userDoc.data()?['defaultImageUrl'];
    final docRef = FirebaseFirestore.instance.collection('posts').doc();
    final postId = docRef.id;

    await docRef.set({
      'postId': postId,
      'userId': user.uid,
      'username': username,
      'profileImage': profileimage,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'caption': caption,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> updatePost({
    required String postId,
    required BuildContext context,
    required String mediaUrl,
    required String captionController,
    required String mediaType,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final user = currentUser.uid;
    final postOwnerId = await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .get();

    final id = postOwnerId.data()?['userId'];
    if (user == id) {
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'mediaUrl': mediaUrl,
        'caption': captionController,
        'mediaType': mediaType,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Only Post owner can update post')),
      );
    }
  }

  Future<void> deletePost(String postId, BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final user = currentUser.uid;
    final postOwnerId = await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .get();

    final id = postOwnerId.data()?['userId'];

    if (user == id) {
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Post deleted")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Only Post owner can delete post')),
      );
    }
  }
}
