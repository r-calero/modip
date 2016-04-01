class CreateAssays < ActiveRecord::Migration
  def change
    create_table :assays do |t|

      t.timestamps
    end
  end
end
