import 'dart:io';
import 'dart:developer';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite_example/models/note_model.dart';
import 'package:flutter/material.dart';

class NoteDataState extends ChangeNotifier {
  Client appwriteClient;
  Database database;
  Account account;
  String _userId;

  // @TODO Get this values from a local configuration or from the system environment
  String _projectId = '6179b11f507a2';
  String _noteCollectionId = '6179b1ae528cd';

  List<dynamic> _noteList = [];

  List<String> _write;

  List<String> _read;

  List<dynamic> get totalNoteList => _noteList;

  init() {
    var apiUrl = 'http://localhost/v1';

    //10.0.2.2 is Android emulator's proxy to access Appwrite server on localhost
    if (Platform.isAndroid) {
      apiUrl = 'http://10.0.2.2/v1';
    }

    appwriteClient = Client(selfSigned: true);
    appwriteClient
        .setEndpoint(apiUrl)
        .setProject(_projectId);
    database = Database(appwriteClient);
    account = Account(appwriteClient);
  }

  login({String username, String password}) {
    Future result = account.createSession(
      email: '${username}',
      password: '${password}',
    );

    result.then((response) {
      _userId = response.userId;

      _read = [
        'user:$_userId'
      ];

      _write = [
        'user:$_userId'
      ];

      getNoteData();
    }).catchError((error) {
      log(error.toString());
    });
  }

  logout({String username, String password}) {
    var session;
    account.getSessions().then((value) => {session = value});
    Future result = account.deleteSession(
      sessionId: session,
    );

    result.then((response) {
      _userId = null;
      print(response);
    }).catchError((error) {
      print(error);
    });
  }

  getUserId() {
    return _userId;
  }

  getUserInfo() {
    Future result = account.get();
    result.then((response) {
      log(response.toString());
      getNoteData();
      notifyListeners();
    }).catchError((error) {
      log(error.toString());
    });
  }

  addNoteData({NoteModel noteModel, String userId}) {
    appwriteClient.setProject(_projectId);
    Future result = database.createDocument(
      collectionId: '$_noteCollectionId',
      data: noteModel.toJson(),
      read: _read,
      write: _write,
    );

    result.then((response) {
      log('Create document: ' + response.toString());
      getNoteData(); //// Refresh document list
    }).catchError((error) {
      log('Create document: ' + error.toString());
    });
  }

  getNoteData() {
    appwriteClient.setProject(_projectId);
    Future result = database.listDocuments(
      orderField: 'timestamp',
      orderType: 'DESC',
      collectionId: _noteCollectionId,
    );

    result.then((response) {
      var documents = response.toMap()["documents"];
      _noteList = documents
          .map((note) => NoteModel.fromMap(note["data"]))
          .toList();
      notifyListeners();
    }).catchError((error) {
      log('Get getNoteData: ' + error.toString());
    });
  }

  List<NoteModel> getNoteList() {
    log('Get getNoteList:' + _noteList.toString());
    return _noteList;
  }

  updateNoteData({NoteModel noteModel, String userId}) {
    log(noteModel.toJson().toString());
    appwriteClient.setProject(_projectId);
    Future result = database.updateDocument(
      documentId: noteModel.id,
      collectionId: '$_noteCollectionId',
      data: noteModel.toJson(),
      read: _read,
      write: _write,
    );

    result.then((response) {
      log('Update document: ' + response.toString());
      getNoteData();
    }).catchError((error) {
      log('Update document: ' + error.toString());
    });
  }

  deleteNoteData({NoteModel noteModel}) {
    appwriteClient.setProject(_projectId);
    Future result = database.deleteDocument(
      documentId: noteModel.id,
      collectionId: '$_noteCollectionId',
    );

    result.then((response) {
      log('Delete document: ' + response.toString());
      getNoteData();
    }).catchError((error) {
      log('Delete document: ' + error.toString());
    });
  }
}
