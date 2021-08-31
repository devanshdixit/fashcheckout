import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fastcheckout/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:select_form_field/select_form_field.dart';

class AddProduct {
  final String name;
  final String pud;
  final String price;
  final String weight;
  final String weightType;

  AddProduct(
      {required this.pud,
      required this.weight,
      required this.weightType,
      required this.name,
      required this.price});
}

class AddProductForm extends StatefulWidget {
  final String cameracode;
  final Function afterData;
  AddProductForm({Key? key, required this.cameracode, required this.afterData})
      : super(key: key);

  @override
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  String weightType = 'kg';
  String pud = '';
  String pdName = '';
  String pdPrice = '';
  String pdWeight = '';
  bool loading = false;
  final List<Map<String, dynamic>> _items = [
    {
      'value': 'lt',
      'label': 'lt',
      'textStyle': TextStyle(
        fontSize: 20,
        color: Colors.black,
      ),
    },
    {
      'value': 'kg',
      'label': 'kg',
    },
  ];

  @override
  void initState() {
    super.initState();
    setState(() {
      pud = widget.cameracode;
    });
  }

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
      body: ListView(
        children: [
          verticalSpaceRegular,
          Center(
            child: Text(
              'Add Product',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          verticalSpaceMedium,
          ListTile(
            title: TextFormField(
              decoration: textInputDecoration.copyWith(
                hintStyle: TextStyle(color: Colors.black),
                hintText: 'Enter PUD No.',
                labelText: 'Enter PUD No.',
                labelStyle: TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                ),
              ),
              validator: (value) => value!.isEmpty ? 'Enter pud number' : null,
              initialValue: pud,
              onChanged: (val) {
                setState(() {
                  pud = val;
                });
                print(pud);
              },
            ),
          ),
          verticalSpaceSmall,
          ListTile(
            title: TextFormField(
              decoration: textInputDecoration.copyWith(
                hintStyle: TextStyle(color: Colors.black),
                hintText: 'Enter Product Name',
                labelText: 'Enter Product Name',
                labelStyle: TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                ),
              ),
              validator: (value) =>
                  value!.isEmpty ? 'Enter Product Name' : null,
              onChanged: (val) {
                setState(() {
                  pdName = val;
                });
                print(pdName);
              },
            ),
          ),
          verticalSpaceSmall,
          ListTile(
            title: TextFormField(
              decoration: textInputDecoration.copyWith(
                hintStyle: TextStyle(color: Colors.black),
                hintText: 'Enter Product Price',
                labelText: 'Enter Product Price',
                labelStyle: TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                ),
              ),
              validator: (value) =>
                  value!.isEmpty ? 'Enter Product Price' : null,
              onChanged: (val) {
                setState(() {
                  pdPrice = val;
                });
                print(pdPrice);
              },
            ),
          ),
          verticalSpaceSmall,
          ListTile(
            title: Row(
              children: [
                Container(
                  width: screenWidth(context) / 1.9,
                  child: TextFormField(
                    decoration: textInputDecoration.copyWith(
                      hintStyle: TextStyle(color: Colors.black),
                      hintText: 'Enter Product weight',
                      labelText: 'Enter Product weight',
                      labelStyle: TextStyle(
                        fontSize: 20.0,
                        color: Colors.black,
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Enter Product Price' : null,
                    onChanged: (val) {
                      setState(() {
                        pdWeight = val;
                      });
                      print(pdWeight);
                    },
                  ),
                ),
                horizontalSpaceTiny,
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: Colors.black,
                    ),
                  ),
                  width: 140,
                  child: SelectFormField(
                    type: SelectFormFieldType.dropdown,
                    initialValue: 'kg',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                    items: _items,
                    onChanged: (val) {
                      setState(() {
                        weightType = val;
                      });
                      print(weightType);
                    },
                  ),
                ),
              ],
            ),
          ),
          verticalSpaceRegular,
          Center(
            child: GestureDetector(
              onTap: () async {
                setState(() {
                  loading = false;
                });
                if (pud.isNotEmpty &&
                    pdName.isNotEmpty &&
                    pdPrice.isNotEmpty &&
                    pdWeight.isNotEmpty &&
                    weightType.isNotEmpty) {
                  await saveProduct(
                    AddProduct(
                      pud: pud,
                      weight: pdWeight,
                      weightType: weightType,
                      name: pdName,
                      price: pdPrice,
                    ),
                  );
                  final snackBar = SnackBar(
                    content: Text('Product Added Successsfully'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {},
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  setState(() {
                    loading = false;
                  });
                  widget.afterData(AddProduct(
                    pud: pud,
                    weight: pdWeight,
                    weightType: weightType,
                    name: pdName,
                    price: pdPrice,
                  ));
                  Navigator.of(context).pop();
                } else {
                  final snackBar = SnackBar(
                    backgroundColor: Colors.red,
                    content: Text(
                      'Complete Form',
                      style: TextStyle(color: Colors.white),
                    ),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {},
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
              child: Container(
                width: screenWidth(context) / 1.7,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: CustomColors.firebaseNavy,
                ),
                child: loading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      )
                    : Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
              ),
            ),
          ),
          verticalSpaceSmall,
        ],
      ),
    );
  }

  setSearchParam(String caseNumber) {
    List<String> caseSearchList = [];
    String temp = "";
    for (int i = 0; i < caseNumber.length; i++) {
      temp = temp + caseNumber[i];
      caseSearchList.add(temp);
    }
    return caseSearchList;
  }

  Future saveProduct(AddProduct data) async {
    try {
      final CollectionReference productCollection =
          FirebaseFirestore.instance.collection('products');
      final productDocument = productCollection;

      final productData = productDocument.doc(data.pud);
      await productData.set({
        'pud': data.pud,
        'name': data.name,
        'price': data.price,
        'weight': data.weight,
        'weightType': data.weightType,
        "caseSearch": setSearchParam(data.pud + data.name),
      });
      print('Product created at ${productData.path}');
      return true;
    } catch (error) {
      throw Exception(error);
    }
  }
}
