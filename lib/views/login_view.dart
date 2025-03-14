import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:first_app/constants/routes.dart';
import 'package:first_app/firebase_options.dart';
import 'package:first_app/utilities/show_error_dialog.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
        title: const Text("Login"),
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
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: email,
                  password: password
                );
                final user = FirebaseAuth.instance.currentUser;
                if(user?.emailVerified ?? false){
                  if(context.mounted){
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      notesRoute, 
                      (route)=> false,
                    );
                  }
                }else{
                  if(context.mounted){
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      verifyEmailRoute, 
                      (route)=>false);
                  }
                }
                
                }on FirebaseAuthException catch (e){
                  if(e.code == 'user-not-found'){
                    // devtools.log('user-not-found');
                    if(context.mounted){
                      await showErrorDialog(context, 'user not found',);
                    }
                  }else if (e.code == 'invalid-credential'){
                    // devtools.log('wrong password');
                    if(context.mounted){
                      await showErrorDialog(context, 'Invalid Credentials',);
                    }
                    devtools.log(e.code);
                  }else{
                    if(context.mounted){
                      await showErrorDialog(context, 'Error: ${e.code}',);
                    }
                  }
                  
                } catch (e){
                  if(context.mounted){
                    await showErrorDialog(context, e.toString(),);
                  }
                }
                // catch (e) {
                //   print('something bad happened');
                //   print(e.runtimeType);
                //   print(e);
                // }
                
              }, 
              child: const Text("Login")),

              TextButton(
                onPressed: (){
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    registerRoute,
                    (route)=> false,
                    );
                }, 
                child:  const Text('Not Registered yet? Register Here!'))
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