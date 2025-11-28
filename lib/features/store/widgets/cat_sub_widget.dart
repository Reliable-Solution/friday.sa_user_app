import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:friday_sa/common/widgets/custom_image.dart';
import 'package:friday_sa/helper/string_extension.dart';
import 'package:friday_sa/util/dimensions.dart';

import '../../../util/styles.dart';
import '../../category/controllers/category_controller.dart';
import '../controllers/store_controller.dart';

class CatSubCategoryWidget extends StatelessWidget {
  const CatSubCategoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(
      builder: (storeController) {
        "===> storeController.categoryList #${storeController.categoryList}"
            .print;
        return GetBuilder<CategoryController>(
          builder: (categoryController) {
            return Column(
              spacing: 10,
              children: [
                if (storeController.categoryList.isNotEmpty)
                  SizedBox(
                    height: 70,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: storeController.categoryList.length,
                      padding: const EdgeInsets.only(
                        left: Dimensions.paddingSizeSmall,
                      ),
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () => storeController.setCategoryIndex(index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall,
                              vertical: Dimensions.paddingSizeExtraSmall,
                            ),
                            margin: const EdgeInsets.only(
                              right: Dimensions.paddingSizeSmall,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusDefault,
                              ),
                              color: index == storeController.categoryIndex
                                  ? Theme.of(
                                      context,
                                    ).primaryColor.withValues(alpha: 0.1)
                                  : Colors.transparent,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                if (storeController
                                        .categoryList[index]
                                        .imageFullUrl
                                        ?.isNotEmpty ??
                                    false)
                                  CustomImage(
                                    image: storeController
                                        .categoryList[index]
                                        .imageFullUrl!,
                                    height: 30,
                                    width: 30,
                                    fit: BoxFit.cover,
                                  ),
                                Text(
                                  storeController.categoryList[index].name!,
                                  style: index == storeController.categoryIndex
                                      ? robotoMedium.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: Theme.of(context).primaryColor,
                                        )
                                      : robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                        ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                if (storeController.isSubCatLoad ||
                    storeController.subCategoryList.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(
                      left: storeController.isSubCatLoad ? 0 : 20,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 10,
                      children: [
                        if (storeController.subCategoryList.isNotEmpty)
                          // Text(
                          //   'category'.tr,
                          //   style: const TextStyle(fontWeight: FontWeight.w500),
                          // ),
                        Expanded(
                          child: SizedBox(
                            height: 30,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: storeController.isSubCatLoad
                                  ? 10
                                  : storeController.subCategoryList.length,
                              padding: const EdgeInsets.only(
                                left: Dimensions.paddingSizeSmall,
                              ),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return storeController.isSubCatLoad
                                    ? Container(
                                        height: 35,
                                        width: 50,
                                        alignment: Alignment.center,
                                        margin: const EdgeInsets.only(
                                          right: Dimensions.paddingSizeSmall,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            Dimensions.radiusDefault,
                                          ),
                                          color: Colors.black.withValues(
                                            alpha: .05,
                                          ),
                                        ),
                                      )
                                    : InkWell(
                                        onTap: () => storeController
                                            .setSubCategoryIndex(index),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                Dimensions.paddingSizeSmall,
                                            vertical: Dimensions
                                                .paddingSizeExtraSmall,
                                          ),
                                          alignment: Alignment.center,
                                          margin: const EdgeInsets.only(
                                            right: Dimensions.paddingSizeSmall,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              Dimensions.radiusDefault,
                                            ),
                                            color:
                                                index ==
                                                    storeController
                                                        .subCategoryIndex
                                                ? Theme.of(context).primaryColor
                                                      .withValues(alpha: 0.1)
                                                : Colors.transparent,
                                          ),
                                          child: Text(
                                            storeController
                                                .subCategoryList[index]
                                                .name!,
                                            style:
                                                index ==
                                                    storeController
                                                        .subCategoryIndex
                                                ? robotoMedium.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeSmall,
                                                    color: Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                  )
                                                : robotoRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeSmall,
                                                  ),
                                          ),
                                        ),
                                      );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
