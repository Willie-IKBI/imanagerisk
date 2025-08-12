

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "public";


ALTER SCHEMA "public" OWNER TO "pg_database_owner";


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE TYPE "public"."claim_status" AS ENUM (
    'reported',
    'in_review',
    'approved',
    'declined',
    'settled'
);


ALTER TYPE "public"."claim_status" OWNER TO "postgres";


CREATE TYPE "public"."client_status" AS ENUM (
    'active',
    'inactive'
);


ALTER TYPE "public"."client_status" OWNER TO "postgres";


CREATE TYPE "public"."client_type" AS ENUM (
    'personal',
    'business',
    'body_corporate'
);


ALTER TYPE "public"."client_type" OWNER TO "postgres";


CREATE TYPE "public"."lead_status" AS ENUM (
    'new',
    'contacted',
    'qualifying',
    'quoting',
    'awaiting_docs',
    'decision',
    'won',
    'lost'
);


ALTER TYPE "public"."lead_status" OWNER TO "postgres";


CREATE TYPE "public"."policy_status" AS ENUM (
    'active',
    'cancelled',
    'pending'
);


ALTER TYPE "public"."policy_status" OWNER TO "postgres";


CREATE TYPE "public"."quote_status" AS ENUM (
    'draft',
    'sent',
    'accepted',
    'declined',
    'expired'
);


ALTER TYPE "public"."quote_status" OWNER TO "postgres";


CREATE TYPE "public"."task_priority" AS ENUM (
    'low',
    'medium',
    'high',
    'urgent'
);


ALTER TYPE "public"."task_priority" OWNER TO "postgres";


CREATE TYPE "public"."task_status" AS ENUM (
    'pending',
    'in_progress',
    'completed',
    'cancelled'
);


ALTER TYPE "public"."task_status" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_renewal_flag"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    IF NEW.end_date IS NOT NULL THEN
        NEW.renewal_flag := (NEW.end_date - CURRENT_DATE) <= INTERVAL '60 days';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."check_renewal_flag"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."generate_quote_number"() RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    next_number INTEGER;
BEGIN
    SELECT COALESCE(MAX(CAST(SUBSTRING(quote_number FROM 4) AS INTEGER)), 0) + 1
    INTO next_number
    FROM quotes
    WHERE quote_number LIKE 'QT-%';
    
    RETURN 'QT-' || LPAD(next_number::TEXT, 6, '0');
END;
$$;


ALTER FUNCTION "public"."generate_quote_number"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."clients" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "client_type" "public"."client_type" NOT NULL,
    "entity_name" "text",
    "first_name" "text",
    "last_name" "text",
    "id_number" character varying(13),
    "company_reg_number" character varying(20),
    "vat_number" character varying(15),
    "comments" "text",
    "status" "public"."client_status" DEFAULT 'active'::"public"."client_status",
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."clients" OWNER TO "postgres";


COMMENT ON TABLE "public"."clients" IS 'Stores all client entities (Personal, Business, Body Corporate)';



CREATE OR REPLACE FUNCTION "public"."get_client_full_name"("client_record" "public"."clients") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    CASE client_record.client_type
        WHEN 'personal' THEN
            RETURN COALESCE(client_record.first_name || ' ' || client_record.last_name, '');
        WHEN 'business', 'body_corporate' THEN
            RETURN COALESCE(client_record.entity_name, '');
        ELSE
            RETURN '';
    END CASE;
END;
$$;


ALTER FUNCTION "public"."get_client_full_name"("client_record" "public"."clients") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_updated_at_column"() OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."addresses" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "client_id" "uuid" NOT NULL,
    "is_primary" boolean DEFAULT false,
    "line1" "text" NOT NULL,
    "line2" "text",
    "city" "text",
    "province" "text",
    "postal_code" character varying(10),
    "country" "text" DEFAULT 'South Africa'::"text",
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."addresses" OWNER TO "postgres";


COMMENT ON TABLE "public"."addresses" IS 'Stores addresses per client';



CREATE TABLE IF NOT EXISTS "public"."attachments" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "parent_type" "text" NOT NULL,
    "parent_id" "uuid" NOT NULL,
    "url" "text" NOT NULL,
    "file_name" "text",
    "file_size" integer,
    "mime_type" "text",
    "uploaded_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."attachments" OWNER TO "postgres";


COMMENT ON TABLE "public"."attachments" IS 'Stores files linked to any entity';



CREATE TABLE IF NOT EXISTS "public"."claim_items" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "claim_id" "uuid" NOT NULL,
    "description" "text" NOT NULL,
    "amount" numeric,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."claim_items" OWNER TO "postgres";


COMMENT ON TABLE "public"."claim_items" IS 'Line items for claims';



CREATE TABLE IF NOT EXISTS "public"."claim_updates" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "claim_id" "uuid" NOT NULL,
    "update_text" "text" NOT NULL,
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."claim_updates" OWNER TO "postgres";


