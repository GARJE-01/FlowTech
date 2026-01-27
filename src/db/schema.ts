
import { sqliteTable, text, integer, real } from "drizzle-orm/sqlite-core";
import { sql } from "drizzle-orm";

// Users Table (for Better-Auth and App Logic)
export const user = sqliteTable("user", {
    id: text("id").primaryKey(),
    name: text("name").notNull(),
    email: text("email").notNull().unique(),
    emailVerified: integer('email_verified', { mode: 'boolean' }).notNull().default(false),
    image: text('image'),
    createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
    updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull(),
    role: text("role").default("salesman"), // admin, salesman, delivery
});

export const session = sqliteTable("session", {
    id: text("id").primaryKey(),
    expiresAt: integer('expires_at', { mode: 'timestamp' }).notNull(),
    token: text('token').notNull().unique(),
    createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
    updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull(),
    ipAddress: text('ip_address'),
    userAgent: text('user_agent'),
    userId: text('user_id').notNull().references(() => user.id),
});

export const account = sqliteTable("account", {
    id: text("id").primaryKey(),
    accountId: text('account_id').notNull(),
    providerId: text('provider_id').notNull(),
    userId: text('user_id').notNull().references(() => user.id),
    accessToken: text('access_token'),
    refreshToken: text('refresh_token'),
    idToken: text('id_token'),
    accessTokenExpiresAt: integer('access_token_expires_at', { mode: 'timestamp' }),
    refreshTokenExpiresAt: integer('refresh_token_expires_at', { mode: 'timestamp' }),
    scope: text('scope'),
    password: text('password'),
    createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
    updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull(),
});

export const verification = sqliteTable("verification", {
    id: text("id").primaryKey(),
    identifier: text('identifier').notNull(),
    value: text('value').notNull(),
    expiresAt: integer('expires_at', { mode: 'timestamp' }).notNull(),
    createdAt: integer('created_at', { mode: 'timestamp' }),
    updatedAt: integer('updated_at', { mode: 'timestamp' }),
});

// Business Logic Tables

export const suppliers = sqliteTable("suppliers", {
    id: integer("id").primaryKey({ autoIncrement: true }),
    name: text("name").notNull(),
    contactPerson: text("contact_person"),
    email: text("email").unique(),
    phone: text("phone"),
    address: text("address"),
    createdAt: integer("created_at", { mode: "timestamp" }).default(sql`(unixepoch())`),
});

export const products = sqliteTable("products", {
    id: integer("id").primaryKey({ autoIncrement: true }),
    name: text("name").notNull(),
    category: text("category").notNull(),
    description: text("description"),
    basePrice: real("base_price").notNull(), // Sourcing price or base selling price? Assuming base selling.
    createdAt: integer("created_at", { mode: "timestamp" }).default(sql`(unixepoch())`),
});

export const productVariants = sqliteTable("product_variants", {
    id: integer("id").primaryKey({ autoIncrement: true }),
    productId: integer("product_id").references(() => products.id, { onDelete: 'cascade' }).notNull(),
    sku: text("sku").unique().notNull(),
    variantName: text("variant_name"), // e.g. "Red / M"
    price: real("price").notNull(), // Selling price for this variant
    currentStock: integer("current_stock").default(0).notNull(),
});

// Stock Ledger for audit trail
export const stockLedger = sqliteTable("stock_ledger", {
    id: integer("id").primaryKey({ autoIncrement: true }),
    variantId: integer("variant_id").references(() => productVariants.id).notNull(),
    changeAmount: integer("change_amount").notNull(), // + for in, - for out
    type: text("type").notNull(), // 'STOCK_IN', 'ORDER', 'ADJUSTMENT'
    referenceId: text("reference_id"), // Order ID or Invoice# usually
    notes: text("notes"),
    createdAt: integer("created_at", { mode: "timestamp" }).default(sql`(unixepoch())`),
    supplierId: integer("supplier_id").references(() => suppliers.id), // Optional, for Stock In
});

export const orders = sqliteTable("orders", {
    id: text("id").primaryKey(), // Using text for custom order IDs like ORD-2025-001
    salesmanId: text("salesman_id").references(() => user.id),
    totalAmount: real("total_amount").notNull(),
    status: text("status").default("pending"), // pending, approved, rejected, delivered
    createdAt: integer("created_at", { mode: "timestamp" }).default(sql`(unixepoch())`),
    updatedAt: integer("updated_at", { mode: "timestamp" }).default(sql`(unixepoch())`),
    approverId: text("approver_id").references(() => user.id), // Admin who approved
});

export const orderItems = sqliteTable("order_items", {
    id: integer("id").primaryKey({ autoIncrement: true }),
    orderId: text("order_id").references(() => orders.id, { onDelete: 'cascade' }).notNull(),
    variantId: integer("variant_id").references(() => productVariants.id).notNull(),
    quantity: integer("quantity").notNull(),
    price: real("price").notNull(), // Price at time of order
});
