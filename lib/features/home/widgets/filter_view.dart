import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:friday_sa/features/store/controllers/store_controller.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/styles.dart';

class FilterView extends StatelessWidget {
  const FilterView({super.key, required this.storeController});
  final StoreController storeController;

  @override
  Widget build(BuildContext context) {
    return storeController.storeModel != null
        ? PopupMenuButton(
            padding: EdgeInsets.zero,
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: 'all',
                  child: Text(
                    'all'.tr,
                    style: robotoMedium.copyWith(
                      color: storeController.filterType == 'all'
                          ? Theme.of(context).textTheme.bodyLarge!.color
                          : Theme.of(context).disabledColor,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'take_away',
                  child: Text(
                    'take_away'.tr,
                    style: robotoMedium.copyWith(
                      color: storeController.filterType == 'take_away'
                          ? Theme.of(context).textTheme.bodyLarge!.color
                          : Theme.of(context).disabledColor,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'delivery',
                  child: Text(
                    'delivery'.tr,
                    style: robotoMedium.copyWith(
                      color: storeController.filterType == 'delivery'
                          ? Theme.of(context).textTheme.bodyLarge!.color
                          : Theme.of(context).disabledColor,
                    ),
                  ),
                ),
              ];
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  border: Border.all(color: Theme.of(context).primaryColor),
                ),
                child: Icon(
                  Icons.filter_list,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            onSelected: (dynamic value) => storeController.setFilterType(value),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                border: Border.all(color: Theme.of(context).disabledColor),
              ),
              child: Icon(
                Icons.filter_list,
                color: Theme.of(context).disabledColor,
              ),
            ),
          );
  }
}
