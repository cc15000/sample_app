class PasswordDigest < ActiveRecord::Migration
  def change
   add_column :users, :password_digest, :string
   add_index :users, :password_digest
  end
end