COMMENT ON TABLE "public"."claim_updates" IS 'Tracks updates in the claim lifecycle';



CREATE TABLE IF NOT EXISTS "public"."claims" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "policy_id" "uuid" NOT NULL,
    "claim_number" "text" NOT NULL,
    "date_reported" "date" NOT NULL,
    "status" "public"."claim_status" DEFAULT 'reported'::"public"."claim_status",
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."claims" OWNER TO "postgres";


COMMENT ON TABLE "public"."claims" IS 'Main claims table';



CREATE TABLE IF NOT EXISTS "public"."client_contacts" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "client_id" "uuid" NOT NULL,
    "is_primary" boolean DEFAULT false,
    "role" "text",
    "name" "text" NOT NULL,
    "phone" character varying(20),
    "email" "text",
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."client_contacts" OWNER TO "postgres";


COMMENT ON TABLE "public"."client_contacts" IS 'Stores multiple contact records linked to a client';



CREATE OR REPLACE VIEW "public"."client_summary" AS
SELECT
    NULL::"uuid" AS "id",
    NULL::"public"."client_type" AS "client_type",
    NULL::"text" AS "full_name",
    NULL::"public"."client_status" AS "status",
    NULL::timestamp with time zone AS "created_at",
    NULL::bigint AS "policy_count",
    NULL::bigint AS "claim_count";


ALTER VIEW "public"."client_summary" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."leads" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "owner_id" "uuid" NOT NULL,
    "source" "text",
    "client_type" "public"."client_type" NOT NULL,
    "prospect_name" "text" NOT NULL,
    "company_reg_number" character varying(20),
    "id_number" character varying(13),
    "contact_email" "text",
    "contact_phone" character varying(20),
    "region" "text",
    "province" "text",
    "product_interest" "text",
    "status" "public"."lead_status" DEFAULT 'new'::"public"."lead_status",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."leads" OWNER TO "postgres";


COMMENT ON TABLE "public"."leads" IS 'Stores sales leads and prospects';



CREATE TABLE IF NOT EXISTS "public"."policies" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "client_id" "uuid" NOT NULL,
    "insurer_id" "uuid" NOT NULL,
    "product_id" "uuid" NOT NULL,
    "policy_number" "text" NOT NULL,
    "start_date" "date",
    "end_date" "date",
    "status" "public"."policy_status" DEFAULT 'active'::"public"."policy_status",
    "renewal_flag" boolean DEFAULT false,
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."policies" OWNER TO "postgres";


COMMENT ON TABLE "public"."policies" IS 'Main policy table';



CREATE TABLE IF NOT EXISTS "public"."quotes" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "lead_id" "uuid",
    "client_id" "uuid",
    "quote_number" "text" NOT NULL,
    "status" "public"."quote_status" DEFAULT 'draft'::"public"."quote_status",
    "valid_until" "date",
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."quotes" OWNER TO "postgres";


COMMENT ON TABLE "public"."quotes" IS 'Stores quotes for leads';



CREATE TABLE IF NOT EXISTS "public"."tasks" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "title" "text" NOT NULL,
    "description" "text",
    "assigned_to" "uuid",
    "created_by" "uuid",
    "due_date" "date",
    "priority" "public"."task_priority" DEFAULT 'medium'::"public"."task_priority",
    "status" "public"."task_status" DEFAULT 'pending'::"public"."task_status",
    "parent_type" "text",
    "parent_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."tasks" OWNER TO "postgres";


COMMENT ON TABLE "public"."tasks" IS 'Stores tasks and reminders';



CREATE OR REPLACE VIEW "public"."dashboard_stats" AS
 SELECT ( SELECT "count"(*) AS "count"
           FROM "public"."leads"
          WHERE ("leads"."status" = 'new'::"public"."lead_status")) AS "new_leads",
    ( SELECT "count"(*) AS "count"
           FROM "public"."quotes"
          WHERE ("quotes"."status" = 'sent'::"public"."quote_status")) AS "pending_quotes",
    ( SELECT "count"(*) AS "count"
           FROM "public"."policies"
          WHERE ("policies"."renewal_flag" = true)) AS "renewals_due",
    ( SELECT "count"(*) AS "count"
           FROM "public"."claims"
          WHERE ("claims"."status" = ANY (ARRAY['reported'::"public"."claim_status", 'in_review'::"public"."claim_status"]))) AS "open_claims",
    ( SELECT "count"(*) AS "count"
           FROM "public"."tasks"
          WHERE (("tasks"."status" = 'pending'::"public"."task_status") AND ("tasks"."assigned_to" = "auth"."uid"()))) AS "my_tasks";


