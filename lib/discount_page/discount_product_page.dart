import '../flutter_flow/flutter_flow_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../models/Discount.dart';
import '../models/Product.dart';
import '../utils.dart';

class DiscountProductPageWidget extends StatefulWidget {
  final Product? product;
  final String docKey;
  const DiscountProductPageWidget({
    Key? key,
    required this.docKey,
    required this.product,
  }) : super(key: key);

  @override
  _UpdateProductState createState() => _UpdateProductState();
}

class _UpdateProductState extends State<DiscountProductPageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  final _formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> minControllers = {};
  final Map<String, TextEditingController> maxControllers = {};
  final Map<String, TextEditingController> percentControllers = {};

  List<String> itemTypes = <String>['Drinkware', 'Others'];

  late FirebaseFirestore db;
  bool loading = false;
  String imgUrl = "";

  Map<String, Discount> discounts = Map();
  Map<String, Discount> newDiscounts = Map();

  var discountList;

  // late Future<QuerySnapshot<Discount>> discountList;

  @override
  void initState() {
    super.initState();
    if (widget.product == null) {
      Navigator.pop(this.context);
    }

    db = FirebaseFirestore.instance;
    if (widget.product!.img_url != null) {
      setState(() {
        imgUrl = widget.product!.img_url!;
      });
    }

    discountList = fetchDiscounts;
  }

  Stream<QuerySnapshot<Discount>> get fetchDiscounts {
    var stream = db
        .collection("Discounts")
        .where("id", isEqualTo: widget.docKey)
        .withConverter<Discount>(
      fromFirestore: Discount.fromFirestore,
      toFirestore: (data, _) => data.toFirestore(),
    ).snapshots();

    stream.forEach((element) {
      element.docs.forEach((e) {

        setState(() {
          minControllers[e.id] = TextEditingController(text:e.data().minQuantity.toString());
          maxControllers[e.id] = TextEditingController(text:e.data().maxQuantity.toString());
          percentControllers[e.id] = TextEditingController(text:e.data().percent.toString());
        });
      });
    });

    return stream;
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
          'Update discounts',
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
                    child:
                    Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child:
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [

                            Padding(
                              padding:
                              EdgeInsetsDirectional.fromSTEB(15, 20, 15, 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.product!.name??"Unnamed product",
                                    style: FlutterFlowTheme.of(context)
                                        .title1
                                        .override(
                                      fontFamily: 'Playfair Display',
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                    onPressed: () async {
                                      // final newDiscountRef = db.collection("Discounts").doc();
                                      var discount = Discount(id:widget.docKey, minQuantity: 0, maxQuantity: 0, percent: 0);
                                      await db.collection("Discounts").add(discount.toFirestore());
                                    },
                                    child: const Text('add new discount'),
                                  ),

                                  StreamBuilder<QuerySnapshot<Discount>>(
                                  stream: discountList,
                                  builder: (BuildContext context,
                                      AsyncSnapshot<QuerySnapshot<Discount>> snapshot) {
                                    if (snapshot.hasError) return Text('Something went wrong');
                                    if (snapshot.connectionState == ConnectionState.waiting)
                                      return ProgressDialogPrimary();

                                    discounts = Map.fromIterable(snapshot.data!.docs,
                                        key: (item) => item.id, value: (item) => item.data());


                                    return

                                      ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: discounts.length,
                                      itemBuilder: (context, index) {
                                        String key = discounts.keys.elementAt(index);
                                        return DiscountWidget(context, key, discounts[key]!);
                                      },
                                    );
                                  },
                                ),

                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
            Center(child: loading ? CircularProgressIndicator() : null)
          ],
        ),
      ),
    );
  }

  String? validateEmpty(String? value) {
    if (value == null || value.trim().length == 0)
      return 'Field is required!';
    else
      return null;
  }

  Widget DiscountWidget(BuildContext context, String key, Discount discount){
    return
      Container(
        child:
        Padding(
        padding:
        EdgeInsetsDirectional.all(15),
    child:
    Column(
      children:[
      Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
                flex: 1,
                child:
                Text(
                  'Min qty',
                  style: FlutterFlowTheme.of(context)
                      .title1
                      .override(
                    fontFamily: 'Playfair Display',
                    fontSize: 14,
                  ),
                )),
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: minControllers[key],
                // initialValue: discount.minQuantity.toString(),
                // onChanged: (value)=>{
                //   setState((){
                //     var modified = Discount(id: discount.id, minQuantity: int.parse(value), maxQuantity: discount.maxQuantity, percent: discount.percent);
                //     discounts[key] = modified;
                //   })
                // },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'min quantity',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [LimitRangeTextInputFormatter(1, 1000)],
                validator: validateEmpty,
              ),
            ),
            Expanded(
                flex: 1,
                child:Text('Max qty',
                    style: FlutterFlowTheme.of(context)
                        .title1
                        .override(
                        fontFamily: 'Playfair Display',
                        fontSize: 14
                    ))),
            Expanded(
              flex: 1,
              child: TextFormField(
                  controller: maxControllers[key],
                // initialValue: discount.maxQuantity.toString(),
                //   onChanged: (value)=>{
                //     setState((){
                //       var modified = Discount(id: discount.id, minQuantity: discount.minQuantity, maxQuantity: int.parse(value), percent: discount.percent);
                //       discounts[key] = modified;
                //     })
                //   },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'max quantity',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [LimitRangeTextInputFormatter(1, 1000)],
                  validator: validateEmpty
              ),
            )
          ]
      ),

         Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              flex: 1,
              child:Text(
                'percent discount',
                style: FlutterFlowTheme.of(context)
                    .title1
                    .override(
                  fontFamily: 'Playfair Display',
                  fontSize: 14,
                ),
              )),
          Expanded(
              flex: 1,
              child:TextFormField(
                controller: percentControllers[key],
                // initialValue: discount.percent.toString(),
                // onChanged: (value)=>{
                //   setState((){
                //     var modified = Discount(id: discount.id, minQuantity: discount.minQuantity, maxQuantity: discount.maxQuantity, percent: double.parse(value));
                //     discounts[key] = modified;
                //   })
                // },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '%',
                ),
                inputFormatters: [LimitRangeTextInputFormatter(1, 100)],
                validator: validateEmpty,
              )
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () async {
              final modifiedDiscountRef = db.collection("Discounts").doc(key);
              var modified = Discount(id: discount.id, minQuantity: int.parse(minControllers[key]!.value.text.toString()),
                  maxQuantity: int.parse(maxControllers[key]!.value.text.toString()), percent: double.parse(percentControllers[key]!.value.text.toString()));
              // setState(() {
              //   discounts[key] = modified;
              // });
              await modifiedDiscountRef.set(modified.toFirestore(), SetOptions(merge: true));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Discount saved!')));
            },
            icon: Icon(Icons.check),
            label: const Text('save'),
          ),

          ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
          await db.collection("Discounts").doc(key).delete();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('Discount deleted!')));
          }, icon: Icon(Icons.delete), label: const Text(''))


        ],)
      ])));
  }
}

