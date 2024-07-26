import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hesapp/screens/stock_market_screen.dart';
import 'package:hesapp/services/authentication.dart';
import 'package:hesapp/custom_widgets/button.dart';
import 'package:hesapp/screens/forgot_password.dart';
import 'package:hesapp/services/google_auth.dart';
import 'package:hesapp/screens/signup_screen.dart';
import 'package:hesapp/custom_widgets/snackbar.dart';
import 'package:hesapp/custom_widgets/text_field.dart';
import 'package:hesapp/screens/bist_screen.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({super.key});

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

// email and passowrd auth part
  void loginUser() async {

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showSnackBar(context, 'Please fill in all fields');
      return;
    }

    setState(() {
      isLoading = true;
    });
    // signup user using our authmethod
    String res = await AuthMethod().loginUser(
        email: emailController.text, password: passwordController.text);

    if (res == "success") {
      setState(() {
        isLoading = false;
      });
      //navigate to the home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const StockList(),
        ),
      );
    } else if (res == "Please verify your email") {
      print(res);
      showSnackBar(context, res);
    }
    else if (res == "We have blocked all requests from this device due to unusual activity. Try again later.") {
      res = "Please verify your email";
      print(res);
      showSnackBar(context, res);
    }
    else {
      setState(() {
        isLoading = false;
      });
      // show error
      res="User not found";
      showSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: SafeArea(
        child: SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: height / 2.7,
                child: Image.asset('images/login.jpg'),
              ),
              TextFieldInput(
                  icon: Icons.person,
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
              //  we call our forgot password below the login in button
              const ForgotPassword(),
              MyButtons(onTap: loginUser, text: "Log In"),

              //ekranda aralarında "or" yazan siyah bir çizgi oluşturur
              Row(
                children: [
                  Expanded(
                    child: Container(height: 1, color: Colors.black26),
                  ),
                  const Text("  or  "),
                  Expanded(
                    child: Container(height: 1, color: Colors.black26),
                  )
                ],
              ),

              // for google login
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey),
                  onPressed: () async {
                    bool success = await FirebaseServices().signInWithGoogle();
                    if (success) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StockList(),
                        ),
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Image.network(
                          "https://ouch-cdn2.icons8.com/VGHyfDgzIiyEwg3RIll1nYupfj653vnEPRLr0AeoJ8g/rs:fit:456:456/czM6Ly9pY29uczgu/b3VjaC1wcm9kLmFz/c2V0cy9wbmcvODg2/LzRjNzU2YThjLTQx/MjgtNGZlZS04MDNl/LTAwMTM0YzEwOTMy/Ny5wbmc.png",
                          height: 35,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Continue with Google",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const SignupScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "SignUp",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Text(" or "),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const StockMarketScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Continue without registration",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}

