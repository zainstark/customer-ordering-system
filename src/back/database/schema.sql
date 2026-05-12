PRAGMA foreign_keys = ON;

-- =========================
-- CUSTOMER ACCOUNTS
-- =========================
CREATE TABLE customer_accounts (
    account_id TEXT PRIMARY KEY,
    display_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    phone_number TEXT,
    active BOOLEAN NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- SESSIONS
-- =========================
CREATE TABLE sessions (
    session_id TEXT PRIMARY KEY,
    account_id TEXT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME NOT NULL,
    active BOOLEAN NOT NULL DEFAULT 1,

    FOREIGN KEY (account_id)
        REFERENCES customer_accounts(account_id)
        ON DELETE CASCADE
);

-- =========================
-- MENU CATALOGS
-- =========================
CREATE TABLE menu_catalogs (
    catalog_id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    active BOOLEAN NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- MENU ITEMS
-- =========================
CREATE TABLE menu_items (
    menu_item_id TEXT PRIMARY KEY,
    catalog_id TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    price_cents INTEGER NOT NULL,
    category TEXT,
    available BOOLEAN NOT NULL DEFAULT 1,
    image_url TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (catalog_id)
        REFERENCES menu_catalogs(catalog_id)
        ON DELETE CASCADE
);

-- =========================
-- CARTS
-- =========================
CREATE TABLE carts (
    cart_id TEXT PRIMARY KEY,
    account_id TEXT NOT NULL UNIQUE,
    status TEXT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (account_id)
        REFERENCES customer_accounts(account_id)
        ON DELETE CASCADE
);

-- =========================
-- CART ITEMS
-- =========================
CREATE TABLE cart_items (
    cart_item_id TEXT PRIMARY KEY,
    cart_id TEXT NOT NULL,
    menu_item_id TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK(quantity > 0),
    unit_price_snapshot INTEGER NOT NULL,
    line_total INTEGER NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (cart_id)
        REFERENCES carts(cart_id)
        ON DELETE CASCADE,

    FOREIGN KEY (menu_item_id)
        REFERENCES menu_items(menu_item_id)
);

-- =========================
-- ORDERS
-- =========================
CREATE TABLE orders (
    order_id TEXT PRIMARY KEY,
    account_id TEXT NOT NULL,
    total_amount INTEGER NOT NULL,
    placed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    order_status TEXT NOT NULL,
    confirmed_at DATETIME,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK(order_status IN (
    'PENDING',
    'CONFIRMED',
    'PREPARING',
    'READY',
    'OUT_FOR_DELIVERY',
    'DELIVERED',
    'CANCELLED',
    'REFUNDED',
    'FAILED'
))

    FOREIGN KEY (account_id)
        REFERENCES customer_accounts(account_id)
        ON DELETE CASCADE
);

-- =========================
-- ORDER ITEMS
-- =========================
CREATE TABLE order_items (
    order_item_id TEXT PRIMARY KEY,
    order_id TEXT NOT NULL,
    menu_item_id TEXT NOT NULL,
    item_name_snapshot TEXT NOT NULL,
    item_description_snapshot TEXT,
    unit_price_snapshot INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK(quantity > 0),
    line_total INTEGER NOT NULL,

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE,

    FOREIGN KEY (menu_item_id)
        REFERENCES menu_items(menu_item_id)
);

-- =========================
-- PAYMENTS
-- =========================
CREATE TABLE payments (
    payment_id TEXT PRIMARY KEY,
    order_id TEXT NOT NULL,
    amount INTEGER NOT NULL,
    initiated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_at DATETIME,

    payment_method TEXT NOT NULL,
    payment_status TEXT NOT NULL,

    CHECK(payment_method IN (
        'CASH',
        'CARD'
)),
    CHECK(payment_status IN (
        'PENDING',
        'AUTHORIZED',
        'COMPLETED',
        'FAILED',
        'REFUNDED',
        'CANCELLED'
)),

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE
);

-- =========================
-- TRANSACTIONS
-- =========================
CREATE TABLE transactions (
    transaction_id TEXT PRIMARY KEY,
    payment_id TEXT NOT NULL,
    gateway_reference TEXT,
    authorization_code TEXT,
    processed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (payment_id)
        REFERENCES payments(payment_id)
        ON DELETE CASCADE
);

-- =========================
-- ORDER STATUS HISTORY
-- =========================
CREATE TABLE order_status_history (
    history_id TEXT PRIMARY KEY,
    order_id TEXT NOT NULL,
    order_status TEXT NOT NULL,
    note TEXT,
    changed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE
);

-- =========================
-- NOTIFICATION MESSAGES
-- =========================
CREATE TABLE notification_messages (
    message_id TEXT PRIMARY KEY,
    account_id TEXT NOT NULL,
    order_id TEXT,
    subject TEXT NOT NULL,
    body TEXT NOT NULL,
    delivery_channel TEXT NOT NULL,
    delivery_status TEXT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sent_at DATETIME,

    CHECK(delivery_channel IN (
    'EMAIL',
    'SMS',
    'IN_APP',
    'WHATSAPP'
)),
    CHECK(delivery_status IN (
    'PENDING',
    'SENT',
    'FAILED',
    'DELIVERED'
))
    FOREIGN KEY (account_id)
        REFERENCES customer_accounts(account_id)
        ON DELETE CASCADE,

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE SET NULL
);

-- =========================
-- INDEXES
-- =========================

CREATE INDEX idx_sessions_account_id
ON sessions(account_id);

CREATE INDEX idx_menu_items_catalog_id
ON menu_items(catalog_id);

CREATE INDEX idx_cart_items_cart_id
ON cart_items(cart_id);

CREATE INDEX idx_cart_items_menu_item_id
ON cart_items(menu_item_id);

CREATE INDEX idx_orders_account_id
ON orders(account_id);

CREATE INDEX idx_order_items_order_id
ON order_items(order_id);

CREATE INDEX idx_order_items_menu_item_id
ON order_items(menu_item_id);

CREATE INDEX idx_payments_order_id
ON payments(order_id);

CREATE INDEX idx_transactions_payment_id
ON transactions(payment_id);

CREATE INDEX idx_order_status_history_order_id
ON order_status_history(order_id);

CREATE INDEX idx_notification_messages_account_id
ON notification_messages(account_id);

CREATE INDEX idx_notification_messages_order_id
ON notification_messages(order_id);

