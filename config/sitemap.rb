# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://my-university.com.ua"

SitemapGenerator::Sitemap.create do

  # Static pages
  add about_path, :priority => 0.8, :changefreq => 'monthly'
  add cooperation_path, :priority => 0.8, :changefreq => 'monthly'
  add contacts_path, :priority => 0.8, :changefreq => 'monthly'
  add privacy_policy_path, :priority => 0.8, :changefreq => 'monthly'
  add terms_of_service_path, :priority => 0.8, :changefreq => 'monthly'
  add ios_path, :priority => 0.8, :changefreq => 'monthly'
  add android_path, :priority => 0.8, :changefreq => 'monthly'
  add telegram_channels_path, :priority => 0.8, :changefreq => 'monthly'

  # Universities
  University.where(is_hidden: false).find_each do |university|
    add university_path(university.url), :lastmod => university.updated_at
  end

  # Auditoriums
  University.where(is_hidden: false).find_each do |university|
    Auditorium.where(university: university).where(is_hidden: false).find_each do |auditorium|
      add university_auditorium_path(university.url, auditorium.friendly_id), :lastmod => auditorium.updated_at
    end
  end

  # Groups
  University.where(is_hidden: false).find_each do |university|
    Group.where(university: university).where(is_hidden: false).find_each do |group|
      add university_group_path(university.url, group.friendly_id), :lastmod => group.updated_at
    end
  end

  # Teachers
  University.where(is_hidden: false).find_each do |university|
    Teacher.where(university: university).where(is_hidden: false).find_each do |teacher|
      add university_teacher_path(university.url, teacher.friendly_id), :lastmod => teacher.updated_at
    end
  end

end
