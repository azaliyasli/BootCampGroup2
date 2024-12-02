import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// News model
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

// Fetch news from API
Future<List<News>> fetchNews() async {
  final String apiKey = 'NnipeUp9Uo3myinXPuM3zIf5uzZ4MzYzylPF3QPY';
  final String url =
      'https://api.marketaux.com/v1/news/all?countries=us&filter_entities=true&limit=10&published_after=2024-07-18T09:30&api_token=$apiKey';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body)['data'];
    return jsonResponse.map((news) => News.fromJson(news)).toList();
  } else {
    throw Exception('Failed to load news');
  }
}

// News Page Widget
class NEWNEWS extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Latest News'),
      ),
      body: FutureBuilder<List<News>>(
        future: fetchNews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index].title),
                  subtitle: Text(snapshot.data![index].description),
                  leading: snapshot.data![index].urlToImage.isNotEmpty
                      ? Image.network(snapshot.data![index].urlToImage)
                      : null,
                );
              },
            );
          }
        },
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: NEWNEWS()));
