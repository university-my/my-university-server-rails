# Development

Setup database
- `rake db:setup`
- `rake db:migrate`
- `rake db:seed`

Reset increment of `id` (*optional*)
- `rails runner 'Teacher.reset_increment'`
- `rails runner 'Group.reset_increment'`
- `rails runner 'Auditorium.reset_increment'`
- `rails runner 'Record.reset_increment'`

## Import data

### SumDU
- `rails runner 'SumduService.import_teachers'`
- `rails runner 'SumduService.import_groups'`
- `rails runner 'SumduService.import_auditoriums'`

### KHNUE
- `rails runner 'KhnueService.import_teachers'`
- `rails runner 'KhnueService.import_auditoriums'`
- `rails runner 'KhnueService.import_groups'` (*Very long !!!*)

### KPI
- `rails runner 'KpiService.import_groups'`
- `rails runner 'KpiService.import_teachers'`

Generate links, for old records (*optional*)
- `Auditorium.find_each(&:save)`
- `Group.find_each(&:save)`
- `Teacher.find_each(&:save)`
- `Building.find_each(&:save)`

Reset `updated_at` dates
- `rails runner 'Teacher.reset_update_date'`
- `rails runner 'Group.reset_update_date'`
- `rails runner 'Auditorium.reset_update_date'`

# Production

`git pull`

`bundle install`

Setup database
- `rake db:setup RAILS_ENV=production`
- `rake db:migrate RAILS_ENV=production`
- `rake db:seed RAILS_ENV=production`

Compile assets
`RAILS_ENV=production rails assets:precompile`

Console
`rails c -e production`

## Import data

### SumDU
- `rails runner -e production 'SumduService.import_teachers'`
- `rails runner -e production 'SumduService.import_groups'`
- `rails runner -e production 'SumduService.import_auditoriums'`

### KHNUE
- `rails runner -e production 'KhnueService.import_teachers'`
- `rails runner -e production 'KhnueService.import_auditoriums'`
- `rails runner -e production 'KhnueService.import_groups'` (*Very long !!!*)

### KPI
- `rails runner -e production 'KpiService.import_groups'`
- `rails runner -e production 'KpiService.import_teachers'`

Refresh *sitemap*
`RAILS_ENV=production rake sitemap:refresh`

Restart server
`rails restart`

Other commands
`systemctl {start|stop|restart} rails.service`
