# Ders Kumbarası

Türkiye Yüzyılı Maarif Modeli öğretim programlarına göre hazırlanmış, **tekrar ederek öğrenme** (aralıklı tekrar) ve kısa konu anlatımlarına dayalı ilkokul uygulaması. iOS ve Android (Flutter, tek kod tabanı). Maskot: sincap **Fındık**.

- Web önizleme: https://atgibi.github.io/ders-kumbarasi/
- Android APK ve imzasız iOS paketi: Actions → son başarılı **CI** çalıştırması → Artifacts

## İçerik kapsamı

| Ders | Sınıflar | Öğrenme çıktısı |
| --- | --- | --- |
| Türkçe | 1–4 | 77 |
| Matematik | 1–4 | 111 |
| Hayat Bilgisi | 1–3 | 66 |
| Fen Bilimleri | 3–4 | 39 |
| Sosyal Bilgiler | 4 | 17 |
| **Toplam** | | **310** |

Çıktılar resmî programlardan otomatik çıkarılmış ve programdaki tablolarla sayıca doğrulanmıştır (`curriculum/`). 4. sınıf, 2027-2028'de uygulanacak TYMM programına göre hazırlanmıştır.

**Önemli:** Soru ve anlatım metinleri yazılımla birlikte hazırlanmıştır; yayından önce bir sınıf öğretmeninin pedagojik onayından geçmelidir.

## Mimari

- **Sunucusuz:** hesap yok; tüm veriler cihazda (web'de tarayıcıda). Reklam ve üçüncü taraf izleme yok.
- **Tekrar motoru:** 7 kutulu Leitner (`lib/core/srs/`). Yanlışlar oturum sonunda yeniden sorulur.
- **İçerik:** `tools/content/*.py` → `python3 tools/content/build.py` → `assets/content/*.json`. Kart kimlikleri `<çıktı>#<sıra>`: yeni kartı listenin **sonuna** ekleyin, yoksa öğrenci ilerlemesi kayar.
- **Soru üreteçleri:** `lib/data/generators.dart` (aynı kart her tekrarda farklı sayılarla gelir). Sabit soruların seçenekleri her gösterimde karıştırılır.
- **Veliyle etkinlik kartları:** Konuşma, yazma ve uygulama gerektiren çıktılar için ("Yaptık" / "Şimdi değil").
- **Ses:** Sabit metinler Google Cloud TTS ile önceden seslendirilir (`tools/audio/speech.py`, iş akışı `ses-uret.yml`); kayıt yoksa cihazın Türkçe sesi kullanılır. Etkinleştirmek için depo ayarlarında `GOOGLE_TTS_API_KEY` adlı Actions secret tanımlayın.

## Derleme ve test (GitHub Actions)

- `ci.yml`: içerik doğrulama, biçim, analiz, testler; Android APK; iOS (imzasız).
- `web.yml`: web derlemesi, GitHub Pages yayını, ekran görüntüleri (`ekran` dalı).
- `ses-uret.yml`: eksik sesleri üretir.
- `kaynak-indir.yml`: müfredat kaynaklarını yeniden indirmek için (geliştirme aracı).

## Mağazaya çıkış için eksikler

- Apple Developer hesabı, imzalama sertifikaları ve TestFlight/App Store ayarı
- Google Play Console hesabı, imzalama anahtarı (`android/key.properties`, Actions secret)
- Gizlilik politikası sayfası ve mağaza metinleri (KVKK avukatı onayıyla)
- Pedagojik inceleme, gerçek cihaz testleri
