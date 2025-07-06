// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/main_navigation.dart';
import 'package:instagram/screens/signup.dart';
import 'package:instagram/utils/validators.dart';
import 'package:instagram/widgets/Mybutton.dart';
import 'package:instagram/widgets/mytextfield.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  void login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login successful')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MianNavigation()),
        );
      } on FirebaseAuthException catch (e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message ?? e.code)));
      } catch (_) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("An error occurred")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: MediaQuery.of(
            context,
          ).viewInsets.add(const EdgeInsets.symmetric(horizontal: 24.0)),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo
              Image.asset('assets/images/insta logo.png', height: 100),

              const SizedBox(height: 40),

              // Login Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Mytextfield(
                      controller: _emailController,
                      hintText: 'Username, email or mobile number',
                      labeltext: 'Username',
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

              // Login Button
              Mybutton(
                isloading: isLoading,
                text: 'Log in',
                color: Colors.blue,
                style: const TextStyle(color: Colors.white),
                border: null,
                ontap: () => login(context),
              ),

              const SizedBox(height: 12),

              // Forgot Password
              Text(
                "Forgot password?",
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 20),

              // OR Divider
              Row(
                children: [
                  Expanded(child: Divider(thickness: 1)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("OR"),
                  ),
                  Expanded(child: Divider(thickness: 1)),
                ],
              ),

              const SizedBox(height: 20),

              Spacer(),

              // Create New Account
              Mybutton(
                text: 'Create New Account',
                isloading: false,
                style: const TextStyle(color: Colors.blue),
                color: Colors.white,
                border: Border.all(color: Colors.blue, width: 2),
                ontap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Signup()),
                  );
                },
              ),

              const SizedBox(height: 10),

              // Meta Branding
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.all_inclusive_rounded, size: 20),
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