ALTER VIEW "public"."dashboard_stats" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."employees" (
    "id" "uuid" NOT NULL,
    "full_name" "text" NOT NULL,
    "contact_number" character varying(20),
    "display_image" "text",
    "role" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."employees" OWNER TO "postgres";


COMMENT ON TABLE "public"."employees" IS 'Maps auth users to business profiles';



CREATE TABLE IF NOT EXISTS "public"."insurers" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "name" "text" NOT NULL,
    "contact_info" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."insurers" OWNER TO "postgres";


COMMENT ON TABLE "public"."insurers" IS 'Stores registered insurers';



CREATE TABLE IF NOT EXISTS "public"."interactions" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "parent_type" "text" NOT NULL,
    "parent_id" "uuid" NOT NULL,
    "interaction_type" "text" NOT NULL,
    "subject" "text",
    "description" "text" NOT NULL,
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."interactions" OWNER TO "postgres";


COMMENT ON TABLE "public"."interactions" IS 'Stores interactions with clients/leads';



CREATE TABLE IF NOT EXISTS "public"."policy_covers" (
    "policy_id" "uuid" NOT NULL,
    "type_id" "uuid" NOT NULL,
    "sum_insured" numeric,
    "premium" numeric,
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."policy_covers" OWNER TO "postgres";


COMMENT ON TABLE "public"."policy_covers" IS 'Normalized covers linked to policies';



CREATE TABLE IF NOT EXISTS "public"."policy_endorsements" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "policy_id" "uuid" NOT NULL,
    "endorsement_type" "text" NOT NULL,
    "description" "text" NOT NULL,
    "effective_date" "date",
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."policy_endorsements" OWNER TO "postgres";


COMMENT ON TABLE "public"."policy_endorsements" IS 'Tracks changes to policies';



CREATE TABLE IF NOT EXISTS "public"."products" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "insurer_id" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."products" OWNER TO "postgres";


COMMENT ON TABLE "public"."products" IS 'Links products to insurers';



CREATE OR REPLACE VIEW "public"."policy_summary" AS
 SELECT "p"."id",
    "p"."policy_number",
    "p"."start_date",
    "p"."end_date",
    "p"."status",
    "p"."renewal_flag",
    "c"."id" AS "client_id",
    "public"."get_client_full_name"("c".*) AS "client_name",
    "i"."name" AS "insurer_name",
    "pr"."name" AS "product_name"
   FROM ((("public"."policies" "p"
     JOIN "public"."clients" "c" ON (("p"."client_id" = "c"."id")))
     JOIN "public"."insurers" "i" ON (("p"."insurer_id" = "i"."id")))
     JOIN "public"."products" "pr" ON (("p"."product_id" = "pr"."id")));


ALTER VIEW "public"."policy_summary" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."policy_types" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "slug" "text" NOT NULL,
    "display_name" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."policy_types" OWNER TO "postgres";


COMMENT ON TABLE "public"."policy_types" IS 'Defines possible covers';



CREATE TABLE IF NOT EXISTS "public"."quote_options" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "quote_id" "uuid" NOT NULL,
    "insurer_id" "uuid" NOT NULL,
    "product_id" "uuid" NOT NULL,
    "cover_summary" "text",
    "premium" numeric NOT NULL,
    "excess" numeric,
    "key_exclusions" "text",
    "is_selected" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."quote_options" OWNER TO "postgres";


COMMENT ON TABLE "public"."quote_options" IS 'Stores different insurer options for quotes';



CREATE TABLE IF NOT EXISTS "public"."renewals" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "policy_id" "uuid" NOT NULL,
    "renewal_date" "date" NOT NULL,
    "status" "text" DEFAULT 'pending'::"text",
    "premium_change" numeric,
    "notes" "text",
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."renewals" OWNER TO "postgres";


COMMENT ON TABLE "public"."renewals" IS 'Stores renewal tracking information';



ALTER TABLE ONLY "public"."addresses"
    ADD CONSTRAINT "addresses_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."attachments"
    ADD CONSTRAINT "attachments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."claim_items"
    ADD CONSTRAINT "claim_items_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."claim_updates"
    ADD CONSTRAINT "claim_updates_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."claims"
    ADD CONSTRAINT "claims_claim_number_key" UNIQUE ("claim_number");



ALTER TABLE ONLY "public"."claims"
    ADD CONSTRAINT "claims_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."client_contacts"
    ADD CONSTRAINT "client_contacts_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."clients"
    ADD CONSTRAINT "clients_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."employees"
    ADD CONSTRAINT "employees_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."insurers"
    ADD CONSTRAINT "insurers_name_key" UNIQUE ("name");



ALTER TABLE ONLY "public"."insurers"
    ADD CONSTRAINT "insurers_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."interactions"
    ADD CONSTRAINT "interactions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."leads"
    ADD CONSTRAINT "leads_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."policies"
    ADD CONSTRAINT "policies_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."policy_covers"
    ADD CONSTRAINT "policy_covers_pkey" PRIMARY KEY ("policy_id", "type_id");



ALTER TABLE ONLY "public"."policy_endorsements"
    ADD CONSTRAINT "policy_endorsements_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."policy_types"
    ADD CONSTRAINT "policy_types_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."policy_types"
    ADD CONSTRAINT "policy_types_slug_key" UNIQUE ("slug");



ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."quote_options"
    ADD CONSTRAINT "quote_options_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."quotes"
    ADD CONSTRAINT "quotes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."quotes"
    ADD CONSTRAINT "quotes_quote_number_key" UNIQUE ("quote_number");



ALTER TABLE ONLY "public"."renewals"
    ADD CONSTRAINT "renewals_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."tasks"
    ADD CONSTRAINT "tasks_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."policies"
    ADD CONSTRAINT "unique_policy_number_per_insurer" UNIQUE ("insurer_id", "policy_number");



CREATE INDEX "idx_addresses_client_id" ON "public"."addresses" USING "btree" ("client_id");



CREATE INDEX "idx_addresses_is_primary" ON "public"."addresses" USING "btree" ("is_primary");



CREATE INDEX "idx_attachments_parent_type_parent_id" ON "public"."attachments" USING "btree" ("parent_type", "parent_id");



CREATE INDEX "idx_claims_claim_number" ON "public"."claims" USING "btree" ("claim_number");



CREATE INDEX "idx_claims_date_reported" ON "public"."claims" USING "btree" ("date_reported");



CREATE INDEX "idx_claims_policy_id" ON "public"."claims" USING "btree" ("policy_id");



CREATE INDEX "idx_claims_status" ON "public"."claims" USING "btree" ("status");



CREATE INDEX "idx_client_contacts_client_id" ON "public"."client_contacts" USING "btree" ("client_id");



CREATE INDEX "idx_client_contacts_email" ON "public"."client_contacts" USING "btree" ("email") WHERE ("email" IS NOT NULL);



CREATE INDEX "idx_client_contacts_is_primary" ON "public"."client_contacts" USING "btree" ("is_primary");



CREATE INDEX "idx_clients_client_type" ON "public"."clients" USING "btree" ("client_type");



CREATE INDEX "idx_clients_company_reg_number" ON "public"."clients" USING "btree" ("company_reg_number") WHERE ("company_reg_number" IS NOT NULL);



CREATE INDEX "idx_clients_created_by" ON "public"."clients" USING "btree" ("created_by");



CREATE INDEX "idx_clients_id_number" ON "public"."clients" USING "btree" ("id_number") WHERE ("id_number" IS NOT NULL);



CREATE INDEX "idx_clients_status" ON "public"."clients" USING "btree" ("status");



CREATE INDEX "idx_interactions_created_by" ON "public"."interactions" USING "btree" ("created_by");



CREATE INDEX "idx_interactions_parent_type_parent_id" ON "public"."interactions" USING "btree" ("parent_type", "parent_id");



CREATE INDEX "idx_leads_client_type" ON "public"."leads" USING "btree" ("client_type");



CREATE INDEX "idx_leads_owner_id" ON "public"."leads" USING "btree" ("owner_id");



CREATE INDEX "idx_leads_status" ON "public"."leads" USING "btree" ("status");



CREATE INDEX "idx_policies_client_id" ON "public"."policies" USING "btree" ("client_id");



CREATE INDEX "idx_policies_end_date" ON "public"."policies" USING "btree" ("end_date");



CREATE INDEX "idx_policies_insurer_id" ON "public"."policies" USING "btree" ("insurer_id");



CREATE INDEX "idx_policies_policy_number" ON "public"."policies" USING "btree" ("policy_number");



CREATE INDEX "idx_policies_product_id" ON "public"."policies" USING "btree" ("product_id");



CREATE INDEX "idx_policies_renewal_flag" ON "public"."policies" USING "btree" ("renewal_flag");



CREATE INDEX "idx_policies_status" ON "public"."policies" USING "btree" ("status");



CREATE INDEX "idx_quotes_client_id" ON "public"."quotes" USING "btree" ("client_id");



CREATE INDEX "idx_quotes_lead_id" ON "public"."quotes" USING "btree" ("lead_id");



CREATE INDEX "idx_quotes_status" ON "public"."quotes" USING "btree" ("status");



CREATE INDEX "idx_renewals_policy_id" ON "public"."renewals" USING "btree" ("policy_id");



CREATE INDEX "idx_renewals_renewal_date" ON "public"."renewals" USING "btree" ("renewal_date");



CREATE INDEX "idx_renewals_status" ON "public"."renewals" USING "btree" ("status");



CREATE INDEX "idx_tasks_assigned_to" ON "public"."tasks" USING "btree" ("assigned_to");



CREATE INDEX "idx_tasks_due_date" ON "public"."tasks" USING "btree" ("due_date");



CREATE INDEX "idx_tasks_parent_type_parent_id" ON "public"."tasks" USING "btree" ("parent_type", "parent_id");



CREATE INDEX "idx_tasks_status" ON "public"."tasks" USING "btree" ("status");



CREATE UNIQUE INDEX "unique_primary_address_per_client" ON "public"."addresses" USING "btree" ("client_id") WHERE ("is_primary" = true);



CREATE UNIQUE INDEX "unique_primary_contact_per_client" ON "public"."client_contacts" USING "btree" ("client_id") WHERE ("is_primary" = true);



CREATE UNIQUE INDEX "unique_selected_option_per_quote" ON "public"."quote_options" USING "btree" ("quote_id") WHERE ("is_selected" = true);



CREATE OR REPLACE VIEW "public"."client_summary" AS
 SELECT "c"."id",
    "c"."client_type",
    "public"."get_client_full_name"("c".*) AS "full_name",
    "c"."status",
    "c"."created_at",
    "count"("p"."id") AS "policy_count",
    "count"("cl"."id") AS "claim_count"
   FROM (("public"."clients" "c"
     LEFT JOIN "public"."policies" "p" ON ((("c"."id" = "p"."client_id") AND ("p"."status" = 'active'::"public"."policy_status"))))
     LEFT JOIN "public"."claims" "cl" ON (("p"."id" = "cl"."policy_id")))
  GROUP BY "c"."id", "c"."client_type", "c"."first_name", "c"."last_name", "c"."entity_name", "c"."status", "c"."created_at";



CREATE OR REPLACE TRIGGER "update_addresses_updated_at" BEFORE UPDATE ON "public"."addresses" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_attachments_updated_at" BEFORE UPDATE ON "public"."attachments" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_claim_items_updated_at" BEFORE UPDATE ON "public"."claim_items" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_claim_updates_updated_at" BEFORE UPDATE ON "public"."claim_updates" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_claims_updated_at" BEFORE UPDATE ON "public"."claims" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_client_contacts_updated_at" BEFORE UPDATE ON "public"."client_contacts" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_clients_updated_at" BEFORE UPDATE ON "public"."clients" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_employees_updated_at" BEFORE UPDATE ON "public"."employees" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_insurers_updated_at" BEFORE UPDATE ON "public"."insurers" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_interactions_updated_at" BEFORE UPDATE ON "public"."interactions" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_leads_updated_at" BEFORE UPDATE ON "public"."leads" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_policies_updated_at" BEFORE UPDATE ON "public"."policies" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_policy_covers_updated_at" BEFORE UPDATE ON "public"."policy_covers" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_policy_endorsements_updated_at" BEFORE UPDATE ON "public"."policy_endorsements" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_policy_types_updated_at" BEFORE UPDATE ON "public"."policy_types" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_products_updated_at" BEFORE UPDATE ON "public"."products" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_quote_options_updated_at" BEFORE UPDATE ON "public"."quote_options" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_quotes_updated_at" BEFORE UPDATE ON "public"."quotes" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_renewal_flag" BEFORE INSERT OR UPDATE ON "public"."policies" FOR EACH ROW EXECUTE FUNCTION "public"."check_renewal_flag"();



CREATE OR REPLACE TRIGGER "update_renewals_updated_at" BEFORE UPDATE ON "public"."renewals" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_tasks_updated_at" BEFORE UPDATE ON "public"."tasks" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



ALTER TABLE ONLY "public"."addresses"
    ADD CONSTRAINT "addresses_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "public"."clients"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."addresses"
    ADD CONSTRAINT "addresses_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."attachments"
    ADD CONSTRAINT "attachments_uploaded_by_fkey" FOREIGN KEY ("uploaded_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."claim_items"
    ADD CONSTRAINT "claim_items_claim_id_fkey" FOREIGN KEY ("claim_id") REFERENCES "public"."claims"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."claim_updates"
    ADD CONSTRAINT "claim_updates_claim_id_fkey" FOREIGN KEY ("claim_id") REFERENCES "public"."claims"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."claim_updates"
    ADD CONSTRAINT "claim_updates_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."claims"
    ADD CONSTRAINT "claims_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."claims"
    ADD CONSTRAINT "claims_policy_id_fkey" FOREIGN KEY ("policy_id") REFERENCES "public"."policies"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."client_contacts"
    ADD CONSTRAINT "client_contacts_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "public"."clients"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."client_contacts"
    ADD CONSTRAINT "client_contacts_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."clients"
    ADD CONSTRAINT "clients_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."employees"
    ADD CONSTRAINT "employees_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."interactions"
    ADD CONSTRAINT "interactions_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."leads"
    ADD CONSTRAINT "leads_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."policies"
    ADD CONSTRAINT "policies_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "public"."clients"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."policies"
    ADD CONSTRAINT "policies_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."policies"
    ADD CONSTRAINT "policies_insurer_id_fkey" FOREIGN KEY ("insurer_id") REFERENCES "public"."insurers"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."policies"
    ADD CONSTRAINT "policies_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."policy_covers"
    ADD CONSTRAINT "policy_covers_policy_id_fkey" FOREIGN KEY ("policy_id") REFERENCES "public"."policies"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."policy_covers"
    ADD CONSTRAINT "policy_covers_type_id_fkey" FOREIGN KEY ("type_id") REFERENCES "public"."policy_types"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."policy_endorsements"
    ADD CONSTRAINT "policy_endorsements_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."policy_endorsements"
    ADD CONSTRAINT "policy_endorsements_policy_id_fkey" FOREIGN KEY ("policy_id") REFERENCES "public"."policies"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_insurer_id_fkey" FOREIGN KEY ("insurer_id") REFERENCES "public"."insurers"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."quote_options"
    ADD CONSTRAINT "quote_options_insurer_id_fkey" FOREIGN KEY ("insurer_id") REFERENCES "public"."insurers"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."quote_options"
    ADD CONSTRAINT "quote_options_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."quote_options"
    ADD CONSTRAINT "quote_options_quote_id_fkey" FOREIGN KEY ("quote_id") REFERENCES "public"."quotes"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."quotes"
    ADD CONSTRAINT "quotes_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "public"."clients"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."quotes"
    ADD CONSTRAINT "quotes_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."quotes"
    ADD CONSTRAINT "quotes_lead_id_fkey" FOREIGN KEY ("lead_id") REFERENCES "public"."leads"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."renewals"
    ADD CONSTRAINT "renewals_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."renewals"
    ADD CONSTRAINT "renewals_policy_id_fkey" FOREIGN KEY ("policy_id") REFERENCES "public"."policies"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."tasks"
    ADD CONSTRAINT "tasks_assigned_to_fkey" FOREIGN KEY ("assigned_to") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."tasks"
    ADD CONSTRAINT "tasks_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



CREATE POLICY "Only super_admin can manage employees" ON "public"."employees" USING ((EXISTS ( SELECT 1
   FROM "public"."employees" "employees_1"
  WHERE (("employees_1"."id" = "auth"."uid"()) AND ("employees_1"."role" = 'super_admin'::"text")))));



CREATE POLICY "Users can insert their own clients" ON "public"."clients" FOR INSERT WITH CHECK ((("created_by" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."employees"
  WHERE (("employees"."id" = "auth"."uid"()) AND ("employees"."role" = ANY (ARRAY['super_admin'::"text", 'manager'::"text", 'admin_staff'::"text"])))))));



CREATE POLICY "Users can manage addresses for their clients" ON "public"."addresses" USING ((EXISTS ( SELECT 1
   FROM "public"."clients"
  WHERE (("clients"."id" = "addresses"."client_id") AND (("clients"."created_by" = "auth"."uid"()) OR (EXISTS ( SELECT 1
           FROM "public"."employees"
          WHERE (("employees"."id" = "auth"."uid"()) AND ("employees"."role" = ANY (ARRAY['super_admin'::"text", 'manager'::"text", 'admin_staff'::"text"]))))))))));



CREATE POLICY "Users can manage claims for their policies" ON "public"."claims" USING ((EXISTS ( SELECT 1
   FROM "public"."policies"
  WHERE (("policies"."id" = "claims"."policy_id") AND (("policies"."created_by" = "auth"."uid"()) OR (EXISTS ( SELECT 1
           FROM "public"."employees"
          WHERE (("employees"."id" = "auth"."uid"()) AND ("employees"."role" = ANY (ARRAY['super_admin'::"text", 'manager'::"text", 'claims_handler'::"text"]))))))))));



CREATE POLICY "Users can manage contacts for their clients" ON "public"."client_contacts" USING ((EXISTS ( SELECT 1
   FROM "public"."clients"
  WHERE (("clients"."id" = "client_contacts"."client_id") AND (("clients"."created_by" = "auth"."uid"()) OR (EXISTS ( SELECT 1
           FROM "public"."employees"
          WHERE (("employees"."id" = "auth"."uid"()) AND ("employees"."role" = ANY (ARRAY['super_admin'::"text", 'manager'::"text", 'admin_staff'::"text"]))))))))));



CREATE POLICY "Users can manage quotes for their leads" ON "public"."quotes" USING ((EXISTS ( SELECT 1
   FROM "public"."leads"
  WHERE (("leads"."id" = "quotes"."lead_id") AND (("leads"."owner_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
           FROM "public"."employees"
          WHERE (("employees"."id" = "auth"."uid"()) AND ("employees"."role" = ANY (ARRAY['super_admin'::"text", 'manager'::"text"]))))))))));



CREATE POLICY "Users can manage their own leads" ON "public"."leads" USING ((("owner_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."employees"
  WHERE (("employees"."id" = "auth"."uid"()) AND ("employees"."role" = ANY (ARRAY['super_admin'::"text", 'manager'::"text"])))))));



