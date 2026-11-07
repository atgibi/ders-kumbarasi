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
    "o1_pages": [],
    "o1": [
        gen("syllables"),
        gen("syllables"),
        mc("Hangi sözcük “a” ve “l” seslerinden oluşur?", ["al", "el", "il"], 0,
           why={1: "“el” e sesiyle başlar. “a” ile “l” birleşince “al” olur.",
                2: "“il” i sesiyle başlar. “a” ile “l” birleşince “al” olur."}),
        mc("“e + l” birleşince hangi sözcük olur?", ["el", "al", "ol"], 0,
           why={1: "“al” a sesiyle başlar. e ile l: “el”.", 2: "“ol” o sesiyle başlar. e ile l: “el”."}),
        mc("“ta” ve “ne” hecelerini birleştir.", ["tane", "neta", "tene"], 0,
           why={1: "Heceleri verilen sırayla oku: önce “ta”, sonra “ne”.",
                2: "İlk hece “ta”; “te” değil. Birleşince “tane”."}),
    ],
    "o2": [
        read("Ela topu attı. Top ağaca takıldı.", "Top nereye takıldı?", ["Ağaca", "Eve", "Okula"], 0),
        read("Can elma aldı. Elmayı annesine verdi.", "Can elmayı kime verdi?", ["Annesine", "Babasına", "Öğretmenine"], 0),
        read("Ozan Yaprak bir masal okudu. Kuşlar onu dinledi.", "Masalı kim dinledi?", ["Kuşlar", "Kediler", "Balıklar"], 0),
    ],
    "o3": [
        read("Kedi minik ve tüylüydü. Bütün gün oynadı, akşam uyudu.", "Metin ne hakkında?", ["Bir kedi", "Bir araba", "Bir okul"], 0),
        read("Lale yağmurda şemsiyesini açtı. Islanmadan eve vardı.", "Lale neden ıslanmadı?", ["Şemsiyesi vardı", "Yağmur durdu"], 0),
        read("Ali arkadaşının düşen kalemini aldı ve ona verdi. Arkadaşı çok sevindi.",
             "Bu metin bize ne anlatıyor?", ["Yardım etmek güzeldir", "Kalem pahalıdır"], 0),
    ],
    "o4": [
        mc("Okumak için hangi ortam daha uygundur?", ["Aydınlık ve sessiz bir oda", "Karanlık ve gürültülü bir yer"], 0,
           why={1: "Karanlıkta harfleri zor görürüz, gürültüde dikkatimiz dağılır."}),
        mc("Kitap okurken nasıl otururuz?", ["Dik", "Yatarak, kitabı gözümüze yaklaştırarak"], 0,
           why={1: "Kitabı göze çok yaklaştırmak gözümüzü yorar. Dik otururuz."}),
        mc("Okurken yorulduysan ne yaparsın?", ["Biraz dinlenip devam ederim", "Kitabı fırlatırım"], 0,
           why={1: "Kitaplar bizim dostumuz. Dinlenip sonra devam ederiz."}),
    ],
    "o5": [
        act("Ailenin yanında kısa bir metni sesli oku. Takıldığın sözcükleri birlikte tekrar edin."),
        mc("Okurken bir sözcüğü yanlış okursan ne yaparsın?", ["Durup doğrusunu tekrar okurum", "Hiç umursamam"], 0,
           why={1: "Yanlış okunan sözcük anlamı değiştirebilir. Durup yeniden okuruz."}),
    ],
    "y1_pages": [],
    "y1": [
        act("Bu haftaki harflerden birini defterine 5 kez, doğru yönden yaz ve ailene göster."),
        act("Kendi adını defterine yaz ve süsle."),
        mc("Kalemi hangi parmaklarımızla tutarız?", ["Başparmak ve işaret parmağı", "Serçe parmak"], 0,
           why={1: "Serçe parmakla kalemi sıkıca tutamayız. Başparmak ve işaret parmağıyla tutar, orta parmağa dayarız."}),
        mc("Yazarken defterimiz nasıl durmalı?", ["Önümüzde, hafif eğik", "Sıranın altında"], 0,
           why={1: "Sıranın altında göremeyiz. Defter önümüzde, hafif eğik durur."}),
    ],
    "y2": [
        act("Bir resim çiz ve altına onu anlatan bir sözcük yaz."),
        mc("“At” sözcüğünü yazmak için hangi harfler gerekir?", ["a ve t", "e ve l", "i ve n"], 0,
           why={1: "e ve l ile “el” yazılır.", 2: "i ve n ile “in” yazılır. “At” için a ve t gerekir."}),
        mc("Bir resmin altına ne yazarız?", ["Resmi anlatan bir sözcük", "Rastgele harfler"], 0,
           why={1: "Rastgele harfler bir şey anlatmaz. Resimde ne varsa onu yazarız."}),
    ],
    "y3": [
        mc("Cümle hangi harfle başlar?", ["Büyük harfle", "Küçük harfle"], 0,
           why={1: "Cümlenin ilk harfi her zaman büyük yazılır."}),
        mc("Hangi cümle doğru yazılmıştır?", ["Ali eve geldi.", "ali eve geldi", "Ali eve geldi"], 0,
           why={1: "Hem “Ali” küçük harfle başlamış hem de sonunda nokta yok.",
                2: "Cümle bitince nokta koyarız."}),
        mc("Kişi adları nasıl yazılır?", ["Büyük harfle başlar", "Hep küçük harfle"], 0,
           why={1: "Ali, Ela, Can gibi adlar büyük harfle başlar."}),
        mc("Soru soran cümlenin sonuna ne koyarız?", ["Soru işareti (?)", "Nokta (.)"], 0,
           why={1: "Nokta bir bilgiyi bitirir. Soru soruyorsak soru işareti koyarız."}),
    ],
    "y4": [
        act("Yazdığın bir cümleyi ailenle birlikte kontrol et: büyük harf ve nokta doğru mu?"),
        mc("Sözcükler arasına ne bırakırız?", ["Boşluk", "Hiçbir şey"], 0,
           why={1: "Boşluk bırakmazsak sözcükler birbirine karışır: “alieve” yerine “Ali eve”."}),
    ],
}

