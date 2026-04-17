import 'package:shimmer_animation/shimmer_animation.dart';

import 'package:friday_sa/features/store/controllers/store_controller.dart';
import 'package:friday_sa/features/store/domain/models/store_model.dart';
import 'package:friday_sa/features/home/widgets/components/popular_store_card_widget.dart';
import 'package:friday_sa/helper/route_helper.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/common/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PopularStoreView extends StatelessWidget {
  const PopularStoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeDefault,
      ),
      child: GetBuilder<StoreController>(
        builder: (storeController) {
          List<Store>? storeList = storeController.popularStoreList;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: Dimensions.paddingSizeDefault,
                  right: Dimensions.paddingSizeDefault,
                  bottom: Dimensions.paddingSizeDefault,
                ),
                child: TitleWidget(
                  title: 'popular_stores'.tr,
                  onTap: () =>
                      Get.toNamed(RouteHelper.getAllStoreRoute('popular')),
                ),
              ),
              SizedBox(
                height: 170,
                child: storeList != null
                    ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: storeList.length,
                        padding: const EdgeInsets.only(
                          left: Dimensions.paddingSizeDefault,
                        ),
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              right: Dimensions.paddingSizeDefault,
                              bottom: Dimensions.paddingSizeExtraSmall,
                            ),
                            child: PopularStoreCard(store: storeList[index]),
                          );
                        },
                      )
                    : const PopularStoreShimmer(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class PopularStoreShimmer extends StatelessWidget {
  const PopularStoreShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemCount: 10,
      padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(
            right: Dimensions.paddingSizeDefault,
            bottom: Dimensions.paddingSizeExtraSmall,
          ),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: true,
            child: Container(
              height: 170,
              width: 260,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
            ),
          ),
        );
      },
    );
  }
}
