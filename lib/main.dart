import 'package:first_app/constants/routes.dart';
import 'package:first_app/services/auth/auth_services.dart';

import 'package:first_app/views/login_view.dart';
import 'package:first_app/views/notes/new_notes_view.dart';
import 'package:first_app/views/notes/notes_view.dart';
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
        loginRoute : (context)=> const LoginView(),
        registerRoute : (context)=> const RegisterView(),
        notesRoute: (context)=> const NotesView(),
        verifyEmailRoute : (context)=> const VerifyEmailView(),
        newNoteRoute : (context) => const NewNoteView()
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthServices.firebase().initialize(),
        builder: (context, snapshot) {
          switch(snapshot.connectionState) {
            case ConnectionState.done:
            final user = AuthServices.firebase().currentUser;

            if(user != null){
              if(user.isEmailVerified){
                return const NotesView();
              }else{
                return const VerifyEmailView();
              }
            }else{
              return LoginView();
            }

            // if(user?.emailVerified ?? false){
            //   // print('User is verified ');
            //   return const Text('Done');
            // }else{
            //   // print('You need to verify first');
            //   return const VerifyEmailView();
            // }
            
            default:
              return const CircularProgressIndicator();
          }
          
          
        },
        
      );
  }
}