CREATE POLICY "Users can manage their own policies" ON "public"."policies" USING ((("created_by" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."employees"
  WHERE (("employees"."id" = "auth"."uid"()) AND ("employees"."role" = ANY (ARRAY['super_admin'::"text", 'manager'::"text", 'admin_staff'::"text"])))))));



CREATE POLICY "Users can update their own clients" ON "public"."clients" FOR UPDATE USING ((("created_by" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."employees"
  WHERE (("employees"."id" = "auth"."uid"()) AND ("employees"."role" = ANY (ARRAY['super_admin'::"text", 'manager'::"text", 'admin_staff'::"text"])))))));



CREATE POLICY "Users can view addresses for their clients" ON "public"."addresses" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."clients"
  WHERE (("clients"."id" = "addresses"."client_id") AND (("clients"."created_by" = "auth"."uid"()) OR (EXISTS ( SELECT 1
           FROM "public"."employees"
          WHERE (("employees"."id" = "auth"."uid"()) AND ("employees"."role" = ANY (ARRAY['super_admin'::"text", 'manager'::"text", 'admin_staff'::"text"]))))))))));



CREATE POLICY "Users can view claims for their policies" ON "public"."claims" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."policies"
  WHERE (("policies"."id" = "claims"."policy_id") AND (("policies"."created_by" = "auth"."uid"()) OR (EXISTS ( SELECT 1
           FROM "public"."employees"
          WHERE (("employees"."id" = "auth"."uid"()) AND ("employees"."role" = ANY (ARRAY['super_admin'::"text", 'manager'::"text", 'claims_handler'::"text"]))))))))));



