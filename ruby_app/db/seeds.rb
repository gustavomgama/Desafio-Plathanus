if Rails.env.development?
  Photo.delete_all
  Property.delete_all
end

SAMPLE_PHOTOS = [
  'exterior_front.jpg', 'living_room.jpg', 'kitchen.jpg', 'master_bedroom.jpg',
  'bathroom.jpg', 'backyard.jpg', 'garage.jpg', 'dining_room.jpg',
  'guest_bedroom.jpg', 'office.jpg', 'basement.jpg', 'pool.jpg'
].freeze

CONTENT_TYPES = %w[image/jpeg image/png].freeze

puts "Creating 50 properties with photos..."

50.times do |i|
  property = Property.create!(
    name: "#{['Luxury', 'Modern', 'Charming', 'Spacious', 'Cozy', 'Elegant'].sample} #{['Villa', 'House', 'Apartment', 'Condo', 'Townhouse'].sample} #{i + 1}"
  )

  photo_count = rand(3..5)
  selected_photos = SAMPLE_PHOTOS.sample(photo_count)

  selected_photos.each_with_index do |filename, index|
    Photo.create!(
      property: property,
      filename: "#{property.id}_#{filename}",
      position: index + 1,
      content_type: CONTENT_TYPES.sample,
      file_size: rand(500_000..5_000_000) # 500KB to 5MB
    )
  end

  print "." if (i + 1) % 10 == 0
end

puts "\nCreated #{Property.count} properties with #{Photo.count} photos"
puts "Sample cover photos:"

Property.limit(5).includes(:photos).each do |property|
  cover = property.cover_photo
  puts "- #{property.name}: #{cover&.filename || 'No photos'} (#{property.photos.count} photos)"
end
