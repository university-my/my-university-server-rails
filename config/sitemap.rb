# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://my-university.com.ua"

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end

  # Static pages
  add about_path, :priority => 0.8, :changefreq => 'monthly'
  add cooperation_path, :priority => 0.8, :changefreq => 'monthly'
  add contacts_path, :priority => 0.8, :changefreq => 'monthly'
  add privacy_policy_path, :priority => 0.8, :changefreq => 'monthly'
  add terms_of_service_path, :priority => 0.8, :changefreq => 'monthly'
  add ios_path, :priority => 0.8, :changefreq => 'monthly'
  add android_path, :priority => 0.8, :changefreq => 'monthly'
  
  # Universities
  add universities_path, :priority => 0.7, :changefreq => 'monthly'
  
  University.where(is_hidden: false).find_each do |university|
    add university_path(university.url), :lastmod => university.updated_at
  end
  
  # Auditoriums
  University.where(is_hidden: false).find_each do |university|
    add university_auditoriums_path(university.url), :priority => 0.5, :changefreq => 'daily'
    
    Auditorium.where(university_id: university.id).find_each do |auditorium|
      add university_auditorium_path(university.url, auditorium.friendly_id), :lastmod => auditorium.updated_at
    end
  end
  
  # Groups
  University.where(is_hidden: false).find_each do |university|
    add university_groups_path(university.url), :priority => 0.5, :changefreq => 'daily'
    
    Group.where(university_id: university.id).find_each do |group|
      add university_group_path(university.url, group.friendly_id), :lastmod => group.updated_at
    end
  end
  
  # Teachers
  University.where(is_hidden: false).find_each do |university|
    add university_teachers_path(university.url), :priority => 0.5, :changefreq => 'daily'
    
    Teacher.where(university_id: university.id).find_each do |teacher|
      add university_teacher_path(university.url, teacher.friendly_id), :lastmod => teacher.updated_at
    end
  end


end
