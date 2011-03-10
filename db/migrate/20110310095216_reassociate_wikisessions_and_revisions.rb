class ReassociateWikisessionsAndRevisions < ActiveRecord::Migration
  def self.up
    WikiSession.all.each do |wikisession|
      revision = Revision.find_by_id(wikisession.revision_id)
      revision.wikisession_id = wikisession.id
      revision.save!
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration, "Can't change many to one relationship back into one to one."
  end
end
