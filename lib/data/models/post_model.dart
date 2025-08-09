class Post {
  final int id;
  final String title;
  final String body;
  final bool isFavorite; // add this field

  Post({
    required this.id,
    required this.title,
    required this.body,
    this.isFavorite = false, // default false
  });

  factory Post.fromJson(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      isFavorite: map['isFavorite'] == 1, // convert int back to bool here
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'isFavorite': isFavorite ? 1 : 0, // convert bool to int here
    };
  }

  // Optional: copyWith method for easier updates
  Post copyWith({
    int? id,
    String? title,
    String? body,
    bool? isFavorite,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
