import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:first_app/constants/routes.dart';
import 'package:first_app/firebase_options.dart';
import 'package:first_app/utilities/show_error_dialog.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

@override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
                  options: DefaultFirebaseOptions.currentPlatform,
                ),
        builder: (context, snapshot) {
          switch(snapshot.connectionState) {
            case ConnectionState.done:
            return Column(
          children: [
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(
                hintText: "Enter your email here "
              ),
            ),
            TextField(
              controller: _password,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(
                hintText: "Enter your password here "
              ),
            ),
            TextButton(
              onPressed: () async{
                final email = _email.text;
                final password = _password.text;
                try {
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: email,
                  password: password
                );
                await FirebaseAuth.instance.currentUser?.sendEmailVerification();
                if(context.mounted){
                  Navigator.of(context).pushNamed(verifyEmailRoute);
                }

                }on FirebaseAuthException catch (e) {
                  if(e.code == 'weak-password'){
                    // devtools.log('weak password');
                    if(context.mounted){
                      await showErrorDialog(context, 'Weak Password',);
                    }
                  }else if(e.code == 'email-already-in-use'){
                    // devtools.log('email already in use');
                    if(context.mounted){
                      await showErrorDialog(context, 'Email already in use',);
                    }
                  }else if(e.code == 'invalid-email'){
                    // devtools.log('invalid email emtered');
                    if(context.mounted){
                      await showErrorDialog(context, 'Invalid Email',);
                    }
                  }else{
                    if(context.mounted){
                      await showErrorDialog(context, 'Error: ${e.code}',);
                    }
                  }
                  
                }catch (e){
                  if(context.mounted){
                      await showErrorDialog(context, e.toString(),);
                    }
                }
                
              }, 
              child: const Text("Register")),

              TextButton(
                onPressed: (){
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    loginRoute, 
                    (route) => false,
                    );
                }, 
                child: const Text('Already have an account? Login'))
          ],

          
        );
            
            default:
            return const Text('Loading...');
          }
          
          
        },
        
      ),
    );
  }
}