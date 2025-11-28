import 'package:friday_sa/features/search/controllers/search_controller.dart'
    as search;
import 'package:friday_sa/helper/responsive_helper.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/common/widgets/footer_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:friday_sa/common/widgets/item_view.dart';
import 'package:friday_sa/common/widgets/web_item_view.dart';

class ItemViewWidget extends StatelessWidget {
  const ItemViewWidget({super.key, required this.isItem});
  final bool isItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<search.SearchController>(
        builder: (searchController) {
          return SingleChildScrollView(
            child: FooterView(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: ResponsiveHelper.isDesktop(context)
                    ? WebItemsView(
                        isStore: isItem,
                        items: searchController.searchItemList,
                        stores: searchController.searchStoreList,
                      )
                    : ItemsView(
                        isStore: isItem,
                        items: searchController.searchItemList,
                        stores: searchController.searchStoreList,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
