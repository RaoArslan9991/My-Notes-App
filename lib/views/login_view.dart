import 'package:first_app/constants/routes.dart';
import 'package:first_app/services/auth/auth_exceptions.dart';
import 'package:first_app/services/auth/auth_services.dart';

import 'package:first_app/utilities/show_error_dialog.dart';
import 'package:flutter/material.dart';

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
        future: AuthServices.firebase().initialize(),
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
                  await AuthServices.firebase().logIn(
                    email: email, 
                    password: password
                    );
                final user = AuthServices.firebase().currentUser;
                if(user?.isEmailVerified ?? false){
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
                
                }on UserNotFoundAuthException{
                  if(context.mounted){
                      await showErrorDialog(context, 'user not found',);
                    }
                }on WrondPasswordAuthException{
                  if(context.mounted){
                      await showErrorDialog(context, 'Invalid Credentials',);
                    }
                }on GenericAuthException{
                  if(context.mounted){
                    await showErrorDialog(context, "Authentication error ",);
                  }
                }
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