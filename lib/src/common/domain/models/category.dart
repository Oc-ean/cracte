import 'package:hive/hive.dart';
part 'category.g.dart';

@HiveType(typeId: 1)
class Category {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;

  Category({required this.id, required this.name});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json, String id) {
    return Category(
      id: id,
      name: json['name'] as String,
    );
  }

  factory Category.sampleData() =>
      Category(id: 'sample', name: 'Sample Category');
}
