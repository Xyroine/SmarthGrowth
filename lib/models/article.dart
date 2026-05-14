class Article {
  final int? id;
  final String title;
  final String content;
  final String category; // Kesehatan, Tumbuh Kembang, Parenting, Psikologi Anak
  final String? imageUrl;
  final DateTime publishedAt;

  Article({
    this.id,
    required this.title,
    required this.content,
    required this.category,
    this.imageUrl,
    DateTime? publishedAt,
  }) : publishedAt = publishedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'image_url': imageUrl,
      'published_at': publishedAt.toIso8601String(),
    };
  }

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      category: map['category'] as String,
      imageUrl: map['image_url'] as String?,
      publishedAt: DateTime.parse(map['published_at'] as String),
    );
  }
}
