/**
 * E2E Tests — Customer Ordering System
 *
 * IMPORTANT: Flutter Web renders on a canvas, NOT real DOM elements.
 * Playwright must use Flutter's Semantics tree (accessibility tree) OR
 * test the API layer directly. This file combines both strategies:
 *
 *   - Group A: Pure API tests  → always work, no UI needed
 *   - Group B: UI smoke tests  → use URL checks + page.waitForURL
 *
 * Stack:
 *   Frontend : Flutter Web → http://localhost:3000
 *   Backend  : Django DRF  → http://localhost:8000
 *
 * Run:
 *   npm test
 */

import { test, expect, APIRequestContext } from '@playwright/test';

// ── Config ────────────────────────────────────────────────────────────────────
const FRONTEND = 'http://localhost:3000';
const BACKEND  = 'http://localhost:8000';

// Unique email per test run so we never clash with existing accounts
const EMAIL    = `e2e_${Date.now()}@test.local`;
const PASSWORD = 'TestPass123!';
const ADDRESS  = '123 Playwright Street, Cairo';

// ── Shared state (filled in beforeAll) ───────────────────────────────────────
let accessToken  = '';
let placedOrderId = '';

// ── Helper: get a fresh token ─────────────────────────────────────────────────
async function getToken(request: APIRequestContext): Promise<string> {
  const res = await request.post(`${BACKEND}/api/auth/login/`, {
    data: { email: EMAIL, password: PASSWORD },
  });
  const body = await res.json();
  return body.access ?? body.access_token ?? body.token ?? '';
}

