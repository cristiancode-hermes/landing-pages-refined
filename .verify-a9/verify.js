const { chromium } = require('playwright-core');
const path = require('path');
const os = require('os');
const fs = require('fs');

const pages = ['003-monsoon.html', '036-typecase.html', '057-wild-type.html', '090-studio-verte.html'];
const base = 'http://127.0.0.1:8471/';
const shotsDir = path.join(__dirname, 'shots');

function findChrome() {
  const root = path.join(os.homedir(), 'AppData', 'Local', 'ms-playwright');
  const dirs = fs.readdirSync(root).filter(d => d.startsWith('chromium-')).sort().reverse();
  for (const d of dirs) {
    const p = path.join(root, d, 'chrome-win', 'chrome.exe');
    if (fs.existsSync(p)) return p;
  }
  throw new Error('no chromium found');
}

(async () => {
  const browser = await chromium.launch({ executablePath: findChrome(), headless: true });
  for (const file of pages) {
    const errors = [];
    const results = {};
    for (const [label, vp] of [['desktop', { width: 1440, height: 900 }], ['mobile', { width: 390, height: 844 }]]) {
      const ctx = await browser.newContext({ viewport: vp, deviceScaleFactor: 1 });
      const page = await ctx.newPage();
      page.on('console', m => { if (m.type() === 'error') errors.push(`[${label}] console: ${m.text()}`); });
      page.on('pageerror', e => errors.push(`[${label}] pageerror: ${e.message}`));
      await page.goto(base + file, { waitUntil: 'networkidle', timeout: 45000 });
      await page.waitForTimeout(1200);
      const overflow = await page.evaluate(() => ({
        scrollW: document.documentElement.scrollWidth,
        innerW: window.innerWidth,
        overflowX: document.documentElement.scrollWidth > window.innerWidth
      }));
      results[label] = overflow;
      await page.screenshot({ path: path.join(shotsDir, file.replace('.html', '') + '-' + label + '.png'), fullPage: true });
      await ctx.close();
    }
    console.log(JSON.stringify({ file, results, errors }, null, 1));
  }
  await browser.close();
})().catch(e => { console.error('FATAL', e); process.exit(1); });
