# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141006152553) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "btree_gist"

  create_table "acls", force: true do |t|
    t.inet   "address"
    t.string "k",       null: false
    t.string "v"
    t.string "domain"
  end

  add_index "acls", ["k"], name: "acls_k_idx", using: :btree

  create_table "changeset_tags", id: false, force: true do |t|
    t.integer "changeset_id", limit: 8,              null: false
    t.string  "k",                      default: "", null: false
    t.string  "v",                      default: "", null: false
  end

  add_index "changeset_tags", ["changeset_id"], name: "changeset_tags_id_idx", using: :btree

  create_table "changesets", force: true do |t|
    t.integer  "user_id",     limit: 8,             null: false
    t.datetime "created_at",                        null: false
    t.integer  "min_lat"
    t.integer  "max_lat"
    t.integer  "min_lon"
    t.integer  "max_lon"
    t.datetime "closed_at",                         null: false
    t.integer  "num_changes",           default: 0, null: false
  end

  add_index "changesets", ["closed_at"], name: "changesets_closed_at_idx", using: :btree
  add_index "changesets", ["created_at"], name: "changesets_created_at_idx", using: :btree
  add_index "changesets", ["min_lat", "max_lat", "min_lon", "max_lon"], name: "changesets_bbox_idx", using: :gist
  add_index "changesets", ["user_id", "created_at"], name: "changesets_user_id_created_at_idx", using: :btree
  add_index "changesets", ["user_id", "id"], name: "changesets_user_id_id_idx", using: :btree

  create_table "client_applications", force: true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "support_url"
    t.string   "callback_url"
    t.string   "key",               limit: 50
    t.string   "secret",            limit: 50
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "allow_read_prefs",             default: false, null: false
    t.boolean  "allow_write_prefs",            default: false, null: false
    t.boolean  "allow_write_diary",            default: false, null: false
    t.boolean  "allow_write_api",              default: false, null: false
    t.boolean  "allow_read_gpx",               default: false, null: false
    t.boolean  "allow_write_gpx",              default: false, null: false
    t.boolean  "allow_write_notes",            default: false, null: false
  end

  add_index "client_applications", ["key"], name: "index_client_applications_on_key", unique: true, using: :btree

  create_table "current_node_tags", id: false, force: true do |t|
    t.integer "node_id", limit: 8,              null: false
    t.string  "k",                 default: "", null: false
    t.string  "v",                 default: "", null: false
  end

  create_table "current_nodes", force: true do |t|
    t.integer  "latitude",               null: false
    t.integer  "longitude",              null: false
    t.integer  "changeset_id", limit: 8, null: false
    t.boolean  "visible",                null: false
    t.datetime "timestamp",              null: false
    t.integer  "tile",         limit: 8, null: false
    t.integer  "version",      limit: 8, null: false
  end

  add_index "current_nodes", ["tile"], name: "current_nodes_tile_idx", using: :btree
  add_index "current_nodes", ["timestamp"], name: "current_nodes_timestamp_idx", using: :btree

  create_table "current_relation_members", id: false, force: true do |t|
    t.integer "relation_id", limit: 8,               null: false
    t.string  "member_type", limit: nil,             null: false
    t.integer "member_id",   limit: 8,               null: false
    t.string  "member_role",                         null: false
    t.integer "sequence_id",             default: 0, null: false
  end

  add_index "current_relation_members", ["member_type", "member_id"], name: "current_relation_members_member_idx", using: :btree

  create_table "current_relation_tags", id: false, force: true do |t|
    t.integer "relation_id", limit: 8,              null: false
    t.string  "k",                     default: "", null: false
    t.string  "v",                     default: "", null: false
  end

  create_table "current_relations", force: true do |t|
    t.integer  "changeset_id", limit: 8, null: false
    t.datetime "timestamp",              null: false
    t.boolean  "visible",                null: false
    t.integer  "version",      limit: 8, null: false
  end

  add_index "current_relations", ["timestamp"], name: "current_relations_timestamp_idx", using: :btree

  create_table "current_way_nodes", id: false, force: true do |t|
    t.integer "way_id",      limit: 8, null: false
    t.integer "node_id",     limit: 8, null: false
    t.integer "sequence_id", limit: 8, null: false
  end

  add_index "current_way_nodes", ["node_id"], name: "current_way_nodes_node_idx", using: :btree

  create_table "current_way_tags", id: false, force: true do |t|
    t.integer "way_id", limit: 8,              null: false
    t.string  "k",                default: "", null: false
    t.string  "v",                default: "", null: false
  end

  create_table "current_ways", force: true do |t|
    t.integer  "changeset_id", limit: 8, null: false
    t.datetime "timestamp",              null: false
    t.boolean  "visible",                null: false
    t.integer  "version",      limit: 8, null: false
  end

  add_index "current_ways", ["timestamp"], name: "current_ways_timestamp_idx", using: :btree

  create_table "diary_comments", force: true do |t|
    t.integer  "diary_entry_id", limit: 8,                  null: false
    t.integer  "user_id",        limit: 8,                  null: false
    t.text     "body",                                      null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.boolean  "visible",                    default: true, null: false
    t.string   "body_format",    limit: nil,                null: false
  end

  add_index "diary_comments", ["diary_entry_id", "id"], name: "diary_comments_entry_id_idx", unique: true, using: :btree
  add_index "diary_comments", ["user_id", "created_at"], name: "diary_comment_user_id_created_at_index", using: :btree

  create_table "diary_entries", force: true do |t|
    t.integer  "user_id",       limit: 8,                  null: false
    t.string   "title",                                    null: false
    t.text     "body",                                     null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.float    "latitude"
    t.float    "longitude"
    t.string   "language_code",             default: "en", null: false
    t.boolean  "visible",                   default: true, null: false
    t.string   "body_format",   limit: nil,                null: false
    t.integer  "group_id"
  end

  add_index "diary_entries", ["created_at"], name: "diary_entry_created_at_index", using: :btree
  add_index "diary_entries", ["group_id"], name: "diary_entries_group_id_idx", using: :btree
  add_index "diary_entries", ["language_code", "created_at"], name: "diary_entry_language_code_created_at_index", using: :btree
  add_index "diary_entries", ["user_id", "created_at"], name: "diary_entry_user_id_created_at_index", using: :btree

  create_table "fields", force: true do |t|
    t.text     "json"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "type"
    t.string   "key"
    t.string   "label"
    t.integer  "preset_id"
  end

  add_index "fields", ["preset_id"], name: "index_fields_on_preset_id", using: :btree

  create_table "friends", force: true do |t|
    t.integer "user_id",        limit: 8, null: false
    t.integer "friend_user_id", limit: 8, null: false
  end

  add_index "friends", ["friend_user_id"], name: "user_id_idx", using: :btree
  add_index "friends", ["user_id"], name: "friends_user_id_idx", using: :btree

  create_table "gps_points", id: false, force: true do |t|
    t.float    "altitude"
    t.integer  "trackid",             null: false
    t.integer  "latitude",            null: false
    t.integer  "longitude",           null: false
    t.integer  "gpx_id",    limit: 8, null: false
    t.datetime "timestamp"
    t.integer  "tile",      limit: 8
  end

  add_index "gps_points", ["gpx_id"], name: "points_gpxid_idx", using: :btree
  add_index "gps_points", ["tile"], name: "points_tile_idx", using: :btree

  create_table "gpx_file_tags", force: true do |t|
    t.integer "gpx_id", limit: 8, default: 0, null: false
    t.string  "tag",                          null: false
  end

  add_index "gpx_file_tags", ["gpx_id"], name: "gpx_file_tags_gpxid_idx", using: :btree
  add_index "gpx_file_tags", ["tag"], name: "gpx_file_tags_tag_idx", using: :btree

  create_table "gpx_files", force: true do |t|
    t.integer  "user_id",     limit: 8,                  null: false
    t.boolean  "visible",                 default: true, null: false
    t.string   "name",                    default: "",   null: false
    t.integer  "size",        limit: 8
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "timestamp",                              null: false
    t.string   "description",             default: "",   null: false
    t.boolean  "inserted",                               null: false
    t.string   "visibility",  limit: nil,                null: false
  end

  add_index "gpx_files", ["timestamp"], name: "gpx_files_timestamp_idx", using: :btree
  add_index "gpx_files", ["user_id"], name: "gpx_files_user_id_idx", using: :btree
  add_index "gpx_files", ["visible", "visibility"], name: "gpx_files_visible_visibility_idx", using: :btree

  create_table "group_memberships", force: true do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "invite_token"
    t.datetime "invite_accepted_at"
    t.string   "status"
  end

  add_index "group_memberships", ["group_id", "user_id"], name: "index_group_memberships_on_group_id_and_user_id", unique: true, using: :btree
  add_index "group_memberships", ["group_id"], name: "index_group_memberships_on_group_id", using: :btree
  add_index "group_memberships", ["user_id"], name: "index_group_memberships_on_user_id", using: :btree

  create_table "groups", force: true do |t|
    t.string  "title"
    t.text    "description"
    t.text    "description_format"
    t.integer "story_id"
    t.float   "lon"
    t.float   "lat"
  end

  add_index "groups", ["story_id"], name: "index_groups_on_story_id", using: :btree

  create_table "languages", id: false, force: true do |t|
    t.string "code",         null: false
    t.string "english_name", null: false
    t.string "native_name"
  end

  create_table "messages", force: true do |t|
    t.integer  "from_user_id",      limit: 8,                   null: false
    t.string   "title",                                         null: false
    t.text     "body",                                          null: false
    t.datetime "sent_on",                                       null: false
    t.boolean  "message_read",                  default: false, null: false
    t.integer  "to_user_id",        limit: 8,                   null: false
    t.boolean  "to_user_visible",               default: true,  null: false
    t.boolean  "from_user_visible",             default: true,  null: false
    t.string   "body_format",       limit: nil,                 null: false
  end

  add_index "messages", ["from_user_id"], name: "messages_from_user_id_idx", using: :btree
  add_index "messages", ["to_user_id"], name: "messages_to_user_id_idx", using: :btree

  create_table "node_tags", id: false, force: true do |t|
    t.integer "node_id", limit: 8,              null: false
    t.integer "version", limit: 8,              null: false
    t.string  "k",                 default: "", null: false
    t.string  "v",                 default: "", null: false
  end

  create_table "nodes", id: false, force: true do |t|
    t.integer  "node_id",      limit: 8, null: false
    t.integer  "latitude",               null: false
    t.integer  "longitude",              null: false
    t.integer  "changeset_id", limit: 8, null: false
    t.boolean  "visible",                null: false
    t.datetime "timestamp",              null: false
    t.integer  "tile",         limit: 8, null: false
    t.integer  "version",      limit: 8, null: false
    t.integer  "redaction_id"
  end

  add_index "nodes", ["changeset_id"], name: "nodes_changeset_id_idx", using: :btree
  add_index "nodes", ["tile"], name: "nodes_tile_idx", using: :btree
  add_index "nodes", ["timestamp"], name: "nodes_timestamp_idx", using: :btree

  create_table "note_comments", force: true do |t|
    t.integer  "note_id",    limit: 8,   null: false
    t.boolean  "visible",                null: false
    t.datetime "created_at",             null: false
    t.inet     "author_ip"
    t.integer  "author_id",  limit: 8
    t.text     "body"
    t.string   "event",      limit: nil
  end

  add_index "note_comments", ["created_at"], name: "index_note_comments_on_created_at", using: :btree
  add_index "note_comments", ["note_id"], name: "note_comments_note_id_idx", using: :btree

  create_table "notes", force: true do |t|
    t.integer  "latitude",               null: false
    t.integer  "longitude",              null: false
    t.integer  "tile",       limit: 8,   null: false
    t.datetime "updated_at",             null: false
    t.datetime "created_at",             null: false
    t.string   "status",     limit: nil, null: false
    t.datetime "closed_at"
  end

  add_index "notes", ["created_at"], name: "notes_created_at_idx", using: :btree
  add_index "notes", ["tile", "status"], name: "notes_tile_status_idx", using: :btree
  add_index "notes", ["updated_at"], name: "notes_updated_at_idx", using: :btree

  create_table "oauth_nonces", force: true do |t|
    t.string   "nonce"
    t.integer  "timestamp"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_nonces", ["nonce", "timestamp"], name: "index_oauth_nonces_on_nonce_and_timestamp", unique: true, using: :btree

  create_table "oauth_tokens", force: true do |t|
    t.integer  "user_id"
    t.string   "type",                  limit: 20
    t.integer  "client_application_id"
    t.string   "token",                 limit: 50
    t.string   "secret",                limit: 50
    t.datetime "authorized_at"
    t.datetime "invalidated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "allow_read_prefs",                 default: false, null: false
    t.boolean  "allow_write_prefs",                default: false, null: false
    t.boolean  "allow_write_diary",                default: false, null: false
    t.boolean  "allow_write_api",                  default: false, null: false
    t.boolean  "allow_read_gpx",                   default: false, null: false
    t.boolean  "allow_write_gpx",                  default: false, null: false
    t.string   "callback_url"
    t.string   "verifier",              limit: 20
    t.string   "scope"
    t.datetime "valid_to"
    t.boolean  "allow_write_notes",                default: false, null: false
  end

  add_index "oauth_tokens", ["token"], name: "index_oauth_tokens_on_token", unique: true, using: :btree

  create_table "presets", force: true do |t|
    t.text     "json"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "group_id"
    t.text     "geometry"
    t.string   "name"
    t.text     "tags"
  end

  add_index "presets", ["group_id"], name: "index_presets_on_group_id", using: :btree

  create_table "redactions", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",            limit: 8,   null: false
    t.string   "description_format", limit: nil, null: false
  end

  create_table "relation_members", id: false, force: true do |t|
    t.integer "relation_id", limit: 8,   default: 0, null: false
    t.string  "member_type", limit: nil,             null: false
    t.integer "member_id",   limit: 8,               null: false
    t.string  "member_role",                         null: false
    t.integer "version",     limit: 8,   default: 0, null: false
    t.integer "sequence_id",             default: 0, null: false
  end

  add_index "relation_members", ["member_type", "member_id"], name: "relation_members_member_idx", using: :btree

  create_table "relation_tags", id: false, force: true do |t|
    t.integer "relation_id", limit: 8, default: 0,  null: false
    t.string  "k",                     default: "", null: false
    t.string  "v",                     default: "", null: false
    t.integer "version",     limit: 8,              null: false
  end

  create_table "relations", id: false, force: true do |t|
    t.integer  "relation_id",  limit: 8, default: 0,    null: false
    t.integer  "changeset_id", limit: 8,                null: false
    t.datetime "timestamp",                             null: false
    t.integer  "version",      limit: 8,                null: false
    t.boolean  "visible",                default: true, null: false
    t.integer  "redaction_id"
  end

  add_index "relations", ["changeset_id"], name: "relations_changeset_id_idx", using: :btree
  add_index "relations", ["timestamp"], name: "relations_timestamp_idx", using: :btree

  create_table "stories", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "zoom"
    t.text     "layers"
    t.text     "body"
    t.string   "filename"
    t.string   "layout"
    t.string   "language"
    t.string   "image_url"
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "author"
    t.boolean  "draft"
  end

  create_table "story_attachments", force: true do |t|
    t.text     "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.string   "image_fingerprint"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "tiles", force: true do |t|
    t.string "code"
    t.string "keyid"
    t.string "name"
    t.string "attribution"
    t.string "url"
    t.string "subdomains"
    t.string "base_layer"
    t.text   "description"
  end

  create_table "user_blocks", force: true do |t|
    t.integer  "user_id",       limit: 8,                   null: false
    t.integer  "creator_id",    limit: 8,                   null: false
    t.text     "reason",                                    null: false
    t.datetime "ends_at",                                   null: false
    t.boolean  "needs_view",                default: false, null: false
    t.integer  "revoker_id",    limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reason_format", limit: nil,                 null: false
  end

  add_index "user_blocks", ["user_id"], name: "index_user_blocks_on_user_id", using: :btree

  create_table "user_preferences", id: false, force: true do |t|
    t.integer "user_id", limit: 8, null: false
    t.string  "k",                 null: false
    t.string  "v",                 null: false
  end

  create_table "user_roles", force: true do |t|
    t.integer  "user_id",    limit: 8,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role",       limit: nil, null: false
    t.integer  "granter_id", limit: 8,   null: false
  end

  add_index "user_roles", ["user_id", "role"], name: "user_roles_id_role_unique", unique: true, using: :btree

  create_table "user_tokens", force: true do |t|
    t.integer  "user_id", limit: 8, null: false
    t.string   "token",             null: false
    t.datetime "expiry",            null: false
    t.text     "referer"
  end

  add_index "user_tokens", ["token"], name: "user_tokens_token_idx", unique: true, using: :btree
  add_index "user_tokens", ["user_id"], name: "user_tokens_user_id_idx", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                                           null: false
    t.string   "pass_crypt",                                      null: false
    t.datetime "creation_time",                                   null: false
    t.string   "display_name",                    default: "",    null: false
    t.boolean  "data_public",                     default: false, null: false
    t.text     "description",                     default: "",    null: false
    t.float    "home_lat"
    t.float    "home_lon"
    t.integer  "home_zoom",           limit: 2,   default: 3
    t.integer  "nearby",                          default: 50
    t.string   "pass_salt"
    t.text     "image_file_name"
    t.boolean  "email_valid",                     default: false, null: false
    t.string   "new_email"
    t.string   "creation_ip"
    t.string   "languages"
    t.string   "status",              limit: nil,                 null: false
    t.datetime "terms_agreed"
    t.boolean  "consider_pd",                     default: false, null: false
    t.string   "openid_url"
    t.string   "preferred_editor"
    t.boolean  "terms_seen",                      default: false, null: false
    t.string   "description_format",  limit: nil,                 null: false
    t.string   "image_fingerprint"
    t.integer  "changesets_count",                default: 0,     null: false
    t.integer  "traces_count",                    default: 0,     null: false
    t.integer  "diary_entries_count",             default: 0,     null: false
    t.boolean  "image_use_gravatar",              default: true,  null: false
    t.integer  "story_id"
    t.string   "image_content_type"
  end

  add_index "users", ["display_name"], name: "users_display_name_idx", unique: true, using: :btree
  add_index "users", ["email"], name: "users_email_idx", unique: true, using: :btree
  add_index "users", ["openid_url"], name: "user_openid_url_idx", unique: true, using: :btree
  add_index "users", ["story_id"], name: "index_users_on_story_id", using: :btree

  create_table "way_nodes", id: false, force: true do |t|
    t.integer "way_id",      limit: 8, null: false
    t.integer "node_id",     limit: 8, null: false
    t.integer "version",     limit: 8, null: false
    t.integer "sequence_id", limit: 8, null: false
  end

  add_index "way_nodes", ["node_id"], name: "way_nodes_node_idx", using: :btree

  create_table "way_tags", id: false, force: true do |t|
    t.integer "way_id",  limit: 8, default: 0, null: false
    t.string  "k",                             null: false
    t.string  "v",                             null: false
    t.integer "version", limit: 8,             null: false
  end

  create_table "ways", id: false, force: true do |t|
    t.integer  "way_id",       limit: 8, default: 0,    null: false
    t.integer  "changeset_id", limit: 8,                null: false
    t.datetime "timestamp",                             null: false
    t.integer  "version",      limit: 8,                null: false
    t.boolean  "visible",                default: true, null: false
    t.integer  "redaction_id"
  end

  add_index "ways", ["changeset_id"], name: "ways_changeset_id_idx", using: :btree
  add_index "ways", ["timestamp"], name: "ways_timestamp_idx", using: :btree

end
