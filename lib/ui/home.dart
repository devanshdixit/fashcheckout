import 'dart:convert';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fastcheckout/api/authentication.dart';
import 'package:fastcheckout/api/firestore_api.dart';
import 'package:fastcheckout/api/pdf_api.dart';
import 'package:fastcheckout/api/pdf_invoice_api.dart';
import 'package:fastcheckout/model/customer.dart';
import 'package:fastcheckout/model/invoice.dart';
import 'package:fastcheckout/model/supplier.dart';
import 'package:fastcheckout/shared/constants.dart';
import 'package:fastcheckout/ui/add_order.dart';
import 'package:fastcheckout/ui/add_product.dart';
import 'package:fastcheckout/ui/order_details.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class ProductCard {
  final String name;
  final String price;
  ProductCard({required this.name, required this.price});
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final db = FirestoreApi();
  ScanResult scanResult = ScanResult();
  bool loading = false;
  bool showResult = false;
  TextEditingController textEditingController = TextEditingController();
  List<InvoiceItem> invoiceList = [];
  List<ProductCard> items = [];
  List orderList = [];
  List<DocumentSnapshot> documentList = [];

  @override
  void initState() {
    super.initState();
  }

  void settingModalBottomSheet(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Column(
          children: [
            ListView(
              shrinkWrap: true,
              children: [
                Row(
                  children: [
                    Container(
                      width: screenWidth(context) / 1.3,
                      child: CupertinoSearchTextField(
                        onSuffixTap: () {},
                        onChanged: (val) async {
                          print(val);
                          final data = await FirebaseFirestore.instance
                              .collection("products")
                              .where("caseSearch", arrayContains: val)
                              .get();
                          print(data.docs);
                          setState(() {
                            documentList = data.docs;
                            showResult = true;
                          });
                        },
                        controller: textEditingController,
                      ),
                    ),
                    IconButton(onPressed: scan, icon: Icon(Icons.camera))
                  ],
                ),
                verticalSpaceSmall,
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: documentList.length,
                  itemBuilder: (context, index) {
                    final search = documentList[index].data();
                    final s = json.encode(search);
                    Map<String, dynamic> pd = jsonDecode(s);
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Card(
                        elevation: 5,
                        child: ListTile(
                          onTap: () {
                            setState(() {
                              items.add(
                                ProductCard(
                                    name: pd['name'], price: pd['price']),
                              );
                            });
                            FocusScope.of(context).requestFocus(FocusNode());
                            setState(() {
                              showResult = false;
                            });
                          },
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                pd['name'],
                                style: TextStyle(
                                  fontSize: 22,
                                ),
                              ),
                              Text(
                                'Rs ${pd['price']}',
                                style: TextStyle(
                                  fontSize: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                items.length != 0
                    ? Container(
                        height: 200,
                        child: Stack(
                          children: [
                            ListView.builder(
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                invoiceList.add(InvoiceItem(
                                  description: '',
                                  date: DateTime.now(),
                                  quantity: 1,
                                  vat: 0.19,
                                  unitPrice: double.parse(items[index].price),
                                ));
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Card(
                                    elevation: 5,
                                    child: ListTile(
                                      onLongPress: () {
                                        setState(() {
                                          items.remove(items[index]);
                                        });
                                        final snackBar = SnackBar(
                                          content: Text(
                                              'Product removed from cart!'),
                                          action: SnackBarAction(
                                            label: 'Undo',
                                            onPressed: () {},
                                          ),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBar);
                                      },
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            items[index].name,
                                            style: TextStyle(
                                              fontSize: 22,
                                            ),
                                          ),
                                          Text(
                                            'Rs. ${items[index].price.toString()}',
                                            style: TextStyle(
                                              fontSize: 22,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      )
                    : SizedBox(),
                verticalSpaceSmall,
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      orderList.add(Orders(order: items));
                      items.clear();
                    });
                    textEditingController.clear();
                    Navigator.of(context).pop();
                  },
                  child: Text('data'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var orders = Provider.of<List<Orders>>(context);
    if (orders.length != 0) {
      setState(() {
        orderList = orders[0].order;
      });
    }
    var scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Assets.appbg,
        elevation: 5.0,
        leading: IconButton(
          icon: Icon(
            Icons.format_align_left_rounded,
          ),
          onPressed: () {
            scaffoldKey.currentState!.openDrawer();
          },
        ),
        title: Container(
          height: 40,
          child: Image.asset(
            'assets/images/fastcheckout.png',
          ),
        ),
        centerTitle: true,
      ),
      drawer: SafeArea(
        child: Container(
          width: screenWidth(context) / 1.8,
          child: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: CustomColors.firebaseNavy,
                  ),
                  child: Image.asset(
                    'assets/images/fastcheckout.png',
                    height: 160,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                        color: CustomColors.firebaseNavy,
                        border: Border.all(color: Colors.grey, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: ListTile(
                      title: Center(
                        child: Text('Sign Out',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            )),
                      ),
                      onTap: () {
                        Authentication().signOut(context: context);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: CustomColors.firebaseNavy,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddOrder(
                data: orderList,
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            )
          : orderList.length == 0
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Image.asset(
                      'assets/NotAvailable@2x.png',
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  itemCount: orderList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Card(
                        elevation: 5,
                        child: ListTile(
                          onLongPress: () async {
                            final snackBar = SnackBar(
                              content: Text('Product removed from cart!'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () {},
                              ),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          },
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => OrderDetails(
                                  inDex: index,
                                  orderData: orderList[index]['items'],
                                ),
                              ),
                            );
                          },
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                'Order $index',
                                style: TextStyle(
                                  fontSize: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Future scan() async {
    try {
      var result = await BarcodeScanner.scan();
      setState(() {
        scanResult = result;
        loading = true;
      });
      print(scanResult.rawContent);
      final data = await FirestoreApi().getProduct(scanResult.rawContent);
      if (data != null) {
        setState(() {
          loading = false;
          items.add(
            ProductCard(
              name: data['name'],
              price: data['price'],
            ),
          );
        });
      } else {
        setState(() {
          loading = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddProductForm(
              cameracode: scanResult.rawContent,
              afterData: (AddProduct data) {
                setState(() {
                  items.add(
                    ProductCard(
                      name: data.name,
                      price: data.price,
                    ),
                  );
                });
              },
            ),
          ),
        );
      }
    } on PlatformException catch (e) {
      var result = ScanResult(
        type: ResultType.Error,
        format: BarcodeFormat.unknown,
      );

      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          print('The user did not grant the camera permission!');
        });
      } else {
        print('Unknown error: $e');
      }
      setState(() {
        scanResult = result;
      });
    }
  }
}
