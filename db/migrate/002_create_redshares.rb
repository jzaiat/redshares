class CreateRedshares < ActiveRecord::Migration
  def up
    create_table :redshares do |t|
      t.references :issue, :null => false
      t.references :user, :null => false
      t.boolean :editable, :default => false
    end
    add_index(:redshares, [:issue_id, :user_id], :unique => true)
    #add foreign keys
    execute <<-SQL
      ALTER TABLE redshares
        ADD CONSTRAINT fk_redshares_issues
        FOREIGN KEY (issue_id)
        REFERENCES issues(id)
    SQL
    execute <<-SQL
      ALTER TABLE redshares
        ADD CONSTRAINT fk_redshares_users
        FOREIGN KEY (user_id)
        REFERENCES users(id)
    SQL
  end

  def down
    #remove the foreign keys
    execute <<-SQL
      ALTER TABLE redshares
        DROP FOREIGN KEY fk_redshares_issues
    SQL
    execute <<-SQL
      ALTER TABLE redshares
        DROP FOREIGN KEY fk_redshares_users
    SQL
    remove_index :redshares, :column => [:issue_id, :user_id]
    drop_table :redshares
  end
end