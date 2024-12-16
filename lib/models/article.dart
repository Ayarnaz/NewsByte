class Article {
  final String? title; // The title of the article
  final String? description; // The description or short summary of the article
  final String? content; // Full content of the article
  final String? author; // Author of the article
  final String? urlToImage; // URL to the article's image
  final String? url; // The URL of the article for redirection
  final String? publishedAt; // The publication date of the article
  final String? source; // The source of the article (like a news outlet)
  // Constructor to initialize the article with optional fields
  Article({
    this.title,
    this.description,
    this.content,
    this.author,
    this.urlToImage,
    this.url,
    this.publishedAt,
    this.source,
  });
  // Factory constructor to create an Article object from a JSON map
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'],
      description: json['description'],
      content: json['content'],
      author: json['author'],
      urlToImage: json['urlToImage'],
      url: json['url'],
      publishedAt: json['publishedAt'],
      source: json['source'] is String ? json['source'] : json['source']['name'],
    );
  }
  // Method to convert the Article object back into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'content': content,
      'author': author,
      'urlToImage': urlToImage,
      'url': url,
      'publishedAt': publishedAt,
      'source': source,
    };
  }
} 