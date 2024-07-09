import 'package:flutter/material.dart';
import 'article_service.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const ArticleCard({super.key, required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.thumbnail != null)
              Expanded(
                flex: 3,
                child: Image.network(
                  article.thumbnail!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8.0),
                    Expanded(
                      child: Text(
                        article.content,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            article.createDate.toString(),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        _buildStatusChip(article.status),
                      ],
                    ),
                  ],
                ),
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
      label: Text(label, style: const TextStyle(fontSize: 10)),
      backgroundColor: color,
      padding: const EdgeInsets.all(4),
    );
  }
}