CREATE POLICY "Users can view contacts for their clients" ON "public"."client_contacts" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."clients"
  WHERE (("clients"."id" = "client_contacts"."client_id") AND (("clients"."created_by" = "auth"."uid"()) OR (EXISTS ( SELECT 1
           FROM "public"."employees"
          WHERE (("employees"."id" = "auth"."uid"()) AND ("employees"."role" = ANY (ARRAY['super_admin'::"text", 'manager'::"text", 'admin_staff'::"text"]))))))))));



CREATE POLICY "Users can view employees" ON "public"."employees" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."employees" "employees_1"
  WHERE (("employees_1"."id" = "auth"."uid"()) AND ("employees_1"."role" = ANY (ARRAY['super_admin'::"text", 'manager'::"text"]))))));



CREATE POLICY "Users can view quotes for their leads" ON "public"."quotes" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."leads"
  WHERE (("leads"."id" = "quotes"."lead_id") AND (("leads"."owner_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
           FROM "public"."employees"
          WHERE (("employees"."id" = "auth"."uid"()) AND ("employees"."role" = ANY (ARRAY['super_admin'::"text", 'manager'::"text"]))))))))));



CREATE POLICY "Users can view their own clients" ON "public"."clients" FOR SELECT USING ((("created_by" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."employees"
  WHERE (("employees"."id" = "auth"."uid"()) AND ("employees"."role" = ANY (ARRAY['super_admin'::"text", 'manager'::"text", 'admin_staff'::"text"])))))));



