import 'package:first_app/constants/routes.dart';
import 'package:first_app/services/auth/auth_services.dart';
import 'package:flutter/material.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verify Email'),),
      body: Column(children: [
          Text("We have sent you an email ,Please verify to register"),
          Text("If you havn't recieved email click on the button below"),
          TextButton(
            onPressed: () async{
              await AuthService.firebase().sendEmailVerification();
            },
            child: Text('Send Email Verification')
          ),
          
          TextButton(
            onPressed: ()async{
              await AuthService.firebase().logOut();
              if(context.mounted){
                Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route)=> false);
              }
            }, 
            child: const Text('Restart'))
        ],
      ),
    );
  }
}