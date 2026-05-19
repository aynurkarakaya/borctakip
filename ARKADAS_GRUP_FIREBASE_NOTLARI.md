# Arkadaşlık, Grup ve Bildirim Sistemi Notları

Bu sürümde eklenen ana yapı:

- `friend_requests`: arkadaşlık istekleri
- `friends`: onaylanmış arkadaş kayıtları
- `groups`: grup kayıtları
- `notifications`: uygulama içi bildirimler
- `transactions.status = requested`: karşı taraf onayı bekleyen borç isteği
- `transactions.status = pending`: onaylanmış aktif borç/alacak

## Önemli kullanım akışı

1. Kullanıcı, kullanıcı adıyla arkadaş arar.
2. Arkadaşlık isteği gönderir.
3. Karşı taraf isteği onaylar.
4. Kullanıcılar arkadaş olduktan sonra manuel borç isteği gönderebilir.
5. Borç isteği, karşı tarafın Bildirimler > Borç Onayı sekmesine düşer.
6. Karşı taraf onaylarsa işlem aktif borç/alacak listelerine geçer.
7. Grup borçlarında gruptaki diğer üyelere ayrı ayrı onay isteği gönderilir.

## Firebase Console tarafında yapılacaklar

1. Firestore Rules kısmına projedeki `firestore.rules` dosyasını yapıştırıp Publish et.
2. Authentication > Sign-in method > Email/Password aktif olmalı.
3. Firebase Messaging için Android kullanacaksan `google-services.json` güncel olmalı.
4. Web kullanacaksan `flutterfire configure` sonrası `lib/firebase_options.dart` güncel olmalı.

## Eklenen önemli dosyalar

- `lib/data/models/friend_request_model.dart`
- `lib/data/models/friend_model.dart`
- `lib/data/models/group_model.dart`
- `lib/data/models/app_notification_model.dart`
- `lib/data/services/friend_service.dart`
- `lib/data/services/notification_service.dart`
- `lib/modules/friends/pages/*`
- `lib/modules/groups/pages/*`
- `lib/modules/notifications/pages/*`
- `lib/modules/friends/widgets/friend_card.dart`
- `lib/modules/notifications/widgets/notification_badge.dart`
