class RenameWikisessionId < ActiveRecord::Migration
  def self.up
    change_table :revisions do |t|
      t.rename :wikisession_id, :wiki_session_id
    end
  end

  def self.down
    change_table :revisions do |t|
      t.rename :wiki_session_id, :wikisession_id
    end
  end
end