CREATE POLICY "Users can view their own leads" ON "public"."leads" FOR SELECT USING ((("owner_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."employees"
  WHERE (("employees"."id" = "auth"."uid"()) AND ("employees"."role" = ANY (ARRAY['super_admin'::"text", 'manager'::"text"])))))));



CREATE POLICY "Users can view their own policies" ON "public"."policies" FOR SELECT USING ((("created_by" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."employees"
  WHERE (("employees"."id" = "auth"."uid"()) AND ("employees"."role" = ANY (ARRAY['super_admin'::"text", 'manager'::"text", 'admin_staff'::"text"])))))));



ALTER TABLE "public"."addresses" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."attachments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."claim_items" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."claim_updates" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."claims" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."client_contacts" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."clients" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."employees" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."insurers" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."interactions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."leads" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."policies" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."policy_covers" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."policy_endorsements" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."policy_types" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."products" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."quote_options" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."quotes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."renewals" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."tasks" ENABLE ROW LEVEL SECURITY;


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT ALL ON FUNCTION "public"."check_renewal_flag"() TO "anon";
GRANT ALL ON FUNCTION "public"."check_renewal_flag"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_renewal_flag"() TO "service_role";



GRANT ALL ON FUNCTION "public"."generate_quote_number"() TO "anon";
GRANT ALL ON FUNCTION "public"."generate_quote_number"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_quote_number"() TO "service_role";



