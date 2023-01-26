import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../flutter_flow/flutter_flow_util.dart';
import '../home_page.dart';
import '../login_page/login_page_widget.dart';
import '../main.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';
import '../models/Product.dart';

class CreateProductPageWidget extends StatefulWidget {
  const CreateProductPageWidget({
    Key? key,
    this.artPiece,
  }) : super(key: key);

  final dynamic artPiece;

  @override
  _CreateProductState createState() => _CreateProductState();
}

class _CreateProductState extends State<CreateProductPageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController ratingController;
  late TextEditingController uniqueKeyController;
  // Initial Selected Value
  String itemTypeValue = 'Drinkware';

  List<String> itemTypes = <String>['Drinkware', 'Others'];

  late FirebaseFirestore db;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    db = FirebaseFirestore.instance;
    nameController = TextEditingController();
    descriptionController = TextEditingController();
    priceController = TextEditingController();
    ratingController = TextEditingController();
    uniqueKeyController = TextEditingController();
  }

  Future imgFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        // uploadFile();
      } else {
        print('No image selected.');
      }
    });
  }

  Future imgFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        // uploadFile();
      } else {
        print('No image selected.');
      }
    });
  }

  Future<String> uploadFile() async {
    if (_imageFile == null) return "";
    final fileName = basename(_imageFile!.path);
    final destination = '$fileName';

    try {
      final ref = firebase_storage.FirebaseStorage.instance.ref(destination);
      await ref.putFile(_imageFile!);
      var upload_path = await ref.getDownloadURL();
      return upload_path;
    } catch (e) {
      print('error occured');
    }

    return "";
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
          'Create new product',
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
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                    child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showPicker(context);
                          },
                          child: _imageFile == null
                              ? Image.asset(
                                  'assets/images/logo.jpg',
                                  width: double.infinity,
                                  height: 255,
                                  fit: BoxFit.fill,
                                )
                              : Image.file(_imageFile!),
                        ),
                        Padding(
                          padding:
                              EdgeInsetsDirectional.fromSTEB(15, 20, 15, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Name',
                                style: FlutterFlowTheme.of(context)
                                    .title1
                                    .override(
                                      fontFamily: 'Playfair Display',
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 16),
                                child: TextFormField(
                                  controller: nameController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Enter product name',
                                  ),
                                  validator: validateEmpty,
                                ),
                              ),
                              Text('Description',
                                  style: FlutterFlowTheme.of(context).title1),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 16),
                                child: TextFormField(
                                  controller: descriptionController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Enter product description',
                                  ),
                                  validator: validateEmpty,
                                ),
                              ),
                              Text('Type',
                                  style: FlutterFlowTheme.of(context).title1),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 16),
                                child: DropdownButton<String>(
                                  value: itemTypeValue,
                                  icon: const Icon(Icons.arrow_downward),
                                  elevation: 16,
                                  style: const TextStyle(color: Colors.black),
                                  underline: Container(
                                    height: 2,
                                    color: Colors.black,
                                  ),
                                  onChanged: (String? value) {
                                    // This is called when the user selects an item.
                                    setState(() {
                                      itemTypeValue = value!;
                                    });
                                  },
                                  items: itemTypes
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                              Text(
                                'Price',
                                style: FlutterFlowTheme.of(context).title1,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 16),
                                child: TextFormField(
                                  controller: priceController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Enter product price',
                                  ),
                                  validator: validateEmpty,
                                ),
                              ),
                              Text(
                                'Rating',
                                style: FlutterFlowTheme.of(context).title1,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 16),
                                child: TextFormField(
                                  controller: ratingController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder()),
                                  validator: validateEmpty,
                                ),
                              ),
                              Text(
                                'Unique Key',
                                style: FlutterFlowTheme.of(context).title1,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 16),
                                child: TextFormField(
                                  controller: uniqueKeyController,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'ex: DriWaBEERMUG1PC'),
                                  validator: validateEmpty,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
                Container(
                  width: double.infinity,
                  height: 84,
                  child: Align(
                    alignment: AlignmentDirectional(0, 0),
                    child: loading == false
                        ? FFButtonWidget(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  loading = true;
                                });
                                String img_url = await uploadFile();

                                final product = Product(
                                  name: nameController.text,
                                  description: descriptionController.text,
                                  type: itemTypeValue.toLowerCase(),
                                  img_url: img_url,
                                  price:
                                      double.tryParse(priceController.text) ??
                                          0,
                                  rating: ratingController.text,
                                );
                                String uniqueKey = uniqueKeyController.text
                                    .replaceAll(' ', '');

                                final docRef = db
                                    .collection(itemTypeValue)
                                    .withConverter(
                                      fromFirestore: Product.fromFirestore,
                                      toFirestore: (Product product, options) =>
                                          product.toFirestore(),
                                    )
                                    .doc(uniqueKey);

                                await docRef.set(product);
                                final docAllRef = db
                                    .collection("AllProducts")
                                    .withConverter(
                                      fromFirestore: Product.fromFirestore,
                                      toFirestore: (Product product, options) =>
                                          product.toFirestore(),
                                    )
                                    .doc(uniqueKey);

                                await docAllRef.set(product);

                                final docNavRef = db
                                    .collection("Nav$itemTypeValue")
                                    .withConverter(
                                      fromFirestore: Product.fromFirestore,
                                      toFirestore: (Product product, options) =>
                                          product.toFirestore(),
                                    )
                                    .doc(uniqueKey);

                                await docNavRef.set(product);

                                setState(() {
                                  loading = false;
                                });

                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomePageWidget(),
                                  ),
                                );
                              }
                            },
                            child: Text('Add new product'),
                          )
                        : null,
                  ),
                ),
              ],
            ),
            Center(child: loading ? CircularProgressIndicator() : null)
          ],
        ),
      ),
    );
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Gallery'),
                      onTap: () {
                        imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  String? validateEmpty(String? value) {
    if (value == null || value.trim().length == 0)
      return 'Field is required!';
    else
      return null;
  }
}
