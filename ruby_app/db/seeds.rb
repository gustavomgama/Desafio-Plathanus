# Clear existing data in development
if Rails.env.development?
  Photo.delete_all
  Property.delete_all
  puts "🧹 Cleared existing data"
end

# Enhanced sample photo filenames that look realistic
SAMPLE_PHOTOS = [
  'exterior_front.jpg', 'living_room.jpg', 'kitchen.jpg', 'master_bedroom.jpg',
  'bathroom.jpg', 'backyard.jpg', 'garage.jpg', 'dining_room.jpg',
  'guest_bedroom.jpg', 'office.jpg', 'basement.jpg', 'pool.jpg',
  'balcony.jpg', 'entrance.jpg', 'family_room.jpg', 'walk_in_closet.jpg',
  'powder_room.jpg', 'laundry.jpg', 'terrace.jpg', 'gym.jpg'
].freeze

CONTENT_TYPES = %w[image/jpeg image/png image/webp].freeze

# Property name templates for realistic data
ADJECTIVES = %w[Luxury Modern Charming Spacious Cozy Elegant Contemporary Classic Beautiful Stunning].freeze
PROPERTY_TYPES = %w[Villa House Apartment Condo Townhouse Penthouse Loft Manor Estate].freeze
LOCATIONS = %w[Downtown Midtown Uptown Westside Eastside Riverside Lakefront Hillside Garden Historic].freeze

puts "🏗️  Creating 50 properties with photos..."

50.times do |i|
  # Generate realistic property names
  adjective = ADJECTIVES.sample
  type = PROPERTY_TYPES.sample
  location = LOCATIONS.sample

  property_names = [
    "#{adjective} #{type} #{i + 1}",
    "#{location} #{type}",
    "The #{adjective} #{type}",
    "#{adjective} #{location} #{type}"
  ]

  property = Property.create!(
    name: property_names.sample
  )

  photo_count = rand(3..5)
  selected_photos = SAMPLE_PHOTOS.sample(photo_count)

  selected_photos.each_with_index do |base_filename, index|
    # Make filenames unique per property
    filename = "property_#{property.id}_#{base_filename}"

    Photo.create!(
      property: property,
      filename: filename,
      position: index + 1,
      content_type: CONTENT_TYPES.sample,
      file_size: rand(500_000..5_000_000) # 500KB to 5MB
    )
  end

  print "." if (i + 1) % 10 == 0
end

puts "\n🎉 Created #{Property.count} properties with #{Photo.count} photos"
puts "\n📊 Summary:"
puts "   • Properties with cover photos: #{Property.joins(:photos).where(photos: { position: 3 }).distinct.count}"
puts "   • Properties without cover photos: #{Property.count - Property.joins(:photos).where(photos: { position: 3 }).distinct.count}"
puts "   • Average photos per property: #{(Photo.count.to_f / Property.count).round(1)}"

puts "\n🖼️  Sample cover photos:"
Property.limit(5).includes(:photos).each do |property|
  cover = property.cover_photo
  if cover
    puts "   • #{property.name}: #{cover.filename} (#{property.photos.count} photos total)"
  else
    puts "   • #{property.name}: No cover photo (#{property.photos.count} photos total)"
  end
end

puts "\n🚀 Ready! Visit http://localhost:3000 to see your properties"
