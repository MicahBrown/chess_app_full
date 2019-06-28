class CreatePieces < ActiveRecord::Migration[5.2]
  def change
    create_table :pieces do |t|
      t.belongs_to :game, null: false, foreign_key: true
      t.string :type, null: false
      t.integer :color, null: false
      t.string :position, null: false
      t.text :moves
      t.timestamps null: false
    end
  end
end
