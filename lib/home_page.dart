import 'package:strong_grip_prints_admin/update_product_list_page/update_product_list_page.dart';

import '../flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

import 'create_product/create_product.dart';
import 'delete_product_page/delete_product_page.dart';
import 'discount_page/discount_list_page.dart';
import 'inventory_page/inventory_page.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({Key? key}) : super(key: key);

  @override
  _HomePageWidgetState createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).secondaryColor,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Align(
              alignment: AlignmentDirectional(0, 0),
              child: Image.asset(
                'assets/images/banner.jpg',
                width: double.infinity,
                height: 255,
                fit: BoxFit.fill,
              ),
            ),
            Stack(
              children: [
                Align(
                  alignment: AlignmentDirectional(0, 0),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(20, 60, 20, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        GridView(
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 1,
                              ),
                          primary: false,
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          children: [
                            HomeCardButton('Add Product', () async =>{await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CreateProductPageWidget(),
                              ),
                            )},
                                Icons.add,
                                Color(0xFF6100FF)
                            ),
                            HomeCardButton('Disable Product', () async =>{await Navigator.push(
                            context,
                            MaterialPageRoute(
                            builder: (context) =>
                            DeleteProductPageWidget(),
                            ),
                            )},
                                Icons
                                .disabled_visible,
                                Color(0xFFFC0000)
                            ),
                            HomeCardButton('View Product', () async => {await Navigator.push(
                            context,
                            MaterialPageRoute(
                            builder: (context) =>
                            UpdateProductListPageWidget(),
                            ),
                            )}, Icons
                                .youtube_searched_for_sharp, Color(0xFFFF7A00)),
                            HomeCardButton('View Inventory', () async => {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      InventoryListPageWidget(),
                                ),
                              )
                            }, Icons.attach_money_outlined, Color(0xFF59FF00)),
                            HomeCardButton('Edit Discounts', () async => {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DiscountProductListPageWidget(),
                                ),
                              )
                            }, Icons.discount, Colors.blue)
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget HomeCardButton(String text, Function() callback, IconData? icon, Color color){
    return
      // Flexible(
      // flex: 1,
      // fit: FlexFit.tight,
      // child:
        InkWell(
        onTap: () async {
          callback();
        },
        child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Container(
                      width: 70,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.transparent,
                            width: 1),
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          icon,
                          color: Colors.white,
                          size: 45,
                        ),
                        onPressed: null,
                      ))),
              Align(
                alignment: AlignmentDirectional(0, 0),
                child: Padding(
                  padding:
                  EdgeInsetsDirectional.fromSTEB(
                      5, 0, 5, 0),
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context)
                        .title1,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    // );
  }
}