// ── Helper: add first available menu item to cart ─────────────────────────────
async function addItemToCart(request: APIRequestContext, token: string) {
  // Fetch categories (only public menu endpoint)
  const catRes = await request.get(`${BACKEND}/menu/categories/`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  const catBody = await catRes.json();
  const categories: any[] = Array.isArray(catBody)
    ? catBody
    : catBody.results ?? catBody.categories ?? [];

  // Categories contain menu items nested under them
  let menuItem: any = null;
  for (const cat of categories) {
    const catItems: any[] = cat.menuItems ?? cat.items ?? cat.menu_items ?? [];
    const found = catItems.find((i: any) => i.available !== false);
    if (found) { menuItem = found; break; }
  }
  if (!menuItem) throw new Error('No available menu item found in any category');

  // Add to cart
  const cartRes = await request.post(`${BACKEND}/api/cart/items/`, {
    headers: { Authorization: `Bearer ${token}` },
    data: { menu_item_id: menuItem.menu_item_id ?? menuItem.id, quantity: 1 },
  });
  return menuItem;
}

// ═════════════════════════════════════════════════════════════════════════════
// SETUP — Register user once before ALL tests
// ═════════════════════════════════════════════════════════════════════════════

test.beforeAll(async ({ request }) => {
  const res = await request.post(`${BACKEND}/api/auth/register/`, {
    data: {
      display_name : 'E2E Playwright User',
      email        : EMAIL,
      password     : PASSWORD,
      phone_number : '01000000000',
      role         : 'customer',
    },
  });
  // 201 Created or 200 OK
  expect([200, 201]).toContain(res.status());

  // Get initial token
  accessToken = await getToken(request);
  expect(accessToken).toBeTruthy();
});

// ═════════════════════════════════════════════════════════════════════════════
// GROUP A — Backend API Tests (no browser needed, always reliable)
// ═════════════════════════════════════════════════════════════════════════════

test.describe('A. Authentication API', () => {

  test('A.1 Login with correct credentials returns access token', async ({ request }) => {
    const res = await request.post(`${BACKEND}/api/auth/login/`, {
      data: { email: EMAIL, password: PASSWORD },
    });
    expect(res.status()).toBe(200);
    const body = await res.json();
    const token = body.access ?? body.access_token ?? body.token;
    expect(token).toBeTruthy();
  });

  test('A.2 Login with wrong password returns 400 or 401', async ({ request }) => {
    const res = await request.post(`${BACKEND}/api/auth/login/`, {
      data: { email: EMAIL, password: 'WRONG_PASSWORD' },
    });
    expect([400, 401, 403]).toContain(res.status());
  });

  test('A.3 Login with non-existent email returns error or empty response', async ({ request }) => {
    const res = await request.post(`${BACKEND}/api/auth/login/`, {
      data: { email: 'nobody@nowhere.com', password: 'anything' },
    });
    // Backend may return 400/401 OR a 200 with error detail — either is acceptable
    const body = await res.json().catch(() => ({}));
    if (res.status() === 200) {
      // If 200, body must not contain a valid access token
      expect(body.access ?? body.access_token ?? body.token ?? '').toBeFalsy();
    } else {
      expect([400, 401, 403, 404]).toContain(res.status());
    }
  });

  test('A.4 Register with duplicate email returns error', async ({ request }) => {
    const res = await request.post(`${BACKEND}/api/auth/register/`, {
      data: {
        display_name : 'Duplicate',
        email        : EMAIL,   // already registered
        password     : PASSWORD,
        phone_number : '01000000000',
        role         : 'customer',
      },
    });
    expect([400, 409]).toContain(res.status());
  });

});

// ─────────────────────────────────────────────────────────────────────────────

test.describe('B. Menu API', () => {

  test('B.1 GET /menu/categories/ with auth returns 200 and a list', async ({ request }) => {
    const res = await request.get(`${BACKEND}/menu/categories/`, {
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    expect(res.status()).toBe(200);
    const body = await res.json();
    const cats: any[] = Array.isArray(body) ? body : (body.results ?? body.categories ?? []);
    expect(Array.isArray(cats)).toBeTruthy();
  });

  test('B.2 Each category has a label field', async ({ request }) => {
    const res = await request.get(`${BACKEND}/menu/categories/`, {
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    const body = await res.json();
    const cats: any[] = Array.isArray(body) ? body : (body.results ?? body.categories ?? []);
    if (cats.length > 0) {
      expect(cats[0]).toHaveProperty('label');
    }
  });

  test('B.3 GET /menu/categories/ without auth is rejected (requires login)', async ({ request }) => {
    const res = await request.get(`${BACKEND}/menu/categories/`);
    expect([401, 403]).toContain(res.status());
  });

});

// ─────────────────────────────────────────────────────────────────────────────

test.describe('C. Cart API', () => {

  test('C.1 GET /api/cart/ without auth returns 401', async ({ request }) => {
    const res = await request.get(`${BACKEND}/api/cart/`);
    expect([401, 403]).toContain(res.status());
  });

  test('C.2 GET /api/cart/ with auth returns 200', async ({ request }) => {
    const res = await request.get(`${BACKEND}/api/cart/`, {
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    expect(res.status()).toBe(200);
  });

  test('C.3 POST /api/cart/items/ adds an item to cart', async ({ request }) => {
    const catRes = await request.get(`${BACKEND}/menu/categories/`, {
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    const catBody = await catRes.json();
    const categories: any[] = Array.isArray(catBody) ? catBody : [];
    let item: any = null;
    for (const cat of categories) {
      const found = (cat.menuItems ?? []).find((i: any) => i.available !== false);
      if (found) { item = found; break; }
    }
    expect(item).toBeTruthy();

    const res = await request.post(`${BACKEND}/api/cart/items/`, {
      headers: { Authorization: `Bearer ${accessToken}` },
      data: {
        menu_item_id: item.id,
        quantity: 1,
      },
    });
    expect([200, 201]).toContain(res.status());
  });

  test('C.4 DELETE /api/cart/clear/ empties the cart', async ({ request }) => {
    const res = await request.delete(`${BACKEND}/api/cart/clear/`, {
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    expect([200, 204]).toContain(res.status());

    // Verify cart is empty
    const cartRes = await request.get(`${BACKEND}/api/cart/`, {
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    const cart = await cartRes.json();
    const cartItems: any[] = cart.items ?? cart.cart_items ?? [];
    expect(cartItems.length).toBe(0);
  });

});

// ─────────────────────────────────────────────────────────────────────────────

test.describe('D. Order Placement API', () => {

  test('D.1 POST /api/order/place/ without auth returns 401', async ({ request }) => {
    const res = await request.post(`${BACKEND}/api/order/place/`, {
      data: { address: ADDRESS },
    });
    expect([401, 403]).toContain(res.status());
  });

  test('D.2 POST /api/order/place/ without address returns 400', async ({ request }) => {
    const res = await request.post(`${BACKEND}/api/order/place/`, {
      headers: { Authorization: `Bearer ${accessToken}` },
      data: {},
    });
    expect(res.status()).toBe(400);
  });

  test('D.3 POST /api/order/place/ with empty cart returns 400 with "empty" message', async ({ request }) => {
    // Clear cart first
    await request.delete(`${BACKEND}/api/cart/clear/`, {
      headers: { Authorization: `Bearer ${accessToken}` },
    });

    const res = await request.post(`${BACKEND}/api/order/place/`, {
      headers: { Authorization: `Bearer ${accessToken}` },
      data: { address: ADDRESS },
    });
    expect(res.status()).toBe(400);
    const body = await res.json();
    expect(body.error.toLowerCase()).toContain('empty');
  });

  test('D.4 POST /api/order/place/ with item in cart returns 201 with correct shape', async ({ request }) => {
    // Add item first
    await addItemToCart(request, accessToken);

    const res = await request.post(`${BACKEND}/api/order/place/`, {
      headers: { Authorization: `Bearer ${accessToken}` },
      data: { address: ADDRESS },
    });
    expect([200, 201]).toContain(res.status());

    const order = await res.json();
    expect(order).toHaveProperty('orderId');
    expect(order).toHaveProperty('accountId');
    expect(order).toHaveProperty('status', 'PENDING');
    expect(order).toHaveProperty('placedAt');
    expect(order).toHaveProperty('totalAmount');
    expect(order).toHaveProperty('progress');
    expect(order).toHaveProperty('items');
    expect(typeof order.totalAmount).toBe('number');
    expect(order.progress).toBeGreaterThanOrEqual(0);
    expect(order.progress).toBeLessThanOrEqual(1);

    // Save orderId for tracking tests
    placedOrderId = order.orderId;
  });

  test('D.5 Duplicate order within 30s returns same orderId (idempotency)', async ({ request }) => {
    // Cart was cleared by placing order in D.4 — add again
    await addItemToCart(request, accessToken);

    const res = await request.post(`${BACKEND}/api/order/place/`, {
      headers: { Authorization: `Bearer ${accessToken}` },
      data: { address: ADDRESS },
    });
    expect([200, 201]).toContain(res.status());
    const order2 = await res.json();

    // Same orderId as the one placed in D.4
    expect(order2.orderId).toBe(placedOrderId);
  });

  test('D.6 account_id in request body is ignored (security)', async ({ request }) => {
    await addItemToCart(request, accessToken);

    // Get a second user token to try injecting their account_id
    const otherEmail = `other_${Date.now()}@test.local`;
    await request.post(`${BACKEND}/api/auth/register/`, {
      data: {
        display_name: 'Other User', email: otherEmail,
        password: PASSWORD, phone_number: '01111111111', role: 'customer',
      },
    });

    const res = await request.post(`${BACKEND}/api/order/place/`, {
      headers: { Authorization: `Bearer ${accessToken}` },
      data: { address: ADDRESS, account_id: otherEmail }, // injected field
    });
    if (res.status() === 201 || res.status() === 200) {
      const order = await res.json();
      // accountId must match the token owner, not the injected value
      expect(order.accountId).not.toBe(otherEmail);
    }
  });

});

// ─────────────────────────────────────────────────────────────────────────────

test.describe('E. Order Listing API', () => {

  test('E.1 GET /api/order/ without auth returns 401', async ({ request }) => {
    const res = await request.get(`${BACKEND}/api/order/`);
    expect([401, 403]).toContain(res.status());
  });

  test('E.2 GET /api/order/ returns a list of orders', async ({ request }) => {
    const res = await request.get(`${BACKEND}/api/order/`, {
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    expect(res.status()).toBe(200);
    const body = await res.json();
    expect(Array.isArray(body)).toBeTruthy();
  });

  test('E.3 Order list items have required fields', async ({ request }) => {
    const res = await request.get(`${BACKEND}/api/order/`, {
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    const orders = await res.json();
    expect(orders.length).toBeGreaterThan(0);
    const o = orders[0];
    for (const f of ['orderId', 'accountId', 'status', 'placedAt', 'totalAmount', 'progress', 'items']) {
      expect(o).toHaveProperty(f);
    }
  });

  test('E.4 Orders are sorted newest first', async ({ request }) => {
    const res = await request.get(`${BACKEND}/api/order/`, {
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    const orders = await res.json();
    if (orders.length >= 2) {
      const t0 = new Date(orders[0].placedAt).getTime();
      const t1 = new Date(orders[1].placedAt).getTime();
      expect(t0).toBeGreaterThanOrEqual(t1);
    }
  });

  test('E.5 account_id query param is ignored (returns only own orders)', async ({ request }) => {
    // Register a fresh account
    const freshEmail = `fresh_${Date.now()}@test.local`;
    await request.post(`${BACKEND}/api/auth/register/`, {
      data: {
        display_name: 'Fresh', email: freshEmail,
        password: PASSWORD, phone_number: '01000000000', role: 'customer',
      },
    });
    const freshRes = await request.post(`${BACKEND}/api/auth/login/`, {
      data: { email: freshEmail, password: PASSWORD },
    });
    const freshToken = (await freshRes.json()).access;

    // Fresh user has no orders
    const res = await request.get(`${BACKEND}/api/order/`, {
      headers: { Authorization: `Bearer ${freshToken}` },
      params: { account_id: 'other_user_id' }, // injection attempt
    });
    expect(res.status()).toBe(200);
    const orders = await res.json();
    expect(orders.length).toBe(0); // must see their own (empty) list
  });

  test('E.6 Nested items in order have correct shape', async ({ request }) => {
    const res = await request.get(`${BACKEND}/api/order/`, {
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    const orders = await res.json();
    expect(orders.length).toBeGreaterThan(0);
    const items = orders[0].items;
    expect(Array.isArray(items)).toBeTruthy();
    if (items.length > 0) {
      const item = items[0];
      for (const f of ['id', 'title', 'unitPrice', 'quantity', 'lineTotal']) {
        expect(item).toHaveProperty(f);
      }
      expect(typeof item.unitPrice).toBe('number');
      expect(typeof item.quantity).toBe('number');
      expect(typeof item.lineTotal).toBe('number');
    }
  });

});

// ─────────────────────────────────────────────────────────────────────────────

test.describe('F. Order Tracking API', () => {

  test('F.1 GET tracking without auth returns 401', async ({ request }) => {
    const res = await request.get(`${BACKEND}/api/order/fake-id/tracking/`);
    expect([401, 403]).toContain(res.status());
  });

  test('F.2 GET tracking for non-existent order returns 404', async ({ request }) => {
    const res = await request.get(`${BACKEND}/api/order/FAKE-9999/tracking/`, {
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    expect(res.status()).toBe(404);
  });

  test('F.3 404 response has "message" field and no internals', async ({ request }) => {
    const res = await request.get(`${BACKEND}/api/order/FAKE-9999/tracking/`, {
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    expect(res.status()).toBe(404);
    const body = await res.json();
    expect(body).toHaveProperty('message');
    const text = JSON.stringify(body).toLowerCase();
    expect(text).not.toContain('traceback');
    expect(text).not.toContain('django');
    expect(text).not.toContain('sql');
  });

  test('F.4 GET tracking for own order returns 200 with required fields', async ({ request }) => {
    expect(placedOrderId).toBeTruthy();
    const res = await request.get(`${BACKEND}/api/order/${placedOrderId}/tracking/`, {
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    expect(res.status()).toBe(200);
    const body = await res.json();
    for (const f of ['orderId', 'currentStatus', 'progress', 'estimatedTimeMinutes', 'history']) {
      expect(body).toHaveProperty(f);
    }
  });

  test('F.5 Tracking orderId matches requested order', async ({ request }) => {
    const res = await request.get(`${BACKEND}/api/order/${placedOrderId}/tracking/`, {
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    const body = await res.json();
    expect(body.orderId).toBe(placedOrderId);
  });

  test('F.6 PENDING order has currentStatus = "pending"', async ({ request }) => {
    const res = await request.get(`${BACKEND}/api/order/${placedOrderId}/tracking/`, {
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    const body = await res.json();
    expect(body.currentStatus).toBe('pending');
  });

  test('F.7 Progress is 0 for PENDING order', async ({ request }) => {
    const res = await request.get(`${BACKEND}/api/order/${placedOrderId}/tracking/`, {
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    const body = await res.json();
    expect(body.progress).toBe(0);
  });

  test('F.8 ETA is a non-negative integer for PENDING order', async ({ request }) => {
    const res = await request.get(`${BACKEND}/api/order/${placedOrderId}/tracking/`, {
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    const body = await res.json();
    expect(typeof body.estimatedTimeMinutes).toBe('number');
    expect(body.estimatedTimeMinutes).toBeGreaterThan(0); // PENDING = 45 min
  });

  test('F.9 History is a non-empty list with status+timestamp entries', async ({ request }) => {
    const res = await request.get(`${BACKEND}/api/order/${placedOrderId}/tracking/`, {
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    const body = await res.json();
    expect(Array.isArray(body.history)).toBeTruthy();
    expect(body.history.length).toBeGreaterThanOrEqual(1);
    const entry = body.history[0];
    expect(entry).toHaveProperty('status');
    expect(entry).toHaveProperty('timestamp');
    expect(entry.status).toBe(entry.status.toLowerCase()); // must be lowercase
  });

  test('F.10 Another account cannot access this order (returns 404)', async ({ request }) => {
    const otherEmail = `isolate_${Date.now()}@test.local`;
    await request.post(`${BACKEND}/api/auth/register/`, {
      data: {
        display_name: 'Other', email: otherEmail,
        password: PASSWORD, phone_number: '01000000000', role: 'customer',
      },
    });
    const loginRes = await request.post(`${BACKEND}/api/auth/login/`, {
      data: { email: otherEmail, password: PASSWORD },
    });
    const otherToken = (await loginRes.json()).access;

    const res = await request.get(`${BACKEND}/api/order/${placedOrderId}/tracking/`, {
      headers: { Authorization: `Bearer ${otherToken}` },
    });
    expect(res.status()).toBe(404);

    // Must not leak orderId or accountId of the real owner
    const text = JSON.stringify(await res.json());
    expect(text).not.toContain(placedOrderId);
  });

  test('F.11 Tracking endpoint rejects POST (read-only)', async ({ request }) => {
    const res = await request.post(`${BACKEND}/api/order/${placedOrderId}/tracking/`, {
      headers: { Authorization: `Bearer ${accessToken}` },
      data: {},
    });
    expect([405, 404]).toContain(res.status());
  });

  test('F.12 account_id injection via query param is blocked', async ({ request }) => {
    const otherEmail = `inject_${Date.now()}@test.local`;
    await request.post(`${BACKEND}/api/auth/register/`, {
      data: {
        display_name: 'Inject', email: otherEmail,
        password: PASSWORD, phone_number: '01000000000', role: 'customer',
      },
    });
    const loginRes = await request.post(`${BACKEND}/api/auth/login/`, {
      data: { email: otherEmail, password: PASSWORD },
    });
    const otherToken = (await loginRes.json()).access;

    const res = await request.get(
      `${BACKEND}/api/order/${placedOrderId}/tracking/?account_id=${EMAIL}`,
      { headers: { Authorization: `Bearer ${otherToken}` } }
    );
    expect(res.status()).toBe(404);
  });

});

// ─────────────────────────────────────────────────────────────────────────────

test.describe('G. UI Smoke Tests (Flutter Web)', () => {

  test('G.1 Frontend is reachable and returns HTML', async ({ page }) => {
    const res = await page.goto(FRONTEND);
    expect(res?.status()).toBe(200);
    const content = await page.content();
    expect(content.toLowerCase()).toContain('html');
  });

  test('G.2 /login route loads Flutter app (canvas visible)', async ({ page }) => {
    // Flutter Web takes time to compile — use domcontentloaded not networkidle
    await page.goto(`${FRONTEND}/login`, { waitUntil: 'domcontentloaded' });
    await page.waitForTimeout(3000);
    const body = await page.locator('body').first();
    await expect(body).toBeVisible();
    await expect(page).not.toHaveURL(/error/i);
  });

  test('G.3 /signup route loads without crash', async ({ page }) => {
    await page.goto(`${FRONTEND}/signup`, { waitUntil: 'domcontentloaded' });
    await page.waitForTimeout(3000);
    await expect(page).not.toHaveURL(/error/i);
  });

  test('G.4 Unauthenticated /orders redirects to /login', async ({ page }) => {
    // Flutter needs time to initialise and run the auth guard — toHaveURL will auto-retry
    await page.goto(`${FRONTEND}/orders`, { waitUntil: 'domcontentloaded' });
    await expect(page).toHaveURL(/.*\/login.*/, { timeout: 15_000 });
  });

  test('G.5 Unauthenticated /cart redirects to /login', async ({ page }) => {
    await page.goto(`${FRONTEND}/cart`, { waitUntil: 'domcontentloaded' });
    await expect(page).toHaveURL(/.*\/login.*/, { timeout: 15_000 });
  });

  test('G.6 Unauthenticated /menu redirects to /login', async ({ page }) => {
    await page.goto(`${FRONTEND}/menu`, { waitUntil: 'domcontentloaded' });
    await expect(page).toHaveURL(/.*\/login.*/, { timeout: 15_000 });
  });

  test('G.7 App loads Flutter bootstrap JS files', async ({ page }) => {
    const jsResponses: number[] = [];
    page.on('response', (r) => {
      if (r.url().endsWith('.js') || r.url().includes('flutter') || r.url().includes('main.dart')) {
        jsResponses.push(r.status());
      }
    });
    await page.goto(FRONTEND, { waitUntil: 'domcontentloaded' });
    await page.waitForTimeout(5000);
    const ok = jsResponses.some((s) => s === 200);
    expect(ok).toBeTruthy();
  });

});
