class CreateClubs < ActiveRecord::Migration[5.2]
  def change
    create_table :clubs do |t|
      t.belongs_to :creator, null: false, foreign_key: {to_table: :users}
      t.string :uid, null: false, index: {unique: true}
      t.string :name, null: false
      t.timestamps null: false
    end
  end
end
