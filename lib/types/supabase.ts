export type Database = {
  public: {
    Tables: {
      claim_updates: {
        Row: {
          claim_id: string
          created_at: string | null
          created_by: string | null
          id: string
          update_text: string
          updated_at: string | null
        }
        Insert: {
          claim_id: string
          created_at?: string | null
          created_by?: string | null
          id?: string
          update_text: string
          updated_at?: string | null
        }
        Update: {
          claim_id?: string
          created_at?: string | null
          created_by?: string | null
          id?: string
          update_text?: string
          updated_at?: string | null
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
          created_at: string | null
          created_by: string | null
          date_reported: string
          id: string
          policy_id: string
          status: Database["public"]["Enums"]["claim_status"] | null
          updated_at: string | null
        }
        Insert: {
          claim_number: string
          created_at?: string | null
          created_by?: string | null
          date_reported: string
          id?: string
          policy_id: string
          status?: Database["public"]["Enums"]["claim_status"] | null
          updated_at?: string | null
        }
        Update: {
          claim_number?: string
          created_at?: string | null
          created_by?: string | null
          date_reported?: string
          id?: string
          policy_id?: string
          status?: Database["public"]["Enums"]["claim_status"] | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "claims_policy_id_fkey"
            columns: ["policy_id"]
            isOneToOne: false
            referencedRelation: "policies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "claims_policy_id_fkey"
            columns: ["policy_id"]
            isOneToOne: false
            referencedRelation: "policy_summary"
            referencedColumns: ["id"]
          },
        ]
      }
      client_contacts: {
        Row: {
          client_id: string
          created_at: string | null
          created_by: string | null
          email: string | null
          id: string
          is_primary: boolean | null
          name: string
          phone: string | null
          role: string | null
          updated_at: string | null
        }
        Insert: {
          client_id: string
          created_at?: string | null
          created_by?: string | null
          email?: string | null
          id?: string
          is_primary?: boolean | null
          name: string
          phone?: string | null
          role?: string | null
          updated_at?: string | null
        }
        Update: {
          client_id?: string
          created_at?: string | null
          created_by?: string | null
          email?: string | null
          id?: string
          is_primary?: boolean | null
          name?: string
          phone?: string | null
          role?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "client_contacts_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "client_summary"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "client_contacts_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "clients"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "client_contacts_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "policy_summary"
            referencedColumns: ["client_id"]
          },
        ]
      }
      clients: {
        Row: {
          client_type: Database["public"]["Enums"]["client_type"]
          comments: string | null
          company_reg_number: string | null
          created_at: string | null
          created_by: string | null
          entity_name: string | null
          first_name: string | null
          id: string
          id_number: string | null
          last_name: string | null
          status: Database["public"]["Enums"]["client_status"] | null
          updated_at: string | null
          vat_number: string | null
        }
        Insert: {
          client_type: Database["public"]["Enums"]["client_type"]
          comments?: string | null
          company_reg_number?: string | null
          created_at?: string | null
          created_by?: string | null
          entity_name?: string | null
          first_name?: string | null
          id?: string
          id_number?: string | null
          last_name?: string | null
          status?: Database["public"]["Enums"]["client_status"] | null
          updated_at?: string | null
          vat_number?: string | null
        }
        Update: {
          client_type?: Database["public"]["Enums"]["client_type"]
          comments?: string | null
          company_reg_number?: string | null
          created_at?: string | null
          created_by?: string | null
          entity_name?: string | null
          first_name?: string | null
          id?: string
          id_number?: string | null
          last_name?: string | null
          status?: Database["public"]["Enums"]["client_status"] | null
          updated_at?: string | null
          vat_number?: string | null
        }
        Relationships: []
      }
      employees: {
        Row: {
          contact_number: string | null
          created_at: string | null
          display_image: string | null
          full_name: string
          id: string
          role: string
          updated_at: string | null
        }
        Insert: {
          contact_number?: string | null
          created_at?: string | null
          display_image?: string | null
          full_name: string
          id: string
          role: string
          updated_at?: string | null
        }
        Update: {
          contact_number?: string | null
          created_at?: string | null
          display_image?: string | null
          full_name?: string
          id?: string
          role?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      insurers: {
        Row: {
          contact_info: Json | null
          created_at: string | null
          id: string
          name: string
          updated_at: string | null
        }
        Insert: {
          contact_info?: Json | null
          created_at?: string | null
          id?: string
          name: string
          updated_at?: string | null
        }
        Update: {
          contact_info?: Json | null
          created_at?: string | null
          id?: string
          name?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      interactions: {
        Row: {
          created_at: string | null
          created_by: string | null
          description: string
          id: string
          interaction_type: string
          parent_id: string
          parent_type: string
          subject: string | null
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          created_by?: string | null
          description: string
          id?: string
          interaction_type: string
          parent_id: string
          parent_type: string
          subject?: string | null
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          created_by?: string | null
          description?: string
          id?: string
          interaction_type?: string
          parent_id?: string
          parent_type?: string
          subject?: string | null
          updated_at?: string | null
        }
        Relationships: []
      }
      leads: {
        Row: {
          client_type: Database["public"]["Enums"]["client_type"]
          company_reg_number: string | null
          contact_email: string | null
          contact_phone: string | null
          created_at: string | null
          id: string
          id_number: string | null
          owner_id: string
          product_interest: string | null
          prospect_name: string
          province: string | null
          region: string | null
          source: string | null
          status: Database["public"]["Enums"]["lead_status"] | null
          updated_at: string | null
        }
        Insert: {
          client_type: Database["public"]["Enums"]["client_type"]
          company_reg_number?: string | null
          contact_email?: string | null
          contact_phone?: string | null
          created_at?: string | null
          id?: string
          id_number?: string | null
          owner_id: string
          product_interest?: string | null
          prospect_name: string
          province?: string | null
          region?: string | null
          source?: string | null
          status?: Database["public"]["Enums"]["lead_status"] | null
          updated_at?: string | null
        }
        Update: {
          client_type?: Database["public"]["Enums"]["client_type"]
          company_reg_number?: string | null
          contact_email?: string | null
          contact_phone?: string | null
          created_at?: string | null
          id?: string
          id_number?: string | null
          owner_id?: string
          product_interest?: string | null
          prospect_name: string
          province?: string | null
          region?: string | null
          source?: string | null
          status?: Database["public"]["Enums"]["lead_status"] | null
          updated_at?: string | null
        }
        Relationships: []
      }
      policies: {
        Row: {
          client_id: string
          created_at: string | null
          created_by: string | null
          end_date: string | null
          id: string
          insurer_id: string
          policy_number: string
          product_id: string
          renewal_flag: boolean | null
          start_date: string | null
          status: Database["public"]["Enums"]["policy_status"] | null
          updated_at: string | null
        }
        Insert: {
          client_id: string
          created_at?: string | null
          created_by?: string | null
          end_date?: string | null
          id?: string
          insurer_id: string
          policy_number: string
          product_id: string
          renewal_flag?: boolean | null
          start_date?: string | null
          status?: Database["public"]["Enums"]["policy_status"] | null
          updated_at?: string | null
        }
        Update: {
          client_id?: string
          created_at?: string | null
          created_by?: string | null
          end_date?: string | null
          id?: string
          insurer_id?: string
          policy_number?: string
          product_id?: string
          renewal_flag?: boolean | null
          start_date?: string | null
          status?: Database["public"]["Enums"]["policy_status"] | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "policies_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "client_summary"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "policies_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "clients"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "policies_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "policy_summary"
            referencedColumns: ["client_id"]
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
          policy_id: string
          premium: number | null
          sum_insured: number | null
          type_id: string
          updated_at: string | null
        }
        Insert: {
          policy_id: string
          premium?: number | null
          sum_insured?: number | null
          type_id: string
          updated_at?: string | null
        }
        Update: {
          policy_id?: string
          premium?: number | null
          sum_insured?: number | null
          type_id?: string
          updated_at?: string | null
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
            foreignKeyName: "policy_covers_policy_id_fkey"
            columns: ["policy_id"]
            isOneToOne: false
            referencedRelation: "policy_summary"
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
          created_at: string | null
          created_by: string | null
          description: string
          effective_date: string | null
          endorsement_type: string
          id: string
          policy_id: string
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          created_by?: string | null
          description: string
          effective_date?: string | null
          endorsement_type: string
          id?: string
          policy_id: string
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          created_by?: string | null
          description?: string
          effective_date?: string | null
          endorsement_type?: string
          id?: string
          policy_id?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "policy_endorsements_policy_id_fkey"
            columns: ["policy_id"]
            isOneToOne: false
            referencedRelation: "policies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "policy_endorsements_policy_id_fkey"
            columns: ["policy_id"]
            isOneToOne: false
            referencedRelation: "policy_summary"
            referencedColumns: ["id"]
          },
        ]
      }
      policy_types: {
        Row: {
          created_at: string | null
          display_name: string
          id: string
          slug: string
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          display_name: string
          id?: string
          slug: string
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          display_name?: string
          id?: string
          slug?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      products: {
        Row: {
          created_at: string | null
          description: string | null
          id: string
          insurer_id: string
          name: string
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          description?: string | null
          id?: string
          insurer_id: string
          name: string
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          description?: string | null
          id?: string
          insurer_id?: string
          name?: string
          updated_at?: string | null
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
      quote_options: {
        Row: {
          cover_summary: string | null
          created_at: string | null
          excess: number | null
          id: string
          insurer_id: string
          is_selected: boolean | null
          key_exclusions: string | null
          premium: number
          product_id: string
          quote_id: string
          updated_at: string | null
        }
        Insert: {
          cover_summary?: string | null
          created_at?: string | null
          excess?: number | null
          id?: string
          insurer_id: string
          is_selected?: boolean | null
          key_exclusions?: string | null
          premium: number
          product_id: string
          quote_id: string
          updated_at?: string | null
        }
        Update: {
          cover_summary?: string | null
          created_at?: string | null
          excess?: number | null
          id?: string
          insurer_id?: string
          is_selected?: boolean | null
          key_exclusions?: string | null
          premium?: number
          product_id?: string
          quote_id?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "quote_options_insurer_id_fkey"
            columns: ["insurer_id"]
            isOneToOne: false
            referencedRelation: "insurers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "quote_options_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "products"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "quote_options_quote_id_fkey"
            columns: ["quote_id"]
            isOneToOne: false
            referencedRelation: "quotes"
            referencedColumns: ["id"]
          },
        ]
      }
      quotes: {
        Row: {
          client_id: string | null
          created_at: string | null
          created_by: string | null
          id: string
          lead_id: string | null
          quote_number: string
          status: Database["public"]["Enums"]["quote_status"] | null
          updated_at: string | null
          valid_until: string | null
        }
        Insert: {
          client_id?: string | null
          created_at?: string | null
          created_by?: string | null
          id?: string
          lead_id?: string | null
          quote_number: string
          status?: Database["public"]["Enums"]["quote_status"] | null
          updated_at?: string | null
          valid_until?: string | null
        }
        Update: {
          client_id?: string | null
          created_at?: string | null
          created_by?: string | null
          id?: string
          lead_id?: string | null
          quote_number?: string
          status?: Database["public"]["Enums"]["quote_status"] | null
          updated_at?: string | null
          valid_until?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "quotes_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "client_summary"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "quotes_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "clients"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "quotes_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "policy_summary"
            referencedColumns: ["client_id"]
          },
          {
            foreignKeyName: "quotes_lead_id_fkey"
            columns: ["lead_id"]
            isOneToOne: false
            referencedRelation: "leads"
            referencedColumns: ["id"]
          },
        ]
      }
      renewals: {
        Row: {
          created_at: string | null
          created_by: string | null
          id: string
          notes: string | null
          policy_id: string
          premium_change: number | null
          renewal_date: string
          status: string | null
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          created_by?: string | null
          id?: string
          notes?: string | null
          policy_id: string
          premium_change?: number | null
          renewal_date: string
          status?: string | null
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          created_by?: string | null
          id?: string
          notes?: string | null
          policy_id?: string
          premium_change?: number | null
          renewal_date?: string
          status?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "renewals_policy_id_fkey"
            columns: ["policy_id"]
            isOneToOne: false
            referencedRelation: "policies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "renewals_policy_id_fkey"
            columns: ["policy_id"]
            isOneToOne: false
            referencedRelation: "policy_summary"
            referencedColumns: ["id"]
          },
        ]
      }
      tasks: {
        Row: {
          assigned_to: string | null
          created_at: string | null
          created_by: string | null
          description: string | null
          due_date: string | null
          id: string
          parent_id: string | null
          parent_type: string | null
          priority: Database["public"]["Enums"]["task_priority"] | null
          status: Database["public"]["Enums"]["task_status"] | null
          title: string
          updated_at: string | null
        }
        Insert: {
          assigned_to?: string | null
          created_at?: string | null
          created_by?: string | null
          description?: string | null
          due_date?: string | null
          id?: string
          parent_id?: string | null
          parent_type?: string | null
          priority?: Database["public"]["Enums"]["task_priority"] | null
          status?: Database["public"]["Enums"]["task_status"] | null
          title: string
          updated_at?: string | null
        }
        Update: {
          assigned_to?: string | null
          created_at?: string | null
          created_by?: string | null
          description?: string | null
          due_date?: string | null
          id?: string
          parent_id?: string | null
          parent_type?: string | null
          priority?: Database["public"]["Enums"]["task_priority"] | null
          status?: Database["public"]["Enums"]["task_status"] | null
          title?: string
          updated_at?: string | null
        }
        Relationships: []
      }
    }
    Views: {
      client_summary: {
        Row: {
          claim_count: number | null
          client_type: Database["public"]["Enums"]["client_type"] | null
          created_at: string | null
          full_name: string | null
          id: string | null
          policy_count: number | null
          status: Database["public"]["Enums"]["client_status"] | null
        }
        Relationships: []
      }
      dashboard_stats: {
        Row: {
          my_tasks: number | null
          new_leads: number | null
          open_claims: number | null
          pending_quotes: number | null
          renewals_due: number | null
        }
        Relationships: []
      }
      policy_summary: {
        Row: {
          client_id: string | null
          client_name: string | null
          end_date: string | null
          id: string | null
          insurer_name: string | null
          policy_number: string | null
          product_name: string | null
          renewal_flag: boolean | null
          start_date: string | null
          status: Database["public"]["Enums"]["policy_status"] | null
        }
        Relationships: []
      }
    }
    Functions: {
      generate_quote_number: {
        Args: Record<PropertyKey, never>
        Returns: string
      }
      get_client_full_name: {
        Args: { client_record: Database["public"]["Tables"]["clients"]["Row"] }
        Returns: string
      }
    }
    Enums: {
      claim_status:
        | "reported"
        | "in_review"
        | "approved"
        | "declined"
        | "settled"
      client_status: "active" | "inactive"
      client_type: "personal" | "business" | "body_corporate"
      lead_status:
        | "new"
        | "contacted"
        | "qualifying"
        | "quoting"
        | "awaiting_docs"
        | "decision"
        | "won"
        | "lost"
      policy_status: "active" | "cancelled" | "pending"
      quote_status: "draft" | "sent" | "accepted" | "declined" | "expired"
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
      claim_status: [
        "reported",
        "in_review",
        "approved",
        "declined",
        "settled",
      ],
      client_status: ["active", "inactive"],
      client_type: ["personal", "business", "body_corporate"],
      lead_status: [
        "new",
        "contacted",
        "qualifying",
        "quoting",
        "awaiting_docs",
        "decision",
        "won",
        "lost",
      ],
      policy_status: ["active", "cancelled", "pending"],
      quote_status: ["draft", "sent", "accepted", "declined", "expired"],
      task_priority: ["low", "medium", "high", "urgent"],
      task_status: ["pending", "in_progress", "completed", "cancelled"],
    },
  },
} as const
