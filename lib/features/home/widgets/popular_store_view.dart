import 'package:friday_sa/features/store/controllers/store_controller.dart';
import 'package:friday_sa/features/splash/controllers/splash_controller.dart';
import 'package:friday_sa/common/widgets/item_view.dart';
import 'package:friday_sa/common/widgets/title_widget.dart';
import 'package:friday_sa/helper/route_helper.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/app_constants.dart';
import 'package:friday_sa/features/store/domain/models/store_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PopularStoreView extends StatelessWidget {
  const PopularStoreView({
    super.key,
    required this.isPopular,
    required this.isFeatured,
    this.isTopOfferStore = false,
  });
  final bool isPopular;
  final bool isFeatured;
  final bool isTopOfferStore;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(
      builder: (storeController) {
        /*
        // --- PURANA HORIZONTAL LIST WALA CODE (COMMENTED) ---
        List<Store>? storeList = isFeatured
            ? storeController.featuredStoreList
            : isPopular
            ? storeController.popularStoreList
            : storeController.latestStoreList;

        return (storeList != null && storeList.isEmpty)
            ? const SizedBox()
            : Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(10, isPopular ? 2 : 15, 10, 10),
              child: TitleWidget(
                title: isFeatured
                    ? 'featured_stores'.tr
                    : isPopular
                    ? Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
                    ? 'popular_restaurants'.tr
                    : 'popular_stores'.tr
                    : '${'new_on'.tr} ${AppConstants.appName}',
                onTap: () => Get.toNamed(
                  RouteHelper.getAllStoreRoute(
                    isFeatured ? 'featured' : isPopular ? 'popular' : 'latest',
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 190,
              child: storeList != null
                  ? ListView.builder(
                itemCount: storeList.length > 10 ? 10 : storeList.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                   // ... Old List Item UI ...
                },
              ) : const SizedBox(),
            ),
          ],
        );
        */

        List<Store>? storeList = isFeatured
            ? storeController.featuredStoreList
            : isPopular
            ? storeController.popularStoreList
            : isTopOfferStore
            ? storeController.topOfferStoreList
            : storeController.latestStoreList;

        return (storeList != null && storeList.isEmpty)
            ? const SizedBox()
            : Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      10,
                      isPopular ? 2 : 15,
                      10,
                      10,
                    ),
                    child: TitleWidget(
                      title: isFeatured
                          ? 'featured_stores'.tr
                          : isPopular
                          ? Get.find<SplashController>()
                                    .configModel!
                                    .moduleConfig!
                                    .module!
                                    .showRestaurantText!
                                ? 'popular_restaurants'.tr
                                : 'popular_stores'.tr
                          : isTopOfferStore
                          ? 'top_offers_near_me'.tr
                          : '${'new_on'.tr} ${AppConstants.appName}',
                      onTap: () => Get.toNamed(
                        RouteHelper.getAllStoreRoute(
                          isFeatured
                              ? 'featured'
                              : isPopular
                              ? 'popular'
                              : isTopOfferStore
                              ? 'top_offer'
                              : 'latest',
                        ),
                      ),
                    ),
                  ),

                  ItemsView(
                    isStore: true,
                    items: null,
                    isFeatured: isFeatured,
                    noDataText: isFeatured
                        ? 'no_store_available'.tr
                        : Get.find<SplashController>()
                              .configModel!
                              .moduleConfig!
                              .module!
                              .showRestaurantText!
                        ? 'no_restaurant_available'.tr
                        : 'no_store_available'.tr,
                    stores: storeList,
                  ),
                ],
              );
      },
    );
  }
}
