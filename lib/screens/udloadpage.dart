// ignore_for_file: avoid_print, use_build_context_synchronously, deprecated_member_use

import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:instagram/services/post_servies.dart';
import 'package:instagram/widgets/Mybutton.dart';

class Uploadpage extends StatefulWidget {
  final VoidCallback onUploadComplete;
  const Uploadpage({super.key, required this.onUploadComplete});

  @override
  State<Uploadpage> createState() => _UploadpageState();
}

class _UploadpageState extends State<Uploadpage> {
  final TextEditingController _captionController = TextEditingController();
  Uint8List? _imageBytes;
  String? _fileName;
  bool isLoading = false;
  bool isVideo(String url) => url.toLowerCase().endsWith('.mp4');

  Future<void> _pickMedia() async {
    final result = await PostServies.pickFile();
    if (result.bytes != null && result.name != null) {
      setState(() {
        _imageBytes = result.bytes;
        _fileName = result.name;
      });
      print('image picked$_fileName');
    }
  }

  Future<void> _uploadPost() async {
    setState(() => isLoading = true);

    try {
      final postServices = PostServies();
      String? mediaUrl;

      if (_imageBytes != null && _fileName != null) {
        mediaUrl = await postServices.uploadProfileImageToCloudinary(
          _imageBytes!,
          _fileName!,
        );

        if (mediaUrl == null) {
          print("Media upload failed.");
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Media upload failed.")));
          return;
        }

        await postServices.uploadPost(
          mediaUrl,
          _captionController.text.trim(),
          mediaType: mediaUrl.endsWith('.mp4') ? 'video' : 'image',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post uploaded successfully")),
        );
        //

        setState(() {
          _captionController.clear();
          _imageBytes = null;
          _fileName = null;
        });

        // 👇 Call this to switch to Home tab
        widget.onUploadComplete.call();
      }
    } catch (e) {
      print("Error uploading post: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Upload failed $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Post"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 1,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Padding(
              padding: MediaQuery.of(
                context,
              ).viewInsets.add(const EdgeInsets.all(16)),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Media Preview & Picker
                    GestureDetector(
                      onTap: _pickMedia,
                      child: Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _imageBytes != null
                            ? isVideo(_fileName ?? '')
                                  ? Center(
                                      child: Text(
                                        "Video selected",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : Image.memory(
                                      _imageBytes!,
                                      fit: BoxFit.cover,
                                    )
                            : const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "Tap to select image or video",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Caption Input
                    TextField(
                      controller: _captionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Write a caption...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Post Button
                    SizedBox(
                      width: double.infinity,
                      child: Mybutton(
                        isloading: false,
                        text: 'Post',
                        color: Colors.blue,
                        border: null,
                        ontap: _uploadPost,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loading Overlay
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
