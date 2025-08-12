-- Add claim types table for migration
CREATE TABLE IF NOT EXISTS claim_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add sample claim types
INSERT INTO claim_types (id, name, description) VALUES
(gen_random_uuid(), 'Motor Accident', 'Vehicle collision or accident claims'),
(gen_random_uuid(), 'Theft', 'Stolen property claims'),
(gen_random_uuid(), 'Fire Damage', 'Fire-related property damage'),
(gen_random_uuid(), 'Natural Disaster', 'Weather and natural disaster claims'),
(gen_random_uuid(), 'Water Damage', 'Water-related property damage'),
(gen_random_uuid(), 'Personal Injury', 'Personal injury and medical claims'),
(gen_random_uuid(), 'Business Interruption', 'Business interruption and loss of income'),
(gen_random_uuid(), 'Liability', 'Third-party liability claims')
ON CONFLICT (name) DO NOTHING;
