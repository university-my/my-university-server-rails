# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

sumdu = University.find_by_url("sumdu")
if sumdu.nil?
  University.create(short_name: "СумДУ", full_name: "Сумський державний університет",  url: "sumdu")
end

kpi = University.find_by_url("kpi")
if kpi.nil?
  University.create(short_name: "КПІ", full_name: 'Національний технічний університет України "Київський політехнічний інститут імені Ігоря Сікорського"',  url: "kpi")
end
