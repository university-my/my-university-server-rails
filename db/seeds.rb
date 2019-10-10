# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

sumdu = University.sumdu
if sumdu.nil?
  University.create(short_name: "СумДУ", full_name: "Сумський державний університет",  url: "sumdu")
end

kpi = University.kpi
if kpi.nil?
  University.create(short_name: "КПІ", full_name: 'Національний технічний університет України "Київський політехнічний інститут імені Ігоря Сікорського"',  url: "kpi")
end

khnue = University.khnue
if khnue.nil?
  University.create(short_name: "ХНЕУ", full_name: 'Харківський національний економічний університет',  url: "khnue")
end

# Buildings for SumDU
sumdu_buildings = [
  { name: "АК", description: "" },
  { name: "АН", description: "" },
  { name: "БІЦ", description: "" },
  { name: "Г", description: "Головний" },
  { name: "ГТ4", description: "" },
  { name: "ГТ5", description: "" },
  { name: "ГТ6", description: "" },
  { name: "ЕТ", description: "" },
  { name: "К1", description: "" },
  { name: "К2", description: "" },
  { name: "К3", description: "" },
  { name: "конАК", description: "" },
  { name: "КУКл", description: "" },
  { name: "ЛА", description: "" },
  { name: "ЛБ", description: "" },
  { name: "М", description: "" },
  { name: "Н", description: "" },
  { name: "С", description: "" },
  { name: "ССМ", description: "" },
  { name: "Т", description: "" },
  { name: "ТЗ", description: "" },
  { name: "Ц", description: "Центральний" },
  { name: "кл.кафПА", description: "" },
  { name: "клМДКЛ", description: "" },
  { name: "клМКЛ-4п1", description: "" },
  { name: "клМКЛ-5н", description: "" },
  { name: "клМКПБ", description: "" },
  { name: "клМКСП", description: "" },
  { name: "клОКЛ", description: "" },
  { name: "клОКПТД", description: "" },
  { name: "клОКПЦ", description: "" },
  { name: "клОКСП", description: "" },
]
sumdu_buildings.each do |item|
  building = Building.find_by(university: sumdu, name: item[:name])
  building = Building.new unless building
  building.university = sumdu
  building.name = item[:name]
  building.description = item[:description]
  building.save
end
