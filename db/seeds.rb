# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

if University.sumdu.nil?
  University.create(
    short_name: "СумДУ",
    full_name: "Сумський державний університет",  
    url: "sumdu",
    website: 'https://sumdu.edu.ua/uk',
    uid: 1
    )
end

if University.kpi.nil?
  University.create(
    short_name: "КПІ",
    full_name: 'Національний технічний університет України "Київський політехнічний інститут імені Ігоря Сікорського"',
    url: "kpi",
    website: 'https://kpi.ua',
    uid: 2
    )
end

if University.khnue.nil?
  University.create(
    short_name: "ХНЕУ",
    full_name: 'Харківський національний економічний університет',  
    url: "khnue",
    website: 'https://www.hneu.edu.ua',
    uid: 3
    )
end

if University.nau.nil?
  University.create(
    short_name: "НАУ",
    full_name: 'Національний авіаційний університет', 
    url: "nau",
    website: '',
    uid: 4
    )
end

if University.pnu.nil?
  University.create(
    short_name: "ПНУ",
    full_name: 'Прикарпатський національний університет імені Василя Стефаника', 
    url: "pnu",
    website: 'https://pnu.edu.ua',
    uid: 5
    )
end

if University.znau.nil?
  University.create(
    short_name: "ПНУ",
    full_name: 'Поліський національний університет', 
    url: 'polissya-national-university',
    website: 'http://znau.edu.ua',
    uid: 6
    )
end

if University.nuft.nil?
  University.create(
    short_name: "НУХТ",
    full_name: 'Національний університет харчових технологій', 
    url: "nuft",
    website: 'https://nuft.edu.ua',
    uid: 7
    )
end

if University.sspu.nil?
  University.create(
    short_name: "СумДПУ",
    full_name: 'Сумський державний педагогічний університет імені А.С.Макаренка',
    url: "sspu",
    website: 'https://sspu.edu.ua',
    uid: 8
    )
end

if University.gpnu.nil?
  University.create(
    short_name: "ГНПУ",
    full_name: 'Глухівський національний педагогічний університет імені Олександра Довженка',
    url: "gpnu",
    website: 'http://new.gnpu.edu.ua/uk',
    uid: 9
    )
end

if University.lnu.nil?
  University.create(
    short_name: "ЛНУ",
    full_name: 'Львівський національний університет імені Івана Франка',
    url: "lnu",
    website: 'https://lnu.edu.ua',
    uid: 10
    )
end

if University.nuwm.nil?
  University.create(
    short_name: "НУВГП",
    full_name: 'Національний університет водного господарства та природокористування',
    url: "nuwm",
    website: 'https://nuwm.edu.ua',
    uid: 11
    )
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
  { name: "ЕТ", description: "Електронних технологій" },
  { name: "К1", description: "" },
  { name: "К2", description: "" },
  { name: "К3", description: "" },
  { name: "конАК", description: "" },
  { name: "КУКл", description: "" },
  { name: "ЛА", description: "" },
  { name: "ЛБ", description: "" },
  { name: "М", description: "" },
  { name: "Н", description: "Новий" },
  { name: "С", description: "" },
  { name: "СП", description: "" },
  { name: "ССМ", description: "" },
  { name: "Т", description: "" },
  { name: "ТЗ", description: "" },
  { name: "Ц", description: "Центральний" },
  { name: "кл.кафПА", description: "" },
  { name: "кл.кафХІР", description: "Кафедра хірургії" },
  { name: "клЛДВЦ", description: "" },
  { name: "клМДКЛ", description: "" },
  { name: "клМДКЛп2", description: "" },
  { name: "клМКЛ", description: "" },
  { name: "клМКПБ", description: "" },
  { name: "клМКСП", description: "" },
  { name: "клОДКЛ", description: "" },
  { name: "клОДРЗН", description: "" },
  { name: "клОКГВВ", description: "" },
  { name: "клОКЛ", description: "" },
  { name: "клОКЛФД", description: "" },
  { name: "клОКЛп", description: "" },
  { name: "клОКЛхір", description: "" },
  { name: "клОКПТД", description: "" },
  { name: "клОКПЦ", description: "" },
  { name: "клОКСП", description: "" },
  { name: "клОКСПд", description: "" },
  { name: "клЦРКЛ", description: "Центральна клінічна лікарня" },
  { name: "конНК2", description: "" },
  { name: "клОКПТДст", description: "" },
  { name: "клОНДдис", description: "" },
  { name: "клОНДнар", description: "" },
  { name: "клПрСТОМ", description: "" },
  { name: "клСОІКЛ", description: "" },
  { name: "клСОКД", description: "" },
  { name: "клСОКОД", description: "" },
  { name: "клЦЗору", description: "Цент Зору" },
  { name: "клОДКЛст", description: "" },
  { name: "клОДЦ", description: "" },
  { name: "клМЦелед", description: 'Медичний центр "Еледія"' },
  { name: "клМП", description: "" },
]
sumdu_buildings.each do |item|
  building = Building.find_by(university: University.sumdu, name: item[:name])
  building = Building.new unless building
  building.university = University.sumdu
  building.name = item[:name]
  building.description = item[:description]
  building.save
end
