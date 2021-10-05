import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Nome da banda',
      theme: ThemeData(primarySwatch: Colors.blue
      ),
      home: const MyHomePage(
          title: 'Possíveis nomes de banda'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}): super ();
  final String title;
  final documents = DocumentSnapshot;

  Widget _buildListItem (BuildContext context, DocumentSnapshot document){
    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: Text(
                document['nome'],
                style: Theme.of(context).textTheme.headline5
            ),
          ),
          Container(
            decoration: const BoxDecoration(
                color: Color(0xffddddff)
            ),
            padding: const EdgeInsets.all(10.0),
            child: Text(
              document['votos'].toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
          )
        ],
      ),
      onTap: (){
        Firestore.instance.runTransaction((transaction) async {
          DocumentSnapshot freshSnap =
              await transaction.get(document.reference);
          await transaction.update(freshSnap.reference, {
            'votos' : freshSnap['votos'] + 1,
          });
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('bandnames').snapshots(),
        builder: (context, snapshots) {
          if (!snapshots.hasData) return const Text('Loading...');
          return ListView.builder(
              itemExtent: 80.0,
              itemCount: snapshots.data!.documents.length,
              itemBuilder: (context, index) =>
                  _buildListItem(context, snapshots.data!.documents[index])
          );
        }
      ),
    );
  }
}
