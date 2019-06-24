class CreatePieces < ActiveRecord::Migration[5.2]
  def change
    create_table :pieces do |t|
      t.belongs_to :game, null: false, foreign_key: true
      t.integer :color, null: false
      t.integer :piece_type, null: false
      t.string :piece_position, null: false
      t.timestamps null: false
    end
  end
end
