import 'package:flutter/material.dart';
import 'article_service.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const ArticleCard({super.key, required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
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
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    article.content.length > 100
                        ? '${article.content.substring(0, 100)}...'
                        : article.content,
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(article.createDate.toString()),
                      _buildStatusChip(article.status),
                    ],
                  ),
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
