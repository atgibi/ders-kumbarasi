// Web derlemesinden ekran görüntüleri alır (geliştirme aracı).
// Kullanım: node tools/screenshots.mjs <taban-url> <klasör>
import { chromium } from 'playwright';

const [base, out] = process.argv.slice(2);
const browser = await chromium.launch();
const ctx = await browser.newContext({
  viewport: { width: 412, height: 892 },
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
  await page.screenshot({ path: `${out}/${name}.png` });
  console.log('çekildi:', name);
}

async function clickLabel(page, label) {
  const el = page.locator(`flt-semantics[aria-label="${label}"], [role="button"]:has-text("${label}")`).first();
  await el.click({ timeout: 5000 });
  await page.waitForTimeout(1200);
}

try {
  let p = await open('onboarding');
  await shot(p, '01-ilk-kurulum');
  await p.close();

  p = await open('path');
  await shot(p, '02-yol');
  await p.close();

  p = await open('lesson');
  await shot(p, '03-konu-anlatimi');
  await p.close();

  p = await open('question');
  await shot(p, '04-soru');
  // İlk seçeneği seç: seçenek kartları soru alanında, KONTROL ET'in üstünde
  const buttons = p.locator('flt-semantics[role="button"]');
  const n = await buttons.count();
  for (let i = 0; i < n; i++) {
    const b = await buttons.nth(i).boundingBox();
    if (b && b.y > 330 && b.y < 760 && b.width > 250) {
      await buttons.nth(i).click();
      break;
    }
  }
  await p.waitForTimeout(800);
  await shot(p, '05-secim');
  await clickLabel(p, 'Kontrol et');
  await shot(p, '06-geri-bildirim');
  await p.close();
} catch (e) {
  console.log('ekran görüntüsü hatası:', e.message);
}
await browser.close();
