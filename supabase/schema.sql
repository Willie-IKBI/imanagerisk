-- ============================================================================
-- IMR Database Schema for Supabase
-- ============================================================================
-- This script creates the complete database schema for the I Manage Risk (IMR) application
-- Based on DATA_SCHEMA.md, PRD.md, and other project documentation
-- ============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- ENUMS
-- ============================================================================

-- Client types
CREATE TYPE client_type AS ENUM ('personal', 'business', 'body_corporate');

-- Status enums
CREATE TYPE client_status AS ENUM ('active', 'inactive');
CREATE TYPE policy_status AS ENUM ('active', 'cancelled', 'pending');
CREATE TYPE claim_status AS ENUM ('reported', 'in_review', 'approved', 'declined', 'settled');

-- Lead status enum
CREATE TYPE lead_status AS ENUM ('new', 'contacted', 'qualifying', 'quoting', 'awaiting_docs', 'decision', 'won', 'lost');

-- Quote status enum
CREATE TYPE quote_status AS ENUM ('draft', 'sent', 'accepted', 'declined', 'expired');

-- Task priority enum
CREATE TYPE task_priority AS ENUM ('low', 'medium', 'high', 'urgent');

-- Task status enum
CREATE TYPE task_status AS ENUM ('pending', 'in_progress', 'completed', 'cancelled');

-- ============================================================================
-- TABLES
-- ============================================================================

-- 1. Clients table
CREATE TABLE clients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_type client_type NOT NULL,
    entity_name TEXT, -- For business/body corporate only
    first_name TEXT, -- For personal only
    last_name TEXT, -- For personal only
    id_number VARCHAR(13), -- SA ID number (personal)
    company_reg_number VARCHAR(20), -- Business registration number
    vat_number VARCHAR(15), -- Optional
    comments TEXT, -- Notes on client
    status client_status DEFAULT 'active',
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Client Contacts table
CREATE TABLE client_contacts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    is_primary BOOLEAN DEFAULT FALSE,
    role TEXT, -- E.g., Director, Broker Contact
    name TEXT NOT NULL,
    phone VARCHAR(20),
    email TEXT,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Addresses table
