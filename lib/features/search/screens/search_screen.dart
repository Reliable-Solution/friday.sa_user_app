import 'package:flutter/cupertino.dart';
import 'package:friday_sa/common/controllers/theme_controller.dart';
import 'package:friday_sa/common/widgets/custom_asset_image_widget.dart';
import 'package:friday_sa/common/widgets/custom_ink_well.dart';
import 'package:friday_sa/features/cart/controllers/cart_controller.dart';
import 'package:friday_sa/features/item/controllers/item_controller.dart';
import 'package:friday_sa/features/search/controllers/search_controller.dart'
    as search;
import 'package:friday_sa/features/splash/controllers/splash_controller.dart';
import 'package:friday_sa/helper/auth_helper.dart';
import 'package:friday_sa/helper/responsive_helper.dart';
import 'package:friday_sa/util/dimensions.dart';
import 'package:friday_sa/util/images.dart';
import 'package:friday_sa/util/styles.dart';
import 'package:friday_sa/common/widgets/custom_image.dart';
import 'package:friday_sa/common/widgets/custom_snackbar.dart';
import 'package:friday_sa/common/widgets/footer_view.dart';
import 'package:friday_sa/common/widgets/menu_drawer.dart';
import 'package:friday_sa/common/widgets/web_menu_bar.dart';
import 'package:friday_sa/features/search/widgets/filter_widget.dart';
import 'package:friday_sa/features/search/widgets/search_field_widget.dart';
import 'package:friday_sa/features/search/widgets/search_result_widget.dart';
import 'package:friday_sa/features/search/domain/models/popular_categories_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:friday_sa/features/store/widgets/bottom_cart_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.queryText});
  final String? queryText;

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;

  final TextEditingController _searchController = TextEditingController();
  late bool _isLoggedIn;

  List<String> _itemsAndStors = <String>[];
  bool _showSuggestion = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    _isLoggedIn = AuthHelper.isLoggedIn();
    Get.find<search.SearchController>().setSearchMode(true, canUpdate: false);
    Get.find<search.SearchController>().getPopularCategories();
    if (_isLoggedIn) {
      Get.find<search.SearchController>().getSuggestedItems();
    }
    Get.find<search.SearchController>().getHistoryList();
    if (widget.queryText!.isNotEmpty) {
      _actionSearch(true, widget.queryText, true);
    }
  }

  Future<void> _searchSuggestions(String query) async {
    _itemsAndStors = [];
    if (query == '') {
      _showSuggestion = false;
      _itemsAndStors = [];
    } else {
      _showSuggestion = true;
      _itemsAndStors = await Get.find<search.SearchController>()
          .getSearchSuggestions(query);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (Get.find<search.SearchController>().isSearchMode) {
          return;
        } else {
          Get.find<search.SearchController>().setSearchMode(true);
        }
      },
      child: Scaffold(
        appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
        endDrawer: const MenuDrawer(),
        endDrawerEnableOpenDragGesture: false,
        body: SafeArea(
          child: GetBuilder<search.SearchController>(
            builder: (searchController) {
              if (!GetPlatform.isWeb) {
                _searchController.text = searchController.searchText!;
              }
              return Column(
                children: [
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  // --- SEARCH BAR ---
                  Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                      ),
                      child: SearchFieldWidget(
                        controller: _searchController,
                        radius: Dimensions.radiusLarge,
                        filledColor: Colors.transparent,
                        hint: 'search_item_or_store'.tr,
                        prefixIcon: CupertinoIcons.search,
                        suffixIcon: _searchController.text.isNotEmpty ? Icons.clear : null,
                        iconPressed: () {
                          _searchController.text = '';
                          searchController.setSearchText('');
                          searchController.setSearchMode(true);
                        },
                        onChanged: (text) {
                          searchController.setSearchText(text);
                          _searchSuggestions(text);
                        },
                        onSubmit: (text) => _actionSearch(true, text.trim(), false),
                      ),
                    ),
                  ),

                  Expanded(
                    child: searchController.isSearchMode
                        ? _showSuggestion
                              ? showSuggestions(context, searchController, _itemsAndStors)
                              : SingleChildScrollView(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                  child: FooterView(
                                    child: SizedBox(
                                      width: Dimensions.webMaxWidth,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          
                                          // --- SEARCH HISTORY ---
                                          if (searchController.historyList.isNotEmpty) ...[
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'recent_searches'.tr,
                                                  style: robotoBold.copyWith(fontSize: 15, color: Theme.of(context).primaryColor),
                                                ),
                                                InkWell(
                                                  onTap: () => searchController.clearSearchHistory(),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(5.0),
                                                    child: Text(
                                                      'clear_all'.tr,
                                                      style: robotoMedium.copyWith(fontSize: 12, color: Theme.of(context).disabledColor),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            GridView.builder(
                                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                childAspectRatio: 2.5,
                                                mainAxisSpacing: 8,
                                                crossAxisSpacing: 8,
                                              ),
                                              physics: const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: searchController.historyList.length > 4 ? 4 : searchController.historyList.length,
                                              itemBuilder: (context, index) {
                                                return _buildHistoryCard(context, searchController.historyList[index], searchController);
                                              },
                                            ),
                                            const SizedBox(height: 20),
                                          ],

                                          // --- RECOMMENDED SEARCHES ---
                                          if (_isLoggedIn && searchController.suggestedItemList != null && searchController.suggestedItemList!.isNotEmpty) ...[
                                            Text(
                                              'suggestions'.tr,
                                              style: robotoBold.copyWith(fontSize: 15, color: Theme.of(context).primaryColor),
                                            ),
                                            const SizedBox(height: 10),
                                            GridView.builder(
                                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                childAspectRatio: 2.5,
                                                mainAxisSpacing: 8,
                                                crossAxisSpacing: 8,
                                              ),
                                              physics: const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: searchController.suggestedItemList!.length > 4 ? 4 : searchController.suggestedItemList!.length,
                                              itemBuilder: (context, index) {
                                                return _buildSearchCard(context, searchController.suggestedItemList![index]);
                                              },
                                            ),
                                            const SizedBox(height: 20),
                                          ],

                                          // --- POPULAR SEARCHES ---
                                          if (searchController.popularCategoryList != null && searchController.popularCategoryList!.isNotEmpty) ...[
                                            Text(
                                              'popular_categories'.tr,
                                              style: robotoBold.copyWith(fontSize: 15, color: Theme.of(context).primaryColor),
                                            ),
                                            const SizedBox(height: 10),
                                            GridView.builder(
                                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                childAspectRatio: 2.5,
                                                mainAxisSpacing: 8,
                                                crossAxisSpacing: 8,
                                              ),
                                              physics: const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: searchController.popularCategoryList!.length > 6 ? 6 : searchController.popularCategoryList!.length,
                                              itemBuilder: (context, index) {
                                                return _buildCategoryCard(context, searchController.popularCategoryList![index]!);
                                              },
                                            ),
                                          ],
                                          
                                          const SizedBox(height: 20),
                                        ],
                                      ),
                                    ),
                                  )
                                )
                          : SearchResultWidget(
                              searchText: _searchController.text.trim(),
                              tabController: ResponsiveHelper.isDesktop(context)
                                  ? _tabController
                                  : null,
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        bottomNavigationBar: GetBuilder<CartController>(
          builder: (cartController) {
            return cartController.cartList.isNotEmpty &&
                    !ResponsiveHelper.isDesktop(context)
                ? const BottomCartWidget()
                : const SizedBox();
          },
        ),
      ),
    );
  }

  void searchData() {
    if (_searchController.text.trim().isEmpty) {
      showCustomSnackBar(
        Get.find<SplashController>()
                .configModel!
                .moduleConfig!
                .module!
                .showRestaurantText!
            ? 'search_food_or_restaurant'.tr
            : 'search_item_or_store'.tr,
      );
    } else {
      _actionSearch(true, _searchController.text, true);
    }
  }

  void _actionSearch(bool isSubmit, String? queryText, bool fromHome) {
    if (Get.find<search.SearchController>().isSearchMode || isSubmit) {
      if (queryText!.isNotEmpty) {
        Get.find<search.SearchController>().searchData(queryText, fromHome);
      } else {
        showCustomSnackBar(
          Get.find<SplashController>()
                  .configModel!
                  .moduleConfig!
                  .module!
                  .showRestaurantText!
              ? 'search_food_or_restaurant'.tr
              : 'search_item_or_store'.tr,
        );
      }
    } else {
      List<num?> prices = [];
      if (!Get.find<search.SearchController>().isStore) {
        for (var product in Get.find<search.SearchController>().allItemList!) {
          prices.add(product.price);
        }
        prices.sort();
      }
      num? maxValue = prices.isNotEmpty ? prices[prices.length - 1] : 1000;
      Get.dialog(
        FilterWidget(
          maxValue: maxValue,
          isStore: Get.find<search.SearchController>().isStore,
        ),
      );
    }
  }

  Widget showSuggestions(
    BuildContext context,
    search.SearchController searchController,
    List<String> foodsAndRestaurants,
  ) {
    return SingleChildScrollView(
      child: FooterView(
        child: SizedBox(
          width: Dimensions.webMaxWidth,
          child: foodsAndRestaurants.isNotEmpty
              ? ListView.builder(
                  itemCount: foodsAndRestaurants.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(foodsAndRestaurants[index]),
                      leading: Icon(
                        CupertinoIcons.search,
                        color: Theme.of(context).disabledColor,
                      ),
                      trailing: Icon(
                        Icons.north_west,
                        color: Theme.of(context).disabledColor,
                      ),
                      onTap: () async {
                        FocusScope.of(context).unfocus();
                        _searchController.text = foodsAndRestaurants[index];
                        _actionSearch(
                          true,
                          _searchController.text.trim(),
                          false,
                        );
                      },
                    );
                  },
                )
              : Padding(
                  padding: EdgeInsets.only(top: context.height * 0.2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CustomAssetImageWidget(
                        Images.emptyBox,
                        height: 100,
                        width: 100,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      Text(
                        'no_suggestions_found'.tr,
                        style: robotoMedium.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, PopularCategoryModel category) {
    return InkWell(
      onTap: () {
        _searchController.text = category.name ?? '';
        Get.find<search.SearchController>().searchData(category.name ?? '', false);
      },
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              child: CustomImage(
                image: '${category.imageFullUrl}',
                width: 40, height: 40, fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                category.name!,
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyMedium?.color),
                maxLines: 2, overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCard(BuildContext context, item) {
    return InkWell(
      onTap: () => Get.find<ItemController>().navigateToItemPage(item, context),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              child: CustomImage(
                image: '${item.imageFullUrl}',
                width: 40, height: 40, fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.name!,
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyMedium?.color),
                maxLines: 2, overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, String title, search.SearchController searchController) {
    return InkWell(
      onTap: () => searchController.searchData(title, false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            Icon(CupertinoIcons.arrow_counterclockwise, size: 16, color: Theme.of(context).disabledColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyMedium?.color),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.north_west, size: 14, color: Theme.of(context).disabledColor.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}
