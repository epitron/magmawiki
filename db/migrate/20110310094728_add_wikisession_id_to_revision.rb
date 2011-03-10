class AddWikisessionIdToRevision < ActiveRecord::Migration
  def self.up
    change_table :revisions do |t|
      t.references :wikisession
    end
  end

  def self.down
    change_table :revisions do |t|
      t.remove :wikisession_id
    end
  end
end
