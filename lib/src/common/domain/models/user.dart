import 'package:hive/hive.dart';
part 'user.g.dart';

@HiveType(typeId: 2)
class User {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final String photoUrl;
  @HiveField(4)
  final String bio;
  @HiveField(5)
  final List<String> followers;
  @HiveField(6)
  final List<String> following;
  @HiveField(7)
  final int recipes;
  @HiveField(8)
  final bool isDummy;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.bio,
    this.followers = const [],
    this.following = const [],
    this.recipes = 0,
    this.isDummy = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String,
      bio: json['bio'] as String,
      followers: List<String>.from(json['followers'] as List? ?? []),
      following: List<String>.from(json['following'] as List? ?? []),
      recipes: json['recipes'] as int? ?? 0,
      isDummy: json['isDummy'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'bio': bio,
      'followers': followers,
      'following': following,
      'recipes': recipes,
      'isDummy': isDummy,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    String? bio,
    List<String>? followers,
    List<String>? following,
    int? recipes,
    bool? isDummy,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      recipes: recipes ?? this.recipes,
      isDummy: isDummy ?? this.isDummy,
    );
  }

  bool isFollowing(String userId) {
    return following.contains(userId);
  }

  bool isFollowedBy(String userId) {
    return followers.contains(userId);
  }

  factory User.sampleData() {
    return const User(
      id: '1',
      name: 'John Doe',
      email: '4wY5q@example.com',
      photoUrl: 'https://example.com/johndoe.jpg',
      bio: 'I am a software developer.',
      followers: ['user1', 'user2'],
      following: ['user3', 'user4'],
      recipes: 10,
      isDummy: true,
    );
  }

  int get followersCount => followers.length;
  int get followingCount => following.length;
}
