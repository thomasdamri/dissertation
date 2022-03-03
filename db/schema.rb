# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_03_02_235952) do

  create_table "assessment_results", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "author_id"
    t.bigint "target_id"
    t.bigint "criteria_id"
    t.string "value"
    t.bigint "student_weightings_id"
    t.index ["author_id"], name: "index_assessment_results_on_author_id"
    t.index ["criteria_id"], name: "index_assessment_results_on_criteria_id"
    t.index ["student_weightings_id"], name: "fk_rails_0ec8355172"
    t.index ["target_id"], name: "index_assessment_results_on_target_id"
  end

  create_table "assessments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name"
    t.bigint "uni_module_id"
    t.date "date_opened"
    t.date "date_closed"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "show_results"
    t.index ["uni_module_id"], name: "index_assessments_on_uni_module_id"
  end

  create_table "criteria", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "title"
    t.integer "response_type"
    t.string "min_value"
    t.string "max_value"
    t.bigint "assessment_id"
    t.boolean "assessed"
    t.integer "weighting"
    t.boolean "single"
    t.index ["assessment_id"], name: "index_criteria_on_assessment_id"
  end

  create_table "staff_modules", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "uni_module_id"
    t.index ["uni_module_id"], name: "index_staff_modules_on_uni_module_id"
    t.index ["user_id"], name: "index_staff_modules_on_user_id"
  end

  create_table "student_reports", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "student_team_id"
    t.integer "report_object", null: false, comment: "0 if user, 1 if grade, 2 if task, 3 if team"
    t.bigint "report_object_id", null: false, comment: "depending on report object type, object id will link to correct object"
    t.string "report_reason", null: false
    t.date "report_date", null: false
    t.string "reporter_response"
    t.string "reportee_response"
    t.boolean "complete", default: false
    t.index ["student_team_id"], name: "fk_rails_273f11fcde"
  end

  create_table "student_task_comments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "comment", null: false
    t.date "posted_on"
    t.bigint "user_id"
    t.boolean "deleted"
    t.bigint "student_task_id"
    t.index ["student_task_id"], name: "fk_rails_f69fb66277"
  end

  create_table "student_task_edits", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "student_task_id"
    t.string "edit_reason", null: false
    t.date "previous_target_date", null: false
    t.integer "user_id", null: false
    t.datetime "edit_date", null: false
    t.index ["student_task_id"], name: "fk_rails_15e536b427"
  end

  create_table "student_task_likes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "student_task_id"
    t.index ["student_task_id"], name: "fk_rails_085df01f3e"
  end

  create_table "student_tasks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "student_team_id"
    t.string "task_title"
    t.string "task_objective", null: false
    t.integer "task_difficulty", default: 0, null: false
    t.integer "task_progress", default: 0, null: false
    t.date "task_start_date", default: "2022-02-03"
    t.date "task_target_date", null: false
    t.date "task_complete_date"
    t.boolean "hidden", default: false
    t.index ["student_team_id"], name: "fk_rails_fa29fb9ccd"
  end

  create_table "student_teams", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "team_id"
    t.index ["team_id"], name: "index_student_teams_on_team_id"
    t.index ["user_id"], name: "index_student_teams_on_user_id"
  end

  create_table "student_weightings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "assessment_id"
    t.float "weighting"
    t.integer "results_at_last_check"
    t.boolean "manual_set", default: false
    t.string "reason"
    t.bigint "student_team_id"
    t.index ["assessment_id"], name: "index_student_weightings_on_assessment_id"
    t.index ["student_team_id"], name: "fk_rails_44e9fda95c"
  end

  create_table "team_grades", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "team_id"
    t.bigint "assessment_id"
    t.float "grade"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["assessment_id"], name: "index_team_grades_on_assessment_id"
    t.index ["team_id"], name: "index_team_grades_on_team_id"
  end

  create_table "teams", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "uni_module_id"
    t.integer "team_number"
    t.float "team_grade"
    t.index ["uni_module_id"], name: "index_teams_on_uni_module_id"
  end

  create_table "uni_modules", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "start_date"
    t.date "end_date"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "username"
    t.string "uid"
    t.string "mail"
    t.string "ou"
    t.string "dn"
    t.string "sn"
    t.string "givenname"
    t.string "display_name"
    t.integer "reg_no"
    t.boolean "staff"
    t.boolean "admin"
    t.index ["email"], name: "index_users_on_email"
    t.index ["username"], name: "index_users_on_username"
  end

  create_table "worklog_responses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "worklog_id"
    t.bigint "user_id"
    t.integer "status"
    t.text "reason"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_worklog_responses_on_user_id"
    t.index ["worklog_id"], name: "index_worklog_responses_on_worklog_id"
  end

  create_table "worklogs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "author_id"
    t.date "fill_date"
    t.text "content"
    t.text "override"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "uni_module_id"
    t.index ["author_id"], name: "index_worklogs_on_author_id"
  end

  add_foreign_key "assessment_results", "criteria", column: "criteria_id", on_delete: :cascade
  add_foreign_key "assessment_results", "student_weightings", column: "student_weightings_id", on_delete: :cascade
  add_foreign_key "assessment_results", "users", column: "author_id"
  add_foreign_key "assessment_results", "users", column: "target_id"
  add_foreign_key "assessments", "uni_modules", on_delete: :cascade
  add_foreign_key "criteria", "assessments", on_delete: :cascade
  add_foreign_key "staff_modules", "uni_modules", on_delete: :cascade
  add_foreign_key "staff_modules", "users", on_delete: :cascade
  add_foreign_key "student_reports", "student_teams", on_delete: :cascade
  add_foreign_key "student_task_comments", "student_tasks", on_delete: :cascade
  add_foreign_key "student_task_edits", "student_tasks", on_delete: :cascade
  add_foreign_key "student_task_likes", "student_tasks", on_delete: :cascade
  add_foreign_key "student_tasks", "student_teams", on_delete: :cascade
  add_foreign_key "student_teams", "teams", on_delete: :cascade
  add_foreign_key "student_teams", "users", on_delete: :cascade
  add_foreign_key "student_weightings", "assessments"
  add_foreign_key "student_weightings", "student_teams", on_delete: :cascade
  add_foreign_key "teams", "uni_modules", on_delete: :cascade
  add_foreign_key "worklogs", "users", column: "author_id"
end
