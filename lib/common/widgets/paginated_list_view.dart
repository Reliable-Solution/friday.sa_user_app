// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:friday_sa/helper/responsive_helper.dart';
// import 'package:friday_sa/util/dimensions.dart';
// import 'package:friday_sa/util/styles.dart';
//
// class PaginatedListView extends StatefulWidget {
//   const PaginatedListView({
//     super.key,
//     required this.scrollController,
//     required this.onPaginate,
//     required this.totalSize,
//     required this.offset,
//     required this.itemView,
//     this.enabledPagination = true,
//     this.reverse = false,
//   });
//   final ScrollController scrollController;
//   final Function(int? offset) onPaginate;
//   final int? totalSize;
//   final int? offset;
//   final Widget itemView;
//   final bool enabledPagination;
//   final bool reverse;
//
//   @override
//   State<PaginatedListView> createState() => _PaginatedListViewState();
// }
//
// class _PaginatedListViewState extends State<PaginatedListView> {
//   int? _offset;
//   late List<int?> _offsetList;
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _offset = 1;
//     _offsetList = [1];
//
//     widget.scrollController.addListener(() {
//       if (widget.scrollController.position.pixels ==
//               widget.scrollController.position.maxScrollExtent &&
//           widget.totalSize != null &&
//           !_isLoading &&
//           widget.enabledPagination) {
//         if (mounted && !ResponsiveHelper.isDesktop(context)) {
//           _paginate();
//         }
//       }
//     });
//   }
//
//   Future<void> _paginate() async {
//     int pageSize = (widget.totalSize! / 10).ceil();
//     if (_offset! < pageSize && !_offsetList.contains(_offset! + 1)) {
//       setState(() {
//         _offset = _offset! + 1;
//         _offsetList.add(_offset);
//         _isLoading = true;
//       });
//       await widget.onPaginate(_offset);
//       setState(() {
//         _isLoading = false;
//       });
//     } else {
//       if (_isLoading) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (widget.offset != null) {
//       _offset = widget.offset;
//       _offsetList = [];
//       for (int index = 1; index <= widget.offset!; index++) {
//         _offsetList.add(index);
//       }
//     }
//
//     // Calculate if there are more items to load
//     final hasMoreItems = widget.totalSize == null || _offset! < (widget.totalSize! / 10).ceil();
//     final showLoadingIndicator = _isLoading && hasMoreItems;
//     final showViewMore = ResponsiveHelper.isDesktop(context) &&
//                         hasMoreItems &&
//                         widget.totalSize != null &&
//                         !_isLoading;
//
//     return Column(
//       children: [
//         widget.reverse ? const SizedBox() : widget.itemView,
//
//         if (showLoadingIndicator || showViewMore)
//           Padding(
//             padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
//             child: showLoadingIndicator
//                 ? const Center(child: CircularProgressIndicator())
//                 : showViewMore
//                     ? InkWell(
//                         onTap: _paginate,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             vertical: Dimensions.paddingSizeSmall,
//                             horizontal: Dimensions.paddingSizeLarge,
//                           ),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
//                             color: Theme.of(context).primaryColor,
//                           ),
//                           child: Text(
//                             'view_more'.tr,
//                             style: robotoMedium.copyWith(
//                               fontSize: Dimensions.fontSizeLarge,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       )
//                     : const SizedBox(),
//           ),
//
//         widget.reverse ? widget.itemView : const SizedBox(),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:friday_sa/helper/responsive_helper.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/styles.dart';

class PaginatedListView extends StatefulWidget {
  const PaginatedListView({
    super.key,
    required this.scrollController,
    required this.onPaginate,
    required this.totalSize,
    required this.offset,
    required this.itemView,
    this.enabledPagination = true,
    this.reverse = false,
  });
  final ScrollController scrollController;
  final Function(int? offset) onPaginate;
  final int? totalSize;
  final int? offset;
  final Widget itemView;
  final bool enabledPagination;
  final bool reverse;

  @override
  State<PaginatedListView> createState() => _PaginatedListViewState();
}

class _PaginatedListViewState extends State<PaginatedListView> {
  int? _offset;
  late List<int?> _offsetList;
  bool _isLoading = false;

