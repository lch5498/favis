import 'package:flutter/cupertino.dart';

class RefreshableScrollView extends StatelessWidget {
  const RefreshableScrollView({
    super.key,
    required this.onRefresh,
    required this.children,
    this.padding = EdgeInsets.zero,
  });

  final Future<void> Function() onRefresh;
  final EdgeInsetsGeometry padding;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        CupertinoSliverRefreshControl(onRefresh: onRefresh),
        SliverPadding(
          padding: padding,
          sliver: SliverList.list(children: children),
        ),
      ],
    );
  }
}
