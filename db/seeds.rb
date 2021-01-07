begin
  1000.times do
    username = "#{Faker::Internet.username}-#{SecureRandom.hex(8)}"
    user = User.new(
      username: username,
      email: "#{username}@gmail.com",
      gender: [:male, :female].sample,
      name: Faker::Name.name
    )
    user.save!(validate: false)
    admin = Admin.new(
      username: username,
      email: "#{username}@gmail.com",
      name: Faker::Name.name  
    )
    admin.save!(validate: false)
  end

  User.select(:id).all.find_each do |user|
    5.times do
      wishlist = Wishlist.new(user: user, item: Faker::Kpop.solo)
      wishlist.save!(validate: false)
    end
  end
rescue StandardError => e
  pp e.message
  raise ActiveRecord::Rollback
end
