import 'package:flutter/cupertino.dart';
import 'package:friday_sa/features/review/controllers/review_controller.dart';
import 'package:friday_sa/features/review/widgets/review_widget.dart';
import 'package:flutter/material.dart';
import 'package:friday_sa/helper/responsive_helper.dart';

class ReviewListWidget extends StatelessWidget {
  const ReviewListWidget({
    super.key,
    required this.reviewController,
    this.storeName,
  });
  final ReviewController reviewController;
  final String? storeName;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: reviewController.storeReviewList!.length,
      physics: ResponsiveHelper.isDesktop(context)
          ? const ScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.isDesktop(context) ? 40 : 0,
      ),
      itemBuilder: (context, index) {
        return ReviewWidget(
          review: reviewController.storeReviewList![index],
          hasDivider: index != reviewController.storeReviewList!.length - 1,
          storeName: storeName,
        );
      },
    );
  }
}
