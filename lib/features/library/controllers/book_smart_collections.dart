import 'package:flutter/material.dart';
import '../../../models/book.dart';

/// Data for a smart collection card.
class SmartCollectionData {
  final String title;
  final List<Book> books;
  final IconData icon;
  final Color? color;

  SmartCollectionData({required this.title, required this.books, required this.icon, this.color});
  int get count => books.length;
}

/// Smart collection logic for book list.
mixin BookSmartCollections {
  List<Book> get books;

  List<Book> get recentlyAdded {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return books.where((b) => b.createdAt.isAfter(weekAgo)).toList();
  }

  List<Book> get unreadBooks => books.where((b) => b.progressPercent < 0.1).toList();
  List<Book> get almostFinished => books.where((b) => b.progressPercent >= 0.7 && b.progressPercent < 1.0).toList();
  List<Book> get frequentlyRead => books.where((b) => b.readingSeconds > 3600).toList();

  List<SmartCollectionData> getSmartCollections() {
    return [
      SmartCollectionData(title: 'Recently Added', books: recentlyAdded, icon: Icons.new_releases),
      SmartCollectionData(title: 'Unread', books: unreadBooks, icon: Icons.bookmark_border),
      SmartCollectionData(title: 'Almost Finished', books: almostFinished, icon: Icons.trending_up),
      SmartCollectionData(title: 'Frequently Read', books: frequentlyRead, icon: Icons.star),
    ];
  }
}
