create type "public"."claim_status" as enum ('reported', 'in_review', 'approved', 'declined', 'settled');

create type "public"."client_status" as enum ('active', 'inactive');

create type "public"."client_type" as enum ('personal', 'business', 'body_corporate');

create type "public"."lead_status" as enum ('new', 'contacted', 'qualifying', 'quoting', 'awaiting_docs', 'decision', 'won', 'lost');

create type "public"."policy_status" as enum ('active', 'cancelled', 'pending');

create type "public"."quote_status" as enum ('draft', 'sent', 'accepted', 'declined', 'expired');

create type "public"."task_priority" as enum ('low', 'medium', 'high', 'urgent');

create type "public"."task_status" as enum ('pending', 'in_progress', 'completed', 'cancelled');

create table "public"."addresses" (
    "id" uuid not null default uuid_generate_v4(),
    "client_id" uuid not null,
    "is_primary" boolean default false,
    "line1" text not null,
    "line2" text,
    "city" text,
    "province" text,
    "postal_code" character varying(10),
    "country" text default 'South Africa'::text,
    "created_by" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."addresses" enable row level security;

create table "public"."attachments" (
    "id" uuid not null default uuid_generate_v4(),
    "parent_type" text not null,
    "parent_id" uuid not null,
    "url" text not null,
    "file_name" text,
    "file_size" integer,
    "mime_type" text,
    "uploaded_by" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."attachments" enable row level security;

create table "public"."claim_items" (
    "id" uuid not null default uuid_generate_v4(),
    "claim_id" uuid not null,
    "description" text not null,
    "amount" numeric,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."claim_items" enable row level security;

create table "public"."claim_updates" (
    "id" uuid not null default uuid_generate_v4(),
    "claim_id" uuid not null,
    "update_text" text not null,
    "created_by" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."claim_updates" enable row level security;

create table "public"."claims" (
    "id" uuid not null default uuid_generate_v4(),
    "policy_id" uuid not null,
    "claim_number" text not null,
    "date_reported" date not null,
    "status" claim_status default 'reported'::claim_status,
    "created_by" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."claims" enable row level security;

create table "public"."client_contacts" (
    "id" uuid not null default uuid_generate_v4(),
    "client_id" uuid not null,
    "is_primary" boolean default false,
    "role" text,
    "name" text not null,
    "phone" character varying(20),
    "email" text,
    "created_by" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."client_contacts" enable row level security;

create table "public"."clients" (
    "id" uuid not null default uuid_generate_v4(),
    "client_type" client_type not null,
    "entity_name" text,
    "first_name" text,
    "last_name" text,
    "id_number" character varying(13),
    "company_reg_number" character varying(20),
    "vat_number" character varying(15),
    "comments" text,
    "status" client_status default 'active'::client_status,
    "created_by" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."clients" enable row level security;

create table "public"."employees" (
    "id" uuid not null,
    "full_name" text not null,
    "contact_number" character varying(20),
    "display_image" text,
    "role" text not null,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."employees" enable row level security;

create table "public"."insurers" (
    "id" uuid not null default uuid_generate_v4(),
    "name" text not null,
    "contact_info" jsonb,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."insurers" enable row level security;

create table "public"."interactions" (
    "id" uuid not null default uuid_generate_v4(),
    "parent_type" text not null,
    "parent_id" uuid not null,
    "interaction_type" text not null,
    "subject" text,
    "description" text not null,
    "created_by" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."interactions" enable row level security;

create table "public"."leads" (
    "id" uuid not null default uuid_generate_v4(),
    "owner_id" uuid not null,
    "source" text,
    "client_type" client_type not null,
    "prospect_name" text not null,
    "company_reg_number" character varying(20),
    "id_number" character varying(13),
    "contact_email" text,
    "contact_phone" character varying(20),
    "region" text,
    "province" text,
    "product_interest" text,
    "status" lead_status default 'new'::lead_status,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."leads" enable row level security;

create table "public"."policies" (
    "id" uuid not null default uuid_generate_v4(),
    "client_id" uuid not null,
    "insurer_id" uuid not null,
    "product_id" uuid not null,
    "policy_number" text not null,
    "start_date" date,
    "end_date" date,
    "status" policy_status default 'active'::policy_status,
    "renewal_flag" boolean default false,
    "created_by" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."policies" enable row level security;

create table "public"."policy_covers" (
    "policy_id" uuid not null,
    "type_id" uuid not null,
    "sum_insured" numeric,
    "premium" numeric,
    "updated_at" timestamp with time zone default now()
);


alter table "public"."policy_covers" enable row level security;

create table "public"."policy_endorsements" (
    "id" uuid not null default uuid_generate_v4(),
    "policy_id" uuid not null,
    "endorsement_type" text not null,
    "description" text not null,
    "effective_date" date,
    "created_by" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."policy_endorsements" enable row level security;

create table "public"."policy_types" (
    "id" uuid not null default uuid_generate_v4(),
    "slug" text not null,
    "display_name" text not null,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."policy_types" enable row level security;

create table "public"."products" (
    "id" uuid not null default uuid_generate_v4(),
    "insurer_id" uuid not null,
    "name" text not null,
    "description" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."products" enable row level security;

create table "public"."quote_options" (
    "id" uuid not null default uuid_generate_v4(),
    "quote_id" uuid not null,
    "insurer_id" uuid not null,
    "product_id" uuid not null,
    "cover_summary" text,
    "premium" numeric not null,
    "excess" numeric,
    "key_exclusions" text,
    "is_selected" boolean default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."quote_options" enable row level security;

create table "public"."quotes" (
    "id" uuid not null default uuid_generate_v4(),
    "lead_id" uuid,
    "client_id" uuid,
    "quote_number" text not null,
    "status" quote_status default 'draft'::quote_status,
    "valid_until" date,
    "created_by" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."quotes" enable row level security;

create table "public"."renewals" (
    "id" uuid not null default uuid_generate_v4(),
    "policy_id" uuid not null,
    "renewal_date" date not null,
    "status" text default 'pending'::text,
    "premium_change" numeric,
    "notes" text,
    "created_by" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."renewals" enable row level security;

create table "public"."tasks" (
    "id" uuid not null default uuid_generate_v4(),
    "title" text not null,
    "description" text,
    "assigned_to" uuid,
    "created_by" uuid,
    "due_date" date,
    "priority" task_priority default 'medium'::task_priority,
    "status" task_status default 'pending'::task_status,
    "parent_type" text,
    "parent_id" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."tasks" enable row level security;

CREATE UNIQUE INDEX addresses_pkey ON public.addresses USING btree (id);

CREATE UNIQUE INDEX attachments_pkey ON public.attachments USING btree (id);

CREATE UNIQUE INDEX claim_items_pkey ON public.claim_items USING btree (id);

CREATE UNIQUE INDEX claim_updates_pkey ON public.claim_updates USING btree (id);

CREATE UNIQUE INDEX claims_claim_number_key ON public.claims USING btree (claim_number);

CREATE UNIQUE INDEX claims_pkey ON public.claims USING btree (id);

CREATE UNIQUE INDEX client_contacts_pkey ON public.client_contacts USING btree (id);

CREATE UNIQUE INDEX clients_pkey ON public.clients USING btree (id);

CREATE UNIQUE INDEX employees_pkey ON public.employees USING btree (id);

CREATE INDEX idx_addresses_client_id ON public.addresses USING btree (client_id);

CREATE INDEX idx_addresses_is_primary ON public.addresses USING btree (is_primary);

CREATE INDEX idx_attachments_parent_type_parent_id ON public.attachments USING btree (parent_type, parent_id);

CREATE INDEX idx_claims_claim_number ON public.claims USING btree (claim_number);

CREATE INDEX idx_claims_date_reported ON public.claims USING btree (date_reported);

CREATE INDEX idx_claims_policy_id ON public.claims USING btree (policy_id);

CREATE INDEX idx_claims_status ON public.claims USING btree (status);

CREATE INDEX idx_client_contacts_client_id ON public.client_contacts USING btree (client_id);

CREATE INDEX idx_client_contacts_email ON public.client_contacts USING btree (email) WHERE (email IS NOT NULL);

CREATE INDEX idx_client_contacts_is_primary ON public.client_contacts USING btree (is_primary);

CREATE INDEX idx_clients_client_type ON public.clients USING btree (client_type);

CREATE INDEX idx_clients_company_reg_number ON public.clients USING btree (company_reg_number) WHERE (company_reg_number IS NOT NULL);

CREATE INDEX idx_clients_created_by ON public.clients USING btree (created_by);

CREATE INDEX idx_clients_id_number ON public.clients USING btree (id_number) WHERE (id_number IS NOT NULL);

CREATE INDEX idx_clients_status ON public.clients USING btree (status);

CREATE INDEX idx_interactions_created_by ON public.interactions USING btree (created_by);

CREATE INDEX idx_interactions_parent_type_parent_id ON public.interactions USING btree (parent_type, parent_id);

CREATE INDEX idx_leads_client_type ON public.leads USING btree (client_type);

CREATE INDEX idx_leads_owner_id ON public.leads USING btree (owner_id);

CREATE INDEX idx_leads_status ON public.leads USING btree (status);

CREATE INDEX idx_policies_client_id ON public.policies USING btree (client_id);

CREATE INDEX idx_policies_end_date ON public.policies USING btree (end_date);

CREATE INDEX idx_policies_insurer_id ON public.policies USING btree (insurer_id);

CREATE INDEX idx_policies_policy_number ON public.policies USING btree (policy_number);

CREATE INDEX idx_policies_product_id ON public.policies USING btree (product_id);

CREATE INDEX idx_policies_renewal_flag ON public.policies USING btree (renewal_flag);

CREATE INDEX idx_policies_status ON public.policies USING btree (status);

CREATE INDEX idx_quotes_client_id ON public.quotes USING btree (client_id);

CREATE INDEX idx_quotes_lead_id ON public.quotes USING btree (lead_id);

CREATE INDEX idx_quotes_status ON public.quotes USING btree (status);

CREATE INDEX idx_renewals_policy_id ON public.renewals USING btree (policy_id);

CREATE INDEX idx_renewals_renewal_date ON public.renewals USING btree (renewal_date);

CREATE INDEX idx_renewals_status ON public.renewals USING btree (status);

CREATE INDEX idx_tasks_assigned_to ON public.tasks USING btree (assigned_to);

CREATE INDEX idx_tasks_due_date ON public.tasks USING btree (due_date);

CREATE INDEX idx_tasks_parent_type_parent_id ON public.tasks USING btree (parent_type, parent_id);

CREATE INDEX idx_tasks_status ON public.tasks USING btree (status);

CREATE UNIQUE INDEX insurers_name_key ON public.insurers USING btree (name);

CREATE UNIQUE INDEX insurers_pkey ON public.insurers USING btree (id);

CREATE UNIQUE INDEX interactions_pkey ON public.interactions USING btree (id);

CREATE UNIQUE INDEX leads_pkey ON public.leads USING btree (id);

CREATE UNIQUE INDEX policies_pkey ON public.policies USING btree (id);

CREATE UNIQUE INDEX policy_covers_pkey ON public.policy_covers USING btree (policy_id, type_id);

CREATE UNIQUE INDEX policy_endorsements_pkey ON public.policy_endorsements USING btree (id);

CREATE UNIQUE INDEX policy_types_pkey ON public.policy_types USING btree (id);

CREATE UNIQUE INDEX policy_types_slug_key ON public.policy_types USING btree (slug);

CREATE UNIQUE INDEX products_pkey ON public.products USING btree (id);

CREATE UNIQUE INDEX quote_options_pkey ON public.quote_options USING btree (id);

CREATE UNIQUE INDEX quotes_pkey ON public.quotes USING btree (id);

CREATE UNIQUE INDEX quotes_quote_number_key ON public.quotes USING btree (quote_number);

CREATE UNIQUE INDEX renewals_pkey ON public.renewals USING btree (id);

CREATE UNIQUE INDEX tasks_pkey ON public.tasks USING btree (id);

CREATE UNIQUE INDEX unique_policy_number_per_insurer ON public.policies USING btree (insurer_id, policy_number);

CREATE UNIQUE INDEX unique_primary_address_per_client ON public.addresses USING btree (client_id) WHERE (is_primary = true);

CREATE UNIQUE INDEX unique_primary_contact_per_client ON public.client_contacts USING btree (client_id) WHERE (is_primary = true);

CREATE UNIQUE INDEX unique_selected_option_per_quote ON public.quote_options USING btree (quote_id) WHERE (is_selected = true);

alter table "public"."addresses" add constraint "addresses_pkey" PRIMARY KEY using index "addresses_pkey";

alter table "public"."attachments" add constraint "attachments_pkey" PRIMARY KEY using index "attachments_pkey";

alter table "public"."claim_items" add constraint "claim_items_pkey" PRIMARY KEY using index "claim_items_pkey";

alter table "public"."claim_updates" add constraint "claim_updates_pkey" PRIMARY KEY using index "claim_updates_pkey";

alter table "public"."claims" add constraint "claims_pkey" PRIMARY KEY using index "claims_pkey";

alter table "public"."client_contacts" add constraint "client_contacts_pkey" PRIMARY KEY using index "client_contacts_pkey";

alter table "public"."clients" add constraint "clients_pkey" PRIMARY KEY using index "clients_pkey";

alter table "public"."employees" add constraint "employees_pkey" PRIMARY KEY using index "employees_pkey";

alter table "public"."insurers" add constraint "insurers_pkey" PRIMARY KEY using index "insurers_pkey";

alter table "public"."interactions" add constraint "interactions_pkey" PRIMARY KEY using index "interactions_pkey";

alter table "public"."leads" add constraint "leads_pkey" PRIMARY KEY using index "leads_pkey";

alter table "public"."policies" add constraint "policies_pkey" PRIMARY KEY using index "policies_pkey";

alter table "public"."policy_covers" add constraint "policy_covers_pkey" PRIMARY KEY using index "policy_covers_pkey";

alter table "public"."policy_endorsements" add constraint "policy_endorsements_pkey" PRIMARY KEY using index "policy_endorsements_pkey";

alter table "public"."policy_types" add constraint "policy_types_pkey" PRIMARY KEY using index "policy_types_pkey";

alter table "public"."products" add constraint "products_pkey" PRIMARY KEY using index "products_pkey";

alter table "public"."quote_options" add constraint "quote_options_pkey" PRIMARY KEY using index "quote_options_pkey";

alter table "public"."quotes" add constraint "quotes_pkey" PRIMARY KEY using index "quotes_pkey";

alter table "public"."renewals" add constraint "renewals_pkey" PRIMARY KEY using index "renewals_pkey";

alter table "public"."tasks" add constraint "tasks_pkey" PRIMARY KEY using index "tasks_pkey";

alter table "public"."addresses" add constraint "addresses_client_id_fkey" FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE not valid;

alter table "public"."addresses" validate constraint "addresses_client_id_fkey";

alter table "public"."addresses" add constraint "addresses_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "public"."addresses" validate constraint "addresses_created_by_fkey";

alter table "public"."attachments" add constraint "attachments_uploaded_by_fkey" FOREIGN KEY (uploaded_by) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "public"."attachments" validate constraint "attachments_uploaded_by_fkey";

alter table "public"."claim_items" add constraint "claim_items_claim_id_fkey" FOREIGN KEY (claim_id) REFERENCES claims(id) ON DELETE CASCADE not valid;

alter table "public"."claim_items" validate constraint "claim_items_claim_id_fkey";

alter table "public"."claim_updates" add constraint "claim_updates_claim_id_fkey" FOREIGN KEY (claim_id) REFERENCES claims(id) ON DELETE CASCADE not valid;

alter table "public"."claim_updates" validate constraint "claim_updates_claim_id_fkey";

alter table "public"."claim_updates" add constraint "claim_updates_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "public"."claim_updates" validate constraint "claim_updates_created_by_fkey";

alter table "public"."claims" add constraint "claims_claim_number_key" UNIQUE using index "claims_claim_number_key";

alter table "public"."claims" add constraint "claims_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "public"."claims" validate constraint "claims_created_by_fkey";

alter table "public"."claims" add constraint "claims_policy_id_fkey" FOREIGN KEY (policy_id) REFERENCES policies(id) ON DELETE CASCADE not valid;

alter table "public"."claims" validate constraint "claims_policy_id_fkey";

alter table "public"."client_contacts" add constraint "client_contacts_client_id_fkey" FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE not valid;

alter table "public"."client_contacts" validate constraint "client_contacts_client_id_fkey";

alter table "public"."client_contacts" add constraint "client_contacts_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "public"."client_contacts" validate constraint "client_contacts_created_by_fkey";

alter table "public"."clients" add constraint "clients_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "public"."clients" validate constraint "clients_created_by_fkey";

alter table "public"."employees" add constraint "employees_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."employees" validate constraint "employees_id_fkey";

alter table "public"."insurers" add constraint "insurers_name_key" UNIQUE using index "insurers_name_key";

alter table "public"."interactions" add constraint "interactions_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "public"."interactions" validate constraint "interactions_created_by_fkey";

alter table "public"."leads" add constraint "leads_owner_id_fkey" FOREIGN KEY (owner_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."leads" validate constraint "leads_owner_id_fkey";

alter table "public"."policies" add constraint "policies_client_id_fkey" FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE not valid;

alter table "public"."policies" validate constraint "policies_client_id_fkey";

alter table "public"."policies" add constraint "policies_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "public"."policies" validate constraint "policies_created_by_fkey";

alter table "public"."policies" add constraint "policies_insurer_id_fkey" FOREIGN KEY (insurer_id) REFERENCES insurers(id) ON DELETE CASCADE not valid;

alter table "public"."policies" validate constraint "policies_insurer_id_fkey";

alter table "public"."policies" add constraint "policies_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE not valid;

alter table "public"."policies" validate constraint "policies_product_id_fkey";

alter table "public"."policies" add constraint "unique_policy_number_per_insurer" UNIQUE using index "unique_policy_number_per_insurer";

alter table "public"."policy_covers" add constraint "policy_covers_policy_id_fkey" FOREIGN KEY (policy_id) REFERENCES policies(id) ON DELETE CASCADE not valid;

alter table "public"."policy_covers" validate constraint "policy_covers_policy_id_fkey";

alter table "public"."policy_covers" add constraint "policy_covers_type_id_fkey" FOREIGN KEY (type_id) REFERENCES policy_types(id) ON DELETE CASCADE not valid;

alter table "public"."policy_covers" validate constraint "policy_covers_type_id_fkey";

alter table "public"."policy_endorsements" add constraint "policy_endorsements_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "public"."policy_endorsements" validate constraint "policy_endorsements_created_by_fkey";

alter table "public"."policy_endorsements" add constraint "policy_endorsements_policy_id_fkey" FOREIGN KEY (policy_id) REFERENCES policies(id) ON DELETE CASCADE not valid;

alter table "public"."policy_endorsements" validate constraint "policy_endorsements_policy_id_fkey";

alter table "public"."policy_types" add constraint "policy_types_slug_key" UNIQUE using index "policy_types_slug_key";

alter table "public"."products" add constraint "products_insurer_id_fkey" FOREIGN KEY (insurer_id) REFERENCES insurers(id) ON DELETE CASCADE not valid;

alter table "public"."products" validate constraint "products_insurer_id_fkey";

alter table "public"."quote_options" add constraint "quote_options_insurer_id_fkey" FOREIGN KEY (insurer_id) REFERENCES insurers(id) ON DELETE CASCADE not valid;

alter table "public"."quote_options" validate constraint "quote_options_insurer_id_fkey";

alter table "public"."quote_options" add constraint "quote_options_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE not valid;

alter table "public"."quote_options" validate constraint "quote_options_product_id_fkey";

alter table "public"."quote_options" add constraint "quote_options_quote_id_fkey" FOREIGN KEY (quote_id) REFERENCES quotes(id) ON DELETE CASCADE not valid;

alter table "public"."quote_options" validate constraint "quote_options_quote_id_fkey";

alter table "public"."quotes" add constraint "quotes_client_id_fkey" FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE not valid;

alter table "public"."quotes" validate constraint "quotes_client_id_fkey";

alter table "public"."quotes" add constraint "quotes_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "public"."quotes" validate constraint "quotes_created_by_fkey";

alter table "public"."quotes" add constraint "quotes_lead_id_fkey" FOREIGN KEY (lead_id) REFERENCES leads(id) ON DELETE CASCADE not valid;

alter table "public"."quotes" validate constraint "quotes_lead_id_fkey";

alter table "public"."quotes" add constraint "quotes_quote_number_key" UNIQUE using index "quotes_quote_number_key";

alter table "public"."renewals" add constraint "renewals_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "public"."renewals" validate constraint "renewals_created_by_fkey";

alter table "public"."renewals" add constraint "renewals_policy_id_fkey" FOREIGN KEY (policy_id) REFERENCES policies(id) ON DELETE CASCADE not valid;

alter table "public"."renewals" validate constraint "renewals_policy_id_fkey";

alter table "public"."tasks" add constraint "tasks_assigned_to_fkey" FOREIGN KEY (assigned_to) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "public"."tasks" validate constraint "tasks_assigned_to_fkey";

alter table "public"."tasks" add constraint "tasks_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "public"."tasks" validate constraint "tasks_created_by_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.check_renewal_flag()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF NEW.end_date IS NOT NULL THEN
        NEW.renewal_flag := (NEW.end_date - CURRENT_DATE) <= INTERVAL '60 days';
    END IF;
    RETURN NEW;
END;
$function$
;

create or replace view "public"."dashboard_stats" as  SELECT ( SELECT count(*) AS count
           FROM leads
          WHERE (leads.status = 'new'::lead_status)) AS new_leads,
    ( SELECT count(*) AS count
           FROM quotes
          WHERE (quotes.status = 'sent'::quote_status)) AS pending_quotes,
    ( SELECT count(*) AS count
           FROM policies
          WHERE (policies.renewal_flag = true)) AS renewals_due,
    ( SELECT count(*) AS count
           FROM claims
          WHERE (claims.status = ANY (ARRAY['reported'::claim_status, 'in_review'::claim_status]))) AS open_claims,
    ( SELECT count(*) AS count
           FROM tasks
          WHERE ((tasks.status = 'pending'::task_status) AND (tasks.assigned_to = auth.uid()))) AS my_tasks;


CREATE OR REPLACE FUNCTION public.generate_quote_number()
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
    next_number INTEGER;
BEGIN
    SELECT COALESCE(MAX(CAST(SUBSTRING(quote_number FROM 4) AS INTEGER)), 0) + 1
    INTO next_number
    FROM quotes
    WHERE quote_number LIKE 'QT-%';
    
    RETURN 'QT-' || LPAD(next_number::TEXT, 6, '0');
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_client_full_name(client_record clients)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;

create or replace view "public"."policy_summary" as  SELECT p.id,
    p.policy_number,
    p.start_date,
    p.end_date,
    p.status,
    p.renewal_flag,
    c.id AS client_id,
    get_client_full_name(c.*) AS client_name,
    i.name AS insurer_name,
    pr.name AS product_name
   FROM (((policies p
     JOIN clients c ON ((p.client_id = c.id)))
     JOIN insurers i ON ((p.insurer_id = i.id)))
     JOIN products pr ON ((p.product_id = pr.id)));


CREATE OR REPLACE FUNCTION public.update_updated_at_column()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$function$
;

create or replace view "public"."client_summary" as  SELECT c.id,
    c.client_type,
    get_client_full_name(c.*) AS full_name,
    c.status,
    c.created_at,
    count(p.id) AS policy_count,
    count(cl.id) AS claim_count
   FROM ((clients c
     LEFT JOIN policies p ON (((c.id = p.client_id) AND (p.status = 'active'::policy_status))))
     LEFT JOIN claims cl ON ((p.id = cl.policy_id)))
  GROUP BY c.id, c.client_type, c.first_name, c.last_name, c.entity_name, c.status, c.created_at;


grant delete on table "public"."addresses" to "anon";

grant insert on table "public"."addresses" to "anon";

grant references on table "public"."addresses" to "anon";

grant select on table "public"."addresses" to "anon";

grant trigger on table "public"."addresses" to "anon";

grant truncate on table "public"."addresses" to "anon";

grant update on table "public"."addresses" to "anon";

grant delete on table "public"."addresses" to "authenticated";

grant insert on table "public"."addresses" to "authenticated";

grant references on table "public"."addresses" to "authenticated";

grant select on table "public"."addresses" to "authenticated";

grant trigger on table "public"."addresses" to "authenticated";

grant truncate on table "public"."addresses" to "authenticated";

grant update on table "public"."addresses" to "authenticated";

grant delete on table "public"."addresses" to "service_role";

grant insert on table "public"."addresses" to "service_role";

grant references on table "public"."addresses" to "service_role";

grant select on table "public"."addresses" to "service_role";

grant trigger on table "public"."addresses" to "service_role";

grant truncate on table "public"."addresses" to "service_role";

grant update on table "public"."addresses" to "service_role";

grant delete on table "public"."attachments" to "anon";

grant insert on table "public"."attachments" to "anon";

grant references on table "public"."attachments" to "anon";

grant select on table "public"."attachments" to "anon";

grant trigger on table "public"."attachments" to "anon";

grant truncate on table "public"."attachments" to "anon";

grant update on table "public"."attachments" to "anon";

grant delete on table "public"."attachments" to "authenticated";

grant insert on table "public"."attachments" to "authenticated";

grant references on table "public"."attachments" to "authenticated";

grant select on table "public"."attachments" to "authenticated";

grant trigger on table "public"."attachments" to "authenticated";

grant truncate on table "public"."attachments" to "authenticated";

grant update on table "public"."attachments" to "authenticated";

grant delete on table "public"."attachments" to "service_role";

grant insert on table "public"."attachments" to "service_role";

grant references on table "public"."attachments" to "service_role";

grant select on table "public"."attachments" to "service_role";

grant trigger on table "public"."attachments" to "service_role";

grant truncate on table "public"."attachments" to "service_role";

grant update on table "public"."attachments" to "service_role";

grant delete on table "public"."claim_items" to "anon";

grant insert on table "public"."claim_items" to "anon";

grant references on table "public"."claim_items" to "anon";

grant select on table "public"."claim_items" to "anon";

grant trigger on table "public"."claim_items" to "anon";

grant truncate on table "public"."claim_items" to "anon";

grant update on table "public"."claim_items" to "anon";

grant delete on table "public"."claim_items" to "authenticated";

grant insert on table "public"."claim_items" to "authenticated";

grant references on table "public"."claim_items" to "authenticated";

grant select on table "public"."claim_items" to "authenticated";

grant trigger on table "public"."claim_items" to "authenticated";

grant truncate on table "public"."claim_items" to "authenticated";

grant update on table "public"."claim_items" to "authenticated";

grant delete on table "public"."claim_items" to "service_role";

grant insert on table "public"."claim_items" to "service_role";

grant references on table "public"."claim_items" to "service_role";

grant select on table "public"."claim_items" to "service_role";

grant trigger on table "public"."claim_items" to "service_role";

grant truncate on table "public"."claim_items" to "service_role";

grant update on table "public"."claim_items" to "service_role";

grant delete on table "public"."claim_updates" to "anon";

grant insert on table "public"."claim_updates" to "anon";

grant references on table "public"."claim_updates" to "anon";

grant select on table "public"."claim_updates" to "anon";

grant trigger on table "public"."claim_updates" to "anon";

grant truncate on table "public"."claim_updates" to "anon";

grant update on table "public"."claim_updates" to "anon";

grant delete on table "public"."claim_updates" to "authenticated";

grant insert on table "public"."claim_updates" to "authenticated";

grant references on table "public"."claim_updates" to "authenticated";

grant select on table "public"."claim_updates" to "authenticated";

grant trigger on table "public"."claim_updates" to "authenticated";

grant truncate on table "public"."claim_updates" to "authenticated";

grant update on table "public"."claim_updates" to "authenticated";

grant delete on table "public"."claim_updates" to "service_role";

grant insert on table "public"."claim_updates" to "service_role";

grant references on table "public"."claim_updates" to "service_role";

grant select on table "public"."claim_updates" to "service_role";

grant trigger on table "public"."claim_updates" to "service_role";

grant truncate on table "public"."claim_updates" to "service_role";

grant update on table "public"."claim_updates" to "service_role";

grant delete on table "public"."claims" to "anon";

grant insert on table "public"."claims" to "anon";

grant references on table "public"."claims" to "anon";

grant select on table "public"."claims" to "anon";

grant trigger on table "public"."claims" to "anon";

grant truncate on table "public"."claims" to "anon";

grant update on table "public"."claims" to "anon";

grant delete on table "public"."claims" to "authenticated";

grant insert on table "public"."claims" to "authenticated";

grant references on table "public"."claims" to "authenticated";

grant select on table "public"."claims" to "authenticated";

grant trigger on table "public"."claims" to "authenticated";

grant truncate on table "public"."claims" to "authenticated";

grant update on table "public"."claims" to "authenticated";

grant delete on table "public"."claims" to "service_role";

grant insert on table "public"."claims" to "service_role";

grant references on table "public"."claims" to "service_role";

grant select on table "public"."claims" to "service_role";

grant trigger on table "public"."claims" to "service_role";

grant truncate on table "public"."claims" to "service_role";

grant update on table "public"."claims" to "service_role";

grant delete on table "public"."client_contacts" to "anon";

grant insert on table "public"."client_contacts" to "anon";

grant references on table "public"."client_contacts" to "anon";

grant select on table "public"."client_contacts" to "anon";

grant trigger on table "public"."client_contacts" to "anon";

grant truncate on table "public"."client_contacts" to "anon";

grant update on table "public"."client_contacts" to "anon";

grant delete on table "public"."client_contacts" to "authenticated";

grant insert on table "public"."client_contacts" to "authenticated";

grant references on table "public"."client_contacts" to "authenticated";

grant select on table "public"."client_contacts" to "authenticated";

grant trigger on table "public"."client_contacts" to "authenticated";

grant truncate on table "public"."client_contacts" to "authenticated";

grant update on table "public"."client_contacts" to "authenticated";

grant delete on table "public"."client_contacts" to "service_role";

grant insert on table "public"."client_contacts" to "service_role";

grant references on table "public"."client_contacts" to "service_role";

grant select on table "public"."client_contacts" to "service_role";

grant trigger on table "public"."client_contacts" to "service_role";

grant truncate on table "public"."client_contacts" to "service_role";

grant update on table "public"."client_contacts" to "service_role";

grant delete on table "public"."clients" to "anon";

grant insert on table "public"."clients" to "anon";

grant references on table "public"."clients" to "anon";

grant select on table "public"."clients" to "anon";

grant trigger on table "public"."clients" to "anon";

grant truncate on table "public"."clients" to "anon";

grant update on table "public"."clients" to "anon";

grant delete on table "public"."clients" to "authenticated";

grant insert on table "public"."clients" to "authenticated";

grant references on table "public"."clients" to "authenticated";

grant select on table "public"."clients" to "authenticated";

grant trigger on table "public"."clients" to "authenticated";

grant truncate on table "public"."clients" to "authenticated";

grant update on table "public"."clients" to "authenticated";

grant delete on table "public"."clients" to "service_role";

grant insert on table "public"."clients" to "service_role";

grant references on table "public"."clients" to "service_role";

grant select on table "public"."clients" to "service_role";

grant trigger on table "public"."clients" to "service_role";

grant truncate on table "public"."clients" to "service_role";

grant update on table "public"."clients" to "service_role";

grant delete on table "public"."employees" to "anon";

grant insert on table "public"."employees" to "anon";

grant references on table "public"."employees" to "anon";

grant select on table "public"."employees" to "anon";

grant trigger on table "public"."employees" to "anon";

grant truncate on table "public"."employees" to "anon";

grant update on table "public"."employees" to "anon";

grant delete on table "public"."employees" to "authenticated";

grant insert on table "public"."employees" to "authenticated";

grant references on table "public"."employees" to "authenticated";

grant select on table "public"."employees" to "authenticated";

grant trigger on table "public"."employees" to "authenticated";

grant truncate on table "public"."employees" to "authenticated";

grant update on table "public"."employees" to "authenticated";

grant delete on table "public"."employees" to "service_role";

grant insert on table "public"."employees" to "service_role";

grant references on table "public"."employees" to "service_role";

grant select on table "public"."employees" to "service_role";

grant trigger on table "public"."employees" to "service_role";

grant truncate on table "public"."employees" to "service_role";

grant update on table "public"."employees" to "service_role";

grant delete on table "public"."insurers" to "anon";

grant insert on table "public"."insurers" to "anon";

grant references on table "public"."insurers" to "anon";

grant select on table "public"."insurers" to "anon";

grant trigger on table "public"."insurers" to "anon";

grant truncate on table "public"."insurers" to "anon";

grant update on table "public"."insurers" to "anon";

grant delete on table "public"."insurers" to "authenticated";

grant insert on table "public"."insurers" to "authenticated";

grant references on table "public"."insurers" to "authenticated";

grant select on table "public"."insurers" to "authenticated";

grant trigger on table "public"."insurers" to "authenticated";

grant truncate on table "public"."insurers" to "authenticated";

grant update on table "public"."insurers" to "authenticated";

grant delete on table "public"."insurers" to "service_role";

grant insert on table "public"."insurers" to "service_role";

grant references on table "public"."insurers" to "service_role";

grant select on table "public"."insurers" to "service_role";

grant trigger on table "public"."insurers" to "service_role";

grant truncate on table "public"."insurers" to "service_role";

grant update on table "public"."insurers" to "service_role";

grant delete on table "public"."interactions" to "anon";

grant insert on table "public"."interactions" to "anon";

grant references on table "public"."interactions" to "anon";

grant select on table "public"."interactions" to "anon";

grant trigger on table "public"."interactions" to "anon";

grant truncate on table "public"."interactions" to "anon";

grant update on table "public"."interactions" to "anon";

grant delete on table "public"."interactions" to "authenticated";

grant insert on table "public"."interactions" to "authenticated";

grant references on table "public"."interactions" to "authenticated";

grant select on table "public"."interactions" to "authenticated";

grant trigger on table "public"."interactions" to "authenticated";

grant truncate on table "public"."interactions" to "authenticated";

grant update on table "public"."interactions" to "authenticated";

grant delete on table "public"."interactions" to "service_role";

grant insert on table "public"."interactions" to "service_role";

grant references on table "public"."interactions" to "service_role";

grant select on table "public"."interactions" to "service_role";

grant trigger on table "public"."interactions" to "service_role";

grant truncate on table "public"."interactions" to "service_role";

grant update on table "public"."interactions" to "service_role";

grant delete on table "public"."leads" to "anon";

grant insert on table "public"."leads" to "anon";

grant references on table "public"."leads" to "anon";

grant select on table "public"."leads" to "anon";

grant trigger on table "public"."leads" to "anon";

grant truncate on table "public"."leads" to "anon";

grant update on table "public"."leads" to "anon";

grant delete on table "public"."leads" to "authenticated";

grant insert on table "public"."leads" to "authenticated";

grant references on table "public"."leads" to "authenticated";

grant select on table "public"."leads" to "authenticated";

grant trigger on table "public"."leads" to "authenticated";

grant truncate on table "public"."leads" to "authenticated";

grant update on table "public"."leads" to "authenticated";

grant delete on table "public"."leads" to "service_role";

grant insert on table "public"."leads" to "service_role";

grant references on table "public"."leads" to "service_role";

grant select on table "public"."leads" to "service_role";

grant trigger on table "public"."leads" to "service_role";

grant truncate on table "public"."leads" to "service_role";

grant update on table "public"."leads" to "service_role";

grant delete on table "public"."policies" to "anon";

grant insert on table "public"."policies" to "anon";

grant references on table "public"."policies" to "anon";

grant select on table "public"."policies" to "anon";

grant trigger on table "public"."policies" to "anon";

grant truncate on table "public"."policies" to "anon";

grant update on table "public"."policies" to "anon";

grant delete on table "public"."policies" to "authenticated";

grant insert on table "public"."policies" to "authenticated";

grant references on table "public"."policies" to "authenticated";

grant select on table "public"."policies" to "authenticated";

grant trigger on table "public"."policies" to "authenticated";

grant truncate on table "public"."policies" to "authenticated";

grant update on table "public"."policies" to "authenticated";

grant delete on table "public"."policies" to "service_role";

grant insert on table "public"."policies" to "service_role";

grant references on table "public"."policies" to "service_role";

grant select on table "public"."policies" to "service_role";

grant trigger on table "public"."policies" to "service_role";

grant truncate on table "public"."policies" to "service_role";

grant update on table "public"."policies" to "service_role";

grant delete on table "public"."policy_covers" to "anon";

grant insert on table "public"."policy_covers" to "anon";

grant references on table "public"."policy_covers" to "anon";

grant select on table "public"."policy_covers" to "anon";

grant trigger on table "public"."policy_covers" to "anon";

grant truncate on table "public"."policy_covers" to "anon";

grant update on table "public"."policy_covers" to "anon";

grant delete on table "public"."policy_covers" to "authenticated";

grant insert on table "public"."policy_covers" to "authenticated";

grant references on table "public"."policy_covers" to "authenticated";

grant select on table "public"."policy_covers" to "authenticated";

grant trigger on table "public"."policy_covers" to "authenticated";

grant truncate on table "public"."policy_covers" to "authenticated";

grant update on table "public"."policy_covers" to "authenticated";

grant delete on table "public"."policy_covers" to "service_role";

grant insert on table "public"."policy_covers" to "service_role";

grant references on table "public"."policy_covers" to "service_role";

grant select on table "public"."policy_covers" to "service_role";

grant trigger on table "public"."policy_covers" to "service_role";

grant truncate on table "public"."policy_covers" to "service_role";

grant update on table "public"."policy_covers" to "service_role";

grant delete on table "public"."policy_endorsements" to "anon";

grant insert on table "public"."policy_endorsements" to "anon";

grant references on table "public"."policy_endorsements" to "anon";

grant select on table "public"."policy_endorsements" to "anon";

grant trigger on table "public"."policy_endorsements" to "anon";

grant truncate on table "public"."policy_endorsements" to "anon";

grant update on table "public"."policy_endorsements" to "anon";

grant delete on table "public"."policy_endorsements" to "authenticated";

grant insert on table "public"."policy_endorsements" to "authenticated";

grant references on table "public"."policy_endorsements" to "authenticated";

grant select on table "public"."policy_endorsements" to "authenticated";

grant trigger on table "public"."policy_endorsements" to "authenticated";

grant truncate on table "public"."policy_endorsements" to "authenticated";

grant update on table "public"."policy_endorsements" to "authenticated";

grant delete on table "public"."policy_endorsements" to "service_role";

grant insert on table "public"."policy_endorsements" to "service_role";

grant references on table "public"."policy_endorsements" to "service_role";

grant select on table "public"."policy_endorsements" to "service_role";

grant trigger on table "public"."policy_endorsements" to "service_role";

grant truncate on table "public"."policy_endorsements" to "service_role";

grant update on table "public"."policy_endorsements" to "service_role";

grant delete on table "public"."policy_types" to "anon";

grant insert on table "public"."policy_types" to "anon";

grant references on table "public"."policy_types" to "anon";

grant select on table "public"."policy_types" to "anon";

grant trigger on table "public"."policy_types" to "anon";

grant truncate on table "public"."policy_types" to "anon";

grant update on table "public"."policy_types" to "anon";

grant delete on table "public"."policy_types" to "authenticated";

grant insert on table "public"."policy_types" to "authenticated";

grant references on table "public"."policy_types" to "authenticated";

grant select on table "public"."policy_types" to "authenticated";

grant trigger on table "public"."policy_types" to "authenticated";

grant truncate on table "public"."policy_types" to "authenticated";

grant update on table "public"."policy_types" to "authenticated";

grant delete on table "public"."policy_types" to "service_role";

grant insert on table "public"."policy_types" to "service_role";

grant references on table "public"."policy_types" to "service_role";

grant select on table "public"."policy_types" to "service_role";

grant trigger on table "public"."policy_types" to "service_role";

grant truncate on table "public"."policy_types" to "service_role";

grant update on table "public"."policy_types" to "service_role";

grant delete on table "public"."products" to "anon";

grant insert on table "public"."products" to "anon";

grant references on table "public"."products" to "anon";

grant select on table "public"."products" to "anon";

grant trigger on table "public"."products" to "anon";

grant truncate on table "public"."products" to "anon";

grant update on table "public"."products" to "anon";

grant delete on table "public"."products" to "authenticated";

grant insert on table "public"."products" to "authenticated";

grant references on table "public"."products" to "authenticated";

grant select on table "public"."products" to "authenticated";

grant trigger on table "public"."products" to "authenticated";

grant truncate on table "public"."products" to "authenticated";

grant update on table "public"."products" to "authenticated";

grant delete on table "public"."products" to "service_role";

grant insert on table "public"."products" to "service_role";

grant references on table "public"."products" to "service_role";

grant select on table "public"."products" to "service_role";

grant trigger on table "public"."products" to "service_role";

grant truncate on table "public"."products" to "service_role";

grant update on table "public"."products" to "service_role";

grant delete on table "public"."quote_options" to "anon";

grant insert on table "public"."quote_options" to "anon";

grant references on table "public"."quote_options" to "anon";

grant select on table "public"."quote_options" to "anon";

grant trigger on table "public"."quote_options" to "anon";

grant truncate on table "public"."quote_options" to "anon";

grant update on table "public"."quote_options" to "anon";

grant delete on table "public"."quote_options" to "authenticated";

grant insert on table "public"."quote_options" to "authenticated";

grant references on table "public"."quote_options" to "authenticated";

grant select on table "public"."quote_options" to "authenticated";

grant trigger on table "public"."quote_options" to "authenticated";

grant truncate on table "public"."quote_options" to "authenticated";

grant update on table "public"."quote_options" to "authenticated";

grant delete on table "public"."quote_options" to "service_role";

grant insert on table "public"."quote_options" to "service_role";

grant references on table "public"."quote_options" to "service_role";

grant select on table "public"."quote_options" to "service_role";

grant trigger on table "public"."quote_options" to "service_role";

grant truncate on table "public"."quote_options" to "service_role";

grant update on table "public"."quote_options" to "service_role";

grant delete on table "public"."quotes" to "anon";

grant insert on table "public"."quotes" to "anon";

grant references on table "public"."quotes" to "anon";

grant select on table "public"."quotes" to "anon";

grant trigger on table "public"."quotes" to "anon";

grant truncate on table "public"."quotes" to "anon";

grant update on table "public"."quotes" to "anon";

grant delete on table "public"."quotes" to "authenticated";

grant insert on table "public"."quotes" to "authenticated";

grant references on table "public"."quotes" to "authenticated";

grant select on table "public"."quotes" to "authenticated";

grant trigger on table "public"."quotes" to "authenticated";

grant truncate on table "public"."quotes" to "authenticated";

grant update on table "public"."quotes" to "authenticated";

grant delete on table "public"."quotes" to "service_role";

grant insert on table "public"."quotes" to "service_role";

grant references on table "public"."quotes" to "service_role";

grant select on table "public"."quotes" to "service_role";

grant trigger on table "public"."quotes" to "service_role";

grant truncate on table "public"."quotes" to "service_role";

grant update on table "public"."quotes" to "service_role";

grant delete on table "public"."renewals" to "anon";

grant insert on table "public"."renewals" to "anon";

grant references on table "public"."renewals" to "anon";

grant select on table "public"."renewals" to "anon";

grant trigger on table "public"."renewals" to "anon";

grant truncate on table "public"."renewals" to "anon";

grant update on table "public"."renewals" to "anon";

grant delete on table "public"."renewals" to "authenticated";

grant insert on table "public"."renewals" to "authenticated";

grant references on table "public"."renewals" to "authenticated";

grant select on table "public"."renewals" to "authenticated";

grant trigger on table "public"."renewals" to "authenticated";

grant truncate on table "public"."renewals" to "authenticated";

grant update on table "public"."renewals" to "authenticated";

grant delete on table "public"."renewals" to "service_role";

grant insert on table "public"."renewals" to "service_role";

grant references on table "public"."renewals" to "service_role";

grant select on table "public"."renewals" to "service_role";

grant trigger on table "public"."renewals" to "service_role";

grant truncate on table "public"."renewals" to "service_role";

grant update on table "public"."renewals" to "service_role";

grant delete on table "public"."tasks" to "anon";

grant insert on table "public"."tasks" to "anon";

grant references on table "public"."tasks" to "anon";

grant select on table "public"."tasks" to "anon";

grant trigger on table "public"."tasks" to "anon";

grant truncate on table "public"."tasks" to "anon";

grant update on table "public"."tasks" to "anon";

grant delete on table "public"."tasks" to "authenticated";

grant insert on table "public"."tasks" to "authenticated";

grant references on table "public"."tasks" to "authenticated";

grant select on table "public"."tasks" to "authenticated";

grant trigger on table "public"."tasks" to "authenticated";

grant truncate on table "public"."tasks" to "authenticated";

grant update on table "public"."tasks" to "authenticated";

grant delete on table "public"."tasks" to "service_role";

grant insert on table "public"."tasks" to "service_role";

grant references on table "public"."tasks" to "service_role";

grant select on table "public"."tasks" to "service_role";

grant trigger on table "public"."tasks" to "service_role";

grant truncate on table "public"."tasks" to "service_role";

grant update on table "public"."tasks" to "service_role";

create policy "Users can manage addresses for their clients"
on "public"."addresses"
as permissive
for all
to public
using ((EXISTS ( SELECT 1
   FROM clients
  WHERE ((clients.id = addresses.client_id) AND ((clients.created_by = auth.uid()) OR (EXISTS ( SELECT 1
           FROM employees
          WHERE ((employees.id = auth.uid()) AND (employees.role = ANY (ARRAY['super_admin'::text, 'manager'::text, 'admin_staff'::text]))))))))));


create policy "Users can view addresses for their clients"
on "public"."addresses"
as permissive
for select
to public
using ((EXISTS ( SELECT 1
   FROM clients
  WHERE ((clients.id = addresses.client_id) AND ((clients.created_by = auth.uid()) OR (EXISTS ( SELECT 1
           FROM employees
          WHERE ((employees.id = auth.uid()) AND (employees.role = ANY (ARRAY['super_admin'::text, 'manager'::text, 'admin_staff'::text]))))))))));


create policy "Users can manage claims for their policies"
on "public"."claims"
as permissive
for all
to public
using ((EXISTS ( SELECT 1
   FROM policies
  WHERE ((policies.id = claims.policy_id) AND ((policies.created_by = auth.uid()) OR (EXISTS ( SELECT 1
           FROM employees
          WHERE ((employees.id = auth.uid()) AND (employees.role = ANY (ARRAY['super_admin'::text, 'manager'::text, 'claims_handler'::text]))))))))));


create policy "Users can view claims for their policies"
on "public"."claims"
as permissive
for select
to public
using ((EXISTS ( SELECT 1
   FROM policies
  WHERE ((policies.id = claims.policy_id) AND ((policies.created_by = auth.uid()) OR (EXISTS ( SELECT 1
           FROM employees
          WHERE ((employees.id = auth.uid()) AND (employees.role = ANY (ARRAY['super_admin'::text, 'manager'::text, 'claims_handler'::text]))))))))));


create policy "Users can manage contacts for their clients"
on "public"."client_contacts"
as permissive
for all
to public
using ((EXISTS ( SELECT 1
   FROM clients
  WHERE ((clients.id = client_contacts.client_id) AND ((clients.created_by = auth.uid()) OR (EXISTS ( SELECT 1
           FROM employees
          WHERE ((employees.id = auth.uid()) AND (employees.role = ANY (ARRAY['super_admin'::text, 'manager'::text, 'admin_staff'::text]))))))))));


create policy "Users can view contacts for their clients"
on "public"."client_contacts"
as permissive
for select
to public
using ((EXISTS ( SELECT 1
   FROM clients
  WHERE ((clients.id = client_contacts.client_id) AND ((clients.created_by = auth.uid()) OR (EXISTS ( SELECT 1
           FROM employees
          WHERE ((employees.id = auth.uid()) AND (employees.role = ANY (ARRAY['super_admin'::text, 'manager'::text, 'admin_staff'::text]))))))))));


create policy "Users can insert their own clients"
on "public"."clients"
as permissive
for insert
to public
with check (((created_by = auth.uid()) OR (EXISTS ( SELECT 1
   FROM employees
  WHERE ((employees.id = auth.uid()) AND (employees.role = ANY (ARRAY['super_admin'::text, 'manager'::text, 'admin_staff'::text])))))));


create policy "Users can update their own clients"
on "public"."clients"
as permissive
for update
to public
using (((created_by = auth.uid()) OR (EXISTS ( SELECT 1
   FROM employees
  WHERE ((employees.id = auth.uid()) AND (employees.role = ANY (ARRAY['super_admin'::text, 'manager'::text, 'admin_staff'::text])))))));


create policy "Users can view their own clients"
on "public"."clients"
as permissive
for select
to public
using (((created_by = auth.uid()) OR (EXISTS ( SELECT 1
   FROM employees
  WHERE ((employees.id = auth.uid()) AND (employees.role = ANY (ARRAY['super_admin'::text, 'manager'::text, 'admin_staff'::text])))))));


create policy "Only super_admin can manage employees"
on "public"."employees"
as permissive
for all
to public
using ((EXISTS ( SELECT 1
   FROM employees employees_1
  WHERE ((employees_1.id = auth.uid()) AND (employees_1.role = 'super_admin'::text)))));


create policy "Users can view employees"
on "public"."employees"
as permissive
for select
to public
using ((EXISTS ( SELECT 1
   FROM employees employees_1
  WHERE ((employees_1.id = auth.uid()) AND (employees_1.role = ANY (ARRAY['super_admin'::text, 'manager'::text]))))));


create policy "Users can manage their own leads"
on "public"."leads"
as permissive
for all
to public
using (((owner_id = auth.uid()) OR (EXISTS ( SELECT 1
   FROM employees
  WHERE ((employees.id = auth.uid()) AND (employees.role = ANY (ARRAY['super_admin'::text, 'manager'::text])))))));


create policy "Users can view their own leads"
on "public"."leads"
as permissive
for select
to public
using (((owner_id = auth.uid()) OR (EXISTS ( SELECT 1
   FROM employees
  WHERE ((employees.id = auth.uid()) AND (employees.role = ANY (ARRAY['super_admin'::text, 'manager'::text])))))));


create policy "Users can manage their own policies"
on "public"."policies"
as permissive
for all
to public
using (((created_by = auth.uid()) OR (EXISTS ( SELECT 1
   FROM employees
  WHERE ((employees.id = auth.uid()) AND (employees.role = ANY (ARRAY['super_admin'::text, 'manager'::text, 'admin_staff'::text])))))));


create policy "Users can view their own policies"
on "public"."policies"
as permissive
for select
to public
using (((created_by = auth.uid()) OR (EXISTS ( SELECT 1
   FROM employees
  WHERE ((employees.id = auth.uid()) AND (employees.role = ANY (ARRAY['super_admin'::text, 'manager'::text, 'admin_staff'::text])))))));


create policy "Users can manage quotes for their leads"
on "public"."quotes"
as permissive
for all
to public
using ((EXISTS ( SELECT 1
   FROM leads
  WHERE ((leads.id = quotes.lead_id) AND ((leads.owner_id = auth.uid()) OR (EXISTS ( SELECT 1
           FROM employees
          WHERE ((employees.id = auth.uid()) AND (employees.role = ANY (ARRAY['super_admin'::text, 'manager'::text]))))))))));


create policy "Users can view quotes for their leads"
on "public"."quotes"
as permissive
for select
to public
using ((EXISTS ( SELECT 1
   FROM leads
  WHERE ((leads.id = quotes.lead_id) AND ((leads.owner_id = auth.uid()) OR (EXISTS ( SELECT 1
           FROM employees
          WHERE ((employees.id = auth.uid()) AND (employees.role = ANY (ARRAY['super_admin'::text, 'manager'::text]))))))))));


CREATE TRIGGER update_addresses_updated_at BEFORE UPDATE ON public.addresses FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_attachments_updated_at BEFORE UPDATE ON public.attachments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_claim_items_updated_at BEFORE UPDATE ON public.claim_items FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_claim_updates_updated_at BEFORE UPDATE ON public.claim_updates FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_claims_updated_at BEFORE UPDATE ON public.claims FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_client_contacts_updated_at BEFORE UPDATE ON public.client_contacts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_clients_updated_at BEFORE UPDATE ON public.clients FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_employees_updated_at BEFORE UPDATE ON public.employees FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_insurers_updated_at BEFORE UPDATE ON public.insurers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_interactions_updated_at BEFORE UPDATE ON public.interactions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_leads_updated_at BEFORE UPDATE ON public.leads FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_policies_updated_at BEFORE UPDATE ON public.policies FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_renewal_flag BEFORE INSERT OR UPDATE ON public.policies FOR EACH ROW EXECUTE FUNCTION check_renewal_flag();

CREATE TRIGGER update_policy_covers_updated_at BEFORE UPDATE ON public.policy_covers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_policy_endorsements_updated_at BEFORE UPDATE ON public.policy_endorsements FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_policy_types_updated_at BEFORE UPDATE ON public.policy_types FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_quote_options_updated_at BEFORE UPDATE ON public.quote_options FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_quotes_updated_at BEFORE UPDATE ON public.quotes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_renewals_updated_at BEFORE UPDATE ON public.renewals FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON public.tasks FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


