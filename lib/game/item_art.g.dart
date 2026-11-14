// ÜRETİLMİŞ DOSYA: elle değiştirmeyin. Kaynak: tools/hero/items.py
// python3 tools/hero/items.py

/// Eşya çizimleri: kahramanın çizim alanında SVG parçaları.
const itemArt = <String, String>{
  'atki':
      '<path d="M60 97Q80 109 100 97L103 106Q80 121 57 106Z" fill="#B8432F"/><path d="M88 108L97 136L87 138L82 111Z" fill="#B8432F"/><path d="M65 103l3 4M75 106l2 5M86 106l-1 5M88 130l8-2" fill="none" stroke="#FBF5E8" stroke-width="1.6"/>',
  'bere':
      '<path d="M48 46C48 24 112 24 112 46Q80 38 48 46Z" fill="#6E5A9C"/><path d="M48 46Q80 38 112 46Q80 52 48 46Z" fill="#5A4882"/><path d="M102 34C108 20 118 12 128 10C124 20 116 30 106 38Z" fill="#E3A535"/><path d="M106 36L124 14" fill="none" stroke-width="1.2"/>',
  'canta':
      '<path d="M98 100L56 156" fill="none" stroke="#6C4F35" stroke-width="5"/><path d="M40 150H64L66 174H38Z" fill="#8A5A3C"/><path d="M39 150H65L62 160H42Z" fill="#A06E4C"/><circle cx="52" cy="160" r="2" fill="#E3A535" stroke-width="1"/>',
  'cicek':
      '<path d="M107 150L101 128M110 150L110 124M113 150L119 129" fill="none" stroke="#2F7A5B" stroke-width="2"/><circle cx="101" cy="126" r="5" fill="#B8432F"/><circle cx="110" cy="121" r="5" fill="#E3A535"/><circle cx="119" cy="127" r="5" fill="#6E5A9C"/><path d="M103 144L117 144L113 152H107Z" fill="#FBF5E8" stroke-width="1.6"/>',
  'cicek_taci':
      '<path d="M50 42Q80 30 110 42" fill="none" stroke="#2F7A5B" stroke-width="3"/><circle cx="54" cy="40" r="4.2" fill="#B8432F" stroke-width="1.4"/><circle cx="54" cy="40" r="1.4" fill="#E3A535" stroke="none"/><circle cx="66" cy="35" r="4.2" fill="#FBF5E8" stroke-width="1.4"/><circle cx="66" cy="35" r="1.4" fill="#E3A535" stroke="none"/><circle cx="80" cy="33" r="4.2" fill="#6E5A9C" stroke-width="1.4"/><circle cx="80" cy="33" r="1.4" fill="#E3A535" stroke="none"/><circle cx="94" cy="35" r="4.2" fill="#FBF5E8" stroke-width="1.4"/><circle cx="94" cy="35" r="1.4" fill="#E3A535" stroke="none"/><circle cx="106" cy="40" r="4.2" fill="#B8432F" stroke-width="1.4"/><circle cx="106" cy="40" r="1.4" fill="#E3A535" stroke="none"/>',
  'fener':
      '<path d="M109 159V166" fill="none" stroke-width="2"/><circle cx="109" cy="182" r="15" fill="#E8B84A" fill-opacity=".25" stroke="none"/><path d="M101 166H117L115 170V188L117 192H101L103 188V170Z" fill="#5A4B42"/><path d="M104 171H114V187H104Z" fill="#E8B84A"/><path d="M109 175C106 179 107 183 109 184C111 183 112 179 109 175Z" fill="#B8432F" stroke-width="1"/>',
  'kanat':
      '<path d="M62 110C34 82 10 96 14 124C24 118 32 122 38 128C44 124 52 124 60 130Z" fill="#FBF5E8"/><path d="M98 110C126 82 150 96 146 124C136 118 128 122 122 128C116 124 108 124 100 130Z" fill="#FBF5E8"/><path d="M24 108L56 122M34 98L58 116M136 108L104 122M126 98L102 116" fill="none" stroke="#9AA6B2" stroke-width="1.4"/>',
  'kitap':
      '<path d="M100 146L120 140L124 162L104 168Z" fill="#1F4E79"/><path d="M103 148L121 143" fill="none" stroke="#E3A535" stroke-width="1.6"/><polygon points="113.0,151.5 113.9,153.7 116.3,153.9 114.5,155.5 115.1,157.8 113.0,156.6 110.9,157.8 111.5,155.5 109.7,153.9 112.1,153.7" fill="#E3A535" stroke-width="1.4"/>',
  'kolye':
      '<path d="M63 99Q80 128 97 99" fill="none" stroke-width="1.6"/><circle cx="68" cy="110" r="2.2" fill="#E3A535" stroke-width="1"/><circle cx="92" cy="110" r="2.2" fill="#E3A535" stroke-width="1"/><circle cx="80" cy="121" r="6.5" fill="#1F4E79"/><circle cx="80" cy="121" r="3.6" fill="#FBF5E8" stroke-width="1"/><circle cx="80" cy="121" r="1.6" fill="#2B2320" stroke="none"/>',
  'madalyon':
      '<path d="M64 99Q80 120 96 99" fill="none" stroke="#E3A535" stroke-width="2.4"/><circle cx="80" cy="120" r="7.5" fill="#E3A535"/><polygon points="80.0,115.8 81.1,118.5 84.0,118.7 81.8,120.6 82.5,123.4 80.0,121.9 77.5,123.4 78.2,120.6 76.0,118.7 78.9,118.5" fill="#FBF5E8" stroke-width="1"/>',
  'rozet_ay':
      '<circle cx="67" cy="126" r="8.5" fill="#6E5A9C" stroke-width="1.8"/><path d="M69 120.5A6 6 0 1 0 69 131.5A4.6 4.6 0 1 1 69 120.5Z" fill="#E8B84A" stroke-width="1.2"/>',
  'rozet_yaprak':
      '<circle cx="67" cy="126" r="8.5" fill="#FBF5E8" stroke-width="1.8"/><path d="M62 130C62 122 68 119 73 121C73 128 68 131 62 130Z" fill="#2F7A5B" stroke-width="1.4"/><path d="M63 129L71 123" fill="none" stroke-width="1"/>',
  'rozet_yildiz':
      '<circle cx="67" cy="126" r="8.5" fill="#1F4E79" stroke-width="1.8"/><polygon points="67.0,120.0 68.6,123.8 72.7,124.1 69.6,126.8 70.5,130.9 67.0,128.7 63.5,130.9 64.4,126.8 61.3,124.1 65.4,123.8" fill="#E3A535" stroke-width="1.4"/>',
  'tac':
      '<path d="M60 38L63 18L72 28L80 12L88 28L97 18L100 38Q80 32 60 38Z" fill="#E3A535"/><circle cx="80" cy="30" r="3" fill="#B8432F" stroke-width="1.4"/><circle cx="68" cy="33" r="2" fill="#1F4E79" stroke-width="1.2"/><circle cx="92" cy="33" r="2" fill="#1F4E79" stroke-width="1.2"/>',
  'yildiz_pelerin':
      '<path d="M58 102C42 130 36 162 40 190C66 198 94 198 120 190C124 162 118 130 102 102Z" fill="#1F4E79"/><polygon points="44.0,176.0 45.1,178.5 47.8,178.8 45.7,180.6 46.4,183.2 44.0,181.8 41.6,183.2 42.3,180.6 40.2,178.8 42.9,178.5" fill="#E3A535" stroke-width="1.4"/><polygon points="116.0,176.0 117.1,178.5 119.8,178.8 117.7,180.6 118.4,183.2 116.0,181.8 113.6,183.2 114.3,180.6 112.2,178.8 114.9,178.5" fill="#E3A535" stroke-width="1.4"/><polygon points="43.0,149.0 43.8,150.9 45.9,151.1 44.3,152.4 44.8,154.4 43.0,153.3 41.2,154.4 41.7,152.4 40.1,151.1 42.2,150.9" fill="#E3A535" stroke-width="1.4"/><polygon points="117.0,149.0 117.8,150.9 119.9,151.1 118.3,152.4 118.8,154.4 117.0,153.3 115.2,154.4 115.7,152.4 114.1,151.1 116.2,150.9" fill="#E3A535" stroke-width="1.4"/>',
};

/// Dolaptaki küçük resim için eşyanın çevresindeki kutu.
const itemBox = <String, String>{
  'atki': '52 90 56 52',
  'bere': '44 6 90 50',
  'canta': '34 96 70 82',
  'cicek': '92 112 34 44',
  'cicek_taci': '44 22 72 26',
  'fener': '92 154 34 42',
  'kanat': '8 80 144 54',
  'kitap': '94 134 34 40',
  'kolye': '58 94 44 40',
  'madalyon': '58 94 44 40',
  'rozet_ay': '55 114 24 24',
  'rozet_yaprak': '55 114 24 24',
  'rozet_yildiz': '55 114 24 24',
  'tac': '56 8 48 34',
  'yildiz_pelerin': '34 98 92 104',
};

/// Gövdenin arkasına çizilen eşyalar.
const itemBack = <String>{'kanat', 'yildiz_pelerin'};
