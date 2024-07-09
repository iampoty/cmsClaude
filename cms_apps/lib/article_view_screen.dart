import 'package:flutter/material.dart';
import 'article_service.dart';

class ArticleViewScreen extends StatelessWidget {
  final Article article;

  const ArticleViewScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(article.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.thumbnail != null)
              Image.network(
                article.thumbnail!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(article.createDate.toString()),
                      _buildStatusChip(article.status),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Text(article.content),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(int status) {
    String label;
    Color color;
    switch (status) {
      case 0:
        label = 'Draft';
        color = Colors.yellow;
        break;
      case 1:
        label = 'Published';
        color = Colors.green;
        break;
      case 2:
        label = 'Archived';
        color = Colors.grey;
        break;
      default:
        label = 'Unknown';
        color = Colors.blue;
    }
    return Chip(
      label: Text(label),
      backgroundColor: color,
    );
  }
}
