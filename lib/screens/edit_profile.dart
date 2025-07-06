// ignore_for_file: use_build_context_synchronously, avoid_print, deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/services/auth_services.dart';
import 'package:instagram/services/post_servies.dart';
import 'package:instagram/utils/validators.dart';
import 'package:instagram/widgets/Mybutton.dart';
import 'package:instagram/widgets/mytextfield.dart';
import 'package:flutter/foundation.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _editNameController = TextEditingController();

  final TextEditingController _editBioController = TextEditingController();

  final TextEditingController _editUsernameController = TextEditingController();

  final authservice = AuthServices();
  bool _isLoading = false;

  Uint8List? _imageBytes; // To hold selected image
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Ensures keyboard pushes content instead of hiding
      appBar: AppBar(
        title: Text("Edit Profile"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, 0);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              children: [
                Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                  ),
                  child: _imageBytes != null
                      ? ClipOval(
                          child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                        )
                      : const Icon(Icons.person, size: 50),
                ),
                TextButton(
                  onPressed: () async {
                    final result = await PostServies.pickFile();
                    if (result.bytes != null) {
                      setState(() {
                        _imageBytes = result.bytes!;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Select only image")),
                      );
                    }
                  },
                  child: Text(
                    "Edit Picture",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                Mytextfield(
                  controller: _editNameController,
                  hintText: 'Name',
                  labeltext: 'Name',
                  validators: Validators.validateUsername,
                ),
                SizedBox(height: 10),
                Mytextfield(
                  controller: _editUsernameController,
                  hintText: 'Username',
                  labeltext: 'Username',
                  validators: Validators.validatePassword,
                ),
                SizedBox(height: 10),
                Mytextfield(
                  controller: _editBioController,
                  hintText: 'Bio',
                  labeltext: 'Bio',
                  validators: Validators.validateBio,
                ),
                SizedBox(height: 20),
                Mybutton(
                  isloading: false,
                  text: 'Update',
                  color: Colors.blue,
                  border: null,
                  ontap: () async {
                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      final user = FirebaseAuth.instance.currentUser!;
                      final postServices = PostServies();
                      String? imageUrl;

                      if (_imageBytes != null) {
                        imageUrl = await postServices
                            .uploadProfileImageToCloudinary(
                              _imageBytes!,
                              'profile',
                            );
                      }

                      await authservice.updateUserDocument(
                        user,
                        _editUsernameController.text.trim(),
                        _editNameController.text.trim(),
                        _editBioController.text.trim(),
                        imageUrl,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Profile updated successfully")),
                      );

                      Navigator.pop(
                        context,
                        true,
                      ); // return true to trigger profile tab switch
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Update failed")));
                    } finally {
                      setState(() => _isLoading = false);
                    }
                  },
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