GRANT ALL ON TABLE "public"."clients" TO "anon";
GRANT ALL ON TABLE "public"."clients" TO "authenticated";
GRANT ALL ON TABLE "public"."clients" TO "service_role";



GRANT ALL ON FUNCTION "public"."get_client_full_name"("client_record" "public"."clients") TO "anon";
GRANT ALL ON FUNCTION "public"."get_client_full_name"("client_record" "public"."clients") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_client_full_name"("client_record" "public"."clients") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "service_role";



GRANT ALL ON TABLE "public"."addresses" TO "anon";
GRANT ALL ON TABLE "public"."addresses" TO "authenticated";
GRANT ALL ON TABLE "public"."addresses" TO "service_role";



GRANT ALL ON TABLE "public"."attachments" TO "anon";
GRANT ALL ON TABLE "public"."attachments" TO "authenticated";
GRANT ALL ON TABLE "public"."attachments" TO "service_role";



GRANT ALL ON TABLE "public"."claim_items" TO "anon";
GRANT ALL ON TABLE "public"."claim_items" TO "authenticated";
GRANT ALL ON TABLE "public"."claim_items" TO "service_role";



GRANT ALL ON TABLE "public"."claim_updates" TO "anon";
GRANT ALL ON TABLE "public"."claim_updates" TO "authenticated";
GRANT ALL ON TABLE "public"."claim_updates" TO "service_role";



