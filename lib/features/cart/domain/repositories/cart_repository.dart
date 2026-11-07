import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:get/get_connect.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:friday_sa/api/api_client.dart';
import 'package:friday_sa/features/cart/domain/models/cart_model.dart';
import 'package:friday_sa/features/cart/domain/models/online_cart_model.dart';
import 'package:friday_sa/features/cart/domain/repositories/cart_repository_interface.dart';
import 'package:friday_sa/features/checkout/domain/models/place_order_body_model.dart';
import 'package:friday_sa/helper/auth_helper.dart';
import 'package:friday_sa/helper/module_helper.dart';
import 'package:friday_sa/util/app_constants.dart';

class CartRepository implements CartRepositoryInterface<OnlineCart> {
  CartRepository({required this.apiClient, required this.sharedPreferences});
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  @override
  Future<void> addSharedPrefCartList(List<CartModel> cartProductList) async {
    List<String> carts = [];
    if (sharedPreferences.containsKey(AppConstants.cartList)) {
      carts = sharedPreferences.getStringList(AppConstants.cartList) ?? [];
    }
    List<String> cartStringList = [];
    for (String cartString in carts) {
      CartModel cartModel = CartModel.fromJson(jsonDecode(cartString));
      if (cartModel.item!.moduleId != _getModuleId()) {
        cartStringList.add(cartString);
      }
    }
    for (CartModel cartModel in cartProductList) {
      cartStringList.add(jsonEncode(cartModel.toJson()));
    }
    await sharedPreferences.setStringList(
      AppConstants.cartList,
      cartStringList,
    );
  }

  int _getModuleId() {
    return ModuleHelper.getModule()?.id ??
        ModuleHelper.getCacheModule()?.id ??
        0;
  }

  @override
  Future add(OnlineCart cart) async {
    return _addToCartOnline(cart);
  }

  Future<List<OnlineCartModel>?> _addToCartOnline(OnlineCart cart) async {
    final String url =
        '${AppConstants.addCartUri}${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}';
    final Map<String, dynamic> payload = cart.toJson();
    List<OnlineCartModel>? onlineCartList;
    int maxAttempts = 3;
    int attempt = 0;

    while (attempt < maxAttempts) {
      attempt++;
      debugPrint(
        '[CartRepository] addToCart Attempt $attempt/$maxAttempts | URL: $url | Payload: $payload',
      );

      try {
        Response response = await apiClient.postData(
          url,
          payload,
          handleError: false,
        );

        debugPrint(
          '[CartRepository] addToCart Response | Status Code: ${response.statusCode} | Body: ${response.body}',
        );

        if (response.statusCode == 200) {
          onlineCartList = [];
          response.body.forEach(
            (cart) => onlineCartList!.add(OnlineCartModel.fromJson(cart)),
          );
          return onlineCartList;
        }

        // If server error or temporary timeout, wait and retry
        if (response.statusCode == 500 ||
            response.statusCode == 1 ||
            response.statusCode == 0) {
          debugPrint(
            '[CartRepository] addToCart encountered transient error (${response.statusCode}). Retrying...',
          );
          if (attempt < maxAttempts) {
            await Future.delayed(Duration(milliseconds: 1000 * attempt));
            continue;
          }
        }
        break; // Non-retriable error
      } catch (e) {
        debugPrint(
          '[CartRepository] addToCart Exception (Attempt $attempt): $e',
        );
        if (attempt < maxAttempts) {
          await Future.delayed(Duration(milliseconds: 1000 * attempt));
          continue;
        }
      }
    }
    if (onlineCartList == null) {
      _reportErrorToFirebase(url, payload, 'addToCartOnline');
    }
    return onlineCartList;
  }

  @override
  Future<bool> delete(int? id, {bool isRemoveAll = false}) async {
    if (isRemoveAll) {
      return _clearCartOnline();
    } else {
      return _removeCartItemOnline(id!);
    }
  }

  Future<bool> _removeCartItemOnline(int cartId) async {
    Response response = await apiClient.deleteData(
      '${AppConstants.removeItemCartUri}?cart_id=$cartId${!AuthHelper.isLoggedIn() ? '&guest_id=${AuthHelper.getGuestId()}' : ''}',
    );
    return (response.statusCode == 200);
  }

  Future<bool> _clearCartOnline() async {
    Response response = await apiClient.deleteData(
      '${AppConstants.removeAllCartUri}${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}',
    );
    return (response.statusCode == 200);
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) async {
    return _getCartDataOnline();
  }