P["lessons"].update({
    "K3": [
        lesson("Konuşma kuralları", [
            page("Sözorman'da şarkı söyleyen dere çok hızlı akınca kimse sözlerini anlamıyor. Konuşmak da böyledir!",
                 T("🌊 🎵")),
            page("Herkesin duyacağı bir sesle konuşuruz: ne bağırarak ne de fısıldayarak.", T("🔊 orta ses")),
            page("Ne çok hızlı ne çok yavaş konuşuruz. Sözcükleri tek tek, doğru söyleriz.", T("🐢 · 🐇 ✗   ·   🚶 ✓")),
            page("Sözcüğün sonunu yutmayız: “gidiyom” değil “gidiyorum”.", T("gidiyorum ✓")),
            page("Anka deniyor: “Tekerlemeyi önce yavaşça söylüyorum: Bir berber bir berbere… Sonra biraz hızlandırıyorum.”",
                 T("🦉 🗣️")),
            page("Dikkat! Ağzımız doluyken konuşmayız; söylediklerimiz anlaşılmaz.", T("🍞 🤐")),
            page("Özet: Duyulacak kadar yüksek, anlaşılacak kadar yavaş, sözcükleri tam söyleyerek konuş.",
                 T("🔊 · 🚶 · ✅")),
        ]),
        lesson("Ayna oyunu", [
            page("Aynanın karşısında bir cümle söyle. Ağzın her sözcükte açılıyor mu?", T("🪞 🗣️")),
            page("Sonra aynı cümleyi ailene söyle. Anladılar mı?", T("👂 ✓")),
        ], alt=True),
    ],
    "K4": [
        lesson("Konuşmamı değerlendiriyorum", [
            page("Ozan Yaprak her şarkıdan sonra dinleyenlere sorar: “Beğendiniz mi? Anlaşıldı mı?”", T("🌳 🎵 ❓")),
            page("Konuştuktan sonra biz de düşünürüz: Beni anladılar mı?", T("🤔")),
            page("Anlaşılmayan bir yer varsa tekrar, daha yavaş anlatırız.", T("🔁 🐢")),
            page("Bir sözcüğü yanlış söylersek düzeltip devam ederiz. Herkes bazen yanlış söyler.", T("✏️ ➜ 🗣️")),
            page("Anka düşünüyor: “Masalı anlatırken çok hızlıydım, sonunu kimse anlamadı. Bir dahakine yavaş anlatacağım.”",
                 T("🦉 🤔")),
            page("Dikkat! Başkalarının önerilerini dinlemek konuşmamızı güzelleştirir.", T("👂 💡")),
            page("Özet: Konuştuktan sonra sor: “Anlaşıldım mı? Neyi daha iyi yapabilirim?”", T("❓ ✅")),
        ]),
    ],
    "O1": [
        lesson("Okumaya başlıyoruz", [
            page("Sözorman'ın ağaçlarında harfli yapraklar var! Yaprakları birleştirebilen, ormanın sözlerini okuyabilir.",
                 T("🍃a 🍃l")),
            page("Her harfin bir sesi vardır. “a” harfi “aaa” diye, “l” harfi “lll” diye ses verir.", T("a · l")),
            page("Sesleri birleştirince hece oluşur: a + l = al. Heceleri birleştirince sözcük: e + l = el.",
                 T("a + l = al")),
            page("a, n, e, t, i, l harfleriyle “at, el, net, tel, ilet” gibi sözcükler okuyabiliriz.", T("at · el · tel · ilet")),
            page("Anka okuyor: “t ile a: ta. n ile e: ne. ta ve ne: tane!”", T("ta + ne = tane")),
            page("Dikkat! Heceleri sırayla oku. “ta-ne” ile “ne-ta” farklıdır.", T("ta-ne ≠ ne-ta")),
            page("Özet: Sesleri birleştir, hece olsun; heceleri birleştir, sözcük olsun.", T("ses ➜ hece ➜ sözcük")),
        ]),
        lesson("Sesleri uzat", [
            page("Harflerin sesini uzatarak söyle: “aaal”. Uzatınca birleştirmek kolaylaşır.", T("aaa…lll = al")),
            page("“eeelll” de: el! Şimdi sen dene: “aaattt”.", T("aaa…ttt = at")),
        ], alt=True),
    ],
    "O2": [
        lesson("Okuduğumu anlıyorum", [
            page("Ozan Yaprak sana bir yaprak mektup gönderdi. Okuyup anlamamız gerek!", T("🍃 ✉️")),
            page("Okumadan önce başlığa ve resimlere bakar, ne anlatılacağını tahmin ederiz.", T("🖼️ ➜ 🤔")),
            page("Okurken kendimize sorarız: Kim? Ne yaptı? Nerede?", T("kim · ne · nerede")),
            page("Örnek: “Ela topu attı. Top ağaca takıldı.” Kim? Ela. Ne oldu? Top ağaca takıldı.", T("👧 ⚽ 🌳")),
            page("Anka okuyor: “Can elma aldı. Elmayı annesine verdi.” Elmayı kime verdi? Metne bakıyorum: annesine!",
                 T("🍎 ➜ 👩")),
            page("Dikkat! Cevabı tahminle değil, metinde arayarak buluruz.", T("🔍 metin")),
            page("Özet: Önce tahmin et, okurken soru sor, cevabı metinde bul.", T("🤔 · ❓ · 🔍")),
        ]),
        lesson("Parmakla takip", [
            page("Okurken parmağınla sözcüklerin altını takip et; satırı kaçırmazsın.", T("👉 Ela topu attı.")),
            page("Bir cümle bitince dur ve ne okuduğunu kendine anlat.", T("⏸️ 🤔")),
        ], alt=True),
    ],
    "O3": [
        lesson("Okuduğumu çözümlüyorum", [
            page("Sözorman'da her masalın bir sırrı var: bize vermek istediği bir mesaj. Onu bulalım!", T("📖 💡")),
            page("Metnin konusu “ne hakkında?” sorusunun cevabıdır: bir kedi, bir yağmurlu gün…", T("📌 konu")),
            page("Bazı metinler bize bir şey öğretmek ister: yardım etmek güzeldir, paylaşmak mutlu eder.",
                 T("💡 mesaj")),
            page("Neden-sonuç: “Lale şemsiyesini açtı, ıslanmadı.” Neden ıslanmadı? Çünkü şemsiyesi vardı.",
                 T("☂️ ➜ 🙂")),
            page("Anka buluyor: “Ali düşen kalemi arkadaşına verdi, arkadaşı sevindi. Mesaj: yardım etmek güzeldir.”",
                 T("✏️ 🤝 😊")),
            page("Dikkat! Mesaj metinde tek bir kez yazmaz; olaylardan çıkarırız.", T("olaylar ➜ 💡")),
            page("Özet: Konuyu bul, neden-sonuçlara bak, metnin mesajını düşün.", T("📌 · ➜ · 💡")),
        ]),
    ],
    "O4": [
        lesson("Okumayı etkileyenler", [
            page("Ozan Yaprak hep aynı yerde okur: güneşli bir dalda, sessizce.", T("🌳 ☀️ 📖")),
            page("Aydınlık bir ortamda okuruz; karanlıkta harfleri göremeyiz.", T("💡 ✓")),
            page("Sessiz bir yer seçeriz; gürültü dikkatimizi dağıtır.", T("🤫 ✓")),
            page("Dik otururuz, kitabı gözümüzden bir karış uzakta tutarız.", T("🪑 · 📖 ↔️ ✋")),
            page("Anka anlatıyor: “Televizyon açıkken okuyamadım. Kapattım, sessiz odaya geçtim; şimdi her şeyi anlıyorum.”",
                 T("📺 ✗ · 🤫 ✓")),
            page("Dikkat! Yorulursan biraz dinlen, sonra devam et.", T("😌 ➜ 📖")),
            page("Özet: Aydınlık, sessiz bir yer; dik oturuş; yorulunca kısa mola.", T("💡 · 🤫 · 🪑 · 😌")),
        ]),
    ],
    "O5": [
        lesson("Okumamı değerlendiriyorum", [
            page("Ozan Yaprak her okumadan sonra kendine sorar: “Bugün ne öğrendim?”", T("🌳 🤔")),
            page("Okuduktan sonra düşünürüz: Akıcı okudum mu? Nerede takıldım?", T("✅ / ⏸️")),
            page("Takıldığımız sözcüğü heceleyerek tekrar okuruz.", T("ke-di ➜ kedi")),
            page("Yanlış okuduğumuzu fark edersek durup doğrusunu okuruz.", T("🔁")),
            page("Anka düşünüyor: “Bugün ‘tane’ sözcüğünde takıldım. Heceledim: ta-ne. Yarın daha hızlı okuyacağım!”",
                 T("🦉 ta-ne")),
            page("Dikkat! Takılmak ayıp değildir; herkes okumayı adım adım öğrenir.", T("🪜")),
            page("Özet: Okuduktan sonra takıldığın yerleri bul ve onları tekrar oku.", T("🔍 ➜ 🔁")),
        ]),
    ],
    "Y1": [
        lesson("Yazıya başlıyoruz", [
            page("Ozan Yaprak yaprak kalemle yazıyor. Yazmak, sözlerimizi kalıcı yapar!", T("🍃 ✏️")),
            page("Kalemi doğru tutarız: başparmak ve işaret parmağıyla, orta parmağa dayayarak.", T("✏️ 👌")),
            page("Defterimiz önümüzde, hafif eğik durur. Dik otururuz.", T("📒 🪑")),
            page("Önce çizgi çalışmaları yaparız: düz, eğik, dalgalı çizgiler.", T("| / 〰️")),
            page("Sonra harfleri doğru yönden yazmayı öğreniriz. Her harfin bir başlangıç noktası vardır.",
                 T("● ➜ a")),
            page("Dikkat! Kalemi çok sıkarsak elimiz yorulur. Hafifçe tut.", T("✋ rahat")),
            page("Özet: Kalemi doğru tut, defteri düz koy, harfleri doğru yönden yaz.", T("✏️ · 📒 · ➜")),
        ]),
    ],
    "Y2": [
        lesson("Yazımda içerik", [
            page("Ozan Yaprak bir resmin altına ne yazacağını düşünüyor. Önce ne anlatacağını seçmeli!", T("🖼️ 🤔")),
            page("Yazmadan önce düşünürüz: Ne anlatmak istiyorum?", T("💭")),
            page("Resim çizip altına onu anlatan bir sözcük yazabiliriz: 🐱 kedi.", T("🐱 kedi")),
            page("Sonra kısa bir cümle yazarız: “Kedi uyudu.”", T("Kedi uyudu.")),
            page("Anka yazıyor: “Resmimde bir at var. Altına ‘at’ yazdım. Sonra ‘At koştu.’ diye bir cümle ekledim.”",
                 T("🐴 at · At koştu.")),
            page("Dikkat! Yazdığımız sözcük resimle ilgili olmalı.", T("🐴 ➜ at ✓")),
            page("Özet: Düşün, bir sözcük yaz, sonra bir cümle kur.", T("💭 ➜ sözcük ➜ cümle")),
        ]),
    ],
    "Y3": [
        lesson("Yazma kuralları", [
            page("Sözorman'ın yapraklarına yazılan sözler kurallara uyarsa rüzgâr onları doğru okur!", T("🍃 📜")),
            page("Cümleye büyük harfle başlarız: “Ali eve geldi.”", T("A li eve geldi.")),
            page("Cümle bitince nokta koyarız. Soru soruyorsak soru işareti koyarız.", T(". · ?")),
            page("Kişi adları büyük harfle başlar: Ali, Ela, Can.", T("Ali · Ela · Can")),
            page("Sözcükler arasında boşluk bırakırız: “Alieve” değil, “Ali eve”.", T("Ali␣eve")),
            page("Dikkat! Soru cümlesinin sonuna nokta koyarsak okuyan soru olduğunu anlamaz: “Nereye gidiyorsun?”",
                 T("? ✓")),
            page("Özet: Büyük harfle başla, boşluk bırak, nokta ya da soru işaretiyle bitir.", T("A … . / ?")),
        ]),
        lesson("Cümle treni", [
            page("Cümle bir tren gibidir: lokomotif büyük harf, vagonlar sözcükler, son vagon nokta.",
                 T("🚂A 🚃 🚃 🚃.")),
            page("Vagonlar arasında boşluk olmazsa tren raydan çıkar!", T("🚃␣🚃")),
        ], alt=True),
    ],
    "Y4": [
        lesson("Yazımı değerlendiriyorum", [
            page("Ozan Yaprak yazdıktan sonra hep bir kez daha okur.", T("🌳 🔍")),
            page("Yazdıktan sonra kontrol ederiz: Büyük harfle başladım mı?", T("A ✓")),
            page("Sözcükler arasında boşluk var mı? Sonunda nokta var mı?", T("␣ ✓ · . ✓")),
            page("Harflerim okunaklı mı? Gerekirse silip yeniden yazarız.", T("✏️ 🔁")),
            page("Anka kontrol ediyor: “‘ali eve geldi’ yazmışım. Ali büyük harfle başlamalı, sona nokta! "
                 "Düzelttim: ‘Ali eve geldi.’”", T("ali ➜ Ali.")),
            page("Dikkat! Ailenle birlikte kontrol etmek de çok yardımcı olur.", T("👨‍👩‍👧 🔍")),
            page("Özet: Yazdıktan sonra büyük harf, boşluk ve noktayı kontrol et.", T("A · ␣ · .")),
        ]),
    ],
})

PACK = pack("turkce", 1, build(1, P))
