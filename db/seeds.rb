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