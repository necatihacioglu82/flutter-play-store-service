import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

class StoreService {
  static final StoreService _instance = StoreService._internal();
  factory StoreService() => _instance;
  StoreService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isAvailable = false;

  /// Store'a bağlanır ve bağlantı durumunu kontrol eder
  Future<bool> connectToStore() async {
    try {
      _isAvailable = await _inAppPurchase.isAvailable();

      if (_isAvailable) {
        // Satın alma işlemlerini dinlemek için stream'i başlat
        _subscription = _inAppPurchase.purchaseStream.listen(
          _onPurchaseUpdate,
          onDone: () => _subscription?.cancel(),
          onError: (error) => print('Store stream error: $error'),
        );

        print('Store bağlantısı başarılı');
        return true;
      } else {
        print('Store kullanılamıyor');
        return false;
      }
    } catch (e) {
      print('Store bağlantı hatası: $e');
      return false;
    }
  }

  /// Verilen ürün ID'lerini kullanarak store'dan ürün bilgilerini çeker
  Future<List<ProductDetails>> getProducts(List<String> productIds) async {
    if (!_isAvailable) {
      print('Store bağlantısı yok. Önce connectToStore() çağırın.');
      return [];
    }

    try {
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(productIds.toSet());

      if (response.error != null) {
        print('Ürün çekme hatası: ${response.error}');
        return [];
      }

      if (response.productDetails.isEmpty) {
        print('Hiç ürün bulunamadı');
        return [];
      }

      print('${response.productDetails.length} ürün başarıyla çekildi');
      return response.productDetails;
    } catch (e) {
      print('Ürün çekme hatası: $e');
      return [];
    }
  }

  /// Satın alma işlemlerini dinler
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        print('Satın alma bekliyor: ${purchaseDetails.productID}');
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        print('Satın alma tamamlandı: ${purchaseDetails.productID}');
        _handleSuccessfulPurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        print('Satın alma hatası: ${purchaseDetails.error}');
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        print('Satın alma iptal edildi: ${purchaseDetails.productID}');
      }
    }
  }

  /// Başarılı satın alma işlemini handle eder
  void _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) {
    // Burada satın alma tamamlandığında yapılacak işlemleri ekleyebilirsiniz
    // Örneğin: kullanıcıya premium özellikleri açma, sunucuya bildirim gönderme vb.

    // Satın alma işlemini tamamla
    _inAppPurchase.completePurchase(purchaseDetails);
  }

  /// Satın alma işlemini başlatır
  Future<bool> purchaseProduct(ProductDetails product) async {
    try {
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: product);

      bool success = false;
      if (product.id.contains('subscription')) {
        success =
            await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        success =
            await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      }

      return success;
    } catch (e) {
      print('Satın alma başlatma hatası: $e');
      return false;
    }
  }

  /// Restore işlemi (iOS için)
  Future<void> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      print('Restore hatası: $e');
    }
  }

  /// Servisi temizler
  void dispose() {
    _subscription?.cancel();
  }

  /// Store bağlantı durumunu döndürür
  bool get isAvailable => _isAvailable;
}
