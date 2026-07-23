const { chromium } = require('playwright');

const pages = [
  '033-tintype.html',
  '053-circuit-breaker.html',
  '084-field-notes-ag.html',
  '092-touchdown.html',
];
const BASE = 'http://127.0.0.1:8765/';
const OUT = process.cwd() + '/shots';

(async () => {
  require('fs').mkdirSync(OUT, { recursive: true });
  const browser = await chromium.launch();
  const results = {};
  for (const p of pages) {
    const ctx = await browser.newContext({ viewport: { width: 1440, height: 900 } });
    const page = await ctx.newPage();
    const errors = [];
    page.on('console', (m) => { if (m.type() === 'error') errors.push(m.text()); });
    page.on('pageerror', (e) => errors.push('PAGEERROR: ' + e.message));
    await page.goto(BASE + p, { waitUntil: 'networkidle' });
    await page.waitForTimeout(1200);

    const overflowDesktop = await page.evaluate(() => ({
      scrollW: document.documentElement.scrollWidth,
      clientW: document.documentElement.clientWidth,
      overflow: document.documentElement.scrollWidth > document.documentElement.clientWidth,
    }));
    const brokenImgs = await page.evaluate(() =>
      Array.from(document.images).filter((i) => !i.complete || i.naturalWidth === 0).map((i) => i.src)
    );
    await page.screenshot({ path: `${OUT}/${p.replace('.html', '')}-desktop.png`, fullPage: true });

    await page.setViewportSize({ width: 390, height: 844 });
    await page.waitForTimeout(600);
    const overflowMobile = await page.evaluate(() => ({
      scrollW: document.documentElement.scrollWidth,
      clientW: document.documentElement.clientWidth,
      overflow: document.documentElement.scrollWidth > document.documentElement.clientWidth,
    }));
    await page.screenshot({ path: `${OUT}/${p.replace('.html', '')}-mobile.png`, fullPage: true });

    results[p] = {
      consoleErrors: errors.filter((e) => !e.includes('favicon')),
      rawErrors: errors,
      overflowDesktop, overflowMobile, brokenImgs,
    };
    await ctx.close();
  }
  await browser.close();
  console.log(JSON.stringify(results, null, 2));
})().catch((e) => { console.error(e); process.exit(1); });
