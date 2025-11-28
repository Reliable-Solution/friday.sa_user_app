import 'package:flutter/material.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/images.dart';
import 'package:friday_sa/common/widgets/custom_image.dart';

class StoreWiseBannerView extends StatelessWidget {
  const StoreWiseBannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeDefault,
        horizontal: Dimensions.paddingSizeSmall,
      ),
      child: Container(
        height: 135,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
          child: const CustomImage(
            image: Images.placeholder,
            fit: BoxFit.cover,
            height: 135,
            width: double.infinity,
          ),
        ),
      ),
    );
  }
}
