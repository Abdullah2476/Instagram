// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:instagram/services/post_servies.dart';
import 'package:instagram/widgets/Mybutton.dart';

class UpdatePost extends StatefulWidget {
  final String postId;
  const UpdatePost({super.key, required this.postId});

  @override
  State<UpdatePost> createState() => _UploadpageState();
}

class _UploadpageState extends State<UpdatePost> {
  final TextEditingController captionController = TextEditingController();
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Media upload failed.")));
          return;
        }

        await postServices.updatePost(
          context: context,
          mediaType: mediaUrl.endsWith('.mp4') ? 'video' : 'image',

          mediaUrl: mediaUrl,
          captionController: captionController.text.toString(),
          postId: widget.postId,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post updated successfully")),
        );
        Navigator.pop(context, true);

        setState(() {
          captionController.clear();
          _imageBytes = null;
          _fileName = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Update failed $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Post"),
        centerTitle: true,

        elevation: 1,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Stack(
        children: [
          Padding(
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
                                : Image.memory(_imageBytes!, fit: BoxFit.cover)
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
                    controller: captionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Update a caption...",
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
                      text: 'Update',
                      color: Colors.blue,
                      border: null,
                      ontap: _uploadPost,
                    ),
                  ),
                ],
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
