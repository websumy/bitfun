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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130906075059) do

  create_table "funs", :force => true do |t|
    t.integer  "user_id"
    t.integer  "parent_id"
    t.integer  "owner_id"
    t.integer  "content_id"
    t.string   "content_type"
    t.integer  "repost_counter",     :default => 0
    t.integer  "cached_votes_total", :default => 0
    t.datetime "published_at"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.integer  "comments_counter",   :default => 0
  end

  add_index "funs", ["cached_votes_total"], :name => "index_funs_on_cached_votes_total"
  add_index "funs", ["comments_counter"], :name => "index_funs_on_comments_counter"
  add_index "funs", ["repost_counter"], :name => "index_funs_on_repost_counter"
  add_index "funs", ["user_id"], :name => "index_funs_on_user_id"

  create_table "identities", :force => true do |t|
    t.string  "uid"
    t.string  "provider"
    t.integer "user_id"
  end

  add_index "identities", ["user_id"], :name => "index_identities_on_user_id"

  create_table "images", :force => true do |t|
    t.string "title"
    t.string "file"
    t.string "url"
    t.string "cached_tag_list"
  end

  create_table "posts", :force => true do |t|
    t.string "title"
    t.text   "body"
    t.string "cached_tag_list"
  end

  create_table "reports", :force => true do |t|
    t.text     "abuse"
    t.integer  "fun_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "settings", :force => true do |t|
    t.text    "info"
    t.string  "location"
    t.string  "site"
    t.string  "vk_link"
    t.string  "fb_link"
    t.string  "tw_link"
    t.integer "sex"
    t.date    "birthday"
    t.integer "user_id"
  end

  create_table "stats", :force => true do |t|
    t.integer "user_id"
    t.integer "day_votes",       :default => 0
    t.integer "week_votes",      :default => 0
    t.integer "month_votes",     :default => 0
    t.integer "all_votes",       :default => 0
    t.integer "day_funs",        :default => 0
    t.integer "week_funs",       :default => 0
    t.integer "month_funs",      :default => 0
    t.integer "all_funs",        :default => 0
    t.integer "day_reposts",     :default => 0
    t.integer "week_reposts",    :default => 0
    t.integer "month_reposts",   :default => 0
    t.integer "all_reposts",     :default => 0
    t.integer "day_followers",   :default => 0
    t.integer "week_followers",  :default => 0
    t.integer "month_followers", :default => 0
    t.integer "all_followers",   :default => 0
  end

  add_index "stats", ["all_followers"], :name => "index_stats_on_all_followers"
  add_index "stats", ["all_funs"], :name => "index_stats_on_all_funs"
  add_index "stats", ["all_reposts"], :name => "index_stats_on_all_reposts"
  add_index "stats", ["all_votes"], :name => "index_stats_on_all_votes"
  add_index "stats", ["day_followers"], :name => "index_stats_on_day_followers"
  add_index "stats", ["day_funs"], :name => "index_stats_on_day_funs"
  add_index "stats", ["day_reposts"], :name => "index_stats_on_day_reposts"
  add_index "stats", ["day_votes"], :name => "index_stats_on_day_votes"
  add_index "stats", ["month_followers"], :name => "index_stats_on_month_followers"
  add_index "stats", ["month_funs"], :name => "index_stats_on_month_funs"
  add_index "stats", ["month_reposts"], :name => "index_stats_on_month_reposts"
  add_index "stats", ["month_votes"], :name => "index_stats_on_month_votes"
  add_index "stats", ["week_followers"], :name => "index_stats_on_week_followers"
  add_index "stats", ["week_funs"], :name => "index_stats_on_week_funs"
  add_index "stats", ["week_reposts"], :name => "index_stats_on_week_reposts"
  add_index "stats", ["week_votes"], :name => "index_stats_on_week_votes"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "user_relationships", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "user_relationships", ["followed_id"], :name => "index_user_relationships_on_followed_id"
  add_index "user_relationships", ["follower_id", "followed_id"], :name => "index_user_relationships_on_follower_id_and_followed_id", :unique => true
  add_index "user_relationships", ["follower_id"], :name => "index_user_relationships_on_follower_id"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "login",                  :default => "", :null => false
    t.string   "avatar",                 :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "role_id"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.datetime "last_response_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["login"], :name => "index_users_on_login", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "videos", :force => true do |t|
    t.string "title"
    t.string "video_id",        :limit => 20
    t.string "video_type",      :limit => 20
    t.string "url"
    t.string "image"
    t.string "cached_tag_list"
  end

  create_table "votes", :force => true do |t|
    t.integer  "votable_id"
    t.string   "votable_type"
    t.integer  "voter_id"
    t.string   "voter_type"
    t.boolean  "vote_flag"
    t.string   "vote_scope"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "votes", ["votable_id", "votable_type", "vote_scope"], :name => "index_votes_on_votable_id_and_votable_type_and_vote_scope"
  add_index "votes", ["votable_id", "votable_type"], :name => "index_votes_on_votable_id_and_votable_type"
  add_index "votes", ["voter_id", "voter_type", "vote_scope"], :name => "index_votes_on_voter_id_and_voter_type_and_vote_scope"
  add_index "votes", ["voter_id", "voter_type"], :name => "index_votes_on_voter_id_and_voter_type"

end
