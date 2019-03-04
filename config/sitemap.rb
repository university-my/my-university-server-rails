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
  
  # Universities
  add universities_path, :priority => 0.7, :changefreq => 'monthly'
  
  University.find_each do |university|
    add university_path(university.url), :lastmod => university.updated_at
  end
  
  # Auditoriums
  University.find_each do |university|
    add university_auditoriums_path(university.url), :priority => 0.5, :changefreq => 'weekly'
    
    Auditorium.find_each do |auditorium|
      add university_auditorium_path(university.url, auditorium.id), :lastmod => auditorium.updated_at
    end
  end
  
  # Groups
  University.find_each do |university|
    add university_groups_path(university.url), :priority => 0.5, :changefreq => 'weekly'
    
    Group.find_each do |group|
      add university_group_path(university.url, group.id), :lastmod => group.updated_at
    end
  end
  
  # Teachers
  University.find_each do |university|
    add university_teachers_path(university.url), :priority => 0.5, :changefreq => 'weekly'
    
    Teacher.find_each do |teacher|
      add university_teacher_path(university.url, teacher.id), :lastmod => teacher.updated_at
    end
  end  
end
