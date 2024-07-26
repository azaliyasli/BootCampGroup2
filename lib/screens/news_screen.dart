import 'package:flutter/material.dart';
import 'package:hesapp/models/news_model.dart';
import 'package:hesapp/services/news_service.dart';

class NewsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Latest News'),
      ),
      body: FutureBuilder<List<News>>(
        future: fetchNews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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