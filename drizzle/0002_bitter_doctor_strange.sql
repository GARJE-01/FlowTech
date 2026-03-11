CREATE TABLE "shops" (
	"id" serial PRIMARY KEY NOT NULL,
	"shop_name" text NOT NULL,
	"owner_name" text NOT NULL,
	"city" text NOT NULL,
	"mobile_number" text NOT NULL,
	"gst_number" text,
	"address" text NOT NULL,
	"created_at" timestamp DEFAULT now()
);
