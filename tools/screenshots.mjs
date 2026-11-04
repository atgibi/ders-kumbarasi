// Web derlemesinden ekran görüntüleri alır (tasarımla karşılaştırma için).
// Kullanım: node tools/screenshots.mjs <taban-url> <klasör>
import { chromium } from 'playwright';

const [base, out] = process.argv.slice(2);
const browser = await chromium.launch();
const ctx = await browser.newContext({
  viewport: { width: 390, height: 844 },
  deviceScaleFactor: 2,
  locale: 'tr-TR',
});

async function open(demo) {
  const page = await ctx.newPage();
  page.on('pageerror', (e) => console.log(`[${demo}] sayfa hatası:`, e.message));
  await page.goto(`${base}?demo=${demo}`);
  await page.waitForTimeout(9000); // Flutter + yazı tipleri + SVG
  return page;
}

async function shot(page, name) {
  await page.waitForTimeout(700);
  await page.screenshot({ path: `${out}/${name}.png` });
  console.log('çekildi:', name);
}

// Erişilebilirlik etiketiyle (ya da görünen metinle) dokun
async function tap(page, label) {
  const cands = [
    page.getByRole('button', { name: label, exact: true }),
    page.getByRole('button', { name: label }),
    page.getByRole('radio', { name: label }),
    page.getByRole('tab', { name: label }),
    page.getByText(label, { exact: true }),
  ];
  for (const c of cands) {
    const el = c.first();
    if ((await el.count()) > 0) {
      try {
        await el.click({ timeout: 3000, force: true });
        await page.waitForTimeout(900);
        return true;
      } catch (_) {}
    }
  }
  console.log('bulunamadı:', label);
  return false;
}

async function step(name, fn) {
  try {
    await fn();
  } catch (e) {
    console.log(`[${name}] hata:`, e.message);
  }
}

await step('A', async () => {
  const p = await open('onboarding');
  await shot(p, 'A1-karsilama');
  await tap(p, 'Başla');
  await shot(p, 'A2-nasil-calisir');
  for (let i = 0; i < 3; i++) await tap(p, 'İleri');
  await shot(p, 'A3-profil');
  const input = p.locator('input').first();
  if ((await input.count()) > 0) {
    await input.click({ force: true });
    await p.keyboard.type('Elif');
    await p.waitForTimeout(500);
  }
  await tap(p, 'Tavşan');
  await shot(p, 'A3-profil-dolu');
  await tap(p, 'Devam');
  await shot(p, 'A4-veli-ayarlari');
  await tap(p, 'Devam');
  await shot(p, 'A5-gizlilik');
  await tap(p, 'Anladım');
  await shot(p, 'A6-ilk-ders');
  await p.close();
});

await step('B1', async () => {
  const p = await open('picker');
  await shot(p, 'B1-profil-secici');
  await p.close();
});

await step('B', async () => {
  const p = await open('path');
  await shot(p, 'G1-harita');
  await p.mouse.wheel(0, 700);
  await shot(p, 'G1-harita-asagi');
  await tap(p, 'Kasaba');
  await shot(p, 'G3-kasaba');
  await tap(p, 'Defter');
  await shot(p, 'G4-defter');
  await tap(p, 'Harita');
  await tap(p, 'Gök Adaları');
  await shot(p, 'B5-tekrar');
  await tap(p, 'Haritaya dön');
  await tap(p, 'Kahraman');
  await shot(p, 'B6-profil');
  await tap(p, 'Veli alanı');
  await shot(p, 'D1-veli-kapisi');
  await tap(p, '1');
  await tap(p, 'Onayla');
  await shot(p, 'D1-yanlis');
  await p.close();
});

await step('G', async () => {
  let p = await open('hero');
  await shot(p, 'G0-kahraman-cinsiyet');
  await tap(p, 'Kız kahraman');
  await shot(p, 'G0-kahraman-yol');
  await tap(p, 'Okçu olacağım');
  await shot(p, 'G0-kahraman-gorunum');
  await p.close();
  p = await open('region');
  await shot(p, 'G2-bolge');
  await p.mouse.wheel(0, 1500);
  await shot(p, 'G2-bolge-bekci');
  await p.close();
  p = await open('duel');
  await shot(p, 'G5-duello');
  await p.close();
});

await step('C2', async () => {
  const p = await open('lesson');
  // Isınma sorularını geç (ilk seçenek, kontrol, devam)
  for (let k = 0; k < 4; k++) {
    if ((await p.getByRole('button', { name: 'İleri' }).count()) > 0) break;
    const opts = p.getByRole('button');
    const n = await opts.count();
    for (let i = 0; i < n; i++) {
      const b = await opts.nth(i).boundingBox();
      if (b && b.y > 250 && b.y < 700 && b.width > 250) {
        await opts.nth(i).click({ force: true });
        break;
      }
    }
    await p.waitForTimeout(500);
    await tap(p, 'Kontrol et');
    if (k === 0) await shot(p, 'C7-dogru-ya-da-tekrar');
    if (!(await tap(p, 'Devam'))) await tap(p, 'Anladım');
    await p.waitForTimeout(2600);
  }
  await shot(p, 'C2-konu-anlatimi');
  await tap(p, 'İleri');
  await shot(p, 'C2-sayfa-2');
  await p.close();
});

await step('C3', async () => {
  const p = await open('question');
  await shot(p, 'C3-soru');
  const opts = p.getByRole('button');
  const n = await opts.count();
  for (let i = 0; i < n; i++) {
    const b = await opts.nth(i).boundingBox();
    if (b && b.y > 250 && b.y < 700 && b.width > 250) {
      await opts.nth(i).click({ force: true });
      await p.waitForTimeout(600);
      break;
    }
  }
  await shot(p, 'C3-secili');
  await tap(p, 'Kontrol et');
  await shot(p, 'C7-geri-bildirim');
  await tap(p, 'Oturumdan çık');
  await shot(p, 'C10-cikis');
  await p.close();
});

await step('D', async () => {
  const p = await open('parent');
  await shot(p, 'D2-veli-paneli');
  await tap(p, 'Çocuk raporu');
  await shot(p, 'D3-rapor');
  await tap(p, 'Çok mu az mı?');
  await shot(p, 'D4-cikti');
  await tap(p, 'Geri');
  await tap(p, 'Geri');
  await tap(p, 'Ayarlar');
  await shot(p, 'D5-ayarlar');
  await tap(p, 'Geri');
  await tap(p, 'Veri, gizlilik ve hakkında');
  await shot(p, 'D7-veri');
  await tap(p, 'Geri');
  await tap(p, 'Kerem');
  await shot(p, 'D2-bos');
  await p.close();
});

for (const k of ['quiet', 'timeup', 'done']) {
  await step(k, async () => {
    const p = await open(k);
    await shot(p, `E-${k}`);
    await p.close();
  });
}
await browser.close();
