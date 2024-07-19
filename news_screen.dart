import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsArticle {
  final String title;
  final String description;
  final String urlToImage;
  final String articleUrl;

  NewsArticle({
    required this.title,
    required this.description,
    required this.urlToImage,
    required this.articleUrl,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      urlToImage: json['urlToImage'] ?? '',
      articleUrl: json['url'] ?? '',
    );
  }
}

class NewsService {
  Future<List<NewsArticle>> fetchNews() async {
    final response = await http.get(Uri.parse(
        'https://newsapi.org/v2/everything?q=Apple&from=2024-07-19&sortBy=popularity&apiKey=9802ec5a4444431285a56a5784e61314'));

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      List articles = json.decode(response.body)['articles'];
      return articles.map((article) => NewsArticle.fromJson(article)).toList();
    } else {
      throw Exception('Failed to load news');
    }
  }
}

class NewsPage2 extends StatefulWidget {
  const NewsPage2({super.key});

  @override
  State<NewsPage2> createState() => _NewsPage2State();
}

class _NewsPage2State extends State<NewsPage2> {
  late Future<List<NewsArticle>> futureNewsArticles;

  @override
  void initState() {
    super.initState();
    futureNewsArticles = NewsService().fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News'),
      ),
      body: FutureBuilder<List<NewsArticle>>(
        future: futureNewsArticles,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                NewsArticle article = snapshot.data![index];
                return ListTile(
                  title: Text(article.title),
                  subtitle: Text(article.description),
                  leading: article.urlToImage.isNotEmpty
                      ? Image.network(article.urlToImage)
                      : null,
                  onTap: () => {}, // Add your action to open article
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}