GRANT ALL ON TABLE "public"."claims" TO "anon";
GRANT ALL ON TABLE "public"."claims" TO "authenticated";
GRANT ALL ON TABLE "public"."claims" TO "service_role";



GRANT ALL ON TABLE "public"."client_contacts" TO "anon";
GRANT ALL ON TABLE "public"."client_contacts" TO "authenticated";
GRANT ALL ON TABLE "public"."client_contacts" TO "service_role";



GRANT ALL ON TABLE "public"."client_summary" TO "anon";
GRANT ALL ON TABLE "public"."client_summary" TO "authenticated";
GRANT ALL ON TABLE "public"."client_summary" TO "service_role";



GRANT ALL ON TABLE "public"."leads" TO "anon";
GRANT ALL ON TABLE "public"."leads" TO "authenticated";
GRANT ALL ON TABLE "public"."leads" TO "service_role";



GRANT ALL ON TABLE "public"."policies" TO "anon";
GRANT ALL ON TABLE "public"."policies" TO "authenticated";
GRANT ALL ON TABLE "public"."policies" TO "service_role";



GRANT ALL ON TABLE "public"."quotes" TO "anon";
GRANT ALL ON TABLE "public"."quotes" TO "authenticated";
GRANT ALL ON TABLE "public"."quotes" TO "service_role";



GRANT ALL ON TABLE "public"."tasks" TO "anon";
GRANT ALL ON TABLE "public"."tasks" TO "authenticated";
GRANT ALL ON TABLE "public"."tasks" TO "service_role";



GRANT ALL ON TABLE "public"."dashboard_stats" TO "anon";
GRANT ALL ON TABLE "public"."dashboard_stats" TO "authenticated";
GRANT ALL ON TABLE "public"."dashboard_stats" TO "service_role";



GRANT ALL ON TABLE "public"."employees" TO "anon";
GRANT ALL ON TABLE "public"."employees" TO "authenticated";
GRANT ALL ON TABLE "public"."employees" TO "service_role";



GRANT ALL ON TABLE "public"."insurers" TO "anon";
GRANT ALL ON TABLE "public"."insurers" TO "authenticated";
GRANT ALL ON TABLE "public"."insurers" TO "service_role";



GRANT ALL ON TABLE "public"."interactions" TO "anon";
GRANT ALL ON TABLE "public"."interactions" TO "authenticated";
GRANT ALL ON TABLE "public"."interactions" TO "service_role";



GRANT ALL ON TABLE "public"."policy_covers" TO "anon";
GRANT ALL ON TABLE "public"."policy_covers" TO "authenticated";
GRANT ALL ON TABLE "public"."policy_covers" TO "service_role";



GRANT ALL ON TABLE "public"."policy_endorsements" TO "anon";
GRANT ALL ON TABLE "public"."policy_endorsements" TO "authenticated";
GRANT ALL ON TABLE "public"."policy_endorsements" TO "service_role";



GRANT ALL ON TABLE "public"."products" TO "anon";
GRANT ALL ON TABLE "public"."products" TO "authenticated";
GRANT ALL ON TABLE "public"."products" TO "service_role";



GRANT ALL ON TABLE "public"."policy_summary" TO "anon";
GRANT ALL ON TABLE "public"."policy_summary" TO "authenticated";
GRANT ALL ON TABLE "public"."policy_summary" TO "service_role";



GRANT ALL ON TABLE "public"."policy_types" TO "anon";
GRANT ALL ON TABLE "public"."policy_types" TO "authenticated";
GRANT ALL ON TABLE "public"."policy_types" TO "service_role";



GRANT ALL ON TABLE "public"."quote_options" TO "anon";
GRANT ALL ON TABLE "public"."quote_options" TO "authenticated";
GRANT ALL ON TABLE "public"."quote_options" TO "service_role";



GRANT ALL ON TABLE "public"."renewals" TO "anon";
GRANT ALL ON TABLE "public"."renewals" TO "authenticated";
GRANT ALL ON TABLE "public"."renewals" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";






RESET ALL;
