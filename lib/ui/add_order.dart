import 'dart:math';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fastcheckout/api/authentication.dart';
import 'package:fastcheckout/shared/constants.dart';
import 'package:fastcheckout/ui/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:fastcheckout/api/firestore_api.dart';
import 'package:fastcheckout/model/invoice.dart';
import 'package:fastcheckout/ui/add_product.dart';

class AddOrder extends StatefulWidget {
  List data;
  AddOrder({Key? key, required this.data}) : super(key: key);

  @override
  _AddOrderState createState() => _AddOrderState();
}

class _AddOrderState extends State<AddOrder> {
  TextEditingController textEditingController = TextEditingController();
  List<DocumentSnapshot> documentList = [];
  ScanResult scanResult = ScanResult();
  bool loading = false;
  bool showResult = false;
  List<InvoiceItem> invoiceList = [];
  List items = [];
  List orderList = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Assets.appbg,
        elevation: 5.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.of(context).pop();
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
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
                          showResult = true;
                          documentList = data.docs;
                        });
                      },
                      controller: textEditingController,
                    ),
                  ),
                  IconButton(onPressed: scan, icon: Icon(Icons.camera))
                ],
              ),
              verticalSpaceSmall,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AddProductForm(
                          cameracode: '',
                          afterData: (AddProduct data) {
                            setState(() {
                              items.add(
                                ProductCard(
                                  name: data.name,
                                  price: data.price,
                                ),
                              );
                              showResult = false;
                            });
                            FocusScope.of(context).requestFocus(FocusNode());
                            textEditingController.clear();
                          },
                        ),
                      ));
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: CustomColors.firebaseNavy, width: 3),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: Text('+ Add Items'),
                    ),
                  )
                ],
              ),
              verticalSpaceSmall,
              showResult
                  ? Container(
                      color: Colors.grey.shade300,
                      height: screenHeight(context) / 1.4,
                      child: ListView.builder(
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
                                      {
                                        'name': pd['name'],
                                        'price': pd['price']
                                      },
                                    );
                                  });
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    showResult = false;
                                  });

                                  textEditingController.clear();
                                },
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
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
                    )
                  : SizedBox(),
              showResult
                  ? SizedBox()
                  : items.length != 0
                      ? Container(
                          color: Colors.grey[500],
                          height: screenHeight(context) / 1.7,
                          child: Stack(
                            children: [
                              ListView.builder(
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  return Card(
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
                                            items[index]['name'],
                                            style: TextStyle(
                                              fontSize: 22,
                                            ),
                                          ),
                                          Text(
                                            'Rs. ${items[index]['price'].toString()}',
                                            style: TextStyle(
                                              fontSize: 22,
                                            ),
                                          ),
                                        ],
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
              items.length != 0
                  ? InkWell(
                      onTap: () {
                        setState(() {
                          loading = true;
                          orderList = widget.data;
                        });
                        orderList.add({'items': items});
                        FirestoreApi().updateOrder(orderList);
                        setState(() {
                          loading = false;
                        });
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: screenWidth(context) / 1.7,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: CustomColors.firebaseNavy,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: loading
                            ? CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              )
                            : Text(
                                'Create Order',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
        ),
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
