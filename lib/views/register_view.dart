import 'package:first_app/constants/routes.dart';
import 'package:first_app/services/auth/auth_exceptions.dart';
import 'package:first_app/services/auth/auth_services.dart';
import 'package:first_app/utilities/show_error_dialog.dart';
import 'package:flutter/material.dart';

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
                  await AuthServices.firebase().createUser(
                    email: email, 
                    password: password
                  );
                await AuthServices.firebase().sendEmailVerification();
                if(context.mounted){
                  Navigator.of(context).pushNamed(verifyEmailRoute);
                }

                }on WeakPasswordAuthException{
                  if(context.mounted){
                      await showErrorDialog(context, 'Weak Password',);
                    }
                }on EmailAlreadyInUseAuthException{
                  if(context.mounted){
                      await showErrorDialog(context, 'Email already in use',);
                    }
                }on InvalidEmailAuthException{
                  if(context.mounted){
                      await showErrorDialog(context, 'Invalid Email',);
                    }
                }on GenericAuthException{
                  if(context.mounted){
                      await showErrorDialog(context, 'Failed to register',);
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