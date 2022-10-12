import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class InfiniteScrollingList<T> extends StatefulWidget {
  const InfiniteScrollingList({required this.builder, required this.fetch, super.key});

  final Widget Function(BuildContext context, T item) builder;
  final Future<List<T>> Function(int amount, int offset) fetch;

  @override
  State<InfiniteScrollingList<T>> createState() => _InfiniteScrollingListState<T>();
}

class _InfiniteScrollingListState<T> extends State<InfiniteScrollingList<T>> {
  static const _pageSize = 20;

  final PagingController<int, T> _pagingController = PagingController(firstPageKey: 0);

  @override
  void initState() {
    print("init");
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      print("fetch");
      print("pageKey ${pageKey}");
      final newItems = await widget.fetch(_pageSize, pageKey);
      print('newItems: ${newItems}');
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      print(error);
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: PagedListView<int, T>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<T>(
          itemBuilder: (context, item, index) => widget.builder(context, item),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
