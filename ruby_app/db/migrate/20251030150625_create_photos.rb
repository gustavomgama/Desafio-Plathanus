class CreatePhotos < ActiveRecord::Migration[8.0]
  def change
    create_table :photos do |t|
      t.references :property, null: false, foreign_key: true
      t.string :filename
      t.integer :position
      t.string :content_type
      t.integer :file_size

      t.timestamps

      t.index [ :property_id, :position ], unique: true
    end
  end
end
