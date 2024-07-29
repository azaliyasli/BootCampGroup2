class News {
  final String uuid;
  final String title;
  final String description;
  final String keywords;
  final String snippet;
  final String url;
  final String urlToImage;
  final String language;
  final String publishedAt;
  final String source;

  // Consider creating another class for entities if you need to use them
  // final List<Entity> entities;

  News({
    required this.uuid,
    required this.title,
    required this.description,
    required this.keywords,
    required this.snippet,
    required this.url,
    required this.urlToImage,
    required this.language,
    required this.publishedAt,
    required this.source,
    // this.entities,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      uuid: json['uuid'],
      title: json['title'],
      description: json['description'],
      keywords: json['keywords'] ?? '',
      snippet: json['snippet'] ?? '',
      url: json['url'],
      urlToImage: json['image_url'] ?? '',
      language: json['language'] ?? 'en',
      publishedAt: json['published_at'],
      source: json['source'] ?? 'Unknown',
      // entities: (json['entities'] as List).map((e) => Entity.fromJson(e)).toList(),
    );
  }
}