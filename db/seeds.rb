cities = [
  ['LA', 'USA', 5_000_000],
  ['Hanoi', 'VNM', 10_000_000],
  ['Hochiminh', 'VNM', 10_000_000],
  ['Tokyo', 'JPN', 3_000_000],
  ['Seoul', 'KOR', 4_000_000],
  ['Guangdong', 'CHN', 8_000_000],
  ['Shanghai', 'CHN', 8_000_000],
]

persisted = cities.map do |city|
  City.create(name: city[0], code: city[1])
end

usa = persisted[0]
tokyo = persisted[3]

usa.satellites.create(name: "#{usa.code} satellite 1")
usa.satellites.create(name: "#{usa.code} satellite 2")

tokyo.satellites.create(name: "#{tokyo.code} satellite 1")
tokyo.satellites.create(name: "#{tokyo.code} satellite 2")

City.all.each.with_index do |city, index|
  city.create_population(number: cities[index][2])
end
