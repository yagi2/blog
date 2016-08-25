xml.instruct!
xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  sitemap.resources.each do |resource|
    xml.url do
      xml.loc "#{site_url}#{resource.url}"
      xml.lastmod File.mtime(resource.source_file).strftime('%Y-%m-%d')
      xml.priority (1.1 - resource.url.count("/") * 0.1).round(1).to_s
      xml.changefreq "daily"
    end if resource.destination_path =~ /\.html$/
  end
end
