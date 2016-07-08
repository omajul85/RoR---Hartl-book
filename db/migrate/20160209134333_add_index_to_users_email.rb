class AddIndexToUsersEmail < ActiveRecord::Migration
  def change
  	add_index :users, :email, unique: true
  	# we put an index on the email because we expect to retrieve users by searching the email
  end
end
