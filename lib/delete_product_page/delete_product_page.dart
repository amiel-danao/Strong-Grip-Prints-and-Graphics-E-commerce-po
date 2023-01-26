import 'dart:async';

import 'package:strong_grip_prints_admin/string_extension.dart';

import '../flutter_flow/flutter_flow_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../models/Product.dart';

class DeleteProductPageWidget extends StatefulWidget {
  const DeleteProductPageWidget({
    Key? key,
    this.artPiece,
  }) : super(key: key);

  final dynamic artPiece;

  @override
  _DeleteProductState createState() => _DeleteProductState();
}

class _DeleteProductState extends State<DeleteProductPageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  late FirebaseFirestore db;
  bool loading = false;
  late StreamController<bool> _events;

  @override
  void initState() {
    super.initState();
    db = FirebaseFirestore.instance;
    _events = StreamController<bool>.broadcast();
    //new StreamController<bool>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        leading: InkWell(
          onTap: () async {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 24,
          ),
        ),
        title: Text(
          'Delete Product',
          style: FlutterFlowTheme.of(context).bodyText2.override(
                fontFamily: 'Playfair Display',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [],
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot<Product>>(
        stream: recipeData,
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Product>> snapshot) {
          if (snapshot.hasError) return Text('Something went wrong');
          if (snapshot.connectionState == ConnectionState.waiting)
            return CircularProgressIndicator();

          Map<String, Product> products = Map.fromIterable(snapshot.data!.docs,
              key: (item) => item.id, value: (item) => item.data());

          // List<Product> products =
          //     snapshot.data!.docs.map((e) => e.id  e.data()).toList();

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              String key = products.keys.elementAt(index);
              return ListTile(
                leading: products[key]!.img_url == null
                    ? Image.asset('assets/images/logo.jpg')
                    : Image.network(
                        products[key]!.img_url ??
                            'https://docs.flutter.dev/assets/images/dash/dash-fainting.gif',
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                        return Text('no image');
                      }),
                title: Text(products[key]!.name ?? ""),
                trailing: IconButton(
                  onPressed: () => {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return showAlertDialog(context, key, products[key]!);
                      },
                    )
                  },
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: 45,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot<Product>> get recipeData {
    return db
        .collection("AllProducts")
        .withConverter<Product>(
          fromFirestore: Product.fromFirestore,
          toFirestore: (data, _) => data.toFirestore(),
        )
        .snapshots();
  }

  Future<bool> deleteProduct(
      {required String key, required Product product}) async {
    await db.collection("AllProducts").doc(key).delete().then(
          (doc) => print("Document deleted"),
          onError: (e) => print("Error updating document $e"),
        );

    var typeCapitalized = product.type!.toCapitalized();
    var typeNavCollectionKey = "Nav$typeCapitalized";

    await db.collection(typeNavCollectionKey).doc(key).delete().then(
          (doc) => print("Document deleted"),
          onError: (e) => print("Error updating document $e"),
        );

    await db.collection(typeCapitalized).doc(key).delete().then(
          (doc) => print("Document deleted"),
          onError: (e) => print("Error updating document $e"),
        );

    String fileName = getFileName(product.img_url);
    print("filename is : $fileName");
    if (fileName.length > 0) {
      final productRef =
          firebase_storage.FirebaseStorage.instance.ref(fileName);

      // Delete the file
      await productRef.delete().then((value) => print("Firebase Image deleted"),
          onError: (e) => print("Error updating document $e"));
    }

    return true;
  }

  AlertDialog showAlertDialog(
      BuildContext context, String key, Product product) {
    Widget cancelButton = TextButton(
        child: Text("Cancel"),
        onPressed: () {
          Navigator.pop(context, false);
          _events.close();
        }
        //Navigator.of(context, rootNavigator: true).pop('dialog'),
        );
    Widget continueButton = TextButton(
      child: Text("Yes"),
      onPressed: () async {
        _events.add(true);

        var saved = await deleteProduct(key: key, product: product);
        if (saved) {
          // Navigator.pop(context, false);
          Navigator.of(context, rootNavigator: true).pop('dialog');
          // await Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => DeleteProductPageWidget(),
          //   ),
          // );
          // Navigator.pop(context, false);

        } else {
          _events.add(false);
        }

        db.collection("AllProducts").doc(key).delete().then(
              (doc) => print("Document deleted"),
              onError: (e) => print("Error updating document $e"),
            );
      },
    );

    return AlertDialog(
      title: Text("Delete product"),
      //desc: 'Reason',
      content: StreamBuilder<bool>(
          initialData: false,
          stream: _events.stream,
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            print(" ${snapshot.data.toString()}");
            return snapshot.data!
                ? SizedBox(
                    child: Center(child: CircularProgressIndicator()),
                    height: 50.0,
                    width: 50.0,
                  )
                : Text(
                    "Are you sure you want to delete this product?\n ${product.name}");
          }),
      actions: [cancelButton, continueButton],
    );
  }

  String getFileName(String? url) {
    if (url == null || url.trim().length == 0) return "";
    RegExp regExp = new RegExp(r'.+(\/|%2F)(.+)\?.+');
    //This Regex won't work if you remove ?alt...token
    var matches = regExp.allMatches(url);

    var match = matches.elementAt(0);
    print("${Uri.decodeFull(match.group(2)!)}");
    return Uri.decodeFull(match.group(2)!);
  }
}
