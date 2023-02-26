import 'package:cloud_firestore/cloud_firestore.dart';

class Discount {
  final String? id;
  final int? minQuantity;
  final int? maxQuantity;
  final double? percent;

  Discount({
    this.id,
    this.minQuantity,
    this.maxQuantity,
    this.percent
  });

  factory Discount.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Discount(
        id: data?['id'],
        minQuantity: data?['min_quantity'],
        maxQuantity: data?['max_quantity'],
        percent: data?['percent']
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) "id": id,
      if (minQuantity != null) "min_quantity": minQuantity,
      if (maxQuantity != null) "max_quantity": maxQuantity,
      if (percent != null) "percent": percent,
    };
  }
}