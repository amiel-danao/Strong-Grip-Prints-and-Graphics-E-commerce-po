import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String? name;
  final String? description;
  final String? type;
  final String? img_url;
  final num? price;
  final String? rating;
  final bool? active;

  Product({
    this.name,
    this.description,
    this.type,
    this.img_url,
    this.price,
    this.rating,
    this.active
  });

  factory Product.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Product(
      name: data?['name'],
      description: data?['description'],
      type: data?['type'],
      img_url: data?['img_url'],
      price: data?['price'],
      rating: data?['rating'],
      active: data?['active'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) "name": name,
      if (description != null) "description": description,
      if (type != null) "type": type,
      if (img_url != null) "img_url": img_url,
      if (price != null) "price": price,
      if (rating != null) "rating": rating,
      if (active != null) "active": active,
    };
  }
}
