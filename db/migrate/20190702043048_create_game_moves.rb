class CreateGameMoves < ActiveRecord::Migration[5.2]
  def change
    create_table :game_moves do |t|
      t.belongs :game, null: false, foreign_key: true
      t.integer :team, null: false
      t.timestamps null: false
    end
  end
end
