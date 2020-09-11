# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :email
      t.string :password
      t.string :provider
      t.string :uid
      t.string :name
      t.string :access_token
      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
  end
end
