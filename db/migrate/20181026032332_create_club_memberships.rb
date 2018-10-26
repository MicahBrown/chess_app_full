class CreateClubMemberships < ActiveRecord::Migration[5.2]
  def change
    create_table :club_memberships do |t|
      t.belongs_to :club, null: false, foreign_key: true
      t.belongs_to :user, null: false, foreign_key: true
      t.integer :role, default: 0, null: false
      t.timestamps null: false
      t.index [:user_id, :club_id], unique: true
    end
  end
end
