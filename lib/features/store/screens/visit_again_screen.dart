import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:friday_sa/features/store/controllers/store_controller.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/common/widgets/custom_app_bar.dart';
import 'package:friday_sa/common/widgets/footer_view.dart';
import 'package:friday_sa/common/widgets/item_view.dart';
import 'package:friday_sa/common/widgets/menu_drawer.dart';
import 'package:friday_sa/common/widgets/web_page_title_widget.dart';

class VisitAgainScreen extends StatefulWidget {
  const VisitAgainScreen({super.key});

  @override
  State<VisitAgainScreen> createState() => _VisitAgainScreenState();
}

class _VisitAgainScreenState extends State<VisitAgainScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Get.find<StoreController>().getVisitAgainStoreList(fromModule: false);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(
      builder: (storeController) {
        return Scaffold(
          appBar: CustomAppBar(
            title: 'visit_again'.tr,
          ),
          endDrawer: const MenuDrawer(),
          endDrawerEnableOpenDragGesture: false,
          body: RefreshIndicator(
            onRefresh: () async {
              await Get.find<StoreController>().getVisitAgainStoreList(
                fromModule: false,
              );
            },
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: FooterView(
                child: Column(
                  children: [
                    WebScreenTitleWidget(
                      title: 'visit_again'.tr,
                    ),
                    SizedBox(
                      width: Dimensions.webMaxWidth,
                      child: ItemsView(
                        isStore: true,
                        items: null,
                        stores: storeController.visitAgainStoreList,
                        noDataText: 'no_store_available'.tr,
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeExtraSmall,
                          vertical: Dimensions.paddingSizeDefault,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
