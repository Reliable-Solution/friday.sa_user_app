import 'package:friday_sa/features/splash/controllers/splash_controller.dart';
import 'package:friday_sa/features/order/domain/models/order_model.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/images.dart';
import 'package:friday_sa/util/styles.dart';
import 'package:friday_sa/common/widgets/custom_divider.dart';
import 'package:friday_sa/common/widgets/custom_image.dart';
import 'package:friday_sa/common/widgets/custom_snackbar.dart';
import 'package:friday_sa/common/widgets/rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:friday_sa/features/order/widgets/address_details_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TrackDetailsViewWidget extends StatelessWidget {
  const TrackDetailsViewWidget({
    super.key,
    required this.track,
    required this.status,
    this.callback,
    required this.showChatPermission,
  });
  final String? status;
  final OrderModel track;
  final Function? callback;
  final bool showChatPermission;

  @override
  Widget build(BuildContext context) {
    num distance = 0;
    bool takeAway = track.orderType == 'take_away';
    if (track.deliveryMan != null) {
      distance =
          Geolocator.distanceBetween(
            double.parse(track.deliveryAddress!.latitude!),
            double.parse(track.deliveryAddress!.longitude!),
            double.parse(track.deliveryMan!.lat ?? '0'),
            double.parse(track.deliveryMan!.lng ?? '0'),
          ) /
          1000;
    }

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        color: Theme.of(context).cardColor,
      ),
      alignment: Alignment.center,
      child: (!takeAway && track.deliveryMan == null)
          ? Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Text(
                'delivery_man_not_assigned'.tr,
                style: robotoMedium,
                textAlign: TextAlign.center,
              ),
            )
          : takeAway
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Get.find<SplashController>()
                              .configModel!
                              .moduleConfig!
                              .module!
                              .showRestaurantText!
                          ? 'restaurant_details'.tr
                          : 'store_details'.tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Row(
                      children: [
                        ClipOval(
                          child: CustomImage(
                            image: '${track.store != null ? track.store!.logoFullUrl : ''}',
                            height: 40,
                            width: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                track.store != null ? track.store!.name! : '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                track.store != null ? track.store!.address! : '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeExtraSmall,
                                  color: Theme.of(context).disabledColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              RatingBar(
                                rating: track.store?.avgRating?.toDouble(),
                                size: 12,
                                ratingCount: track.store?.ratingCount,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              if (track.store?.phone != null &&
                                  await canLaunchUrlString('tel:${track.store!.phone}')) {
                                launchUrlString(
                                  'tel:${track.store!.phone}',
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                color: Colors.green.withValues(alpha: 0.1),
                                border: Border.all(color: Colors.green, width: 1),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.phone, color: Colors.green, size: 18),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  Text(
                                    'call'.tr,
                                    style: robotoMedium.copyWith(color: Colors.green, fontSize: Dimensions.fontSizeSmall),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (showChatPermission) ...[
                          const SizedBox(width: Dimensions.paddingSizeDefault),
                          Expanded(
                            child: InkWell(
                              onTap: callback as void Function()?,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                  border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                                  ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.chat, color: Theme.of(context).primaryColor, size: 18),
                                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                    Text(
                                      'chat'.tr,
                                      style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                )
              : Column(
                  children: [
                    Text('trip_route'.tr, style: robotoMedium),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        takeAway
                            ? track.deliveryAddress?.address ?? ''
                            : track.deliveryMan?.location ?? '',
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    SizedBox(
                      width: 80,
                      child: CustomDivider(
                        color: Theme.of(context).primaryColor,
                        height: 2,
                      ),
                    ),
                    Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Expanded(
                      flex: 5,
                      child: (takeAway && track.orderType != 'parcel')
                          ? Text(
                              track.store != null ? track.store!.address! : '',
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          : (track.orderType == 'parcel' &&
                                status == 'picked_up')
                          ? AddressDetailsWidget(
                              addressDetails: track.receiverDetails,
                            )
                          : AddressDetailsWidget(
                              addressDetails: track.deliveryAddress,
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                takeAway
                    ? InkWell(
                        onTap: () async {
                          String url =
                              'https://www.google.com/maps/dir/?api=1&destination=${track.store != null ? track.store!.latitude : ''}'
                              ',${track.store != null ? track.store!.longitude : ''}&mode=d';
                          if (await canLaunchUrlString(url)) {
                            await launchUrlString(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          } else {
                            showCustomSnackBar(
                              'unable_to_launch_google_map'.tr,
                            );
                          }
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.directions,
                              size: 25,
                              color: Theme.of(context).primaryColor,
                            ),
                            Text(
                              'direction'.tr,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall,
                                color: Theme.of(context).disabledColor,
                              ),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          Image.asset(
                            Images.route,
                            height: 20,
                            width: 20,
                            color: Theme.of(context).primaryColor,
                          ),
                          Text(
                            '${distance.toStringAsFixed(2)} ${'km'.tr}',
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                        ],
                      ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    takeAway
                        ? Get.find<SplashController>()
                                  .configModel!
                                  .moduleConfig!
                                  .module!
                                  .showRestaurantText!
                              ? 'store'.tr
                              : 'store'.tr
                        : 'delivery_man'.tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Row(
                  children: [
                    ClipOval(
                      child: CustomImage(
                        image:
                            '${takeAway ? (track.store != null ? track.store!.logoFullUrl : '') : track.deliveryMan!.imageFullUrl}',
                        height: 35,
                        width: 35,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            takeAway
                                ? track.store != null
                                      ? track.store!.name!
                                      : ''
                                : '${track.deliveryMan!.fName} ${track.deliveryMan!.lName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                            ),
                          ),
                          RatingBar(
                            rating:
                                (takeAway
                                        ? track.store != null
                                              ? track.store!.avgRating
                                              : '' as num?
                                        : track.deliveryMan!.avgRating)
                                    ?.toDouble(),
                            size: 10,
                            ratingCount: takeAway
                                ? track.store != null
                                      ? track.store!.ratingCount
                                      : '' as int?
                                : track.deliveryMan!.ratingCount,
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        if (await canLaunchUrlString(
                          'tel:${takeAway
                              ? track.store != null
                                    ? track.store!.phone
                                    : ''
                              : track.deliveryMan!.phone}',
                        )) {
                          launchUrlString(
                            'tel:${takeAway
                                ? track.store != null
                                      ? track.store!.phone
                                      : ''
                                : track.deliveryMan!.phone}',
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          showCustomSnackBar(
                            '${'can_not_launch'.tr} ${takeAway
                                ? track.store != null
                                      ? track.store!.phone
                                      : ''
                                : track.deliveryMan!.phone}',
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeExtraSmall,
                          horizontal: Dimensions.paddingSizeSmall,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusSmall,
                          ),
                          color: Colors.green,
                        ),
                        child: Text(
                          'call'.tr,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Theme.of(context).cardColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    showChatPermission
                        ? InkWell(
                            onTap: callback as void Function()?,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: Get.context!.width >= 1300
                                    ? 7
                                    : Dimensions.paddingSizeExtraSmall,
                                horizontal: Dimensions.paddingSizeSmall,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusSmall,
                                ),
                                color: Colors.green,
                              ),
                              child: Icon(
                                Icons.chat,
                                size: 12,
                                color: Theme.of(context).cardColor,
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ],
            ),
    );
  }
}
