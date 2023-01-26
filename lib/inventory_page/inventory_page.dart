import 'dart:async';

import 'package:strong_grip_prints_admin/string_extension.dart';
import 'package:strong_grip_prints_admin/update_product_page/update_product_page.dart';

import '../flutter_flow/flutter_flow_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../models/Product.dart';

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
                  trailing: TextFormField(
                    onChanged: (value) => {},
                    keyboardType: TextInputType.number,
                  ));
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
