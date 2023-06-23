// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/responsive/mobile_screen_layout.dart';
import 'package:instagram_clone/responsive/responsive.dart';
import 'package:instagram_clone/responsive/web_screen_layout.dart';
import 'package:instagram_clone/screens/login_screen.dart';
import 'package:instagram_clone/utils/image_picker.dart';
import 'package:instagram_clone/utils/show_snackbar.dart';
import 'package:instagram_clone/widgets/text_field.dart';

import '../resources/auth_methods.dart';
import '../utils/colors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().signUpUser(
      bio: _bioController.text,
      password: _passwordController.text,
      email: _emailController.text,
      username: _usernameController.text,
      file: _image!,
    );
    if (res != "success") {
      // ignore: use_build_context_synchronously
      showSnackBar(context, res);
      setState(() {
        _isLoading = false;
      });
    } else {
      // Do something
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ResponsiveLayout(
            mobileScreenLayout: MobileScreenLayout(),
            webScreenLayout: WebScreenLayout(),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
  }

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  void navigateToLogin() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Flexible(flex: 2, child: Container()),
              const SizedBox(height: 70),
              //svg image
              SvgPicture.asset(
                "assets/ic_instagram.svg",
                color: primaryColor,
                height: 64,
              ),
              const SizedBox(height: 50),
              //circlar widget to show and select a profile picture
              Stack(
                children: [
                  _image != null
                      ? CircleAvatar(
                          backgroundImage: MemoryImage(_image!),
                          radius: 55,
                        )
                      : const CircleAvatar(
                          backgroundImage: AssetImage(
                            "assets/profile_picture.png",
                          ),
                          radius: 55,
                        ),
                  Positioned(
                    bottom: -15,
                    right: 0,
                    child: IconButton(
                      onPressed: selectImage,
                      icon: const Icon(
                        Icons.add_a_photo,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              //text fiel for username
              TextFieldInput(
                textEditingController: _usernameController,
                hintText: "Enter your username",
                textInputType: TextInputType.text,
              ),
              const SizedBox(height: 25),

              // text field for email
              TextFieldInput(
                textEditingController: _emailController,
                hintText: "Enter your email",
                textInputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 25),

              // text field for password
              TextFieldInput(
                textEditingController: _passwordController,
                hintText: "Enter your password",
                textInputType: TextInputType.emailAddress,
                isPassword: true,
              ),
              const SizedBox(height: 25),

              // text field for bio
              TextFieldInput(
                textEditingController: _bioController,
                hintText: "Enter your bio",
                textInputType: TextInputType.text,
              ),
              const SizedBox(height: 25),
              // buttom for login
              InkWell(
                onTap: () => signUpUser(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(75),
                    color: blueColor,
                  ),
                  child: Center(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                            color: primaryColor,
                          ))
                        : const Text(
                            "Sign up",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                  ),
                ),
              ),
              // Flexible(flex: 2, child: Container()),
              const SizedBox(height: 70),

              // navigation to signup
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: const Text("Have an account?   "),
                  ),
                  GestureDetector(
                    onTap: navigateToLogin,
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: const Text(
                        "Login",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
