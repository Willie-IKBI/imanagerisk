export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instanciate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "13.0.4"
  }
  public: {
    Tables: {
      addresses: {
        Row: {
          address_notes: string | null
          city: string
          client_id: string
          complex_name: string | null
          country: string
          created_at: string
          created_by: string | null
          id: string
          is_primary: boolean
          line_1: string
          line_2: string | null
          postal_code: string
          province: string
          street_name: string | null
          street_number: string | null
          suburb: string | null
          type: string
          unit_number: string | null
          updated_at: string
        }
        Insert: {
          address_notes?: string | null
          city: string
          client_id: string
          complex_name?: string | null
          country?: string
          created_at?: string
          created_by?: string | null
          id?: string
          is_primary?: boolean
          line_1: string
          line_2?: string | null
          postal_code: string
          province: string
          street_name?: string | null
          street_number?: string | null
          suburb?: string | null
          type?: string
          unit_number?: string | null
          updated_at?: string
        }
        Update: {
          address_notes?: string | null
          city?: string
          client_id?: string
          complex_name?: string | null
          country?: string
          created_at?: string
          created_by?: string | null
          id?: string
          is_primary?: boolean
          line_1?: string
          line_2?: string | null
          postal_code?: string
          province?: string
          street_name?: string | null
          street_number?: string | null
          suburb?: string | null
          type?: string
          unit_number?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "addresses_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "clients"
            referencedColumns: ["id"]
          },
        ]
      }
      attachments: {
        Row: {
          file_name: string
          file_path: string
          file_size: number
          id: string
          mime_type: string
          parent_id: string
          parent_type: string
          uploaded_at: string
          uploaded_by: string | null
        }
        Insert: {
          file_name: string
          file_path: string
          file_size: number
          id?: string
          mime_type: string
          parent_id: string
          parent_type: string
          uploaded_at?: string
          uploaded_by?: string | null
        }
        Update: {
          file_name?: string
          file_path?: string
          file_size?: number
          id?: string
          mime_type?: string
          parent_id?: string
          parent_type?: string
          uploaded_at?: string
          uploaded_by?: string | null
        }
        Relationships: []
      }
      claim_items: {
        Row: {
          claim_id: string
          created_at: string
          description: string
          id: string
          quantity: number
          total_amount: number
          unit_price: number
        }
        Insert: {
          claim_id: string
          created_at?: string
          description: string
          id?: string
          quantity?: number
          total_amount: number
          unit_price: number
        }
        Update: {
          claim_id?: string
          created_at?: string
          description?: string
          id?: string
          quantity?: number
          total_amount?: number
          unit_price?: number
        }
        Relationships: [
          {
            foreignKeyName: "claim_items_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claims"
            referencedColumns: ["id"]
          },
        ]
      }
      claim_updates: {
        Row: {
          claim_id: string
          created_at: string
          created_by: string | null
          id: string
          notes: string
          status: Database["public"]["Enums"]["claim_status"]
        }
        Insert: {
          claim_id: string
          created_at?: string
          created_by?: string | null
          id?: string
          notes: string
          status: Database["public"]["Enums"]["claim_status"]
        }
        Update: {
          claim_id?: string
          created_at?: string
          created_by?: string | null
          id?: string
          notes?: string
          status?: Database["public"]["Enums"]["claim_status"]
        }
        Relationships: [
          {
            foreignKeyName: "claim_updates_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claims"
            referencedColumns: ["id"]
          },
        ]
      }
      claims: {
        Row: {
          claim_number: string
          claim_type: Database["public"]["Enums"]["claim_type"]
          created_at: string
          created_by: string | null
          date_incident: string | null
          date_reported: string
          description: string
          estimated_value: number | null
          id: string
          policy_id: string
          status: Database["public"]["Enums"]["claim_status"]
          updated_at: string
        }
        Insert: {
          claim_number: string
          claim_type: Database["public"]["Enums"]["claim_type"]
          created_at?: string
          created_by?: string | null
          date_incident?: string | null
          date_reported: string
          description: string
          estimated_value?: number | null
          id?: string
          policy_id: string
          status?: Database["public"]["Enums"]["claim_status"]
          updated_at?: string
        }
        Update: {
          claim_number?: string
          claim_type?: Database["public"]["Enums"]["claim_type"]
          created_at?: string
          created_by?: string | null
          date_incident?: string | null
          date_reported?: string
          description?: string
          estimated_value?: number | null
          id?: string
          policy_id?: string
          status?: Database["public"]["Enums"]["claim_status"]
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "claims_policy_id_fkey"
            columns: ["policy_id"]
            isOneToOne: false
            referencedRelation: "policies"
            referencedColumns: ["id"]
          },
        ]
      }
      client_contacts: {
        Row: {
          client_id: string
          created_at: string
          created_by: string | null
          email: string | null
          id: string
          is_primary: boolean
          name: string
          phone: string | null
          position: string | null
          updated_at: string
        }
        Insert: {
          client_id: string
          created_at?: string
          created_by?: string | null
          email?: string | null
          id?: string
          is_primary?: boolean
          name: string
          phone?: string | null
          position?: string | null
          updated_at?: string
        }
        Update: {
          client_id?: string
          created_at?: string
          created_by?: string | null
          email?: string | null
          id?: string
          is_primary?: boolean
          name?: string
          phone?: string | null
          position?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "client_contacts_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "clients"
            referencedColumns: ["id"]
          },
        ]
      }
      clients: {
        Row: {
          alternative_phone: string | null
          client_type: Database["public"]["Enums"]["client_type"]
          company_reg_number: string | null
          created_at: string
          created_by: string | null
          email: string | null
          entity_name: string | null
          first_name: string | null
          id: string
          id_number: string | null
          last_name: string | null
          notes: string | null
          phone: string | null
          ss_number: string | null
          status: Database["public"]["Enums"]["client_status"]
          updated_at: string
          vat_number: string | null
        }
        Insert: {
          alternative_phone?: string | null
          client_type: Database["public"]["Enums"]["client_type"]
          company_reg_number?: string | null
          created_at?: string
          created_by?: string | null
          email?: string | null
          entity_name?: string | null
          first_name?: string | null
          id?: string
          id_number?: string | null
          last_name?: string | null
          notes?: string | null
          phone?: string | null
          ss_number?: string | null
          status?: Database["public"]["Enums"]["client_status"]
          updated_at?: string
          vat_number?: string | null
        }
        Update: {
          alternative_phone?: string | null
          client_type?: Database["public"]["Enums"]["client_type"]
          company_reg_number?: string | null
          created_at?: string
          created_by?: string | null
          email?: string | null
          entity_name?: string | null
          first_name?: string | null
          id?: string
          id_number?: string | null
          last_name?: string | null
          notes?: string | null
          phone?: string | null
          ss_number?: string | null
          status?: Database["public"]["Enums"]["client_status"]
          updated_at?: string
          vat_number?: string | null
        }
        Relationships: []
      }
      employees: {
        Row: {
          created_at: string
          department: string | null
          email: string
          employee_number: string
          first_name: string
          hire_date: string
          id: string
          last_name: string
          phone: string | null
          role: Database["public"]["Enums"]["employee_role"]
          status: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          department?: string | null
          email: string
          employee_number: string
          first_name: string
          hire_date: string
          id: string
          last_name: string
          phone?: string | null
          role: Database["public"]["Enums"]["employee_role"]
          status?: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          department?: string | null
          email?: string
          employee_number?: string
          first_name?: string
          hire_date?: string
          id?: string
          last_name?: string
          phone?: string | null
          role?: Database["public"]["Enums"]["employee_role"]
          status?: string
          updated_at?: string
        }
        Relationships: []
      }
      insurers: {
        Row: {
          code: string | null
          created_at: string
          email: string | null
          id: string
          name: string
          phone: string | null
          status: string
          updated_at: string
          website: string | null
        }
        Insert: {
          code?: string | null
          created_at?: string
          email?: string | null
          id?: string
          name: string
          phone?: string | null
          status?: string
          updated_at?: string
          website?: string | null
        }
        Update: {
          code?: string | null
          created_at?: string
          email?: string | null
          id?: string
          name?: string
          phone?: string | null
          status?: string
          updated_at?: string
          website?: string | null
        }
        Relationships: []
      }
      policies: {
        Row: {
          client_id: string
          created_at: string
          created_by: string | null
          end_date: string
          excess_amount: number | null
          id: string
          insurer_id: string
          policy_number: string
          premium_amount: number
          product_id: string
          renewal_flag: boolean
          start_date: string
          status: Database["public"]["Enums"]["policy_status"]
          updated_at: string
        }
        Insert: {
          client_id: string
          created_at?: string
          created_by?: string | null
          end_date: string
          excess_amount?: number | null
          id?: string
          insurer_id: string
          policy_number: string
          premium_amount: number
          product_id: string
          renewal_flag?: boolean
          start_date: string
          status?: Database["public"]["Enums"]["policy_status"]
          updated_at?: string
        }
        Update: {
          client_id?: string
          created_at?: string
          created_by?: string | null
          end_date?: string
          excess_amount?: number | null
          id?: string
          insurer_id?: string
          policy_number?: string
          premium_amount?: number
          product_id?: string
          renewal_flag?: boolean
          start_date?: string
          status?: Database["public"]["Enums"]["policy_status"]
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "policies_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "clients"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "policies_insurer_id_fkey"
            columns: ["insurer_id"]
            isOneToOne: false
            referencedRelation: "insurers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "policies_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "products"
            referencedColumns: ["id"]
          },
        ]
      }
      policy_covers: {
        Row: {
          created_at: string
          excess: number | null
          policy_id: string
          premium: number
          sum_insured: number
          type_id: string
        }
        Insert: {
          created_at?: string
          excess?: number | null
          policy_id: string
          premium: number
          sum_insured: number
          type_id: string
        }
        Update: {
          created_at?: string
          excess?: number | null
          policy_id?: string
          premium?: number
          sum_insured?: number
          type_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "policy_covers_policy_id_fkey"
            columns: ["policy_id"]
            isOneToOne: false
            referencedRelation: "policies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "policy_covers_type_id_fkey"
            columns: ["type_id"]
            isOneToOne: false
            referencedRelation: "policy_types"
            referencedColumns: ["id"]
          },
        ]
      }
      policy_endorsements: {
        Row: {
          created_at: string
          created_by: string | null
          description: string
          effective_date: string
          endorsement_number: string
          id: string
          policy_id: string
          premium_adjustment: number
          updated_at: string
        }
        Insert: {
          created_at?: string
          created_by?: string | null
          description: string
          effective_date: string
          endorsement_number: string
          id?: string
          policy_id: string
          premium_adjustment?: number
          updated_at?: string
        }
        Update: {
          created_at?: string
          created_by?: string | null
          description?: string
          effective_date?: string
          endorsement_number?: string
          id?: string
          policy_id?: string
          premium_adjustment?: number
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "policy_endorsements_policy_id_fkey"
            columns: ["policy_id"]
            isOneToOne: false
            referencedRelation: "policies"
            referencedColumns: ["id"]
          },
        ]
      }
      policy_types: {
        Row: {
          category: string
          created_at: string
          description: string | null
          id: string
          name: string
          slug: string
          updated_at: string
        }
        Insert: {
          category: string
          created_at?: string
          description?: string | null
          id?: string
          name: string
          slug: string
          updated_at?: string
        }
        Update: {
          category?: string
          created_at?: string
          description?: string | null
          id?: string
          name?: string
          slug?: string
          updated_at?: string
        }
        Relationships: []
      }
      products: {
        Row: {
          category: string
          created_at: string
          description: string | null
          id: string
          insurer_id: string
          name: string
          status: string
          updated_at: string
        }
        Insert: {
          category: string
          created_at?: string
          description?: string | null
          id?: string
          insurer_id: string
          name: string
          status?: string
          updated_at?: string
        }
        Update: {
          category?: string
          created_at?: string
          description?: string | null
          id?: string
          insurer_id?: string
          name?: string
          status?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "products_insurer_id_fkey"
            columns: ["insurer_id"]
            isOneToOne: false
            referencedRelation: "insurers"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      can_access_client: {
        Args: { client_id: string }
        Returns: boolean
      }
      has_role: {
        Args: { role_name: string }
        Returns: boolean
      }
      is_admin_or_manager: {
        Args: Record<PropertyKey, never>
        Returns: boolean
      }
      is_sales_role: {
        Args: Record<PropertyKey, never>
        Returns: boolean
      }
    }
    Enums: {
      claim_status: "open" | "in_progress" | "closed" | "rejected"
      claim_type: "theft" | "accident" | "fire" | "flood" | "other"
      client_status: "active" | "inactive" | "prospect"
      client_type: "personal" | "business" | "body_corporate"
      employee_role: "admin" | "manager" | "sales" | "claims" | "support"
      policy_status: "active" | "expired" | "cancelled" | "pending"
      task_priority: "low" | "medium" | "high" | "urgent"
      task_status: "pending" | "in_progress" | "completed" | "cancelled"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      claim_status: ["open", "in_progress", "closed", "rejected"],
      claim_type: ["theft", "accident", "fire", "flood", "other"],
      client_status: ["active", "inactive", "prospect"],
      client_type: ["personal", "business", "body_corporate"],
      employee_role: ["admin", "manager", "sales", "claims", "support"],
      policy_status: ["active", "expired", "cancelled", "pending"],
      task_priority: ["low", "medium", "high", "urgent"],
      task_status: ["pending", "in_progress", "completed", "cancelled"],
    },
  },
} as const
