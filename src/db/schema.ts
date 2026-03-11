import { pgTable, text, integer, real, serial, boolean, timestamp } from "drizzle-orm/pg-core";
import { sql } from "drizzle-orm";

// Users Table (for Better-Auth and App Logic)
export const user = pgTable("user", {
    id: text("id").primaryKey(),
    name: text("name").notNull(),
    email: text("email").notNull().unique(),
    emailVerified: boolean('email_verified').notNull().default(false),
    image: text('image'),
    createdAt: timestamp('created_at').notNull(),
    updatedAt: timestamp('updated_at').notNull(),
    role: text("role").default("salesman"), // admin, salesman, delivery
});

export const session = pgTable("session", {
    id: text("id").primaryKey(),
    expiresAt: timestamp('expires_at').notNull(),
    token: text('token').notNull().unique(),
    createdAt: timestamp('created_at').notNull(),
    updatedAt: timestamp('updated_at').notNull(),
    ipAddress: text('ip_address'),
    userAgent: text('user_agent'),
    userId: text('user_id').notNull().references(() => user.id, { onDelete: 'cascade' }),
});

export const account = pgTable("account", {
    id: text("id").primaryKey(),
    accountId: text('account_id').notNull(),
    providerId: text('provider_id').notNull(),
    userId: text('user_id').notNull().references(() => user.id, { onDelete: 'cascade' }),
    accessToken: text('access_token'),
    refreshToken: text('refresh_token'),
    idToken: text('id_token'),
    accessTokenExpiresAt: timestamp('access_token_expires_at'),
    refreshTokenExpiresAt: timestamp('refresh_token_expires_at'),
    scope: text('scope'),
    password: text('password'),
    createdAt: timestamp('created_at').notNull(),
    updatedAt: timestamp('updated_at').notNull(),
});

export const verification = pgTable("verification", {
    id: text("id").primaryKey(),
    identifier: text('identifier').notNull(),
    value: text('value').notNull(),
    expiresAt: timestamp('expires_at').notNull(),
    createdAt: timestamp('created_at'),
    updatedAt: timestamp('updated_at'),
});

// Business Logic Tables

export const suppliers = pgTable("suppliers", {
    id: serial("id").primaryKey(),
    name: text("name").notNull(),
    contactPerson: text("contact_person"),
    email: text("email").unique(),
    phone: text("phone"),
    address: text("address"),
    createdAt: timestamp("created_at").defaultNow(),
});

export const shops = pgTable("shops", {
    id: serial("id").primaryKey(),
    shopName: text("shop_name").notNull(),
    ownerName: text("owner_name").notNull(),
    city: text("city").notNull(),
    mobileNumber: text("mobile_number").notNull(),
    gstNumber: text("gst_number"),
    address: text("address").notNull(),
    isActive: boolean("is_active").default(true).notNull(),
    createdAt: timestamp("created_at").defaultNow(),
});

export const products = pgTable("products", {
    id: serial("id").primaryKey(),
    name: text("name").notNull(),
    category: text("category").notNull(),
    description: text("description"),
    basePrice: real("base_price").notNull(), // Sourcing price or base selling price? Assuming base selling.
    createdAt: timestamp("created_at").defaultNow(),
});

export const productVariants = pgTable("product_variants", {
    id: serial("id").primaryKey(),
    productId: integer("product_id").references(() => products.id, { onDelete: 'cascade' }).notNull(),
    sku: text("sku").unique().notNull(),
    variantName: text("variant_name"), // e.g. "Red / M"
    price: real("price").notNull(), // Selling price for this variant
    currentStock: integer("current_stock").default(0).notNull(),
});

// Stock Ledger for audit trail
export const stockLedger = pgTable("stock_ledger", {
    id: serial("id").primaryKey(),
    variantId: integer("variant_id").references(() => productVariants.id).notNull(),
    changeAmount: integer("change_amount").notNull(), // + for in, - for out
    type: text("type").notNull(), // 'STOCK_IN', 'ORDER', 'ADJUSTMENT'
    referenceId: text("reference_id"), // Order ID or Invoice# usually
    notes: text("notes"),
    createdAt: timestamp("created_at").defaultNow(),
    supplierId: integer("supplier_id").references(() => suppliers.id), // Optional, for Stock In
});

export const orders = pgTable("orders", {
    id: text("id").primaryKey(), // Using text for custom order IDs like ORD-2025-001
    salesmanId: text("salesman_id").references(() => user.id, { onDelete: 'cascade' }),
    shopId: integer("shop_id").references(() => shops.id, { onDelete: 'cascade' }).notNull(),
    totalAmount: real("total_amount").notNull(),
    status: text("status").default("pending"), // pending, approved, rejected, delivered
    isPaid: boolean("is_paid").default(false).notNull(),
    createdAt: timestamp("created_at").defaultNow(),
    updatedAt: timestamp("updated_at").defaultNow(),
    approverId: text("approver_id").references(() => user.id, { onDelete: 'cascade' }), // Admin who approved
});


export const orderItems = pgTable("order_items", {
    id: serial("id").primaryKey(),
    orderId: text("order_id").references(() => orders.id, { onDelete: 'cascade' }).notNull(),
    variantId: integer("variant_id").references(() => productVariants.id).notNull(),
    quantity: integer("quantity").notNull(),
    price: real("price").notNull(), // Price at time of order
});

export const supplierProducts = pgTable("supplier_products", {
    id: serial("id").primaryKey(),
    supplierId: integer("supplier_id").references(() => suppliers.id, { onDelete: 'cascade' }).notNull(),
    productId: integer("product_id").references(() => products.id, { onDelete: 'cascade' }).notNull(),
});

