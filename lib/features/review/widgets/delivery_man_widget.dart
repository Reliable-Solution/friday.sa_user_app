import 'package:friday_sa/features/order/domain/models/order_model.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/styles.dart';
import 'package:friday_sa/common/widgets/custom_image.dart';
import 'package:friday_sa/common/widgets/rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeliveryManWidget extends StatelessWidget {
  const DeliveryManWidget({super.key, required this.deliveryMan});
  final DeliveryMan? deliveryMan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[Get.isDarkMode ? 700 : 300]!,
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'delivery_man'.tr,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
            ),
          ),
          ListTile(
            leading: ClipOval(
              child: CustomImage(
                image: '${deliveryMan!.imageFullUrl}',
                height: 40,
                width: 40,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              '${deliveryMan!.fName} ${deliveryMan!.lName}',
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
            ),
            subtitle: RatingBar(
              rating: deliveryMan!.avgRating?.toDouble(),
              size: 15,
              ratingCount: deliveryMan!.ratingCount ?? 0,
            ),
          ),
        ],
      ),
    );
  }
}
