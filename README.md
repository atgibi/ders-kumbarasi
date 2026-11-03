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
- **İçerik:** `tools/content/*.py` → `python3 tools/content/build.py` → `assets/content/*.json`. Kart kimlikleri `<çıktı>#<içerik karması>`: kartların sırası değişse de ilerleme korunur; kartın metni değişirse yeni kart sayılır.
- **Tasarım:** Claude Design teslim paketindeki marka ve bileşenler (`lib/ui/theme.dart` token'ları, `lib/ui/widgets/kit.dart` bileşenleri). Yazı tipi Nunito (uygulamayla gelir), simgeler Lucide, emojiler Twemoji SVG olarak gömülü (`tools/emoji/fetch.py`): her cihazda aynı görünür, eski Android'de kutucuk çıkmaz.
- **Kayıt güvenliği:** Her yazmada önceki sürüm `.bak` olarak saklanır; bozuk kayıt yedekten kurtarılır, kurtarılamazsa üzerine yazılmadan `.bozuk` olarak kenara alınır. Veli alanından tek dosyalık yedek alınıp geri yüklenebilir.
- **Soru üreteçleri:** `lib/data/generators.dart` (aynı kart her tekrarda farklı sayılarla gelir). Sabit soruların seçenekleri her gösterimde karıştırılır.
- **Veliyle etkinlik kartları:** Konuşma, yazma ve uygulama gerektiren çıktılar için ("Yaptık" / "Şimdi değil").
- **Ses:** Sabit metinler Google Cloud TTS ile önceden seslendirilir (`tools/audio/speech.py`, iş akışı `ses-uret.yml`); kayıt yoksa cihazın Türkçe sesi kullanılır. Etkinleştirmek için depo ayarlarında `GOOGLE_TTS_API_KEY` adlı Actions secret tanımlayın.

## Derleme ve test (GitHub Actions)

- `ci.yml`: içerik ve emoji doğrulama, biçim, `pubspec.lock`, analiz, testler; Android APK + AAB; iOS (imzasız).
- `web.yml`: web derlemesi, GitHub Pages yayını, ekran görüntüleri (`ekran` dalı).
- `ses-uret.yml`: eksik sesleri üretir.
- `kaynak-indir.yml`: müfredat kaynaklarını yeniden indirmek için (geliştirme aracı).

## Mağazaya çıkış

Hazır olanlar: uyarlanabilir simge (tek renkli tema simgesi dahil), açılış ekranı, yayın imzalama altyapısı, App Bundle (AAB), iOS gizlilik bildirimi (`PrivacyInfo.xcprivacy`), şifreleme beyanı, gereksiz izinlerin çıkarılması (internet, depolama, reklam kimliği), Android otomatik bulut yedeğinin kapatılması, uygulama içi ve web'de gizlilik politikası/KVKK metni (`docs/gizlilik.html` → `https://atgibi.github.io/ders-kumbarasi/gizlilik.html`), veli kapısı, çevrimdışı çalışma.

Uygulama kimliği: Android `com.derskumbarasi.app`, iOS `com.derskumbarasi.app` (yayımlandıktan sonra değiştirilemez).

Sizin yapmanız gerekenler:

- **Google Play:** Play Console hesabı. Yükleme anahtarı oluşturup Actions secret olarak ekleyin: `ANDROID_KEYSTORE_BASE64` (`base64 -w0 upload.jks`), `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`. CI imzalı `app-release.aab` üretir. Mağaza kaydında hedef yaş grubu 6–8 ve 9–12, "Aileler" programı, Veri güvenliği formu: "veri toplanmıyor / paylaşılmıyor".
- **App Store:** Apple Developer hesabı, `com.derskumbarasi.app` kimliği, imzalama sertifikası ve profil (Xcode ile ya da CI'ya eklenecek secret'larla). Kategori: Eğitim, "Çocuklar" bölümü (Kids Category, 6–8 yaş), Gizlilik etiketi: "Veri toplanmıyor".
- Mağaza ekran görüntüleri (`ekran` dalındaki görüntüler başlangıç olarak kullanılabilir), açıklama metni, destek e-postası.
- Pedagojik inceleme ve gerçek cihaz testleri; isterseniz KVKK metninin bir hukukçu tarafından gözden geçirilmesi.
