
import 'package:flutter/material.dart';
import 'package:hesapp/services/authentication.dart';
import 'package:hesapp/custom_widgets/button.dart';
import 'package:hesapp/custom_widgets/snackbar.dart';
import 'package:hesapp/custom_widgets/text_field.dart';
import 'package:hesapp/screens/user_login_screen.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
  }

  void signupUser() async {

    if (emailController.text.isEmpty || passwordController.text.isEmpty || nameController.text.isEmpty) {
      showSnackBar(context, 'Please fill in all fields');
      return;
    }

    // set is loading to true.
    setState(() {
      isLoading = true;
    });
    // signup user using our authmethod
    String res = await AuthMethod().signupUser(
        email: emailController.text,
        password: passwordController.text,
        name: nameController.text);
    // if string return is success, user has been creaded and navigate to next screen other witse show error.
    if (res == "success") {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('A verification link has been sent to your email')),
      );

      setState(() {
        isLoading = false;
      });
      //navigate to the next screen
      Navigator.of(context).pop();
    } else {
      setState(() {
        isLoading = false;
      });
      // show error
      showSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: SafeArea(
          child: SizedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: height / 2.8,
                  child: Image.asset('images/signup.jpeg'),
                ),
                TextFieldInput(
                    icon: Icons.person,
                    textEditingController: nameController,
                    hintText: 'Enter your name',
                    textInputType: TextInputType.text),
                TextFieldInput(
                    icon: Icons.email,
                    textEditingController: emailController,
                    hintText: 'Enter your email',
                    textInputType: TextInputType.text),
                TextFieldInput(
                  icon: Icons.lock,
                  textEditingController: passwordController,
                  hintText: 'Enter your passord',
                  textInputType: TextInputType.text,
                  isPass: true,
                ),
                MyButtons(onTap: signupUser, text: "Sign Up"),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const UserLoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        " Login",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                )
              ],
            ),
          )),
    );
  }
}

// Sign up eski kodlar
/*

import 'package:flutter/material.dart';
import 'package:training_app/Firebase_project/authentication.dart';
import 'package:training_app/Firebase_project/button.dart';
import 'package:training_app/Firebase_project/items_list_screen.dart';
import 'package:training_app/Firebase_project/snackbar.dart';
import 'package:training_app/Firebase_project/text_field.dart';
import 'package:training_app/Firebase_project/user_login_screen.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
  }

  void signupUser() async {
    // set is loading to true.
    setState(() {
      isLoading = true;
    });
    // signup user using our authmethod
    String res = await AuthMethod().signupUser(
        email: emailController.text,
        password: passwordController.text,
        name: nameController.text);
    // if string return is success, user has been creaded and navigate to next screen other witse show error.
    if (res == "success") {
      setState(() {
        isLoading = false;
      });
      //navigate to the next screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ItemsListScreen(),
        ),
      );
    } else {
      setState(() {
        isLoading = false;
      });
      // show error
      showSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
          child: SizedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: height / 2.8,
                  child: Image.asset('images/signup.jpeg'),
                ),
                TextFieldInput(
                    icon: Icons.person,
                    textEditingController: nameController,
                    hintText: 'Enter your name',
                    textInputType: TextInputType.text),
                TextFieldInput(
                    icon: Icons.email,
                    textEditingController: emailController,
                    hintText: 'Enter your email',
                    textInputType: TextInputType.text),
                TextFieldInput(
                  icon: Icons.lock,
                  textEditingController: passwordController,
                  hintText: 'Enter your passord',
                  textInputType: TextInputType.text,
                  isPass: true,
                ),
                MyButtons(onTap: signupUser, text: "Sign Up"),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const UserLoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        " Login",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                )
              ],
            ),
          )),
    );
  }
}
 */