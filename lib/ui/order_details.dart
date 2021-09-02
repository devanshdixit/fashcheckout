import 'dart:io';
import 'dart:typed_data';
import 'package:fastcheckout/main.dart';
import 'package:fastcheckout/shared/constants.dart';
import 'package:fastcheckout/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:path_provider/path_provider.dart';

class OrderDetails extends StatefulWidget {
  final List orderData;
  final int inDex;
  OrderDetails({Key? key, required this.orderData, required this.inDex})
      : super(key: key);
  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  late GlobalKey key2;
  Uint8List bytes1 = Uint8List(0);
  Uint8List bytes2 = Uint8List(0);

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
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          verticalSpaceSmall,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Text(
                  'Order ${widget.inDex.toString()}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                )
              ],
            ),
          ),
          verticalSpaceMedium,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Text(
                  'Items:',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                )
              ],
            ),
          ),
          verticalSpaceSmall,
          widget.orderData.length == 0
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Image.asset(
                      'assets/NotAvailable@2x.png',
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                )
              : WidgetToImage(
                  builder: (key) {
                    this.key2 = key;
                    return Container(
                      color: Colors.grey.shade300,
                      height: (70 * widget.orderData.length.toDouble()),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.orderData.length,
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
                                onTap: () {},
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      widget.orderData[index]['name']
                                          .toString(),
                                      style: TextStyle(
                                        fontSize: 22,
                                      ),
                                    ),
                                    Text(
                                      widget.orderData[index]['price']
                                          .toString(),
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
                  },
                ),
          verticalSpaceSmall,
          Visibility(
            child: bytes1.isNotEmpty ? buildImage(bytes1) : SizedBox(),
            visible: false,
          ),
        ],
      ),
      bottomSheet: Container(
        color: Colors.white,
        padding: EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          child: ElevatedButton(
            child: Text('Capture'),
            onPressed: () async {
              final bytes1 = await Utils.capture(key2);

              setState(() {
                this.bytes1 = bytes1;
                this.bytes2 = bytes2;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget buildImage(Uint8List bytes) {
    urlFileShare(bytes);
    return bytes != null ? Image.memory(bytes) : Container();
  }

  Future<Null> urlFileShare(Uint8List bytes) async {
    final data = File.fromRawPath(bytes);
    // final data1 = await File('generated.jpg').writeAsBytes(bytes);
    final dir = await getExternalStorageDirectory();
    final myImagePath = dir!.path + "/myimg.png";
    File imageFile = File(myImagePath);
    if (!await imageFile.exists()) {
      imageFile.create(recursive: true);
    }
    final data1 = imageFile.writeAsBytes(bytes);
    await FlutterShare.shareFile(
      title: 'Example share',
      text: 'Example share text',
      filePath: imageFile.path,
    );
  }
}
