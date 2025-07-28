# Store Service Kullanım Kılavuzu

Bu dokümantasyon, `StoreService` sınıfının nasıl kullanılacağını açıklar.

## Kurulum

1. `pubspec.yaml` dosyasına `in_app_purchase` paketini ekleyin:
```yaml
dependencies:
  in_app_purchase: ^3.1.13
```

2. `flutter pub get` komutunu çalıştırın.

3. Android için `android/app/src/main/AndroidManifest.xml` dosyasına billing iznini ekleyin:
```xml
<uses-permission android:name="com.android.vending.BILLING" />
```

## StoreService Sınıfı

### Temel Kullanım

```dart
import 'package:your_app/core/utils/store_service.dart';

// Singleton instance al
final StoreService storeService = StoreService();

// Store'a bağlan
bool isConnected = await storeService.connectToStore();

if (isConnected) {
  // Ürün listesini çek
  List<String> productIds = [
    'premium_monthly',
    'premium_yearly',
    'coins_100',
  ];
  
  List<ProductDetails> products = await storeService.getProducts(productIds);
  
  // Ürünleri kullan
  for (var product in products) {
    print('Ürün: ${product.title} - Fiyat: ${product.price}');
  }
}
```

### Metodlar

#### `connectToStore()`
- Store'a bağlanır
- `Future<bool>` döndürür
- Başarılı bağlantı durumunda `true` döner

#### `getProducts(List<String> productIds)`
- Verilen ürün ID'lerini kullanarak store'dan ürün bilgilerini çeker
- `Future<List<ProductDetails>>` döndürür
- Ürün bulunamazsa boş liste döner

#### `purchaseProduct(ProductDetails product)`
- Belirtilen ürün için satın alma işlemini başlatır
- `Future<bool>` döndürür
- İşlem başarıyla başlatılırsa `true` döner

#### `restorePurchases()`
- iOS için restore işlemi yapar
- `Future<void>` döndürür

#### `dispose()`
- Stream subscription'ları temizler
- Uygulama kapatılırken çağırılmalı

### Örnek Widget

`lib/store_example.dart` dosyasında tam bir örnek widget bulabilirsiniz.

## Ürün ID'leri

Google Play Console'da tanımladığınız ürün ID'lerini kullanın:

- **Consumable**: Tek kullanımlık ürünler (coin, jeton vb.)
- **Non-consumable**: Kalıcı ürünler (reklam kaldırma vb.)
- **Subscription**: Abonelik ürünleri

## Önemli Notlar

1. **Test**: Geliştirme aşamasında test kullanıcıları ekleyin
2. **Ürün ID'leri**: Google Play Console'da ürünlerinizi tanımlayın
3. **Fiyatlandırma**: Ürün fiyatlarını Play Console'da ayarlayın
4. **Güvenlik**: Satın alma işlemlerini sunucu tarafında doğrulayın

## Hata Ayıklama

- Store bağlantısı başarısız olursa cihazın Google Play Store'a bağlı olduğundan emin olun
- Test cihazında test kullanıcısı olarak eklendiğinizden emin olun
- Ürün ID'lerinin doğru olduğundan emin olun

## Google Play Billing Library 7.0.0+ Uyumluluğu

Bu implementasyon `in_app_purchase` paketini kullanır ve Google Play Billing Library 7.0.0+ ile uyumludur. 31 Ağustos 2025 tarihinden sonra da çalışmaya devam edecektir. 