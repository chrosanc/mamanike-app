class Category {
  final String categoryImage;
  final String categoryName;
  final Map<String, ProductItem> list;

  Category({
    required this.categoryImage,
    required this.categoryName,
    required this.list,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryImage: json['categoryImage'],
      categoryName: json['categoryName'],
      list: (json['list'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, ProductItem.fromJson(value)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryImage': categoryImage,
      'categoryName': categoryName,
      'list': list.map((key, value) => MapEntry(key, value.toJson()))
    };
  }
}

class ProductItem {
  final String description;
  final String productImage;
  final int productPrice;
  final String? category;
  final String productName;
  final int stock;

  ProductItem({
    required this.description,
    required this.productImage,
    required this.productPrice,
    this.category,
    required this.productName,
    required this.stock,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      description: json['description'],
      productImage: json['productImage'],
      productPrice: json['productPrice'],
      category: json['category'],
      productName: json['productName'],
      stock: json['stock'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'productImage': productImage,
      'productPrice': productPrice,
      'category': category,
      'productName': productName,
      'stock': stock,
    };
  }
}
