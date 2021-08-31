import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fastcheckout/api/authentication.dart';
import 'package:fastcheckout/model/userModel.dart';

class FirestoreApi {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  final CollectionReference productCollection =
      FirebaseFirestore.instance.collection('products');
  Future<void> searchProduct(String pud) async {
    try {
      final productDocument = productCollection.where('id', isEqualTo: pud);
      final productData = await productDocument.get();
      productData.docs.map((e) => print(e));
    } catch (error) {
      throw Exception(error);
    }
  }

  Future getProduct(String pud) async {
    try {
      final productDocument = productCollection.where('pud', isEqualTo: pud);
      final productData = await productDocument.get();
      final docs = productData.docs;
      if (docs.isNotEmpty) {
        final user = docs[0].data()!;
        String s = json.encode(user);
        Map<String, dynamic> users = jsonDecode(s);
        return users;
      }
      return null;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future addOrder(dynamic data) async {
    final user = Authentication().currentUser;
    try {
      print('user while adding order $user');
      if (user != null) {
        final productData = usersCollection.doc(user.id.toString());
        await productData.set({
          'orders': data,
        });
        print('Order Added successfully at ${productData.path}');
        return true;
      } else {
        print('Order cannot added user is not there');
        return false;
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future getUser({required String id}) async {
    // try {
    //   final userDocument = usersCollection.where('id', isEqualTo: id);
    //   final userData = await userDocument.get();
    //   final docs = userData.docs;
    //   if (docs.isNotEmpty) {
    //     final user = docs[0].data()!;
    //     String s = json.encode(user);
    //     Map<String, dynamic> mapuser = jsonDecode(s);
    //     return FireStoreUser(id: mapuser['id'], orders: mapuser['orders']);
    //   }
    //   return null;
    // } catch (error) {
    //   throw Exception(error);
    // }
    print(id);
    var doc = await usersCollection.doc(id).get();
    if (doc.exists == false) {
      return null;
    }
    Object? data = doc.data();
    if (data != null) {
      String s = json.encode(data);
      Map<String, dynamic> mapuser = jsonDecode(s);
      return FireStoreUser(id: mapuser['id'], orders: mapuser['orders']);
    }
  }

  Future createUser({required String id}) async {
    try {
      final usersData = usersCollection.doc(id);
      await usersData.set({
        'id': id,
        'orders': [],
      });
      print('User Created successfully at ${usersData.path}');
      return true;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future updateOrder(dynamic data) async {
    try {
      final user = Authentication().user;
      print('user while adding order $user');
      if (user != null) {
        final productData = usersCollection.doc(user.uid);
        await productData.update({
          'orders': data,
        });
        print('Order updated successfully at ${productData.path}');
        return true;
      } else {
        print('Order cannot updated user is not there');
        return false;
      }
    } catch (e) {
      throw Exception(e);
    }
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

  Stream<List<Orders>> streamuser() {
    final id = Authentication().user!.uid;
    return usersCollection.where('id', isEqualTo: id).snapshots().map(
        (list) => list.docs.map((doc) => Orders.fromFirestore(doc)).toList());
  }
}

class Orders {
  final List order;
  Orders({
    required this.order,
  });

  factory Orders.fromFirestore(DocumentSnapshot doc) {
    String s = json.encode(doc.data());
    Map<String, dynamic> data = jsonDecode(s);
    return Orders(order: data['orders']);
  }
}
