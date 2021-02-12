# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# SumDU
## Teachers
every 1.day, at: ['9:00 am', '9:00 pm'] do
  runner 'SumduService.import_teachers'
end
## Groups
every 1.day, at: ['9:05 am', '9:05 pm'] do
  runner 'SumduService.import_groups'
end
## Auditoriums
every 1.day, at: ['9:10 am', '9:10 pm'] do
  runner 'SumduService.import_auditoriums'
end

# KPI
## Teachers
every 1.day, at: ['9:15 am', '9:15 pm'] do
  runner 'KpiService.import_teachers'
end
## Groups
every 1.day, at: ['9:20 am', '9:20 pm'] do
  runner 'KpiService.import_groups'
end

# KHNUE
## Teachers
every 1.day, at: ['9:25 am', '9:25 pm'] do
  runner 'KhnueService.import_teachers'
end
## Auditoriums
every 1.day, at: ['9:30 am', '9:30 pm'] do
  runner 'KhnueService.import_auditoriums'
end
## Groups
every 1.day, at: ['9:35 am', '9:35 pm'] do
  runner 'KhnueService.import_groups'
end

# NUFT
every 1.day, at: ['10:00 am', '10:00 pm'] do
  runner 'NuftService.import_groups'
end
every 1.day, at: ['10:01 am', '10:01 pm'] do
  runner 'NuftService.import_teachers'
end

# PNU
every 1.day, at: ['10:02 am', '10:02 pm'] do
  runner 'PnuService.import_groups'
end
every 1.day, at: ['10:03 am', '10:03 pm'] do
  runner 'PnuService.import_teachers'
end

# ZNAU
every 1.day, at: ['10:04 am', '10:04 pm'] do
  runner 'ZnauService.import_groups'
end
every 1.day, at: ['10:05 am', '10:05 pm'] do
  runner 'ZnauService.import_teachers'
end

# Sitemap refresh
every 1.day, at: '12:00 pm' do
  rake 'sitemap:refresh'
end
