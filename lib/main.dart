import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:first_app/constants/routes.dart';
import 'package:first_app/firebase_options.dart';
import 'package:first_app/views/login_view.dart';
import 'package:first_app/views/register_view.dart';
import 'package:first_app/views/verify_email_view.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;
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

enum MenuActions{logout}

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main UI"),
        actions: [
          PopupMenuButton<MenuActions>(
            onSelected: (value) async {
              switch (value){
                case MenuActions.logout:
                  final shouldLogOut = await showLogOutDialog(context);
                  devtools.log(shouldLogOut.toString());
                  if(shouldLogOut){
                    await FirebaseAuth.instance.signOut();
                    if(context.mounted){
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        loginRoute, 
                        (_) => false);
                      }
                    }
                    
                  break;
              }
            } ,
            itemBuilder: (context) {
              return const[ 
                PopupMenuItem(
                  value: MenuActions.logout,
                  child: Text('Logout')
                )
              ];
            }
          )
        ],
      ),
      body: const Text('Hello World'),
    );
  }
}

Future<bool> showLogOutDialog (BuildContext context){
  return showDialog<bool>(
    context: context, 
    builder: (context){
      return AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.of(context).pop(false);
            }, 
            child: const Text('Cancle'),
            ),
          TextButton(
            onPressed: (){
              Navigator.of(context).pop(true);
            }, 
            child: const Text('Log out'),
          )
        ],
      );
    }
    ).then((value) => value ?? false);
}