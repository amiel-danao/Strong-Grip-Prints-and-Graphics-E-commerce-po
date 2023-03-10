import 'dart:async';

import 'package:strong_grip_prints_admin/update_product_page/update_product_page.dart';

import '../flutter_flow/flutter_flow_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../models/Product.dart';
import '../utils.dart';

class UpdateProductListPageWidget extends StatefulWidget {
  const UpdateProductListPageWidget({
    Key? key,
    this.artPiece,
  }) : super(key: key);

  final dynamic artPiece;

  @override
  _UpdateProductListState createState() => _UpdateProductListState();
}

class _UpdateProductListState extends State<UpdateProductListPageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  late FirebaseFirestore db;
  bool loading = false;

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
          'Update Product',
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
              return Padding(
                padding: EdgeInsets.all(10),
                child: ListTile(
                  leading: products[key]!.img_url == null
                      ? Image.asset('assets/images/logo.jpg')
                      : Image.network(
                          products[key]!.img_url ??
                              'https://docs.flutter.dev/assets/images/dash/dash-fainting.gif',
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                          return Text('no image');
                        }),
                  title: Text(products[key]!.name ?? "",
                      style: FlutterFlowTheme.of(context).bodyText2.override(
                            fontFamily: 'Playfair Display',
                            fontSize: 16,
                          )),
                  trailing: IconButton(
                    onPressed: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UpdateProductPageWidget(
                                docKey: key, product: products[key])),
                      )
                    },
                    icon: Icon(
                      Icons.edit,
                      color: Colors.blue,
                      size: 45,
                    ),
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
}