  Future<List<OnlineCartModel>?> _getCartDataOnline() async {
    List<OnlineCartModel>? onlineCartList;
    Map<String, String>? header = {
      'Content-Type': 'application/json; charset=UTF-8',
      AppConstants.localizationKey: AppConstants.languages[0].languageCode!,
      AppConstants.moduleId: '${ModuleHelper.getCacheModule()?.id}',
      'Authorization':
          'Bearer ${sharedPreferences.getString(AppConstants.token)}',
    };

    Response response = await apiClient.getData(
      '${AppConstants.getCartListUri}${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}',
      headers: ModuleHelper.getModule()?.id == null ? header : null,
    );
    if (response.statusCode == 200) {
      onlineCartList = [];
      response.body.forEach(
        (cart) => onlineCartList!.add(OnlineCartModel.fromJson(cart)),
      );
    }
    return onlineCartList;
  }

  @override
  Future update(
    Map<String, dynamic> body,
    int? id, {
    num? price,
    int? quantity,
    bool isUpdateQty = false,
  }) async {
    if (isUpdateQty) {
      return _updateCartQuantityOnline(id!, price!, quantity!);
    } else {
      return _updateCartOnline(body);
    }
  }

  Future<List<OnlineCartModel>?> _updateCartOnline(
    Map<String, dynamic> body,
  ) async {
    final String url =
        '${AppConstants.updateCartUri}${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}';
    List<OnlineCartModel>? onlineCartList;
    int maxAttempts = 3;
    int attempt = 0;

    while (attempt < maxAttempts) {
      attempt++;
      debugPrint(
        '[CartRepository] updateCart Attempt $attempt/$maxAttempts | URL: $url | Payload: $body',
      );

      try {
        Response response = await apiClient.postData(
          url,
          body,
          handleError: false,
        );

        debugPrint(
          '[CartRepository] updateCart Response | Status Code: ${response.statusCode} | Body: ${response.body}',
        );

        if (response.statusCode == 200) {
          onlineCartList = [];
          response.body.forEach(
            (cart) => onlineCartList!.add(OnlineCartModel.fromJson(cart)),
          );
          return onlineCartList;
        }

        if (response.statusCode == 500 ||
            response.statusCode == 1 ||
            response.statusCode == 0) {
          debugPrint(
            '[CartRepository] updateCart encountered transient error (${response.statusCode}). Retrying...',
          );
          if (attempt < maxAttempts) {
            await Future.delayed(Duration(milliseconds: 1000 * attempt));
            continue;
          }
        }
        break;
      } catch (e) {
        debugPrint(
          '[CartRepository] updateCart Exception (Attempt $attempt): $e',
        );
        if (attempt < maxAttempts) {
          await Future.delayed(Duration(milliseconds: 1000 * attempt));
          continue;
        }
      }
    }
    if (onlineCartList == null) {
      _reportErrorToFirebase(url, body, 'updateCartOnline');
    }
    return onlineCartList;
  }

  Future<bool> _updateCartQuantityOnline(
    int cartId,
    num price,
    int quantity,
  ) async {
    final String url =
        '${AppConstants.updateCartUri}${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}';
    Map<String, dynamic> data = {
      "cart_id": cartId,
      "price": price,
      "quantity": quantity,
    };
    int maxAttempts = 3;
    int attempt = 0;

    while (attempt < maxAttempts) {
      attempt++;
      debugPrint(
        '[CartRepository] updateCartQuantity Attempt $attempt/$maxAttempts | URL: $url | Payload: $data',
      );

      try {
        Response response = await apiClient.postData(
          url,
          data,
          handleError: false,
        );

        debugPrint(
          '[CartRepository] updateCartQuantity Response | Status Code: ${response.statusCode} | Body: ${response.body}',
        );

        if (response.statusCode == 200) {
          return true;
        }

        if (response.statusCode == 500 ||
            response.statusCode == 1 ||
            response.statusCode == 0) {
          debugPrint(
            '[CartRepository] updateCartQuantity encountered transient error (${response.statusCode}). Retrying...',
          );
          if (attempt < maxAttempts) {
            await Future.delayed(Duration(milliseconds: 1000 * attempt));
            continue;
          }
        }
        break;
      } catch (e) {
        debugPrint(
          '[CartRepository] updateCartQuantity Exception (Attempt $attempt): $e',
        );
        if (attempt < maxAttempts) {
          await Future.delayed(Duration(milliseconds: 1000 * attempt));
          continue;
        }
      }
    }
    _reportErrorToFirebase(url, data, 'updateCartQuantityOnline');
    return false;
  }

  void _reportErrorToFirebase(
    String url,
    Map<String, dynamic> payload,
    String action,
  ) {
    try {
      FirebaseCrashlytics.instance.recordError(
        Exception("Cart API Failure in $action"),
        StackTrace.current,
        reason: 'Cart API $action failed after 3 retries',
        information: ['URL: $url', 'Payload: $payload'],
      );
    } catch (e) {
      debugPrint('Firebase Crashlytics logging failed: $e');
    }
  }
}
