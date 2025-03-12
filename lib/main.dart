import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:first_app/firebase_options.dart';
import 'package:first_app/views/login_view.dart';
import 'package:first_app/views/register_view.dart';
import 'package:first_app/views/verify_email_view.dart';
import 'package:flutter/material.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey,
        )
      ),
      home: const HomePage(),
      routes: {
        '/login/' : (context)=> LoginView(),
        '/register/' : (context)=> RegisterView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(
                  options: DefaultFirebaseOptions.currentPlatform,
                ),
        builder: (context, snapshot) {
          switch(snapshot.connectionState) {
            case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;

            if(user != null){
              if(user.emailVerified){
                print("User emaul is verfied ");
              }else{
                return const VerifyEmailView();
              }
            }else{
              return LoginView();
            }

            return const Text('Done');

            // if(user?.emailVerified ?? false){
            //   // print('User is verified ');
            //   return const Text('Done');
            // }else{
            //   // print('You need to verify first');
            //   return const VerifyEmailView();
            // }
            
            return const LoginView();
            default:
              return const CircularProgressIndicator();
          }
          
          
        },
        
      );
  }
}