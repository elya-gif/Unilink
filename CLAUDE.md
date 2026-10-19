# Proje: Öğrenci Proje & Ekip Platformu

Üniversite öğrencilerinin proje/yarışma ekibi kurduğu, bölüm bazlı iletişim kurduğu bir mobil uygulama (Flutter + Supabase).

## Konumlandırma
"Teknofest, TÜBİTAK 2209 ve hackathon ekiplerini kurduğun yer." Sosyal ve bölüm toplulukları özelliği bunun üzerine sonradan büyüyecek. Rakipler (Uniall, Campus101 vb.) "öğrenciler için her şey" olmaya çalışıp dağılmış; biz ekip kurmaya odaklıyız.

## Geliştirici hakkında (önemli)
- Mezun, Flutter'da yeni. Amaç: Flutter'ı öğrenmek ve CV'ye koyulacak, Play Store'da yayında bir uygulama çıkarmak.
- Bu yüzden: kodu yazarken **ne yaptığını ve neden yaptığını kısaca Türkçe açıkla.** Yeni bir kavram (Riverpod provider, async/await, widget lifecycle vb.) ilk kez geçtiğinde bir iki cümleyle anlat.
- Ara sıra küçük, uygun parçaları geliştiriciye bırak ("bunu sen dene, takılırsan sor").
- Tek seferde dev değişiklikler yerine küçük, anlaşılır adımlarla ilerle.
- Kullanıcıyla Türkçe konuş. Kod içi isimler İngilizce, kullanıcıya görünen metinler Türkçe.

## Öğrenme notları (her oturumda güncelle)
`docs/OGRENME_NOTLARI.md` geliştiricinin çalışma notu. Her çalışma oturumunun sonunda:
- Yeni öğrenilen kavramları ilgili bölüme ekle (anlaşılır Türkçe, kısa kod örnekleriyle).
- Karşılaşılan hataları "Hatalardan çıkan dersler" tablosuna ekle.
- Yeni komutları ve terimleri ilgili bölümlere ekle.
- "Oturum günlüğü"ne o oturumun yapılanlarını, öğrenilenleri, alıştırmaları ve sıradaki adımı yaz.

