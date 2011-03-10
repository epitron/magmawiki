class RemoveRevisionIdFromWikisession < ActiveRecord::Migration
  def self.up
    change_table :wiki_sessions do |t|
      t.remove :revision_id
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration, "Can't recover dropped data."
  end
end
