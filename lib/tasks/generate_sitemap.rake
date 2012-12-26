# Finding new AMAs with a score over 100
task :generate_sitemap => :environment do
  SitemapGenerator::Sitemap.default_host = "http://bestofama.com"
  SitemapGenerator::Sitemap.sitemaps_host = "http://s3.bestofama.com"
  SitemapGenerator::Sitemap.public_path = 'tmp/'
  SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'
  SitemapGenerator::Sitemap.adapter = SitemapGenerator::WaveAdapter.new
  SitemapGenerator::Sitemap.create do

    # SITEMAP OF AMAS
    group(:sitemaps_path => 'sitemaps/amas/') do
      Ama.where('responses > ?', 0).each do |ama|
        add ama_full_path(:username => ama.user.username, :key => ama.key, :slug => ama.title.parameterize), :changefreq => 'never'
      end
    end

    #SITEMAP OF TAGS
    group(:sitemaps_path => 'sitemaps/tags/') do
      ActsAsTaggableOn::Tag.select("name").each do |tag|
        add tag_path(tag.name), :changefreq => 'weekly'
      end
    end

    #SITEMAP OF ENTITIES
    group(:sitemaps_path => 'sitemaps/entities/') do
      Entity.all.each do |entity|
        add entity_path(entity), :changefreq => 'monthly'
      end
    end

  end
end