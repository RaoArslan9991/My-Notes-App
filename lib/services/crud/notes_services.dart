import 'dart:async';

import 'package:first_app/services/crud/crud_exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart' ;


class NotesServices {
  Database? _db;

  List<DatabaseNote> _notes = [];

  static final NotesServices _shared = NotesServices._sharedServices();
  NotesServices._sharedServices();
  factory NotesServices()=> _shared; 

  final _notesStreamController = StreamController<List<DatabaseNote>>.broadcast();

  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;
  Future<DatabaseUser> createOrGetUser({required String email})async{
    try{
      final user = await getUser(email: email);
      return user;
    }on CouldNotFindUser{
      final createdUser = createUser(email);
      return createdUser;
    }catch(e){
      rethrow;
    }
  }

  Future<void> _cacheNote()async{
    final allnotes = await getAllNote();
    _notes = allnotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DatabaseNote> updateNote({required DatabaseNote note,required String text})async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);

    final updateCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudColumn:0,
    });
    if(updateCount == 0){
      throw CouldNotUpdateNote;
    }else{
      final updatedNote =  await getNote(id: note.id);
      _notes.removeWhere((note)=> note.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
    }
    
  }
  
  Future <Iterable<DatabaseNote>> getAllNote()async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);
    
    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }
  
  Future<DatabaseNote> getNote({required int id })async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable,where: 'id = ?',whereArgs: [id]);
    if(notes.isEmpty){
      throw CouldNotFindNote();
    }else{
      final note =  DatabaseNote.fromRow(notes.first);
      _notes.removeWhere((note)=> note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }
  
  Future<int> deleteAllNote()async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final noOfDeletions =  await db.delete(noteTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return noOfDeletions;
  }
  
  Future<void> deleteNote({required int id})async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(noteTable,where: 'id = ?',whereArgs: [id]);

    if(deletedCount == 0){
      throw CouldNotDeleteNote();
    }else{
      _notes.removeWhere((note)=> note.id == id);
      _notesStreamController.add(_notes);
    }
  }
  
  Future<DatabaseNote> createNote({required DatabaseUser owner})async{
    await _ensureDbIsOpen();
    // check if user exist or not 
    final db = _getDatabaseOrThrow();
    final dbUser =await getUser(email:owner.email);
    if(dbUser != owner){
      throw CouldNotFindUser();
    }

    const text = '';
    //create note 
    final noteId = await db.insert(
      noteTable,{ 
        userIdColumn:owner.id,
        textColumn:text,
        isSyncedWithCloudColumn:1
        }
      );
      final note =  DatabaseNote(
        id: noteId, 
        userId: owner.id, 
        text: text, 
        isSyncedWithCloud: true
      );

      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
      
  }
  
  Future<DatabaseUser> getUser({required String email})async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable, limit: 1,where: email = '?',whereArgs: [email.toLowerCase()]);
    if(results.isEmpty){
      throw CouldNotFindUser();
    }else{
      return DatabaseUser.fromRow(results.first);
    }
    }
  
  Future<DatabaseUser> createUser(String email)async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable, limit: 1,where: email = '?',whereArgs: [email.toLowerCase()]);
    if(results.isNotEmpty){
      throw UserAlreadyExists();
    }
    final id = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });
    final note =  DatabaseUser(id: id, email: email);
    
    return note;
  }
  
  Future<void> deleteUser({required String email})async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      userTable,where: email = '?',
      whereArgs: [email.toLowerCase()]
    );
    if(deleteCount != 1){
      throw CouldNotDeleteUser();
    }
  }
  
  Database _getDatabaseOrThrow(){
    final db = _db;
    if(db == null){
      throw DatabaseIsNotOpen();
    }
    else{
      return db;
    }
  }
  
  Future<void> close() async{
    final db = _db;
    if(db == null){
      throw DatabaseIsNotOpen();
    }
    else{
      await db.close();
      _db = null;
    }
  }
  
  Future<void> _ensureDbIsOpen() async{
    try{
      await open();
    }on DatabaseAlreadyOpenException{
      //empty
    }
  }

  Future<void> open() async{
    if(_db != null){
      throw DatabaseAlreadyOpenException();
    }

    try{
      final docPath =await getApplicationDocumentsDirectory();
      final dbPath = join(docPath.path,dbName);
      final db =await openDatabase(dbPath);
      _db = db;
      //create user table
      db.execute(createUserTable);
      //create note table 
      db.execute(createNoteTable);
      await _cacheNote();
    }on MissingPlatformDirectoryException{
      throw UnableToGetDocumentDirectory();
      }

    }

  
}

@immutable
class DatabaseUser {
    final int id;
    final String email;
    
    const DatabaseUser({required this.id, required this.email});

    DatabaseUser.fromRow(Map<String,Object?> map)
    :id = map[idColumn] as int,
    email = map[emailColumn] as String;

    @override String toString() => 'Person id is : $id and email is : $email';
    @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;
  
  @override
  int get hashCode => id.hashCode;
  
}

class DatabaseNote{
    final int id;
    final int userId;
    final String text;
    final bool isSyncedWithCloud;

    DatabaseNote({
        required this.id ,
        required this.userId,
        required this.text ,
        required this.isSyncedWithCloud
        });

    DatabaseNote.fromRow(Map<String,Object?>map)
        :   id = map[idColumn] as int,
            userId = map[userIdColumn] as int,
            text = map[textColumn] as String,
            isSyncedWithCloud = 
                (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;
    
    @override
  String toString() => 
    'Note, id = $id, user_id = $userId, is_synced_with_cloud = $isSyncedWithCloud ';

  
  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;
  
  @override
  int get hashCode => id.hashCode;
  
  
}

const dbName = 'testingdb.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud'; 
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
      "id"	INTEGER,
      "email"	TEXT NOT NULL UNIQUE,
      PRIMARY KEY("id" AUTOINCREMENT)
    );
    ''';
    const createNoteTable = ''' CREATE TABLE IF NOT EXISTS "note" (
      "id"	INTEGER NOT NULL,
      "user_id"	INTEGER NOT NULL,
      "text"	TEXT,
      "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY("id" AUTOINCREMENT),
      FOREIGN KEY("user_id") REFERENCES "user"("id")
    );
    ''';