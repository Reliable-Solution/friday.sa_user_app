import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:friday_sa/features/splash/controllers/splash_controller.dart';
import 'package:friday_sa/features/order/controllers/order_controller.dart';
import 'package:friday_sa/features/order/domain/models/order_model.dart';
import 'package:friday_sa/features/location/domain/models/zone_response_model.dart';
import 'package:friday_sa/helper/address_helper.dart';
import 'package:friday_sa/util/app_constants.dart';
import 'package:friday_sa/common/widgets/custom_app_bar.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:friday_sa/features/checkout/widgets/payment_failed_dialog.dart';
import 'package:friday_sa/features/wallet/widgets/fund_payment_dialog_widget.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.orderModel,
    required this.isCashOnDelivery,
    this.addFundUrl,
    required this.paymentMethod,
    required this.guestId,
    required this.contactNumber,
    this.storeId,
    this.subscriptionUrl,
    this.createAccount = false,
    this.createUserId,
  });
  final OrderModel orderModel;
  final bool isCashOnDelivery;
  final String? addFundUrl;
  final String paymentMethod;
  final String guestId;
  final String contactNumber;
  final String? subscriptionUrl;
  final int? storeId;
  final bool createAccount;
  final int? createUserId;

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {
  late String selectedUrl;
  num value = 0.0;
  PullToRefreshController? pullToRefreshController;
  late MyInAppBrowser browser;
  num? _maximumCodOrderAmount;

  @override
  void initState() {
    super.initState();

    if (widget.addFundUrl == '' &&
        widget.addFundUrl!.isEmpty &&
        widget.subscriptionUrl == '' &&
        widget.subscriptionUrl!.isEmpty) {
      selectedUrl =
          '${AppConstants.baseUrl}/payment-mobile?customer_id=${widget.createAccount
              ? widget.createUserId
              : widget.orderModel.userId == 0
              ? widget.guestId
              : widget.orderModel.userId}&order_id=${widget.orderModel.id}&payment_method=${widget.paymentMethod}';
    } else if (widget.subscriptionUrl != '' &&
        widget.subscriptionUrl!.isNotEmpty) {
      selectedUrl = widget.subscriptionUrl!;
    } else {
      selectedUrl = widget.addFundUrl!;
    }

    if (kDebugMode) {
      debugPrint('==========url=======> $selectedUrl');
    }

    _initData();
  }

  Future<void> _initData() async {
    if (widget.addFundUrl == '' &&
        widget.addFundUrl!.isEmpty &&
        widget.subscriptionUrl == '' &&
        widget.subscriptionUrl!.isEmpty) {
      for (ZoneData zData
          in AddressHelper.getUserAddressFromSharedPref()!.zoneData!) {
        for (Modules m in zData.modules!) {
          if (m.id == Get.find<SplashController>().module!.id) {
            _maximumCodOrderAmount = m.pivot!.maximumCodOrderAmount;
            break;
          }
        }
      }
    }

    browser = MyInAppBrowser(
      orderID: widget.orderModel.id.toString(),
      orderType: widget.orderModel.orderType,
      orderAmount: widget.orderModel.orderAmount,
      maxCodOrderAmount: _maximumCodOrderAmount,
      isCashOnDelivery: widget.isCashOnDelivery,
      addFundUrl: widget.addFundUrl,
      contactNumber: widget.contactNumber,
      storeId: widget.storeId,
      subscriptionUrl: widget.subscriptionUrl,
      createAccount: widget.createAccount,
      guestId: widget.guestId,
      onExits: () => _exitApp().then((value) => value!),
    );

    if (GetPlatform.isAndroid) {
      await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);

      bool swAvailable = await WebViewFeature.isFeatureSupported(
        WebViewFeature.SERVICE_WORKER_BASIC_USAGE,
      );
      bool swInterceptAvailable = await WebViewFeature.isFeatureSupported(
        WebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST,
      );

      if (swAvailable && swInterceptAvailable) {
        ServiceWorkerController serviceWorkerController =
            ServiceWorkerController.instance();
        await serviceWorkerController.setServiceWorkerClient(
          ServiceWorkerClient(
            shouldInterceptRequest: (request) async {
              if (kDebugMode) {
                debugPrint(request.toJson().toString());
              }
              return null;
            },
          ),
        );
      }
    }

    await browser.openUrlRequest(
      urlRequest: URLRequest(url: WebUri(selectedUrl)),
      settings: InAppBrowserClassSettings(
        webViewSettings: InAppWebViewSettings(
          useShouldOverrideUrlLoading: true,
          useOnLoadResource: true,
        ),
        browserSettings: InAppBrowserSettings(
          hideUrlBar: true,
          hideToolbarTop: GetPlatform.isAndroid,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        _exitApp().then((value) => value!);
      },
      child: Scaffold(
        appBar: CustomAppBar(title: 'payment'.tr, onBackPressed: _exitApp),
        body: Center(
          child: Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _exitApp() async {
    if ((widget.addFundUrl == null || widget.addFundUrl!.isEmpty) &&
        (widget.subscriptionUrl == '' && widget.subscriptionUrl!.isEmpty)) {
      return Get.dialog(
        barrierDismissible: false,
        PaymentFailedDialog(
          orderID: widget.orderModel.id.toString(),
          orderAmount: widget.orderModel.orderAmount,
          maxCodOrderAmount: _maximumCodOrderAmount,
          orderType: widget.orderModel.orderType,
          isCashOnDelivery: widget.isCashOnDelivery,
          guestId: widget.createAccount
              ? widget.createUserId.toString()
              : widget.guestId,
        ),
      );
    } else {
      return Get.dialog(
        FundPaymentDialogWidget(
          isSubscription:
              widget.subscriptionUrl != null &&
              widget.subscriptionUrl!.isNotEmpty,
        ),
      );
    }
  }
}

class MyInAppBrowser extends InAppBrowser {
  MyInAppBrowser({
    super.windowId,
    super.initialUserScripts,
    required this.orderID,
    required this.orderType,
    required this.orderAmount,
    required this.maxCodOrderAmount,
    required this.isCashOnDelivery,
    this.addFundUrl,
    this.subscriptionUrl,
    this.contactNumber,
    this.storeId,
    required this.createAccount,
    required this.guestId,
    required this.onExits,
  });
  final String orderID;
  final String? orderType;
  final num? orderAmount;
  final num? maxCodOrderAmount;
  final bool isCashOnDelivery;
  final String? addFundUrl;
  final String? subscriptionUrl;
  final String? contactNumber;
  final int? storeId;
  final bool createAccount;
  final String guestId;
  final Function() onExits;

  final bool _canRedirect = true;

  @override
  Future onBrowserCreated() async {
    if (kDebugMode) {
      debugPrint("\n\nBrowser Created!\n\n");
    }
  }

  @override
  Future onLoadStart(url) async {
    if (kDebugMode) {
      debugPrint("\n\nStarted: $url\n\n");
    }
    Get.find<OrderController>().paymentRedirect(
      url: url.toString(),
      canRedirect: _canRedirect,
      onClose: close,
      addFundUrl: addFundUrl,
      orderID: orderID,
      contactNumber: contactNumber,
      storeId: storeId,
      subscriptionUrl: subscriptionUrl,
      createAccount: createAccount,
      guestId: guestId,
    );
  }

  @override
  Future onLoadStop(url) async {
    pullToRefreshController?.endRefreshing();
    if (kDebugMode) {
      debugPrint("\n\nStopped: $url\n\n");
    }
    Get.find<OrderController>().paymentRedirect(
      url: url.toString(),
      canRedirect: _canRedirect,
      onClose: close,
      addFundUrl: addFundUrl,
      orderID: orderID,
      contactNumber: contactNumber,
      storeId: storeId,
      subscriptionUrl: subscriptionUrl,
      createAccount: createAccount,
      guestId: guestId,
    );
  }

  // @override
  // Future<ServerTrustAuthResponse?>? onReceivedServerTrustAuthRequest(URLAuthenticationChallenge challenge) async {
  //   if (kDebugMode) {
  //    debugPrint("\n\n onReceivedServerTrustAuthRequest: ${challenge.toString()}\n\n");
  //   }
  //   return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
  // }
  //
  // @override
  // Future<ShouldAllowDeprecatedTLSAction?>? shouldAllowDeprecatedTLS(URLAuthenticationChallenge challenge) async {
  //   if (kDebugMode) {
  //    debugPrint("\n\n shouldAllowDeprecatedTLS: ${challenge.protectionSpace.host}\n\n");
  //   }
  //   return ShouldAllowDeprecatedTLSAction.ALLOW;
  // }

  @override
  void onLoadError(url, code, message) {
    pullToRefreshController?.endRefreshing();
    if (kDebugMode) {
      debugPrint("Can't load [$url] Error: $message");
    }
  }

  @override
  void onProgressChanged(progress) {
    if (progress == 100) {
      pullToRefreshController?.endRefreshing();
    }
    if (kDebugMode) {
      debugPrint("Progress: $progress");
    }
  }

  @override
  void onExit() {
    onExits();
    if (kDebugMode) {
      debugPrint("\n\nBrowser closed!\n\n");
    }
  }

  @override
  Future<NavigationActionPolicy> shouldOverrideUrlLoading(
    navigationAction,
  ) async {
    if (kDebugMode) {
      debugPrint("\n\nOverride ${navigationAction.request.url}\n\n");
    }
    return NavigationActionPolicy.ALLOW;
  }

  @override
  void onLoadResource(resource) {
    if (kDebugMode) {
      debugPrint(
        "Started at: ${resource.startTime}ms ---> duration: ${resource.duration}ms ${resource.url ?? ''}",
      );
    }
  }

  @override
  void onConsoleMessage(consoleMessage) {
    if (kDebugMode) {
      debugPrint("""
    console output:
      message: ${consoleMessage.message}
      messageLevel: ${consoleMessage.messageLevel.toValue()}
   """);
    }
  }
}
