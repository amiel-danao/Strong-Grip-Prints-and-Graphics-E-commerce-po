import 'dart:async';

import 'package:strong_grip_prints_admin/string_extension.dart';

import '../flutter_flow/flutter_flow_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../models/Product.dart';
import '../utils.dart';

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
  final Map<String, bool> productStates = Map();

  @override
  void initState() {
    super.initState();
    db = FirebaseFirestore.instance;
    _events = StreamController<bool>.broadcast();
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
          'Disable Product',
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
            return ProgressDialogPrimary();

          Map<String, Product> products = Map.fromIterable(snapshot.data!.docs,
              key: (item) => item.id, value: (item) => item.data());

          // List<Product> products =
          //     snapshot.data!.docs.map((e) => e.id  e.data()).toList();

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              String key = products.keys.elementAt(index);
              // setState(() {
              //   productStates[key] = products[key]!.status;
              // });

              return Padding(
                  padding: EdgeInsets.all(10),
                  child: ListTile(
                    leading: products[key]!.img_url == null
                        ? Image.asset('assets/images/logo.jpg')
                        : Image.network(
                            products[key]!.img_url ??
                                'https://docs.flutter.dev/assets/images/dash/dash-fainting.gif',
                            errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                            return Text('no image');
                          }),
                    title: Text(products[key]!.name ?? "",
                        style: FlutterFlowTheme.of(context).bodyText2.override(
                              fontFamily: 'Playfair Display',
                              fontSize: 16,
                            )),
                    trailing:
                    Switch(
                      // thumb color (round icon)
                      activeColor: Colors.amber,
                      activeTrackColor: Colors.cyan,
                      inactiveThumbColor: Colors.blueGrey.shade600,
                      inactiveTrackColor: Colors.grey.shade400,
                      splashRadius: 50.0,
                      // boolean variable value
                      value: products[key]!.active??true,
                      // changes the state of the switch
                      onChanged: (value) async {
                        var saved = await changeProductActiveStatus(key: key, product: products[key]!, active: value);
                        if (saved) {
                          setState(() {
                            productStates[key] = value;
                          });
                        }
                      }),
                    ),

                    // IconButton(
                    //   onPressed: () => {
                    //     showDialog(
                    //       context: context,
                    //       builder: (BuildContext context) {
                    //         return showAlertDialog(
                    //             context, key, products[key]!);
                    //       },
                    //     )
                    //   },
                    //   icon: Icon(
                    //     Icons.delete,
                    //     color: Colors.red,
                    //     size: 45,
                    //   ),
                    // ),

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

  Future<bool> changeProductActiveStatus(
      {required String key, required Product product, required bool active}) async {
    final data = {"active": active};
    await db.collection("AllProducts").doc(key).set(data, SetOptions(merge: true)).then(
          (doc) => print("Document deleted"),
          onError: (e) {
            print("Error updating document $e");
            return false;
          }
        );

    var typeCapitalized = product.type!.toCapitalized();
    var typeNavCollectionKey = "Nav$typeCapitalized";

    await db.collection(typeNavCollectionKey).doc(key).set(data, SetOptions(merge: true)).then(
          (doc) => print("Document deleted"),
          onError: (e) => print("Error updating document $e"),
        );

    await db.collection(typeCapitalized).doc(key).set(data, SetOptions(merge: true)).then(
          (doc) => print("Document deleted"),
          onError: (e) => print("Error updating document $e"),
        );

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

        var saved = await changeProductActiveStatus(key: key, product: product, active: true);
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

        // db.collection("AllProducts").doc(key).delete().then(
        //       (doc) => print("Document deleted"),
        //       onError: (e) => print("Error updating document $e"),
        //     );
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
}
