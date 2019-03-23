import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Tes Firestore'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String id;
  final db = Firestore.instance;
  final _formKey = GlobalKey<FormState>();
  String user;

  void createData(BuildContext context) async {
    final CollectionReference colCRUD = Firestore.instance.collection('CRUD');
    if (_formKey.currentState.validate()==true) {
      _formKey.currentState.save();
       QuerySnapshot _query = await colCRUD
      .where('user', isEqualTo: '$user')
      .getDocuments();
        if (_query.documents.length > 0) {
          Fluttertoast.showToast(
              msg: "User sudah ada, silahkan ganti yang lain",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIos: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0
          );
       }else{
          DocumentReference ref = await db.collection('CRUD').add({'user': '$user'});
          setState(() => id = ref.documentID);
          print(ref.documentID);
          Fluttertoast.showToast(
              msg: "User berhasil disimpan",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIos: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0
          );
          Navigator.of(context).pop();
       }

    }
  }

  void readData() async {
    DocumentSnapshot snapshot = await db.collection('CRUD').document(id).get();
    print(snapshot.data['user']);
  }

  void updateData(DocumentSnapshot doc) async {
    if (_formKey.currentState.validate()==true) {
      _formKey.currentState.save();
      await db.collection('CRUD').document(doc.documentID).updateData(
          {'user': '$user'});
      Fluttertoast.showToast(
          msg: "User berhasil diupdate",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      Navigator.of(context).pop();
    }
  }

  void deleteData(DocumentSnapshot doc) async {
    await db.collection('CRUD').document(doc.documentID).delete();
    setState(() => id = null);
  }

  Card buildItem(DocumentSnapshot doc) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'user: ${doc.data['user']}',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  onPressed: () => _showDialogUpdate(context,doc),
                  child: Text('Update'),
                ),
                SizedBox(width: 8),
                FlatButton(
                  onPressed: () => deleteData(doc),
                  child: Text('Delete'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: db.collection('CRUD').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(children: snapshot.data.documents.map((doc) => buildItem(doc)).toList());
                } else {
                  return SizedBox();
                }
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:()=> _showDialogUser(context),
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  _showDialogUser(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Masukkan UserName"),
          content: Form(
              key: _formKey,
              child: TextFormField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'user',
                  fillColor: Colors.grey[300],
                  filled: true,
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                },
                onSaved: (value) => user = value,
              )
          ),
          actions: <Widget>[
            FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: new Text("Simpan"),
              onPressed: () {
                createData(context);
              },
            ),
          ],
        );
      },
    );
  }

  _showDialogUpdate(BuildContext context,DocumentSnapshot doc) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Masukkan UserName"),
          content: Form(
              key: _formKey,
              child: TextFormField(
                initialValue: doc.data['user'],
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'user',
                  fillColor: Colors.grey[300],
                  filled: true,
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                },
                onSaved: (value) => user = value,
              )
          ),
          actions: <Widget>[
            FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: new Text("Simpan"),
              onPressed: () {
                updateData(doc);
              },
            ),
          ],
        );
      },
    );
  }

}
