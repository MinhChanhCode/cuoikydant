import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:users_app/authentication/signup_screen.dart';

import '../global/global_var.dart';
import '../methobs/common_methobs.dart';
import '../pages/home_page.dart';
import '../widgets/loading_dialog.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}



class _LoginScreenState extends State<LoginScreen>
{
  TextEditingController emailtextEditingController = TextEditingController();
  TextEditingController passwordtextEditingController = TextEditingController();
  CommonMethobs cMethobs = CommonMethobs();



  checkIfNetworkIsAvailable()
  {
    cMethobs.checkConnectivity(context);

    signInFormValidation();
  }

  signInFormValidation()
  {

    if(!emailtextEditingController.text.contains("@"))
    {
      cMethobs.displaySnackBar("please write valid email", context);
    }
    else if(passwordtextEditingController.text.trim().length < 5)
    {
      cMethobs.displaySnackBar("your password must be atleast 6 or more characters", context);
    }
    else
    {
      signInUser();
    }
  }

  signInUser() async
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(messageText: "Allowing you to Login..."),
    );

    final User? userFireBase = (
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailtextEditingController.text.trim(),
          password: passwordtextEditingController.text.trim(),
        ).catchError((errorMsg)
        {
          Navigator.pop(context);
          cMethobs.displaySnackBar(errorMsg.toString(), context);
        })
    ).user;

    if(!context.mounted) return;
    Navigator.pop(context);

    if(userFireBase != null)
      {
        DatabaseReference userRef = FirebaseDatabase.instance.ref().child("user").child(userFireBase.uid);
        userRef.once().then((snap)
        {
          if(snap.snapshot.value !=null)
            {
              if((snap.snapshot.value as Map)["blockStatus"] == "no")
                {
                  userName = (snap.snapshot.value as Map)["name"];
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> HomePage()));
                }
              else
                {
                  FirebaseAuth.instance.signOut();
                  cMethobs.displaySnackBar("you are blocked. Contact admin: lechanh404@gmail.com", context);
                }
            }
          else
            {
              FirebaseAuth.instance.signOut();
              cMethobs.displaySnackBar("your record do not exists", context);
            }
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [

              Image.asset(
                  "assets/images/logo.png"
              ),

              const Text(
                "Login as a User",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              //text fields + button
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [

                    TextField(
                      controller: emailtextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "User Email",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 22,),

                    TextField(
                      controller: passwordtextEditingController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "User Password",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 32,),

                    ElevatedButton(
                      onPressed: ()
                      {
                        checkIfNetworkIsAvailable();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20)
                      ),
                      child: const Text(
                          "Login"
                      ),
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 12,),

              //text button
              TextButton(
                onPressed: ()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> SignupScreen()));
                },
                child: const Text(
                  "Don\'t have an Account? Register Here",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
