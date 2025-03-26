import 'package:first_app/services/auth/auth_services.dart';
import 'package:first_app/services/crud/notes_services.dart';
import 'package:flutter/material.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
  DatabaseNote? _note;
  late final NotesService _notesServices;
  late final TextEditingController _textController;
  
  @override 
  void initState(){
    _notesServices = NotesService();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListner() async{
    final note = _note;
    if(note == null){
      return;
    }
    final text = _textController.text;
    await _notesServices.updateNote(note: note, text: text);
  }

  void _setupTextControllerListner(){
    _textController.removeListener(_textControllerListner);
    _textController.addListener(_textControllerListner);
  }
  Future<DatabaseNote> createNewNote() async{
    final existingNote = _note;
    if(existingNote != null){
      return existingNote;
    }
    final currentUser = AuthServices.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesServices.getUser(email: email);
    return await _notesServices.createNote(owner: owner);
  }

  void _deleteNoteIfTextIsEmpty(){
    final note = _note;
    if(_textController.text.isEmpty && note != null){
      _notesServices.deleteNote(id: note.id);
    }
  }

  void _saveNoteIfTextNoEmpty(){
    final note = _note;
    final text = _textController.text;
    if(note != null && text.isNotEmpty){
      _notesServices.updateNote(note: note, text: text);
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNoEmpty();
    _textController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
      ),
      body: FutureBuilder(
        future: createNewNote(),
        builder: (context, snapshot) {
          if(snapshot.hasError){
            return Text('snapshot Errro ${snapshot.error}');
          }
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _note = snapshot.data as DatabaseNote;
              if(_note == null){
                return Text('Could not create note');
              }
              _setupTextControllerListner();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Start typing your note...',
                ),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),

    );
  }
}