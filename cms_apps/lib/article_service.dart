import 'dart:convert';
// import 'dart:math';
// import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';

class Article {
  final String id;
  final String title;
  final String content;
  final String? thumbnail;
  final String? createDate;
  final int status;

  Article({
    required this.id,
    required this.title,
    required this.content,
    this.thumbnail,
    required this.createDate,
    required this.status,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? "",
      // title: json['title'] ?? "title",
      // content: json['content'] ?? "content",
      // thumbnail: json['thumbnail'] ?? "thumbnail",
      // createDate: json['createDate'] ?? "createDate",
      // status: json['status'] ?? 0,
      title: json['title'] ?? "",
      content: json['content'] ?? "",
      thumbnail: json['thumbnail'] ?? "",
      // createDate: DateTime.parse(json['createDate'] ?? ""),
      createDate: json['createDate'] ?? "",
      status: json['status'] ?? 0,
    );
  }
}

class ArticleService {
  final String baseUrl = 'http://localhost:8000/api';

  Future<List<Article>> getArticles({
    int page = 1,
    int limit = 2,
    String status = '',
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/articles?page=$page&limit=$limit&status=$status'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      // log("!!!!!!!!!!!!!!!!!!!!!jsonData in getArticles$jsonData");
      return jsonData.map((json) => Article.fromJson(json)).toList();
    } else {
      // log("!!!!!!!!!!!!!!!!!!!!!error in getArticles");
      // debugPrint("error in getArticles");
      throw Exception('Failed to load articles');
    }
  }
}
