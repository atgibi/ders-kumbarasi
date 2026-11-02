"""4. sınıf Fen Bilimleri içerik paketi (TYMM FB.4.x.x). Pedagojik onay gerekir."""

from common import pack, outcome, lesson, page, mc, act, V

E = lambda e: V("emoji", emoji=e)
T = lambda t: V("text", text=t)

OUTCOMES = [
    outcome("FB.4.1.1", lessons=[lesson("Bilim nedir?", [
        page("Bilim, kanıta dayanır ve yeni bulgularla değişebilir. Eskiden doğru sanılan bazı bilgiler yeni gözlemlerle değişmiştir.", T("🔬 📈")),
    ])], cards=[
        mc("Bilimsel bilgi için hangisi doğrudur?", ["Yeni kanıtlarla değişebilir", "Asla değişmez"], 0),
        mc("Bilimsel bilgi neye dayanır?", ["Gözlem ve deneye", "Söylentiye"], 0),
        mc("Bir bilim insanı farklı sonuç bulursa ne yapar?", ["Yeniden inceler ve paylaşır", "Gizler"], 0),
    ]),
    outcome("FB.4.1.2", lessons=[lesson("Güvenilir kaynak", [
        page("Bilgiyi resmî kurumlar, bilimsel kitaplar ve uzmanlar gibi güvenilir kaynaklardan araştırırız.", T("📚 🏛️ 👩‍🔬")),
        page("İnternette gördüğümüz her bilgi doğru olmayabilir; birden fazla kaynaktan kontrol ederiz.", E("🔎")),
    ])], cards=[
        mc("Hangisi daha güvenilir bir kaynaktır?", ["Resmî bir kurumun sitesi", "Adı bilinmeyen bir sosyal medya paylaşımı"], 0),
        mc("İnternette bir bilgi görünce ne yaparız?", ["Başka kaynaklardan da kontrol ederiz", "Hemen herkese yayarız"], 0),
        mc("Bir hastalık hakkında en doğru bilgiyi kim verir?", ["Doktor", "Reklam"], 0),
    ]),
    outcome("FB.4.2.1", lessons=[lesson("Besinlerde neler var?", [
        page("Besinlerde karbonhidrat, protein, yağ, vitamin, mineral ve su bulunur.", T("🍞 🥚 🧈 🍊 🥛 💧")),
        page("Nişasta içeren besinlere iyot damlatınca renk koyu mavi-mora döner. Bu basit bir deneydir.", T("🥔 + iyot → 🟣")),
    ])], cards=[
        mc("Ekmek en çok hangi besin ögesini içerir?", ["Karbonhidrat", "Vitamin", "Su"], 0, visual=E("🍞")),
        mc("Yumurta en çok hangi besin ögesini içerir?", ["Protein", "Karbonhidrat"], 0, visual=E("🥚")),
        mc("Nişastalı besine iyot damlatınca hangi renk oluşur?", ["Koyu mavi-mor", "Kırmızı", "Beyaz"], 0),
        mc("Tereyağı en çok hangi besin ögesini içerir?", ["Yağ", "Protein", "Vitamin"], 0),
    ]),
    outcome("FB.4.2.2", lessons=[lesson("Vitamin ve mineraller", [
        page("Meyve ve sebzeler vitamin ve mineral açısından zengindir. Portakalda C vitamini, sütte kalsiyum vardır.", T("🍊 C · 🥛 Ca")),
    ])], cards=[
        mc("C vitamini en çok hangisinde bulunur?", ["Portakal", "Şeker", "Tuz"], 0),
        mc("Kemik ve dişlerimiz için gerekli kalsiyum en çok hangisinde bulunur?", ["Süt", "Cips"], 0),
        mc("Vitamin ve mineraller için en iyi kaynak hangisidir?", ["Meyve ve sebzeler", "Gazlı içecekler"], 0),
    ]),
    outcome("FB.4.2.3", lessons=[lesson("Besinlerin görevleri", [
        page("Karbonhidrat ve yağlar enerji verir. Proteinler büyümemizi sağlar. Vitaminler ve mineraller bizi hastalıklardan korur.", T("⚡ 💪 🛡️")),
    ])], cards=[
        mc("Büyümemizi ve onarılmamızı sağlayan besin ögesi hangisidir?", ["Protein", "Su", "Yağ"], 0),
        mc("Koşmadan önce enerji için hangisi uygundur?", ["Karbonhidratlı besin (ekmek, makarna)", "Sadece su"], 0),
        mc("Hastalıklara karşı korunmamıza yardım eden hangisidir?", ["Vitaminler", "Şekerler"], 0),
    ]),
    outcome("FB.4.3.1", lessons=[lesson("Dünya'nın şekli", [
        page("Dünya'mız küreye benzer. Uzaydan çekilen fotoğraflar bunu gösterir.", T("🌍")),
        page("Uzaklaşan bir geminin önce gövdesi, en son direği görünmez olur. Bu da Dünya'nın yuvarlak olduğunun kanıtıdır.", E("⛵")),
    ])], cards=[
        mc("Dünya'nın şekli hangisine benzer?", ["Küre", "Küp", "Tepsi"], 0),
        mc("Dünya'nın yuvarlak olduğunun kanıtlarından biri hangisidir?", ["Uzaydan çekilen fotoğraflar", "Masanın düz olması"], 0),
        mc("Ufukta kaybolan geminin en son görünen yeri neresidir?", ["Direği", "Gövdesi"], 0),
    ]),
    outcome("FB.4.3.2", lessons=[lesson("Dünya'nın katmanları", [
        page("Dünya'nın dış kısmı taş küre, su küre ve hava küreden oluşur.", T("🪨 🌊 💨")),
        page("İçeriye doğru yer kabuğu, manto ve çekirdek bulunur. Bir şeftaliye benzetebiliriz: kabuk, meyve ve çekirdek.", T("🍑")),
    ])], cards=[
        mc("Dünya'nın en dış katmanı hangisidir?", ["Yer kabuğu", "Çekirdek", "Manto"], 0),
        mc("Dünya'nın merkezinde ne bulunur?", ["Çekirdek", "Hava küre"], 0),
        mc("Denizler ve göller hangi katmandadır?", ["Su küre", "Hava küre", "Çekirdek"], 0),
    ]),
    outcome("FB.4.3.3", lessons=[lesson("Dünya'nın hareketleri", [
        page("Dünya kendi etrafında döner; bir dönüşü 24 saat sürer. Bu dönüşle gece ve gündüz oluşur.", T("🌍 ↻ 🌞🌙")),
        page("Dünya aynı zamanda Güneş'in etrafında dolanır; bir dolanış yaklaşık 365 gün, yani 1 yıl sürer.", T("🌍 → ☀️")),
    ])], cards=[
        mc("Gece ve gündüz nasıl oluşur?", ["Dünya'nın kendi etrafında dönmesiyle", "Güneş'in sönmesiyle"], 0),
        mc("Dünya kendi etrafında bir turunu kaç saatte tamamlar?", ["12", "24", "365"], 1),
        mc("Dünya Güneş'in etrafında bir turunu yaklaşık ne kadar sürede tamamlar?", ["1 gün", "1 ay", "1 yıl"], 2),
    ]),
    outcome("FB.4.4.1", lessons=[lesson("Hâl değişimi", [
        page("Isınan buz erir, sıvı olur. Soğuyan su donar, buz olur.", T("🧊 ⇄ 💧")),
        page("Isınan su buharlaşır, gaz olur. Soğuk yüzeye değen su buharı yoğuşur, damlacık olur.", T("💧 ⇄ ♨️")),
    ])], cards=[
        mc("Buzun erimesi için ne gerekir?", ["Isınması", "Soğuması"], 0, visual=E("🧊")),
        mc("Kaynayan sudan çıkan buhar soğuk kapakta neye dönüşür?", ["Su damlacıklarına", "Buza", "Kuma"], 0),
        mc("Suyun donmasıyla ne oluşur?", ["Buz", "Buhar"], 0),
        mc("Islak çamaşırlar güneşte nasıl kurur?", ["Su buharlaşır", "Su donar"], 0),
    ]),
    outcome("FB.4.4.2", lessons=[lesson("Isı maddeyi değiştirir", [
        page("Tereyağı ısıtılınca erir, çikolata sıcakta yumuşar. Yumurta pişince bir daha eski hâline dönmez.", T("🧈 🍫 🍳")),
    ])], cards=[
        mc("Tereyağı ısıtılınca ne olur?", ["Erir", "Donar"], 0),
        mc("Hangisi ısıtılınca eski hâline geri dönmez?", ["Pişen yumurta", "Eriyen buz"], 0),
        act("Ailenle bir buz küpünü ve bir parça tereyağını aynı tabağa koyup hangisinin daha hızlı eridiğini gözlemleyin."),
    ]),
    outcome("FB.4.5.1", lessons=[lesson("Mıknatısın kutupları", [
        page("Her mıknatısın N (kuzey) ve S (güney) kutbu vardır.", T("🧲 N | S")),
        page("Aynı kutuplar birbirini iter, zıt kutuplar birbirini çeker.", T("N-N ↔ itme · N-S → çekme")),
    ])], cards=[
        mc("İki mıknatısın N kutupları yaklaştırılırsa ne olur?", ["Birbirlerini iterler", "Birbirlerini çekerler"], 0),
        mc("N ve S kutupları yaklaştırılırsa ne olur?", ["Çekerler", "İterler"], 0),
        mc("Mıknatısın kaç kutbu vardır?", ["1", "2", "4"], 1),
    ]),
    outcome("FB.4.5.2", lessons=[lesson("Mıknatıs neyi çeker?", [
        page("Mıknatıs demir, nikel ve kobalt içeren maddeleri çeker. Tahta, plastik ve camı çekmez.", T("📎 ✅  🪵 ❌")),
    ])], cards=[
        mc("Mıknatıs hangisini çeker?", ["Demir çivi", "Tahta kalem", "Plastik cetvel"], 0),
        mc("Mıknatıs hangisini çekmez?", ["Cam bardak", "Ataç"], 0),
        act("Ailenle evdeki bir buzdolabı mıknatısıyla hangi eşyaların çekildiğini deneyin."),
    ]),
    outcome("FB.4.5.3", lessons=[lesson("Mıknatıs nerelerde kullanılır?", [
        page("Buzdolabı kapağı, pusula, çantaların kapaklı cebi ve hurda ayırma makineleri mıknatısla çalışır.", T("🧊 🧭 👜")),
    ])], cards=[
        mc("Pusulada mıknatısın görevi nedir?", ["Yön göstermek", "Işık vermek"], 0, visual=E("🧭")),
        mc("Hurdalıkta demir parçaları nasıl ayrılır?", ["Büyük mıknatıslarla", "Süzgeçle"], 0),
        mc("Buzdolabının kapağı neden sıkıca kapanır?", ["İçinde mıknatıs vardır", "Yapıştırıcı vardır"], 0),
    ]),
    outcome("FB.4.6.1", lessons=[lesson("Basit elektrik devresi", [
        page("Pil, ampul, kablo ve anahtardan basit bir devre kurulur.", T("🔋 — 💡 — 🔘")),
        page("Anahtar kapalıysa devre tamamlanır, ampul yanar. Anahtar açıksa ampul yanmaz.", T("🔘 kapalı → 💡")),
    ])], cards=[
        mc("Basit devrede elektrik enerjisini sağlayan hangisidir?", ["Pil", "Ampul", "Kablo"], 0),
        mc("Anahtar açık olursa ampul ne olur?", ["Yanmaz", "Daha parlak yanar"], 0),
        mc("Devre elemanlarını birbirine ne bağlar?", ["Kablo", "İp"], 0),
    ]),
    outcome("FB.4.6.2", lessons=[lesson("Enerji kaynakları", [
        page("Güneş, rüzgâr ve su yenilenebilir enerji kaynaklarıdır; tükenmezler.", T("☀️ 🌬️ 💧")),
        page("Kömür, petrol ve doğal gaz yenilenemez; tükenebilir ve havayı kirletebilir.", T("⛏️ 🛢️")),
    ])], cards=[
        mc("Hangisi yenilenebilir bir enerji kaynağıdır?", ["Güneş", "Kömür", "Petrol"], 0),
        mc("Hangisi yenilenemez bir enerji kaynağıdır?", ["Doğal gaz", "Rüzgâr"], 0),
        mc("Rüzgâr türbinleri hangi enerjiden elektrik üretir?", ["Rüzgâr", "Kömür"], 0),
    ]),
    outcome("FB.4.7.1", lessons=[lesson("Nasıl görürüz?", [
        page("Işık bir cisme çarpıp gözümüze ulaşınca o cismi görürüz. Tamamen karanlık bir odada hiçbir şeyi göremeyiz.", T("💡 → 🍎 → 👁️")),
    ])], cards=[
        mc("Görmemiz için ne gereklidir?", ["Işık", "Ses"], 0),
        mc("Tamamen karanlık bir odada kırmızı topu görebilir miyiz?", ["Hayır", "Evet"], 0),
        act("Ailenle karanlık bir odada önce ışık kapalıyken, sonra el feneriyle bir oyuncağa bakın."),
    ]),
    outcome("FB.4.7.2", lessons=[lesson("Doğal ve yapay ışık", [
        page("Güneş, yıldızlar, ateş böceği ve şimşek doğal ışık kaynaklarıdır.", T("☀️ ⭐ ⚡")),
        page("Ampul, el feneri ve mum insanların yaptığı yapay ışık kaynaklarıdır.", T("💡 🔦 🕯️")),
    ])], cards=[
        mc("Hangisi doğal ışık kaynağıdır?", ["Güneş", "El feneri", "Ampul"], 0),
        mc("Hangisi yapay ışık kaynağıdır?", ["Masa lambası", "Ateş böceği", "Yıldız"], 0),
        mc("Ay kendi ışığını üretir mi?", ["Hayır, Güneş'in ışığını yansıtır", "Evet"], 0),
    ]),
    outcome("FB.4.7.3", lessons=[lesson("Işık kirliliği", [
        page("Gereğinden fazla ve yanlış yöne tutulan ışıklar ışık kirliliğine yol açar. Göçmen kuşlar yön şaşırabilir, insanların uykusu bozulur.", T("🌃 🐦")),
        page("Işıkları aşağıya yönlendirmek ve gereksiz ışıkları kapatmak çözümdür.", E("💡")),
    ])], cards=[
        mc("Işık kirliliği hangi canlıları etkiler?", ["Kuşlar ve insanlar dahil pek çok canlıyı", "Hiçbir canlıyı"], 0),
        mc("Işık kirliliğini azaltmak için ne yapabiliriz?", ["Gereksiz ışıkları kapatmak", "Daha çok ışık yakmak"], 0),
        mc("Şehirde yıldızları neden az görürüz?", ["Işık kirliliği yüzünden", "Yıldızlar şehirde yok"], 0),
    ]),
    outcome("FB.4.8.1", lessons=[lesson("Sürdürülebilir yaşam alanı", [
        page("Güneş panelleri, yağmur suyu toplama, geri dönüşüm ve yeşil alanlar yaşam alanlarını sürdürülebilir yapar.", T("☀️ 🌧️ ♻️ 🌳")),
    ])], cards=[
        mc("Hangisi sürdürülebilir bir evde olur?", ["Güneş paneli", "Sürekli açık lambalar"], 0),
        mc("Yağmur suyu toplamak neye yarar?", ["Bahçe sulamada su tasarrufu sağlar", "Hiçbir işe yaramaz"], 0),
        act("Ailenle hayalinizdeki sürdürülebilir bir evi çizin: enerji, su ve atıkları nasıl yöneteceğinizi gösterin."),
    ]),
]

PACK = pack("fen_bilimleri", 4, OUTCOMES)
