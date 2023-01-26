import 'dart:async';

import 'package:strong_grip_prints_admin/models/Quantity.dart';
import 'package:strong_grip_prints_admin/string_extension.dart';
import 'package:strong_grip_prints_admin/update_product_page/update_product_page.dart';

import '../flutter_flow/flutter_flow_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../models/Product.dart';
import '../utils.dart';

class InventoryListPageWidget extends StatefulWidget {
  const InventoryListPageWidget({
    Key? key,
    this.artPiece,
  }) : super(key: key);

  final dynamic artPiece;

  @override
  _InventoryListState createState() => _InventoryListState();
}

class _InventoryListState extends State<InventoryListPageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  late FirebaseFirestore db;
  bool loading = false;
  Map<String, Quantity> quantities = Map<String, Quantity>();

  @override
  void initState() {
    super.initState();
    db = FirebaseFirestore.instance;
    getQuantities();
  }

  void getQuantities() async {
    var snaps = await db
        .collection("Quantities")
        .withConverter<Quantity>(
          fromFirestore: Quantity.fromFirestore,
          toFirestore: (data, _) => data.toFirestore(),
        )
        .get();
    setState(() {
      // .snapshots();

      quantities = Map.fromIterable(snaps.docs,
          key: (item) => item.id, value: (item) => item.data());
    });
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
          'Inventory List',
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

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              String key = products.keys.elementAt(index);
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
                          style:
                              FlutterFlowTheme.of(context).bodyText2.override(
                                    fontFamily: 'Playfair Display',
                                    fontSize: 16,
                                  )),
                      trailing: TextButton(
                          onPressed: () =>
                              _displayDialog(context, key, products[key]!),
                          child: Text(quantities[key] == null
                              ? '0'
                              : quantities[key]!
                                  .quantity!
                                  .toInt()
                                  .toString()))));
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

  void _displayDialog(
    BuildContext context,
    String key,
    Product product,
  ) async {
    String currentQuantity = quantities[key] == null
        ? '0'
        : quantities[key]!.quantity!.toInt().toString();
    TextEditingController _textFieldController =
        TextEditingController(text: currentQuantity);
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Update Quantity for ${product.name}'),
            content: TextField(
              keyboardType: TextInputType.number,
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Enter Quantity"),
            ),
            actions: [
              TextButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context, false);
                  }
                  //Navigator.of(context, rootNavigator: true).pop('dialog'),
                  ),
              new TextButton(
                child: new Text('Save'),
                onPressed: () async {
                  var quantity = Quantity(
                      quantity: int.tryParse(_textFieldController.text));

                  final docNavRef = db
                      .collection("Quantities")
                      .withConverter(
                        fromFirestore: Quantity.fromFirestore,
                        toFirestore: (Quantity quantity, options) =>
                            quantity.toFirestore(),
                      )
                      .doc(key);

                  await docNavRef.set(quantity);
                  Navigator.pop(context, false);
                },
              )
            ],
          );
        });
  }
}
