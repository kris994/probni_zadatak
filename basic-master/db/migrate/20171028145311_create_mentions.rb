class CreateMentions < ActiveRecord::Migration
  def change
    create_table :mentions do |t|
      t.integer :user_id

      t.timestamps null: false
    end

    add_index :mentions, [:user_id, :created_at]
  end
end
