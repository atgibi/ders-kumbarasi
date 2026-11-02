# Ders Kumbarası

Türkiye Yüzyılı Maarif Modeli'ne uygun, **tekrar ederek öğrenme** (aralıklı tekrar) ve kısa konu anlatımlarına dayalı ilkokul (1–4. sınıf) uygulaması. iOS ve Android, Flutter ile tek kod tabanı.

## Durum

Geliştirme aşamasında. Henüz kullanıma hazır değil.

## Derleme

Tüm derlemeler GitHub Actions üzerinde yapılır (`.github/workflows/ci.yml`):

- Analiz (`flutter analyze`), biçim kontrolü ve testler
- Android: `app-release.apk` (artifact olarak indirilebilir)
- iOS: imzasız `Runner.app` (imzalama için Apple Developer hesabı gerekir)

## Mimari kararlar

- Sunucusuz: tüm öğrenme verisi cihazda tutulur; hesap yok.
- İçerik uygulamayla birlikte gelir; internetsiz çalışır.