CREATE TABLE addresses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    is_primary BOOLEAN DEFAULT FALSE,
    line1 TEXT NOT NULL,
    line2 TEXT,
    city TEXT,
    province TEXT,
    postal_code VARCHAR(10),
    country TEXT DEFAULT 'South Africa',
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Insurers table
CREATE TABLE insurers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,
    contact_info JSONB, -- Flexible storage for emails, phones
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Products table
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    insurer_id UUID NOT NULL REFERENCES insurers(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Policy Types table
CREATE TABLE policy_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    slug TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Policies table
CREATE TABLE policies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    insurer_id UUID NOT NULL REFERENCES insurers(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    policy_number TEXT NOT NULL,
    start_date DATE,
    end_date DATE, -- Used for annual renewal tracking
    status policy_status DEFAULT 'active',
    renewal_flag BOOLEAN DEFAULT FALSE, -- True if within 2 months of end_date
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. Policy Covers table (Sections)
CREATE TABLE policy_covers (
    policy_id UUID NOT NULL REFERENCES policies(id) ON DELETE CASCADE,
    type_id UUID NOT NULL REFERENCES policy_types(id) ON DELETE CASCADE,
    sum_insured NUMERIC,
    premium NUMERIC,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (policy_id, type_id)
);

-- 9. Policy Endorsements table
CREATE TABLE policy_endorsements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    policy_id UUID NOT NULL REFERENCES policies(id) ON DELETE CASCADE,
    endorsement_type TEXT NOT NULL, -- E.g., Cover Change, Address Change
    description TEXT NOT NULL,
    effective_date DATE,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. Claims table
CREATE TABLE claims (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    policy_id UUID NOT NULL REFERENCES policies(id) ON DELETE CASCADE,
    claim_number TEXT NOT NULL UNIQUE,
    date_reported DATE NOT NULL,
    status claim_status DEFAULT 'reported',
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 11. Claim Items table
CREATE TABLE claim_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    claim_id UUID NOT NULL REFERENCES claims(id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    amount NUMERIC,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 12. Claim Updates table
CREATE TABLE claim_updates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    claim_id UUID NOT NULL REFERENCES claims(id) ON DELETE CASCADE,
    update_text TEXT NOT NULL,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 13. Attachments table (Polymorphic)
CREATE TABLE attachments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    parent_type TEXT NOT NULL, -- E.g., 'policy', 'claim', 'endorsement', 'lead', 'quote'
    parent_id UUID NOT NULL,
    url TEXT NOT NULL, -- Public or signed URL
    file_name TEXT,
    file_size INTEGER,
    mime_type TEXT,
    uploaded_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 14. Employees table (Profiles)
CREATE TABLE employees (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    contact_number VARCHAR(20),
    display_image TEXT,
    role TEXT NOT NULL, -- super_admin, manager, sales_broker, admin_staff, claims_handler, finance
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 15. Leads table
CREATE TABLE leads (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    source TEXT,
    client_type client_type NOT NULL,
    prospect_name TEXT NOT NULL,
    company_reg_number VARCHAR(20),
    id_number VARCHAR(13),
    contact_email TEXT,
    contact_phone VARCHAR(20),
    region TEXT,
    province TEXT,
    product_interest TEXT,
    status lead_status DEFAULT 'new',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 16. Quotes table
CREATE TABLE quotes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lead_id UUID REFERENCES leads(id) ON DELETE CASCADE,
    client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
    quote_number TEXT NOT NULL UNIQUE,
    status quote_status DEFAULT 'draft',
    valid_until DATE,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 17. Quote Options table
CREATE TABLE quote_options (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    quote_id UUID NOT NULL REFERENCES quotes(id) ON DELETE CASCADE,
    insurer_id UUID NOT NULL REFERENCES insurers(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    cover_summary TEXT,
    premium NUMERIC NOT NULL,
    excess NUMERIC,
    key_exclusions TEXT,
    is_selected BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 18. Tasks table
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT,
    assigned_to UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    due_date DATE,
    priority task_priority DEFAULT 'medium',
    status task_status DEFAULT 'pending',
    parent_type TEXT, -- E.g., 'client', 'policy', 'claim', 'lead'
    parent_id UUID,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 19. Interactions table
CREATE TABLE interactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    parent_type TEXT NOT NULL, -- E.g., 'client', 'lead', 'policy', 'claim'
    parent_id UUID NOT NULL,
    interaction_type TEXT NOT NULL, -- E.g., 'call', 'email', 'meeting', 'note'
    subject TEXT,
    description TEXT NOT NULL,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 20. Renewals table
CREATE TABLE renewals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    policy_id UUID NOT NULL REFERENCES policies(id) ON DELETE CASCADE,
    renewal_date DATE NOT NULL,
    status TEXT DEFAULT 'pending', -- pending, in_progress, client_notified, awaiting_response, finalized
    premium_change NUMERIC,
    notes TEXT,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- INDEXES
-- ============================================================================

-- Clients indexes
CREATE INDEX idx_clients_client_type ON clients(client_type);
CREATE INDEX idx_clients_status ON clients(status);
CREATE INDEX idx_clients_created_by ON clients(created_by);
CREATE INDEX idx_clients_id_number ON clients(id_number) WHERE id_number IS NOT NULL;
CREATE INDEX idx_clients_company_reg_number ON clients(company_reg_number) WHERE company_reg_number IS NOT NULL;

-- Client contacts indexes
CREATE INDEX idx_client_contacts_client_id ON client_contacts(client_id);
CREATE INDEX idx_client_contacts_is_primary ON client_contacts(is_primary);
CREATE INDEX idx_client_contacts_email ON client_contacts(email) WHERE email IS NOT NULL;

-- Addresses indexes
CREATE INDEX idx_addresses_client_id ON addresses(client_id);
CREATE INDEX idx_addresses_is_primary ON addresses(is_primary);

-- Policies indexes
CREATE INDEX idx_policies_client_id ON policies(client_id);
CREATE INDEX idx_policies_insurer_id ON policies(insurer_id);
CREATE INDEX idx_policies_product_id ON policies(product_id);
CREATE INDEX idx_policies_status ON policies(status);
CREATE INDEX idx_policies_end_date ON policies(end_date);
CREATE INDEX idx_policies_renewal_flag ON policies(renewal_flag);
CREATE INDEX idx_policies_policy_number ON policies(policy_number);

-- Claims indexes
CREATE INDEX idx_claims_policy_id ON claims(policy_id);
CREATE INDEX idx_claims_status ON claims(status);
CREATE INDEX idx_claims_date_reported ON claims(date_reported);
CREATE INDEX idx_claims_claim_number ON claims(claim_number);

-- Attachments indexes
CREATE INDEX idx_attachments_parent_type_parent_id ON attachments(parent_type, parent_id);

-- Leads indexes
CREATE INDEX idx_leads_owner_id ON leads(owner_id);
CREATE INDEX idx_leads_status ON leads(status);
CREATE INDEX idx_leads_client_type ON leads(client_type);

-- Quotes indexes
CREATE INDEX idx_quotes_lead_id ON quotes(lead_id);
CREATE INDEX idx_quotes_client_id ON quotes(client_id);
CREATE INDEX idx_quotes_status ON quotes(status);

-- Tasks indexes
CREATE INDEX idx_tasks_assigned_to ON tasks(assigned_to);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);
CREATE INDEX idx_tasks_parent_type_parent_id ON tasks(parent_type, parent_id);

-- Interactions indexes
CREATE INDEX idx_interactions_parent_type_parent_id ON interactions(parent_type, parent_id);
CREATE INDEX idx_interactions_created_by ON interactions(created_by);

-- Renewals indexes
CREATE INDEX idx_renewals_policy_id ON renewals(policy_id);
CREATE INDEX idx_renewals_status ON renewals(status);
CREATE INDEX idx_renewals_renewal_date ON renewals(renewal_date);

-- ============================================================================
-- CONSTRAINTS
-- ============================================================================

-- Ensure only one primary contact per client
CREATE UNIQUE INDEX unique_primary_contact_per_client 
ON client_contacts (client_id) 
WHERE is_primary = TRUE;

-- Ensure only one primary address per client
CREATE UNIQUE INDEX unique_primary_address_per_client 
ON addresses (client_id) 
WHERE is_primary = TRUE;

-- Ensure policy number is unique per insurer
ALTER TABLE policies 
ADD CONSTRAINT unique_policy_number_per_insurer 
UNIQUE (insurer_id, policy_number);

-- Ensure only one selected option per quote
CREATE UNIQUE INDEX unique_selected_option_per_quote 
ON quote_options (quote_id) 
WHERE is_selected = TRUE;

-- ============================================================================
-- TRIGGERS FOR UPDATED_AT
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers to all tables with updated_at
CREATE TRIGGER update_clients_updated_at BEFORE UPDATE ON clients FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_client_contacts_updated_at BEFORE UPDATE ON client_contacts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_addresses_updated_at BEFORE UPDATE ON addresses FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_insurers_updated_at BEFORE UPDATE ON insurers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_policy_types_updated_at BEFORE UPDATE ON policy_types FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_policies_updated_at BEFORE UPDATE ON policies FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_policy_covers_updated_at BEFORE UPDATE ON policy_covers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_policy_endorsements_updated_at BEFORE UPDATE ON policy_endorsements FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_claims_updated_at BEFORE UPDATE ON claims FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_claim_items_updated_at BEFORE UPDATE ON claim_items FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_claim_updates_updated_at BEFORE UPDATE ON claim_updates FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_attachments_updated_at BEFORE UPDATE ON attachments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_employees_updated_at BEFORE UPDATE ON employees FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_leads_updated_at BEFORE UPDATE ON leads FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_quotes_updated_at BEFORE UPDATE ON quotes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_quote_options_updated_at BEFORE UPDATE ON quote_options FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_interactions_updated_at BEFORE UPDATE ON interactions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_renewals_updated_at BEFORE UPDATE ON renewals FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE insurers ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE policy_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE policies ENABLE ROW LEVEL SECURITY;
ALTER TABLE policy_covers ENABLE ROW LEVEL SECURITY;
ALTER TABLE policy_endorsements ENABLE ROW LEVEL SECURITY;
ALTER TABLE claims ENABLE ROW LEVEL SECURITY;
ALTER TABLE claim_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE claim_updates ENABLE ROW LEVEL SECURITY;
ALTER TABLE attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE quotes ENABLE ROW LEVEL SECURITY;
ALTER TABLE quote_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE renewals ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- RLS POLICIES
-- ============================================================================

-- Clients policies
CREATE POLICY "Users can view their own clients" ON clients
    FOR SELECT USING (created_by = auth.uid() OR EXISTS (
        SELECT 1 FROM employees WHERE id = auth.uid() AND role IN ('super_admin', 'manager', 'admin_staff')
    ));

CREATE POLICY "Users can insert their own clients" ON clients
    FOR INSERT WITH CHECK (created_by = auth.uid() OR EXISTS (
        SELECT 1 FROM employees WHERE id = auth.uid() AND role IN ('super_admin', 'manager', 'admin_staff')
    ));

CREATE POLICY "Users can update their own clients" ON clients
    FOR UPDATE USING (created_by = auth.uid() OR EXISTS (
        SELECT 1 FROM employees WHERE id = auth.uid() AND role IN ('super_admin', 'manager', 'admin_staff')
    ));

-- Client contacts policies
CREATE POLICY "Users can view contacts for their clients" ON client_contacts
    FOR SELECT USING (EXISTS (
        SELECT 1 FROM clients WHERE id = client_contacts.client_id AND 
        (created_by = auth.uid() OR EXISTS (
            SELECT 1 FROM employees WHERE id = auth.uid() AND role IN ('super_admin', 'manager', 'admin_staff')
        ))
    ));

CREATE POLICY "Users can manage contacts for their clients" ON client_contacts
    FOR ALL USING (EXISTS (
        SELECT 1 FROM clients WHERE id = client_contacts.client_id AND 
        (created_by = auth.uid() OR EXISTS (
            SELECT 1 FROM employees WHERE id = auth.uid() AND role IN ('super_admin', 'manager', 'admin_staff')
        ))
    ));

-- Addresses policies
CREATE POLICY "Users can view addresses for their clients" ON addresses
    FOR SELECT USING (EXISTS (
        SELECT 1 FROM clients WHERE id = addresses.client_id AND 
        (created_by = auth.uid() OR EXISTS (
            SELECT 1 FROM employees WHERE id = auth.uid() AND role IN ('super_admin', 'manager', 'admin_staff')
        ))
    ));

CREATE POLICY "Users can manage addresses for their clients" ON addresses
    FOR ALL USING (EXISTS (
        SELECT 1 FROM clients WHERE id = addresses.client_id AND 
        (created_by = auth.uid() OR EXISTS (
            SELECT 1 FROM employees WHERE id = auth.uid() AND role IN ('super_admin', 'manager', 'admin_staff')
        ))
    ));

-- Policies policies
CREATE POLICY "Users can view their own policies" ON policies
    FOR SELECT USING (created_by = auth.uid() OR EXISTS (
        SELECT 1 FROM employees WHERE id = auth.uid() AND role IN ('super_admin', 'manager', 'admin_staff')
    ));

CREATE POLICY "Users can manage their own policies" ON policies
    FOR ALL USING (created_by = auth.uid() OR EXISTS (
        SELECT 1 FROM employees WHERE id = auth.uid() AND role IN ('super_admin', 'manager', 'admin_staff')
    ));

-- Claims policies
CREATE POLICY "Users can view claims for their policies" ON claims
    FOR SELECT USING (EXISTS (
        SELECT 1 FROM policies WHERE id = claims.policy_id AND 
        (created_by = auth.uid() OR EXISTS (
            SELECT 1 FROM employees WHERE id = auth.uid() AND role IN ('super_admin', 'manager', 'claims_handler')
        ))
    ));

CREATE POLICY "Users can manage claims for their policies" ON claims
    FOR ALL USING (EXISTS (
        SELECT 1 FROM policies WHERE id = claims.policy_id AND 
        (created_by = auth.uid() OR EXISTS (
            SELECT 1 FROM employees WHERE id = auth.uid() AND role IN ('super_admin', 'manager', 'claims_handler')
        ))
    ));

-- Leads policies
CREATE POLICY "Users can view their own leads" ON leads
    FOR SELECT USING (owner_id = auth.uid() OR EXISTS (
        SELECT 1 FROM employees WHERE id = auth.uid() AND role IN ('super_admin', 'manager')
    ));

CREATE POLICY "Users can manage their own leads" ON leads
    FOR ALL USING (owner_id = auth.uid() OR EXISTS (
        SELECT 1 FROM employees WHERE id = auth.uid() AND role IN ('super_admin', 'manager')
    ));

-- Quotes policies
CREATE POLICY "Users can view quotes for their leads" ON quotes
    FOR SELECT USING (EXISTS (
        SELECT 1 FROM leads WHERE id = quotes.lead_id AND 
        (owner_id = auth.uid() OR EXISTS (
            SELECT 1 FROM employees WHERE id = auth.uid() AND role IN ('super_admin', 'manager')
        ))
    ));

CREATE POLICY "Users can manage quotes for their leads" ON quotes
    FOR ALL USING (EXISTS (
        SELECT 1 FROM leads WHERE id = quotes.lead_id AND 
        (owner_id = auth.uid() OR EXISTS (
            SELECT 1 FROM employees WHERE id = auth.uid() AND role IN ('super_admin', 'manager')
        ))
    ));

-- Employees policies (only super_admin can manage)
CREATE POLICY "Users can view employees" ON employees
    FOR SELECT USING (EXISTS (
        SELECT 1 FROM employees WHERE id = auth.uid() AND role IN ('super_admin', 'manager')
    ));

CREATE POLICY "Only super_admin can manage employees" ON employees
    FOR ALL USING (EXISTS (
        SELECT 1 FROM employees WHERE id = auth.uid() AND role = 'super_admin'
    ));

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Function to check if policy is due for renewal (within 2 months)
CREATE OR REPLACE FUNCTION check_renewal_flag()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.end_date IS NOT NULL THEN
        NEW.renewal_flag := (NEW.end_date - CURRENT_DATE) <= INTERVAL '60 days';
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply renewal flag trigger
CREATE TRIGGER update_renewal_flag BEFORE INSERT OR UPDATE ON policies 
FOR EACH ROW EXECUTE FUNCTION check_renewal_flag();

-- Function to get client full name
CREATE OR REPLACE FUNCTION get_client_full_name(client_record clients)
RETURNS TEXT AS $$
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
$$ language 'plpgsql';

-- Function to generate quote number
CREATE OR REPLACE FUNCTION generate_quote_number()
RETURNS TEXT AS $$
DECLARE
    next_number INTEGER;
BEGIN
    SELECT COALESCE(MAX(CAST(SUBSTRING(quote_number FROM 4) AS INTEGER)), 0) + 1
    INTO next_number
    FROM quotes
    WHERE quote_number LIKE 'QT-%';
    
    RETURN 'QT-' || LPAD(next_number::TEXT, 6, '0');
END;
$$ language 'plpgsql';

-- ============================================================================
-- VIEWS
-- ============================================================================

-- View for client summary
CREATE VIEW client_summary AS
SELECT 
    c.id,
    c.client_type,
    get_client_full_name(c) as full_name,
    c.status,
    c.created_at,
    COUNT(p.id) as policy_count,
    COUNT(cl.id) as claim_count
FROM clients c
LEFT JOIN policies p ON c.id = p.client_id AND p.status = 'active'
LEFT JOIN claims cl ON p.id = cl.policy_id
GROUP BY c.id, c.client_type, c.first_name, c.last_name, c.entity_name, c.status, c.created_at;

-- View for policy summary
CREATE VIEW policy_summary AS
SELECT 
    p.id,
    p.policy_number,
    p.start_date,
    p.end_date,
    p.status,
    p.renewal_flag,
    c.id as client_id,
    get_client_full_name(c) as client_name,
    i.name as insurer_name,
    pr.name as product_name
FROM policies p
JOIN clients c ON p.client_id = c.id
JOIN insurers i ON p.insurer_id = i.id
JOIN products pr ON p.product_id = pr.id;

-- View for dashboard statistics
CREATE VIEW dashboard_stats AS
SELECT 
    (SELECT COUNT(*) FROM leads WHERE status = 'new') as new_leads,
    (SELECT COUNT(*) FROM quotes WHERE status = 'sent') as pending_quotes,
    (SELECT COUNT(*) FROM policies WHERE renewal_flag = true) as renewals_due,
    (SELECT COUNT(*) FROM claims WHERE status IN ('reported', 'in_review')) as open_claims,
    (SELECT COUNT(*) FROM tasks WHERE status = 'pending' AND assigned_to = auth.uid()) as my_tasks;

-- ============================================================================
-- SAMPLE DATA
-- ============================================================================

-- Insert sample policy types
INSERT INTO policy_types (slug, display_name) VALUES
('motor', 'Motor Vehicle'),
('home', 'Home Insurance'),
('business', 'Business Insurance'),
('life', 'Life Insurance'),
('health', 'Health Insurance'),
('liability', 'Public Liability'),
('commercial', 'Commercial Property'),
('professional', 'Professional Indemnity');

-- Insert sample insurers
INSERT INTO insurers (name, contact_info) VALUES
('Santam', '{"email": "info@santam.co.za", "phone": "0860 726 826"}'),
('Old Mutual', '{"email": "info@oldmutual.co.za", "phone": "0860 726 826"}'),
('Discovery', '{"email": "info@discovery.co.za", "phone": "0860 726 826"}'),
('Momentum', '{"email": "info@momentum.co.za", "phone": "0860 726 826"}'),
('Hollard', '{"email": "info@hollard.co.za", "phone": "0860 726 826"}'),
('Outsurance', '{"email": "info@outsurance.co.za", "phone": "0860 726 826"}');

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE clients IS 'Stores all client entities (Personal, Business, Body Corporate)';
COMMENT ON TABLE client_contacts IS 'Stores multiple contact records linked to a client';
COMMENT ON TABLE addresses IS 'Stores addresses per client';
COMMENT ON TABLE insurers IS 'Stores registered insurers';
COMMENT ON TABLE products IS 'Links products to insurers';
COMMENT ON TABLE policies IS 'Main policy table';
COMMENT ON TABLE policy_covers IS 'Normalized covers linked to policies';
COMMENT ON TABLE policy_types IS 'Defines possible covers';
COMMENT ON TABLE policy_endorsements IS 'Tracks changes to policies';
COMMENT ON TABLE claims IS 'Main claims table';
COMMENT ON TABLE claim_items IS 'Line items for claims';
COMMENT ON TABLE claim_updates IS 'Tracks updates in the claim lifecycle';
COMMENT ON TABLE attachments IS 'Stores files linked to any entity';
COMMENT ON TABLE employees IS 'Maps auth users to business profiles';
COMMENT ON TABLE leads IS 'Stores sales leads and prospects';
COMMENT ON TABLE quotes IS 'Stores quotes for leads';
COMMENT ON TABLE quote_options IS 'Stores different insurer options for quotes';
COMMENT ON TABLE tasks IS 'Stores tasks and reminders';
COMMENT ON TABLE interactions IS 'Stores interactions with clients/leads';
COMMENT ON TABLE renewals IS 'Stores renewal tracking information';