## Teknoloji
- Flutter (macOS'ta geliştiriliyor, hedef iOS + Android)
- State management: Riverpod
- Navigasyon: go_router
- Backend: Supabase (Auth, PostgreSQL, Storage, Realtime)
- Push bildirim: Firebase Cloud Messaging (ileride)
- Veritabanı şeması: `supabase/schema.sql` (RLS kuralları, trigger'lar ve yardımcı fonksiyonlar dahil)
- Çalıştırma: `flutter run --dart-define-from-file=env.json` (`env.json` kökte, `.gitignore`'da; VS Code'da `.vscode/launch.json` ile F5)
- GitHub: github.com/elya-gif/unilink

## Mevcut durum (Oturum 3, 19 Ekim 2026)
- Dosyalar: `lib/main.dart` (env boşsa fail-fast), `lib/app.dart`, `lib/core/router/app_router.dart`, `lib/core/theme/app_theme.dart`, `lib/features/auth/data/auth_repository.dart`, `lib/features/auth/presentation/login_page.dart`, `lib/features/auth/presentation/register_page.dart`, `lib/features/home/presentation/home_page.dart`, `lib/features/profile/data/profile.dart`, `lib/features/profile/data/profile_repository.dart`
- Git: çalışma `feature/onboarding-profile` dalında (henüz commit yok, main'e merge edilmedi).
- Takvim: bir hafta önde (19 Ekim = 2. hafta başı, iş 3. haftada).
- Bilinen küçük sorunlar: `test/widget_test.dart` var olmayan `MyApp`'i kullanıyor (flutter analyze hatası); `main.dart`'ta `anonKey` deprecated → `publishableKey`.
- Geliştirici kod içi açıklama yorumlarını bilerek siliyor; geri ekleme.
- Auth çalışıyor: `AuthRepository` (signUp/signIn/signOut, `authStateChanges` stream) + `authRepositoryProvider` + `authStateProvider` (StreamProvider). Router `redirect` + `refreshListenable` (`_RouterRefreshStream`) ile giriş yapmamışı `/login`'e, giriş yapmışı `/`'e yönlendiriyor. Rotalar: `/login`, `/register`, `/`.
- Login/register: `ConsumerStatefulWidget`, `Form` + validator, `_isLoading`, Supabase hata mesajları Türkçeye çevriliyor.
- Supabase: Confirm email geliştirme için KAPALI (yayından önce açılacak). `dev_email_allowlist` tablosu: .edu.tr olmayan test mailleri (geliştiricinin maili ekli). Referans tabloları `anon` için okunabilir.
- Geliştirici her oturumda bir-iki küçük parçayı kendisi yazıyor; yorulunca hazır kod istiyor, sorun değil ama farkları açıklamak faydalı.
- Yetenek seçimi ✅ çalışıyor: `skill.dart`, `skills_page.dart` (FilterChip, kategoriye göre), `/skills` rotası, `saveSkills` (sil + ekle). Geliştirici görevi: ana sayfaya `/skills` butonu. Profil fotoğrafı ✅ çalışıyor: `avatar_picker.dart` (image_picker, 512px), `uploadAvatar` → Storage `avatars/{uid}/avatar.jpg`, `profiles.avatar_url`. Bucket + policy Supabase'de kuruldu. HAFTA 3 BİTTİ (19 Ekim); sıradaki: Hafta 4-5 proje ilanları. (İsteğe bağlı: şifremi unuttum.)

## Devam eden iş (Hafta 3, onboarding — 3 adım)
1. ✅ Profili okumak: `Profile` modeli (`fromJson`, `isComplete`), `ProfileRepository.getProfile`, `currentProfileProvider` (FutureProvider, `authStateProvider`'ı watch eder), `home_page.dart` profili `AsyncValue.when` ile gösteriyor. Kalan: geliştirici ana sayfaya "Profil tamam: Evet/Hayır" satırını kendisi yazacak, uygulamayı deneyip commit edecek. Önce bunu sor / dosyadan kontrol et.
2. ✅ Çalışıyor (simülatörde denendi): `lib/features/profile/presentation/onboarding_page.dart`, `/onboarding` rotası, `LookupItem` modeli, `universitiesProvider`/`departmentsProvider`, `updateProfile` (`.select().single()` ile RLS'yi fark eder). Sınıf 1–6 arası (DB'de check constraint bilinmiyor). Ana sayfada "Profili düzenle" butonu var. Plan: ad soyad, kullanıcı adı (unique; 23505 hatasını Türkçeye çevir), üniversite ve bölüm (dropdown, tablolardan), sınıf. `ProfileRepository.updateProfile` eklenecek; kaydedince `ref.invalidate(currentProfileProvider)`.
3. ✅ Çalışıyor (redirect + ref.listen + _RouterRefreshStream.notify; onboarding kaydedince taze profili bekliyor). Router: giriş yapmış ama `isComplete == false` ise `/onboarding`'e yönlendir; `ref.listen(currentProfileProvider)` ile router'ı yenile.

## Temel kurallar
- Kayıt sadece `.edu.tr` mail ile (veritabanı trigger'ı kontrol ediyor). Geliştirme sırasında test için bu kontrol geçici olarak gevşetilebilir; ileride mezunlar için ayrı doğrulama düşünülecek.
- Bölümler okuldan bağımsız tablo; farklı ünilerdeki aynı bölüm öğrencileri eşleşebilsin diye.
- Projelerde aranan roller ve rollerin yetenek etiketleri var; eşleştirme bunun üzerinden yapılacak.
- Başvuru kabul edilince kişi trigger ile otomatik ekibe ekleniyor; proje sahibi de otomatik üye.
- Sohbet başlatmak için `start_conversation(other_user)` RPC fonksiyonu kullanılır.
- Supabase anahtarları koda gömülmez; `.env` / `--dart-define` ile verilir ve `.gitignore`'a eklenir.

## İlk sürüm (MVP) kapsamı
Doğrulanmış kayıt, profil (üni, bölüm, sınıf, yetenekler), rollerle proje ilanı, başvuru akışı, birebir mesajlaşma, yarışmalar listesi, proje takvimi, push bildirim ve yeteneğe göre proje önerisi.

Sonraki sürümlere: portföy profili, ekip arkadaşı onayı, mentor rozeti, bölüm toplulukları. Ders/hoca değerlendirmesi moderasyon riski nedeniyle şimdilik yok.

## Yol haritası (başlangıç: 12 Ekim 2026, hedef: Ocak 2027 başı)
1. Hafta: Proje kurulumu, klasör yapısı, Riverpod + go_router, Supabase bağlantısı, GitHub reposu
2. Hafta: Kayıt/giriş, mail doğrulama
3. Hafta: Onboarding ve profil (fotoğraf yükleme dahil)
4-5. Hafta: Proje ilanı açma, listeleme, filtreleme, detay
6. Hafta: Başvuru akışı ve ekip ekranı
7. Hafta: Gerçek zamanlı mesajlaşma
8. Hafta: Yarışmalar sayfası ve proje takvimi
9. Hafta: Push bildirimleri ve öneriler
10. Hafta: Cilalama (boş/yükleme/hata durumları, testler)
11-12. Hafta: Play Store yayını, README, ekran görüntüleri, demo videosu

## CV için dikkat
- GitHub reposu açık, düzenli ve anlamlı commit mesajları.
- Temiz klasör mimarisi (feature bazlı: `lib/features/auth`, `lib/features/projects` ...).
- README'de ekran görüntüleri, teknoloji listesi ve demo GIF'i.
