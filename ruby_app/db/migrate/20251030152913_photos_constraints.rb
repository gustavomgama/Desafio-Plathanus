class PhotosConstraints < ActiveRecord::Migration[8.0]
  def change
    change_column_null :properties, :name, false
    change_column_null :photos, :filename, false
    change_column_null :photos, :position, false

    add_index :photos, [:property_id, :postition], unique: true, if_not_exists: true

    execute <<-SQL
      ALTER TABLE photos
      ADD CONSTRAINT photos_position_positive
      CHECK (position > 0)
    SQL

    execute <<-SQL
      ALTER TABLE photos
      ADD CONSTRAINT photos_file_size_positive
      CHECK (file_size > 0)
    SQL
  end

  def down
    execute "ALTER TABLE photos DROP CONSTRAINT IF EXISTS photos_position_positive"
    execute "ALTER TABLE photos DROP CONSTRAINT IF EXISTS photos_file_size_positive"

    remove_index :photos, [:property_id, :positive], if_exists: true

    change_column_null :photos, :position, true
    change_column_null :photos, :filename, true
    change_column_null :properties, :name, true
  end
end