  // @override
  // void initState() {
  //   super.initState();
  //
  //   _offset = 1;
  //   _offsetList = [1];
  //
  //   // widget.scrollController.addListener(() {
  //   //   if (widget.scrollController.position.pixels ==
  //   //       widget.scrollController.position.maxScrollExtent
  //   //   // &&
  //   //       // widget.totalSize != null &&
  //   //       // !_isLoading &&
  //   //       // widget.enabledPagination
  //   //   ) {
  //   //     if (mounted && !ResponsiveHelper.isDesktop(context)) {
  //   //       _paginate();
  //   //     }
  //   //   }
  //   // });
  //
  //   widget.scrollController.addListener(() {
  //     final scrollPosition = widget.scrollController.position;
  //     final maxScroll = scrollPosition.maxScrollExtent;
  //     final currentScroll = scrollPosition.pixels;
  //     final screenHeight = MediaQuery.of(context).size.height;
  //
  //     // Trigger pagination when within ~70% of the screen height from the bottom
  //     if (currentScroll > maxScroll - (screenHeight * 0.7)) {
  //       if (mounted && !ResponsiveHelper.isDesktop(context)) {
  //         _paginate();
  //       }
  //     }
  //   });
  // }

  @override
  void initState() {
    super.initState();

    _offset = widget.offset ?? 1;
    _offsetList = List.generate(_offset!, (i) => i + 1);

    // Use a proper scroll listener with safety checks
    widget.scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (!widget.enabledPagination ||
        _isLoading ||
        ResponsiveHelper.isDesktop(context) ||
        !widget.scrollController.hasClients) {
      return;
    }

    final position = widget.scrollController.position;
    final maxScroll = position.maxScrollExtent;
    final currentScroll = position.pixels;

    // Trigger when user has scrolled to ~80% from the bottom (adjust 0.8 as needed)
    final threshold = position.viewportDimension * 0.8; // 80% of visible screen
    final distanceFromBottom = maxScroll - currentScroll;

    if (distanceFromBottom <= threshold) {
      // Only trigger if we haven't requested this page yet
      final int pageSize = widget.totalSize != null
          ? (widget.totalSize! / 10).ceil()
          : _offset! + 5; // fallback

      if (_offset! < pageSize && !_offsetList.contains(_offset! + 1)) {
        _paginate(); // This will only run ONCE per page
      }
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  Future<void> _paginate() async {
    int pageSize = (widget.totalSize! / 10).ceil();
    print("====> Pagination ${_offset }. && ${pageSize}");
    if (_offset! < pageSize && !_offsetList.contains(_offset! + 1)) {
      setState(() {
        _offset = _offset! + 1;
        _offsetList.add(_offset);
        _isLoading = true;
      });
      await widget.onPaginate(_offset);
      setState(() {
        _isLoading = false;
      });
    } else {
      if (_isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.offset != null) {
      _offset = widget.offset;
      _offsetList = [];
      for (int index = 1; index <= widget.offset!; index++) {
        _offsetList.add(index);
      }
    }

    return Column(
      children: [
        widget.reverse ? const SizedBox() : widget.itemView,
        (ResponsiveHelper.isDesktop(context) &&
            (widget.totalSize == null ||
                _offset! >= (widget.totalSize! / 10).ceil() ||
                _offsetList.contains(_offset! + 1)))
            ? const SizedBox()
            : Center(
          child: Padding(
            padding: (_isLoading || ResponsiveHelper.isDesktop(context))
                ? const EdgeInsets.all(Dimensions.paddingSizeSmall)
                : EdgeInsets.zero,
            child: _isLoading
                ? const CircularProgressIndicator()
                : (ResponsiveHelper.isDesktop(context) &&
                widget.totalSize != null)
                ? InkWell(
              onTap: _paginate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeSmall,
                  horizontal: Dimensions.paddingSizeLarge,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    Dimensions.radiusSmall,
                  ),
                  color: Theme.of(context).primaryColor,
                ),
                child: Text(
                  'view_more'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Colors.white,
                  ),
                ),
              ),
            )
                : const SizedBox(),
          ),
        ),
        widget.reverse ? widget.itemView : const SizedBox(),
      ],
    );
  }


}
