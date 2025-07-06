// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/main_navigation.dart';
import 'package:instagram/screens/login.dart';
import 'package:instagram/services/auth_services.dart';
import 'package:instagram/utils/validators.dart';
import 'package:instagram/widgets/Mybutton.dart';
import 'package:instagram/widgets/mytextfield.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  void signup(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        setState(() => isLoading = true);

        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        User? user = userCredential.user;
        if (user != null) {
          final authservices = AuthServices();
          await authservices.createUserDocument(
            user,
            _usernameController.text.trim(),
          );
        }

        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Signup successful')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MianNavigation()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? e.code)));
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('An error occurred')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: MediaQuery.of(
            context,
          ).viewInsets.add(const EdgeInsets.symmetric(horizontal: 24.0)),
          child: Column(
            children: [
              const SizedBox(height: 40),

              Image.asset('assets/images/insta logo.png', height: 100),

              const SizedBox(height: 30),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Mytextfield(
                      controller: _usernameController,
                      hintText: 'Username',
                      labeltext: 'Username',
                      validators: Validators.validateUsername,
                    ),
                    Mytextfield(
                      controller: _emailController,
                      hintText: 'Email or mobile number',
                      labeltext: 'Email',
                      validators: Validators.validateEmail,
                    ),
                    Mytextfield(
                      controller: _passwordController,
                      hintText: 'Password',
                      labeltext: 'Password',
                      isPassword: true,
                      validators: Validators.validatePassword,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Mybutton(
                isloading: isLoading,
                text: 'Sign Up',
                color: Colors.blue,
                style: const TextStyle(color: Colors.white),
                border: null,
                ontap: () => signup(context),
              ),

              const SizedBox(height: 20),
              const Divider(thickness: 1),
              const SizedBox(height: 10),

              Mybutton(
                isloading: false,
                text: 'Already have an account? Log in',
                style: const TextStyle(color: Colors.blue),
                color: Colors.white,
                border: Border.all(color: Colors.blue, width: 2),
                ontap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                  );
                },
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.all_inclusive_rounded),
                  SizedBox(width: 5),
                  Text("Meta", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
