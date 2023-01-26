import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class Quantity {
  final num? quantity;

  Quantity({
    this.quantity,
  });

  factory Quantity.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Quantity(quantity: data?['quantity']);
  }

  Map<String, dynamic> toFirestore() {
    return {if (quantity != null) "quantity": quantity};
  }
}
