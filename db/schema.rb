# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_06_18_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "about_us", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.string "subtitle"
    t.text "description", null: false
    t.text "mission"
    t.text "vision"
    t.text "values"
    t.text "history"
    t.text "team_description"
    t.jsonb "team_members", default: []
    t.jsonb "achievements", default: []
    t.jsonb "milestones", default: []
    t.jsonb "partners", default: []
    t.boolean "is_published", default: true
    t.string "meta_title"
    t.text "meta_description"
    t.string "meta_keywords"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "achievements_description"
    t.text "milestones_description"
    t.string "values_title"
  end

  create_table "active_admin_comments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", default: "local", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "middle_name"
    t.string "role", default: "admin", null: false
    t.string "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_admin_users_on_role"
  end

  create_table "applicants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name", null: false
    t.string "middle_name"
    t.string "last_name", null: false
    t.string "email", null: false
    t.string "phone", null: false
    t.text "address", null: false
    t.date "date_of_birth", null: false
    t.string "gender"
    t.string "education_level", null: false
    t.integer "years_of_experience", default: 0, null: false
    t.string "current_employer"
    t.string "current_position"
    t.text "skills", default: [], array: true
    t.uuid "vacancy_id", null: false
    t.string "status", default: "applied", null: false
    t.text "cover_letter_text"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["education_level"], name: "index_applicants_on_education_level"
    t.index ["email"], name: "index_applicants_on_email", unique: true
    t.index ["skills"], name: "index_applicants_on_skills", using: :gin
    t.index ["status"], name: "index_applicants_on_status"
    t.index ["vacancy_id"], name: "index_applicants_on_vacancy_id"
    t.index ["years_of_experience"], name: "index_applicants_on_years_of_experience"
  end

  create_table "bids", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "bid_number", null: false
    t.string "title", null: false
    t.string "category"
    t.string "type_of_bid"
    t.string "status", default: "active"
    t.date "publish_date"
    t.date "deadline_date"
    t.string "budget"
    t.string "funding_source"
    t.text "description"
    t.jsonb "eligibility", default: []
    t.string "contact_person"
    t.string "contact_email"
    t.string "contact_phone"
    t.string "award_status"
    t.string "awarded_to"
    t.date "award_date"
    t.string "contract_value"
    t.boolean "is_published", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bid_number"], name: "index_bids_on_bid_number", unique: true
    t.index ["category"], name: "index_bids_on_category"
    t.index ["deadline_date"], name: "index_bids_on_deadline_date"
    t.index ["publish_date"], name: "index_bids_on_publish_date"
    t.index ["status"], name: "index_bids_on_status"
    t.index ["type_of_bid"], name: "index_bids_on_type_of_bid"
  end

  create_table "districts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "address"
    t.text "map_embed"
    t.jsonb "phone_numbers", default: []
    t.jsonb "emails", default: []
    t.jsonb "social_media_links", default: []
    t.text "district_overview"
    t.text "detail_description"
    t.boolean "is_published", default: false
    t.string "meta_title"
    t.text "meta_description"
    t.jsonb "meta_keywords", default: []
    t.string "published_by"
    t.string "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["is_published"], name: "index_districts_on_is_published"
    t.index ["name"], name: "index_districts_on_name", unique: true
  end

  create_table "events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.text "excerpt"
    t.string "location"
    t.datetime "start_date", null: false
    t.datetime "end_date", null: false
    t.string "time"
    t.string "event_type", null: false
    t.text "agenda", default: [], array: true
    t.text "speakers", default: [], array: true
    t.integer "capacity"
    t.boolean "registration_required", default: true
    t.string "status", default: "upcoming"
    t.boolean "is_featured", default: false
    t.boolean "is_published", default: true
    t.string "slug", null: false
    t.string "meta_title"
    t.text "meta_description"
    t.string "meta_keywords"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_type"], name: "index_events_on_event_type"
    t.index ["is_featured"], name: "index_events_on_is_featured"
    t.index ["is_published"], name: "index_events_on_is_published"
    t.index ["slug"], name: "index_events_on_slug", unique: true
    t.index ["start_date"], name: "index_events_on_start_date"
    t.index ["status"], name: "index_events_on_status"
  end

  create_table "news", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.text "content", null: false
    t.text "excerpt"
    t.date "published_date"
    t.boolean "is_published", default: false
    t.string "slug", null: false
    t.string "category"
    t.string "tags", default: [], array: true
    t.boolean "is_featured", default: false
    t.integer "view_count", default: 0
    t.string "author"
    t.string "meta_title"
    t.text "meta_description"
    t.string "meta_keywords", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_news_on_category"
    t.index ["is_featured"], name: "index_news_on_is_featured"
    t.index ["is_published"], name: "index_news_on_is_published"
    t.index ["published_date"], name: "index_news_on_published_date"
    t.index ["slug"], name: "index_news_on_slug", unique: true
  end

  create_table "projects", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.string "status"
    t.string "location"
    t.decimal "budget"
    t.date "start_date"
    t.date "end_date"
    t.string "contractor"
    t.string "project_manager"
    t.text "objectives"
    t.text "scope"
    t.jsonb "milestones", default: []
    t.jsonb "challenges", default: []
    t.boolean "is_published", default: true
    t.string "meta_title"
    t.text "meta_description"
    t.string "meta_keywords"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location"], name: "index_projects_on_location"
    t.index ["status"], name: "index_projects_on_status"
    t.index ["title"], name: "index_projects_on_title"
  end

  create_table "publications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.string "category", null: false
    t.integer "year", null: false
    t.datetime "publish_date", null: false
    t.jsonb "authors", default: []
    t.text "description"
    t.integer "download_count", default: 0
    t.boolean "is_new", default: true
    t.string "meta_title"
    t.text "meta_description"
    t.string "citation_information"
    t.jsonb "meta_keywords", default: []
    t.string "status", default: "draft"
    t.string "published_by"
    t.string "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_publications_on_category"
    t.index ["publish_date"], name: "index_publications_on_publish_date"
    t.index ["status"], name: "index_publications_on_status"
    t.index ["year"], name: "index_publications_on_year"
  end

  create_table "taggings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "tag_id"
    t.string "taggable_type"
    t.uuid "taggable_id"
    t.string "tagger_type"
    t.uuid "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.string "tenant", limit: 128
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
    t.index ["tagger_type", "tagger_id"], name: "index_taggings_on_tagger"
    t.index ["tenant"], name: "index_taggings_on_tenant"
  end

  create_table "tags", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "vacancies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.string "department", null: false
    t.string "location", null: false
    t.string "job_type", null: false
    t.date "deadline", null: false
    t.date "posted_date", null: false
    t.text "description", null: false
    t.jsonb "requirements", default: []
    t.jsonb "responsibilities", default: []
    t.string "salary", null: false
    t.jsonb "benefits", default: []
    t.boolean "is_published", default: true
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deadline"], name: "index_vacancies_on_deadline"
    t.index ["department"], name: "index_vacancies_on_department"
    t.index ["is_published"], name: "index_vacancies_on_is_published"
    t.index ["job_type"], name: "index_vacancies_on_job_type"
    t.index ["location"], name: "index_vacancies_on_location"
    t.index ["title"], name: "index_vacancies_on_title"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "applicants", "vacancies", on_delete: :cascade
  add_foreign_key "taggings", "tags"
end
