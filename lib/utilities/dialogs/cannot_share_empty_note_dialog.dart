import 'package:first_app/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<void> cannotShareEmptyNoteDialog(BuildContext context){
  return showGenericDialog<void>(
    context: context, 
    title: 'Sharing', 
    content: 'You cannot share empty note', 
    optionsBuilder: ()=>{
      'OK' : null,
    }
    );
}