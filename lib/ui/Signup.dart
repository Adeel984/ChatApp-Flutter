import 'dart:io';

import 'package:chat_app/utils/FirebaseHelper.dart';
import 'package:flutter/material.dart';

import '../utils/ImageHelper.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var nameController = TextEditingController();
  var formKey = GlobalKey<FormState>();
  File? imageFile;

  bool emailValid(email) => RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(email);

  void _login() async {
    if (formKey.currentState!.validate()) //No error
    {
      var email = emailController.text;
      var password = passwordController.text;
      var name = nameController.text;
      String? image = null;
      if (imageFile != null)
        image = await FirebaseHelper().uploadImage(imageFile!);
      var user =
          FirebaseHelper().signupUser(name, email, password, image, context);
      Navigator.pushNamedAndRemoveUntil(context, "/inbox", (route) => false);
    }
  }

  void selectImage() async {
    imageFile = await ImageHelper().pickImage();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SafeArea(
            child: Center(
                child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(clipBehavior: Clip.none, children: [
                    CircleAvatar(
                      backgroundColor: Colors.black26,
                      radius: 50,
                      backgroundImage:
                          imageFile != null ? FileImage(imageFile!) : null,
                    ),
                    Positioned(
                        bottom: -10,
                        right: -10,
                        child: FloatingActionButton(
                          child: Icon(Icons.edit),
                          onPressed: selectImage,
                        ))
                  ]),
                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    "Welcome to our chat app",
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "Email is required";
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.supervisor_account),
                        hintText: "Enter your name",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "Email is required";
                      else if (!emailValid(value)) return "Email is invalid";
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        hintText: "Enter your email",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "Password is required";
                      else if (value.length < 6)
                        return "Password must at least 6 characters";
                      return null;
                    },
                    obscureText: true,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        hintText: "Enter password",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          minimumSize: Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onPressed: _login,
                      icon: Icon(Icons.login),
                      label: Text("Signup")),
                  TextButton(
                      child: Text("Already have an account? Login"),
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      })
                ],
              ),
            )),
          ),
        ),
      ),
    );
  }
}
