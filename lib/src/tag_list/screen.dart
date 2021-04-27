import 'package:flutter/material.dart';

import 'source.dart';

class TaggedDataView extends StatefulWidget {
  const TaggedDataView({
    Key key,
    @required this.dataSource,
    this.tagViewWidth = 220,
    this.listViewWidth = 280,
  }) : super(key: key);

  final TaggedDataTableSource dataSource;
  final double listViewWidth, tagViewWidth;

  @override
  _TaggedDataViewState createState() => _TaggedDataViewState();
}

class _TaggedDataViewState extends State<TaggedDataView> {
  @override
  void initState() {
    super.initState();
    widget.dataSource.addListener(_handleSourceChange);
  }

  @override
  void dispose() {
    widget.dataSource.removeListener(_handleSourceChange);
    super.dispose();
  }

  void _handleSourceChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final source = widget.dataSource;
    final tags = widget.dataSource.allTags;
    final folders = tags.where((e) => e.contains('/')).toList();
    final other = tags
        .where((e) => !folders.map((e) => e.split('/').first).contains(e))
        .toList();
    final allTags = [...folders, ...other].toSet().toList();
    allTags.sort();
    return Container(
      child: Row(
        children: [
          Container(
            width: widget.tagViewWidth,
            child: Scrollbar(
              child: ListView(
                children: [
                  ListTile(
                    selected: widget.dataSource.selectedTag == null,
                    onTap: () => widget.dataSource.selectTag(null),
                    leading: Icon(Icons.list),
                    title: Text('All'),
                  ),
                  for (var i = 0; i < allTags.length; i++)
                    buildTag(allTags[i], folders.contains(allTags[i])),
                ],
              ),
            ),
          ),
          Container(
            width: widget.listViewWidth,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search',
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (val) {
                            widget.dataSource.onSearch(val);
                            if (mounted) setState(() {});
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Scrollbar(
                    child: ListView.builder(
                      itemCount: source.rowsForTag.length,
                      itemBuilder: (context, index) {
                        final item = source.rowsForTag[index];
                        return ListTile(
                          title: item.cells[0].child,
                          subtitle: item.cells[1].child,
                          selected: item.selected,
                          onTap: () => item.onSelectChanged(!item.selected),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          VerticalDivider(width: 0),
          Expanded(
            child: widget.dataSource.selectedRowCount == 0
                ? Center(
                    child: Text('No Item Selected'),
                  )
                : Center(
                    child: Text(widget.dataSource.selected.last.toString()),
                  ),
          ),
        ],
      ),
    );
  }

  Widget buildTag(String tag, [bool folder = false]) {
    if (folder) {
      return TagFolder(
        dataSource: widget.dataSource,
        tag: tag,
      );
    }
    return ListTile(
      selected: widget.dataSource.selectedTag == tag,
      onTap: () => widget.dataSource.selectTag(tag),
      leading: widget.dataSource.getIconForTag(tag),
      title: Text(tag),
    );
  }
}

class TagFolder extends StatefulWidget {
  const TagFolder({
    Key key,
    @required this.tag,
    @required this.dataSource,
  }) : super(key: key);
  final String tag;
  final TaggedDataTableSource dataSource;

  @override
  _TagFolderState createState() => _TagFolderState();
}

class _TagFolderState extends State<TagFolder> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    final name = widget.tag.split('/').first.trim();
    return Column(
      children: [
        ListTile(
          selected: widget.dataSource.selectedTag == name,
          onTap: () => widget.dataSource.selectTag(name),
          leading: widget.dataSource.getIconForTag(name),
          title: Text(name),
          trailing: IconButton(
            icon: Icon(_expanded
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down),
            onPressed: () {
              if (mounted)
                setState(() {
                  _expanded = !_expanded;
                });
            },
          ),
        ),
        if (_expanded)
          ...widget.dataSource.allTags
              .where((e) => e.contains('$name/'))
              .map((e) => Container(
                    margin: const EdgeInsets.only(left: 20),
                    child: ListTile(
                      selected: widget.dataSource.selectedTag == widget.tag,
                      onTap: () => widget.dataSource.selectTag(widget.tag),
                      leading:
                          widget.dataSource.getIconForTag(e.split('/').last),
                      title: Text(e.split('/').last),
                    ),
                  ))
              .toList()
      ],
    );
  }
}
