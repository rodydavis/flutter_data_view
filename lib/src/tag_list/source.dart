import 'package:flutter/material.dart';

import '../data_source.dart';

abstract class TaggedDataTableSource<T> extends DataSource<T> {
  TaggedDataTableSource(List<T> items) : super(items);

  Icon getIconForTag(String tag) {
    final iconData = () {
      switch (tag) {
        case 'settings':
        case 'system':
          return Icons.settings;
        case 'info':
        case 'about':
        case 'details':
          return Icons.info_outline;
        case 'bookmark':
        case 'bookmarks':
          return Icons.bookmark;
        case 'account':
          return Icons.person;
        case 'dev':
        case 'code':
          return Icons.code;
        case 'favorite':
        case 'favorites':
          return Icons.favorite;
        default:
      }
      return Icons.info;
    };
    if (iconData() == null) return null;
    return Icon(iconData());
  }

  List<String> getTagsForRow(int index) {
    final item = this.items[index];
    if (item is Map && item.containsKey('tags')) {
      return item['tags'];
    }
    return [];
  }

  String _selected;
  String get selectedTag => _selected;
  void selectTag(String tag) {
    _selected = tag;
    this.notifyListeners();
  }

  List<String> get allTags {
    final tags = <String>{};
    for (var i = 0; i < rowCount; i++) {
      final _tags = getTagsForRow(i);
      tags.addAll(_tags);
    }
    final _tags = tags.toList();
    _tags.sort();
    return _tags;
  }

  List<DataRow> get rowsForTag {
    final rows = <DataRow>{};
    for (var i = 0; i < rowCount; i++) {
      final tags = getTagsForRow(i);
      if (_selected == null || tags.contains(_selected)) {
        rows.add(getRow(i));
      }
    }
    final search = this.search.toLowerCase();
    if (search.isEmpty) return rows.toList();
    final _results = <DataRow>[];
    for (var i = 0; i < rowCount; i++) {
      final item = this.items[i];
      if (item.toString().toLowerCase().contains(search)) {
        final row = this.getRow(i);
        _results.add(row);
      }
    }
    return _results;
  }
}
