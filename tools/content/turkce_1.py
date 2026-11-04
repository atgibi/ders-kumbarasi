"""1. sınıf Türkçe (TYMM T.x.1.x). İlk okuma yazma harf grupları programdaki
sırayla: 1) a n e t i l  2) o k u r ı m  3) ü s ö y d z  4) ç b g c ş  5) p h v ğ f j
"""

from common import pack, page, lesson, mc, act, gen, V
from turkce_common import build, listen, read, T

G1 = ["a", "n", "e", "t", "i", "l"]
G2 = ["o", "k", "u", "r", "ı", "m"]
G3 = ["ü", "s", "ö", "y", "d", "z"]
G45 = ["ç", "b", "g", "c", "ş", "p", "h", "v", "f", "j"]

P = {
    "lessons": {
        "D1": [
            lesson("İyi bir dinleyici", [
                page("Sözorman'da ağaçlar konuşur, ama yalnızca iyi dinleyenler duyar! "
                     "Ozan Yaprak sana ormanın sırrını anlatmak istiyor.", T("🌳 👂")),
                page("İyi dinleyici konuşan kişiye bakar. Gözlerimiz konuşana dönük olunca kulaklarımız da ona döner.",
                     T("👀 ➜ 🗣️")),
                page("Konuşanın sözünü kesmeyiz. Sorumuz varsa elimizi kaldırır, sıramızı bekleriz.",
                     T("🙋 ⏳")),
                page("Dinlerken başka işle uğraşmayız: kalemle oynamak, arkadaşla konuşmak dikkatimizi dağıtır.",
                     T("✏️ ✗   ·   👂 ✓")),
                page("Anka dinliyor: “Ozan Yaprak masal anlatırken ona bakıyorum, sessizce dinliyorum. "
                     "Bir sözcüğü anlamadım; masal bitince elimi kaldırıp soracağım.”", T("🦉 👂 🙋")),
                page("Dikkat! Dinlemek yalnızca sessiz durmak değildir. Anlatılanı aklında tutmaya çalış: "
                     "“Kim? Ne oldu?”", T("🤫 + 🧠")),
                page("Özet: Konuşana bak, sözünü kesme, sıranı bekle, anlatılanı aklında tut.",
                     T("👀 · 🤐 · 🙋 · 🧠")),
            ]),
            lesson("Kulak oyunu", [
                page("Gözlerini kapat ve 10'a kadar say. Kaç farklı ses duydun? Kuş, rüzgâr, araba…", T("🙈 👂")),
                page("İşte dinlemek budur: seslere dikkat etmek. Konuşan birini de böyle dikkatle dinleriz.",
                     T("👂 ✨")),
            ], alt=True),
        ],
        "D2": [
            lesson("Dinlediğimi anlıyorum", [
                page("Ozan Yaprak bir masal anlatacak. Masaldan sonra sana sorular soracak. Hazır mısın?",
                     T("📖 🌳")),
                page("Dinlerken aklımızda beş soru tutarız: Kim? Ne yaptı? Nerede? Ne zaman? Neden?",
                     T("kim · ne · nerede · ne zaman · neden")),
                page("Örnek: “Ela bahçede bir kedi gördü.” Kim? Ela. Nerede? Bahçede. Ne gördü? Bir kedi.",
                     T("👧 · 🌳 · 🐱")),
                page("Dinlerken kafamızda resim çizeriz. Bahçeyi, Ela'yı, kediyi gözümüzün önüne getiririz.",
                     T("🧠 🖼️")),
                page("Anka dinliyor: “Ali sabah kalktı, kahvaltı yaptı, okula gitti.” Kahvaltıdan sonra ne oldu? "
                     "Sırayı hatırlıyorum: okula gitti!", T("🌅 ➜ 🍳 ➜ 🏫")),
                page("Dikkat! Hikâyede olmayan bir şeyi uydurmayız. Cevabı dinlediklerimizde ararız.",
                     T("👂 ➜ ✅")),
                page("Özet: Kim, ne, nerede, ne zaman, neden sorularını düşün; kafanda resmini çiz.",
                     T("❓ + 🖼️")),
            ]),
            lesson("Resimli dinleme", [
                page("Dinlerken her cümle için kafanda bir resim çiz: önce bahçe, sonra kedi, sonra Ela.",
                     T("🌳 · 🐱 · 👧")),
                page("Soru gelince resimlerine bak, cevap oradadır!", T("🖼️ ➜ ✅")),
            ], alt=True),
        ],
        "D3": [
            lesson("Konuyu bul", [
                page("Sözorman'ın yaprakları bir rüzgârla karışmış. Her yaprakta bir hikâye var. "
                     "Hangi hikâye ne hakkında, bulalım!", T("🍃 🍃 🍃")),
                page("Bir metnin konusu, “Bu metin ne hakkında?” sorusunun cevabıdır.", T("📌 ne hakkında?")),
                page("Metinde en çok hangi şeyden söz ediliyorsa, konu odur. Kuşlar göç ediyor, kuşlar dönüyor: "
                     "konu kuşların göçü.", T("🐦 ➜ 🌍 ➜ 🐦")),
                page("Konu kısa söylenir: “Kuşların göçü”, “Kedinin yemeği”, “Okulun ilk günü”.",
                     T("2–3 sözcük")),
                page("Anka buluyor: “Ayşe tohum ekti, suladı, fide çıktı.” Hep bitkiden söz ediliyor. "
                     "Konu: bir bitkinin büyümesi.", T("🌱 ➜ 🌿")),
                page("Dikkat! Metinde bir kez geçen küçük bir ayrıntı konu değildir. Bütün metne bak.",
                     T("🔍 bütün metin")),
                page("Özet: “Ne hakkında?” diye sor. En çok neden söz ediliyorsa konu odur.",
                     T("📌 konu")),
            ]),
            lesson("Başlık koyalım", [
                page("Dinlediğin hikâyeye bir ad koy. Bu ad, konuyu söyler.", T("📖 ➜ 🏷️")),
                page("“Kuşlar güneye uçtu, baharda döndü.” Başlık: “Kuşların Yolculuğu”. Konu da budur.",
                     T("🏷️ Kuşların Yolculuğu")),
            ], alt=True),
        ],
        "D4": [
            lesson("Dinlemeyi değerlendir", [
                page("Ozan Yaprak soruyor: “Masalımı iyi dinledin mi? Kendine bakalım.”", T("🌳 🤔")),
                page("Dinledikten sonra kendimize sorarız: Neyi anladım? Neyi kaçırdım?", T("✅ / ❓")),
                page("Gürültülü bir yerde dinlemek zordur. Sessiz bir yer seçmek, konuşana yakın oturmak işimizi kolaylaştırır.",
                     T("🔇 ✓")),
                page("Anlamadığımız bir yer olursa, konuşma bitince nazikçe sorarız: “Bunu tekrar anlatır mısın?”",
                     T("🙋 “Tekrar anlatır mısın?”")),
                page("Anka düşünüyor: “Masalın başını anladım ama sonunu kaçırdım, çünkü pencereden bakıyordum. "
                     "Bir dahaki sefere konuşana bakacağım.”", T("🦉 🤔")),
                page("Dikkat! Anlamadığını saklamak yerine sormak cesurca bir davranıştır.", T("🙋 ✓")),
                page("Özet: Dinledikten sonra düşün: Neyi anladım, neyi kaçırdım, neden?", T("🤔 ✅")),
            ]),
        ],
        "K1": [
            lesson("Konuşmamı yönetiyorum", [
                page("Sözorman'da her sabah ağaçlar birbirine “Günaydın!” der. Güzel konuşma güzel bir selamla başlar.",
                     T("🌳 👋 🌳")),
                page("Konuşurken karşımızdakinin yüzüne bakarız. Böylece onu önemsediğimizi gösteririz.",
                     T("👀 🗣️")),
                page("Sıramızı bekleriz. Biri konuşurken araya girmeyiz; o bitirince biz konuşuruz.",
                     T("🗣️ … ⏳ … 🗣️")),
                page("Nazik sözcükler kullanırız: “Lütfen”, “Teşekkür ederim”, “Özür dilerim”, “Günaydın”.",
                     T("lütfen · teşekkürler · özür dilerim")),
                page("Anka istiyor: “Ozan Yaprak, kalemini kullanabilir miyim lütfen?” Kalemi alınca: "
                     "“Teşekkür ederim!”", T("🦉 ✏️ 🙏")),
                page("Dikkat! Bağırarak ya da başkasının sözünü keserek konuşursak anlaşılmayız.", T("📢 ✗")),
                page("Özet: Selamlaş, yüzüne bak, sıranı bekle, nazik sözcükler kullan.", T("👋 · 👀 · ⏳ · 🙏")),
            ]),
            lesson("Sihirli sözcükler", [
                page("Bazı sözcükler kapıları açar: “Lütfen” ve “Teşekkür ederim”.", T("🚪✨")),
                page("Bir şey isterken “lütfen”, alınca “teşekkür ederim” deriz.", T("lütfen ➜ 🎁 ➜ teşekkürler")),
            ], alt=True),
        ],
        "K2": [
            lesson("Ne anlatacağım?", [
                page("Ozan Yaprak senin bir gününü merak ediyor. Anlatırken nereden başlamalıyız?", T("🌳 👂")),
                page("Anlatacaklarımızı sıraya koyarız: önce, sonra, en son.", T("1️⃣ önce · 2️⃣ sonra · 3️⃣ en son")),
                page("Örnek: “Önce kahvaltı yaptım. Sonra okula gittim. En son parkta oynadım.”",
                     T("🍳 ➜ 🏫 ➜ 🛝")),
                page("Kendimizi tanıtırken adımızı, yaşımızı ve sevdiğimiz bir şeyi söyleriz.",
                     T("👋 Adım… · Yaşım… · Severim…")),
                page("Anka anlatıyor: “Önce Kaf Dağı'ndan uçtum. Sonra Sözorman'a kondum. En son Ozan Yaprak'la masal okudum.”",
                     T("🏔️ ➜ 🌳 ➜ 📖")),
                page("Dikkat! Olayları karışık anlatırsak dinleyen anlamaz. Önce ne oldu, ona bak.", T("🔀 ✗")),
                page("Özet: Anlatacağını sıraya koy: önce, sonra, en son.", T("1️⃣ 2️⃣ 3️⃣")),
            ]),
            lesson("Resimlerle anlat", [
                page("Üç resim düşün: kalkıyorsun, kahvaltı yapıyorsun, okula gidiyorsun.", T("🛏️ 🍳 🏫")),
                page("Resimleri sırayla anlat: önce kalktım, sonra kahvaltı yaptım, en son okula gittim.",
                     T("1️⃣ 🛏️ · 2️⃣ 🍳 · 3️⃣ 🏫")),
            ], alt=True),
        ],
    },
    "d1": [
        gen("first_letter", letters=G1),
        gen("first_letter", letters=G2),
        mc("Öğretmen konuşurken ne yaparız?", ["Dinleriz", "Konuşuruz", "Oyun oynarız"], 0,
           why={1: "Öğretmen konuşurken biz de konuşursak onu duyamayız. Önce dinleriz.",
                2: "Oyun oynarken dinleyemeyiz. Öğretmene bakar, dinleriz."}),
        mc("İyi bir dinleyici nereye bakar?", ["Konuşan kişiye", "Pencereye", "Yere"], 0,
           why={1: "Pencereye bakınca dikkatimiz dağılır. Konuşana bakarız.",
                2: "Yere bakınca konuşanı göremeyiz. Konuşana bakarız."}),
        mc("Ders sırasında bir sorun var. Ne yaparsın?", ["Elimi kaldırıp sıramı beklerim", "Hemen bağırırım"], 0,
           why={1: "Bağırınca konuşanın sözünü keseriz. Elimizi kaldırıp sıramızı bekleriz."}),
    ],
    "d2": [
        listen("Ela bahçede bir kedi gördü. Kedi çok acıkmıştı. Ela ona su ve mama verdi.",
               "Ela bahçede ne gördü?", ["Kedi", "Köpek", "Kuş"], 0),
        listen("Ali sabah erkenden kalktı. Elini yüzünü yıkadı, kahvaltı yaptı ve okula gitti.",
               "Ali kahvaltıdan sonra nereye gitti?", ["Okula", "Parka", "Markete"], 0),
        listen("Deniz ile Can parkta top oynadı. Yağmur başlayınca eve koştular.",
               "Çocuklar neden eve koştu?", ["Yağmur başladı", "Acıktılar", "Top kayboldu"], 0),
        listen("Ozan Yaprak akşam ağacın altında bir masal anlattı. Bütün kuşlar onu dinledi.",
               "Masalı kim anlattı?", ["Ozan Yaprak", "Kuşlar", "Anka"], 0),
        gen("first_letter", letters=G3),
    ],
    "d3": [
        listen("Kuşlar sonbaharda sıcak ülkelere göç eder. İlkbaharda yuvalarına geri dönerler.",
               "Bu metin ne hakkında?", ["Kuşların göçü", "Deniz", "Okul"], 0),
        listen("Ayşe saksıya bir tohum ekti. Her gün suladı. Bir hafta sonra küçük bir fide çıktı.",
               "Bu metin ne hakkında?", ["Bir bitkinin büyümesi", "Bir hafta", "Saksının rengi"], 0),
        mc("Hangi ses kedi sesidir?", ["Miyav", "Hav hav", "Mö"], 0, visual=V("emoji", emoji="🐱"),
           why={1: "Hav hav köpek sesidir.", 2: "Mö inek sesidir."}),
        gen("first_letter", letters=G45),
    ],
    "d4": [
        mc("Dinlerken bir şeyi anlamadıysan ne yaparsın?", ["Sırası gelince sorarım", "Hiçbir şey yapmam"], 0,
           why={1: "Anlamadığımızı sormak cesurca bir şeydir. Konuşma bitince sorarız."}),
        mc("Hangi yerde dinlemek daha kolaydır?", ["Sessiz bir odada", "Gürültülü bir pazarda"], 0,
           why={1: "Gürültü, konuşanın sesini bastırır. Sessiz yerde daha iyi duyarız."}),
        act("Ailenden biri sana kısa bir masal okusun. Sonra masalı ona sen anlat."),
    ],
    "k1": [
        mc("Sabah sınıfa girince ne deriz?", ["Günaydın", "İyi geceler", "Afiyet olsun"], 0,
           why={1: "“İyi geceler” yatmadan önce söylenir.", 2: "“Afiyet olsun” yemekte söylenir."}),
        mc("Arkadaşın sana kalem verdi. Ne dersin?", ["Teşekkür ederim", "Günaydın", "Güle güle"], 0,
           why={1: "“Günaydın” sabah selamıdır. Bir şey alınca teşekkür ederiz.",
                2: "“Güle güle” ayrılırken söylenir. Bir şey alınca teşekkür ederiz."}),
        mc("Biri konuşurken sen de bir şey söylemek istiyorsun. Ne yaparsın?",
           ["Onun bitirmesini beklerim", "Sözünü keserim"], 0,
           why={1: "Sözünü kesersek konuşanı üzeriz. Bitirmesini bekleriz."}),
        act("Ailene “Günaydın”, “Teşekkür ederim” ve “Lütfen” sözcüklerini kullanarak bir istekte bulun."),
    ],
    "k2": [
        act("Bugün yaşadığın bir şeyi “önce, sonra, en son” diyerek ailene anlat."),
        act("Ailen sana bir resim göstersin. Resimde gördüklerini anlat."),
        mc("Kendini tanıtırken ne söylersin?", ["Adımı ve yaşımı", "Arkadaşımın adresini"], 0,
           why={1: "Arkadaşımızın adresi onun bilgisidir, paylaşmayız. Kendimizi tanıtırken adımızı ve yaşımızı söyleriz."}),
        mc("Hangisi doğru sırada?", ["Kalktım, kahvaltı yaptım, okula gittim", "Okula gittim, kalktım, kahvaltı yaptım"], 0,
           why={1: "Kalkmadan okula gidemeyiz. Önce kalkarız, sonra kahvaltı, en son okul."}),
    ],
    "k3": [
        mc("Konuşurken sesimiz nasıl olmalı?", ["Herkesin duyacağı kadar", "Bağırarak", "Fısıltıyla"], 0,
           why={1: "Bağırınca kulakları rahatsız ederiz.", 2: "Fısıltıyı herkes duyamaz."}),
        act("Bir tekerlemeyi yavaşça ve her sözcüğü doğru söyleyerek ailene söyle."),
    ],
    "k4": [
        act("Bir şey anlattıktan sonra ailene “Beni anladınız mı?” diye sor; anlaşılmayan yeri tekrar anlat."),
        mc("Konuşurken bir sözcüğü yanlış söylersen ne yaparsın?", ["Düzeltip devam ederim", "Konuşmayı bırakırım"], 0,
           why={1: "Herkes bazen yanlış söyler. Düzeltip devam ederiz."}),
    ],
    "o1_pages": [
        page("Önce harflerin seslerini öğreniriz. Sesleri birleştirince hece, heceleri birleştirince sözcük oluşur.", T("a + l = al")),
        page("a, n, e, t, i, l harfleriyle “at, el, net, tel, ateş”… gibi sözcükler okuyabiliriz.", T("at · el · tel")),
    ],
    "o1": [
        gen("syllables"),
        gen("syllables"),
        mc("Hangi sözcük “a” ve “l” seslerinden oluşur?", ["al", "el", "il"], 0),
        mc("“e + l” birleşince hangi sözcük olur?", ["el", "al", "ol"], 0),
    ],
    "o2": [
        read("Ela topu attı. Top ağaca takıldı.", "Top nereye takıldı?", ["Ağaca", "Eve", "Okula"], 0),
        read("Can elma aldı. Elmayı annesine verdi.", "Can elmayı kime verdi?", ["Annesine", "Babasına", "Öğretmenine"], 0),
    ],
    "o3": [
        read("Kedi minik ve tüylüydü. Bütün gün oynadı, akşam uyudu.", "Metin ne hakkında?", ["Bir kedi", "Bir araba", "Bir okul"], 0),
        read("Lale yağmurda şemsiyesini açtı. Islanmadan eve vardı.", "Lale neden ıslanmadı?", ["Şemsiyesi vardı", "Yağmur durdu"], 0),
    ],
    "o4": [
        mc("Okumak için hangi ortam daha uygundur?", ["Aydınlık ve sessiz bir oda", "Karanlık ve gürültülü bir yer"], 0),
        mc("Kitap okurken nasıl otururuz?", ["Dik", "Yatarak, kitabı gözümüze yaklaştırarak"], 0),
    ],
    "o5": [
        act("Ailenin yanında kısa bir metni sesli oku. Takıldığın sözcükleri birlikte tekrar edin."),
        mc("Okurken bir sözcüğü yanlış okursan ne yaparsın?", ["Durup doğrusunu tekrar okurum", "Hiç umursamam"], 0),
    ],
    "y1_pages": [
        page("Kalemi doğru tutarız: başparmak ve işaret parmağıyla, orta parmağa dayayarak.", T("✏️")),
        page("Önce çizgi çalışmaları yapar, sonra harfleri doğru yönden yazmayı öğreniriz.", T("〰️ ➜ a")),
    ],
    "y1": [
        act("Bu haftaki harflerden birini defterine 5 kez, doğru yönden yaz ve ailene göster."),
        act("Kendi adını defterine yaz ve süsle."),
        mc("Kalemi hangi parmaklarımızla tutarız?", ["Başparmak ve işaret parmağı", "Serçe parmak"], 0),
    ],
    "y2": [
        act("Bir resim çiz ve altına onu anlatan bir sözcük yaz."),
        mc("“At” sözcüğünü yazmak için hangi harfler gerekir?", ["a ve t", "e ve l", "i ve n"], 0),
    ],
    "y3": [
        mc("Cümle hangi harfle başlar?", ["Büyük harfle", "Küçük harfle"], 0),
        mc("Hangi cümle doğru yazılmıştır?", ["Ali eve geldi.", "ali eve geldi", "Ali eve geldi"], 0),
        mc("Kişi adları nasıl yazılır?", ["Büyük harfle başlar", "Hep küçük harfle"], 0),
        mc("Soru soran cümlenin sonuna ne koyarız?", ["Soru işareti (?)", "Nokta (.)"], 0),
    ],
    "y4": [
        act("Yazdığın bir cümleyi ailenle birlikte kontrol et: büyük harf ve nokta doğru mu?"),
        mc("Sözcükler arasına ne bırakırız?", ["Boşluk", "Hiçbir şey"], 0),
    ],
}

PACK = pack("turkce", 1, build(1, P))
