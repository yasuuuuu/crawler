require 'anemone'
require 'pry'


urls = ["http://www.amazon.co.jp/gp/bestsellers/books/", "http://www.amazon.co.jp/gp/bestsellers/digital-text/2275256051/"]

Anemone.crawl(urls, depth_limit: 1, skip_query_strings: true) do |anemone|
  anemone.focus_crawl do |page|
    page.links.keep_if { |link| link.to_s.match(%r{\/gp\/bestsellers\/books|\/gp\/bestsellers\/digital-text}) }
  end

  anemone.on_every_page do |page|
    puts page.url
  end
end