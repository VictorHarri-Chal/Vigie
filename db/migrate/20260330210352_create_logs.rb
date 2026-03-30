class CreateLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :logs do |t|
      t.string :log_id
      t.string :event_type
      t.datetime :occurred_at
      t.jsonb :payload
      t.datetime :imported_at
      t.references :pav, null: false, foreign_key: true

      t.timestamps
    end

    add_index :logs, :log_id, unique: true
    add_index :logs, :event_type
    add_index :logs, :occurred_at
    add_index :logs, :payload, using: :gin
  end
end
