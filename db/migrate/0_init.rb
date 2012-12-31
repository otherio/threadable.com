class Init < ActiveRecord::Migration
  def change

    create_table :users do |t|
      t.text :name
      t.string :slug, null: false
      t.text :email

      ## Database authenticatable
      t.string :encrypted_password, :null => false, :default => ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, :default => 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, :default => 0 # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      ## Token authenticatable
      t.string :authentication_token

      t.timestamps
    end
    add_index :users, :slug, unique: true
    add_index :users, :email,                :unique => true
    add_index :users, :reset_password_token, :unique => true

    create_table :projects do |t|
      t.string :name
      t.string :slug, null: false
      t.text   :description
      t.timestamps
    end
    add_index :projects, :slug, unique: true

    create_table :project_memberships do |t|
      t.integer :project_id
      t.integer :user_id
      t.boolean :can_write, default: true
      t.boolean :gets_email, default: true
      t.boolean :moderator, default: false
      t.timestamps
    end

    create_table :tasks do |t|
      t.string   :name
      t.string   :slug, null: false
      t.boolean  :done
      t.datetime :due_at
      t.integer  :project_id
      t.timestamps
    end
    add_index :tasks, :slug, unique: true

    create_table :task_doers do |t|
      t.integer :user_id
      t.integer :task_id
    end
    add_index :task_doers, [:user_id, :task_id], unique: true

    create_table :task_followers do |t|
      t.integer :user_id
      t.integer :task_id
    end
    add_index :task_followers, [:user_id, :task_id], unique: true

  end
end
