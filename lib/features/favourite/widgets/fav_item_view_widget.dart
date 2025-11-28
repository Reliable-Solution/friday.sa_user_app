import 'package:friday_sa/features/favourite/controllers/favourite_controller.dart';
import 'package:friday_sa/helper/responsive_helper.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/common/widgets/footer_view.dart';
import 'package:friday_sa/common/widgets/item_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavItemViewWidget extends StatelessWidget {
  const FavItemViewWidget({
    super.key,
    required this.isStore,
    this.isSearch = false,
  });
  final bool isStore;
  final bool isSearch;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<FavouriteController>(
        builder: (favouriteController) {
          return RefreshIndicator(
            onRefresh: () async {
              await favouriteController.getFavouriteList();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: FooterView(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: ResponsiveHelper.isDesktop(context) ? 0 : 80.0,
                    ),
                    child: ItemsView(
                      isStore: isStore,
                      items: favouriteController.wishItemList,
                      stores: favouriteController.wishStoreList,
                      noDataText: 'no_wish_data_found'.tr,
                      isFeatured: true,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
