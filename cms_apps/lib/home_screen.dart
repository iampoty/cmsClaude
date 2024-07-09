import 'package:flutter/material.dart';
import 'article_card.dart';
import 'article_service.dart';
import 'article_view_screen.dart';

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    if (refresh) {
      setState(() {
        _page = 1;
        _articles.clear();
      });
    }

    try {
      final newArticles = await _articleService.getArticles(
        page: _page,
        limit: 6, // เพิ่มจำนวนบทความที่โหลดต่อครั้ง
        status: _selectedStatus,
      );

      setState(() {
        _articles.addAll(newArticles);
        _hasMore = newArticles.length == 6;
        if (_hasMore) _page++;
      });
    } catch (e) {
      // จัดการข้อผิดพลาด
      print('Error loading articles: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: constraints.maxWidth > 900 ? 3 : 1,
                      childAspectRatio: 0.7, // ปรับอัตราส่วนนี้ตามความเหมาะสม
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
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
                    padding: EdgeInsets.all(10),
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<String>(
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
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return _hasMore
        ? Center(
            child: ElevatedButton(
              child:
                  _isLoading ? CircularProgressIndicator() : Text('Load More'),
              onPressed: _isLoading ? null : _loadArticles,
            ),
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
