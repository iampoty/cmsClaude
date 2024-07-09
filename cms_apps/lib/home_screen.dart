import 'package:flutter/material.dart';
import 'article_card.dart';
import 'article_service.dart';
import 'article_view_screen.dart';
import 'dart:developer';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ArticleService _articleService = ArticleService();
  List<Article> _articles = [];
  int _page = 1;
  bool _hasMore = true;
  String _selectedStatus = '';

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _page = 1;
        _articles.clear();
      });
    }

    final newArticles = await _articleService.getArticles(
      page: _page,
      limit: 2,
      status: _selectedStatus,
    );

    log("!!!!!!!!!!!!!!!!!!!!!newArticles in _loadArticles$newArticles");

    setState(() {
      _articles.addAll(newArticles);
      _hasMore = newArticles.length == 2;
      if (_hasMore) _page++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Latest Articles')),
      body: Column(
        children: [
          _buildStatusFilter(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadArticles(refresh: true),
              child: ListView.builder(
                itemCount: _articles.length + 1,
                itemBuilder: (context, index) {
                  if (index == _articles.length) {
                    return _buildLoadMoreButton();
                  }
                  return ArticleCard(
                    article: _articles[index],
                    onTap: () => _openArticle(_articles[index]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return DropdownButton<String>(
      value: _selectedStatus,
      items: [
        DropdownMenuItem(child: Text('All'), value: ''),
        DropdownMenuItem(child: Text('Draft'), value: '0'),
        DropdownMenuItem(child: Text('Published'), value: '1'),
        DropdownMenuItem(child: Text('Archived'), value: '2'),
      ],
      onChanged: (value) {
        setState(() {
          _selectedStatus = value!;
          _loadArticles(refresh: true);
        });
      },
    );
  }

  Widget _buildLoadMoreButton() {
    return _hasMore
        ? ElevatedButton(
            child: Text('Load More'),
            onPressed: _loadArticles,
          )
        : SizedBox.shrink();
  }

  void _openArticle(Article article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleViewScreen(article: article),
      ),
    );
  }
}
