import 'dart:io';
import 'dart:typed_data';
import 'package:fastcheckout/ui/login.dart';
import 'package:fastcheckout/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:flutter_share/flutter_share.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginView(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String title = 'Convert Widget To Image';

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: title,
        theme: ThemeData(primarySwatch: Colors.deepOrange),
        home: MainPage(title: title),
      );
}

class MainPage extends StatefulWidget {
  final String title;

  const MainPage({
    required this.title,
  });

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late GlobalKey key1;
  Uint8List bytes1 = Uint8List(0);
  Uint8List bytes2 = Uint8List(0);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TitleWidget('Widgets'),
            WidgetToImage(
              builder: (key) {
                this.key1 = key;
                return CardWidget(title: 'Title1', description: 'Description1');
              },
            ),
            WidgetToImage(
              builder: (key) {
                this.key1 = key;

                return CardWidget(title: 'Title2', description: 'Description2');
              },
            ),
            TitleWidget('Images'),
            bytes1.isNotEmpty ? buildImage(bytes1) : SizedBox(),
            bytes2.isNotEmpty ? buildImage(bytes2) : SizedBox(),
          ],
        ),
        bottomSheet: Container(
          color: Theme.of(context).accentColor,
          padding: EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            child: ElevatedButton(
              child: Text('Capture'),
              onPressed: () async {
                final bytes1 = await Utils.capture(key1);
                final bytes2 = await Utils.capture(key1);

                setState(() {
                  this.bytes1 = bytes1;
                  this.bytes2 = bytes2;
                });
              },
            ),
          ),
        ),
      );

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

class CardWidget extends StatelessWidget {
  final String title;
  final String description;

  const CardWidget({
    required this.title,
    required this.description,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double radius = 16;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      elevation: 4,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(radius),
            ),
            child: Image.network(
              'https://images.unsplash.com/photo-1598900438157-e28f3f4c09b4?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=634&q=80',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class TitleWidget extends StatelessWidget {
  final String title;

  const TitleWidget(this.title);

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      );
}

class WidgetToImage extends StatefulWidget {
  final Function(GlobalKey key) builder;

  const WidgetToImage({
    required this.builder,
    Key? key,
  }) : super(key: key);

  @override
  _WidgetToImageState createState() => _WidgetToImageState();
}

class _WidgetToImageState extends State<WidgetToImage> {
  final globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: globalKey,
      child: widget.builder(globalKey),
    );
  }
}
