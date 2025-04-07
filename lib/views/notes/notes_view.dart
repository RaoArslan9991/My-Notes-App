import 'package:first_app/constants/routes.dart';
import 'package:first_app/enums/menu_action.dart';
import 'package:first_app/services/auth/auth_services.dart';
import 'package:first_app/services/crud/notes_services.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;

  String get userEmail => AuthServices.firebase().currentUser!.email!;
  
  @override
  void initState() {
    _notesService = NotesService();
    _notesService.open();
    super.initState();
  }

  @override
  void dispose() {
    _notesService.close();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Notes"),
        actions: [
          IconButton(onPressed: (){
            Navigator.of(context).pushNamed(newNoteRoute);
          }, 
          icon: const Icon(Icons.add)
          ),
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
      body: FutureBuilder(future: _notesService.getOrCreateUser(email: userEmail), 
      builder: (context, snapshot) {
        switch(snapshot.connectionState) {
          case ConnectionState.done:
            return StreamBuilder(stream: _notesService.allNotes, 
            builder: (context, snapshot) {
              switch(snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.active:
                  if (snapshot.hasData) {
                        final allNotes = snapshot.data as List<DatabaseNote>;
                        return ListView.builder(
                          itemCount: allNotes.length,
                          itemBuilder: (context, index) {
                            final note = allNotes[index];
                            return ListTile(
                              title: Text(
                                note.text,
                                maxLines: 1,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          },
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                default:
                  return const CircularProgressIndicator();
              }
            },);
          default:
            return CircularProgressIndicator();
        }
      },)
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