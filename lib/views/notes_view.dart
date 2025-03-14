import 'package:first_app/constants/routes.dart';
import 'package:first_app/enums/menu_action.dart';
import 'package:first_app/services/auth/auth_services.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

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
                    await AuthServices.firebase().logOut();
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