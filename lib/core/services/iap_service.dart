import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'settings_service.dart';

/// A service to manage in-app purchases.
class IapService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final SettingsService _settingsService;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  IapService(this._settingsService);

  /// The product IDs for the in-app purchases.
  final Set<String> _productIds = {
    'remove_ads',
    'coins_100',
  };

  /// A stream of purchase updates.
  Stream<List<PurchaseDetails>> get purchaseStream => _inAppPurchase.purchaseStream;

  /// Initializes the in-app purchase service.
  void init() {
    _subscription = purchaseStream.listen(
      (purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () {
        _subscription?.cancel();
      },
      onError: (error) {
        // handle error here.
      },
    );
  }

  /// Disposes the in-app purchase service.
  void dispose() {
    _subscription?.cancel();
  }

  /// Listens to purchase updates.
  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // handle pending purchases.
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // handle error.
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          if (purchaseDetails.productID == 'remove_ads') {
            _settingsService.updateAdsRemoved(true);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  /// Loads the products for sale.
  Future<List<ProductDetails>> loadProducts() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (available) {
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(_productIds);
      if (response.error != null) {
        // handle error.
        return [];
      }
      return response.productDetails;
    }
    return [];
  }

  /// Buys a product.
  void buyProduct(ProductDetails productDetails) {
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);
    if (productDetails.id == 'remove_ads') {
      _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } else {
      _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
    }
  }
}

final iapServiceProvider = Provider<IapService>((ref) {
  final settingsService = ref.watch(settingsServiceProvider);
  final iapService = IapService(settingsService);
  iapService.init();
  ref.onDispose(() => iapService.dispose());
  return iapService;
});
