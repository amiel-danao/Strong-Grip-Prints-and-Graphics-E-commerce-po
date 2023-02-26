import 'dart:async';

import 'package:strong_grip_prints_admin/string_extension.dart';

import '../flutter_flow/flutter_flow_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../models/Product.dart';
import '../utils.dart';
import 'discount_product_page.dart';

class DiscountProductListPageWidget extends StatefulWidget {
  const DiscountProductListPageWidget({
    Key? key
  }) : super(key: key);

  @override
  _DiscountProductState createState() => _DiscountProductState();
}

class _DiscountProductState extends State<DiscountProductListPageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  late FirebaseFirestore db;
  bool loading = false;
  final Map<String, bool> productStates = Map();

  @override
  void initState() {
    super.initState();
    db = FirebaseFirestore.instance;
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
          'Product Discounts',
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
      body:
      StreamBuilder<QuerySnapshot<Product>>(
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
                  IconButton(
                    onPressed: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DiscountProductPageWidget(
                                docKey: key, product: products[key])),
                      )
                    },
                    icon: Icon(
                      Icons.discount,
                      color: Colors.blue,
                      size: 45,
                    ),
                  ),
                )
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
}
