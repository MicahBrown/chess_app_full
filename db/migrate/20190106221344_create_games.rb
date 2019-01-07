class CreateGames < ActiveRecord::Migration[5.2]
  def change
    create_table :games do |t|
      t.belongs_to :black_opponent, foreign_key: {to_table: :users}
      t.belongs_to :white_opponent, foreign_key: {to_table: :users}
      t.text :moves
      t.boolean :white_turn, default: true, null: false
      t.timestamps null: false
    end
  end
end
