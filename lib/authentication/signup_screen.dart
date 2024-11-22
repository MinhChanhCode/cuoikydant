import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:users_app/authentication/login_screen.dart';
import 'package:users_app/methobs/common_methobs.dart';
import 'package:users_app/pages/home_page.dart';
import 'package:users_app/widgets/loading_dialog.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}



class _SignupScreenState extends State<SignupScreen>
{
  TextEditingController userNametextEditingController = TextEditingController();
  TextEditingController userPhonetextEditingController = TextEditingController();
  TextEditingController emailtextEditingController = TextEditingController();
  TextEditingController passwordtextEditingController = TextEditingController();
  CommonMethobs cMethobs = CommonMethobs();


  checkIfNetworkIsAvailable()
  {
    cMethobs.checkConnectivity(context);

    signUpFormValidation();
  }

  signUpFormValidation()
  {
    if(userNametextEditingController.text.trim().length < 3)
      {
        cMethobs.displaySnackBar("your name must be atleast 4 or more characters", context);
      }
    else if(userPhonetextEditingController.text.trim().length < 7)
    {
      cMethobs.displaySnackBar(" your phone number must be atleast 8 or more characters", context);
    }
    else if(!emailtextEditingController.text.contains("@"))
    {
      cMethobs.displaySnackBar("please write valid email", context);
    }
    else if(passwordtextEditingController.text.trim().length < 5)
    {
    cMethobs.displaySnackBar("your password must be atleast 6 or more characters", context);
    }
    else
      {
        registerNewUser();
      }
  }

  registerNewUser() async
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(messageText: "Registering your account..."),
    );

    final User? userFireBase = (
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
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

    DatabaseReference userRef = FirebaseDatabase.instance.ref().child("user").child(userFireBase!.uid);
    Map userDataMap =
        {
          "name": userNametextEditingController.text.trim(),
          "email": emailtextEditingController.text.trim(),
          "phone": userPhonetextEditingController.text.trim(),
          "id": userFireBase.uid,
          "blockStatus": "no",
        };
    userRef.set(userDataMap);

    Navigator.push(context, MaterialPageRoute(builder: (c)=> HomePage()));
  }

  @override
  Widget build(BuildContext context)
  {
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
                "Create a User\'s Account",
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
                      controller: userNametextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "User Name",
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
                      controller: userPhonetextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "User Phone",
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
                        "Sign Up"
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
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
                },
                child: const Text(
                  "Already have an Account? Login Here",
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
