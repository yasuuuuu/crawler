require 'cgi'
require 'open-uri'
require 'rss'

def parse(page_source)
  dates = page_source.scan(%r{(\d+)年\s?(\d+)月\s?(\d+)日<br />?})
  url_titles = page_source.scan(%r{^<a href="(.+?)">(.+?)</a><br />})
  url_titles.zip(dates).map{ |(aurl, atitle), ymd| [CGI.unescapeHTML(aurl), CGI.unescapeHTML(atitle), Time.local(*ymd)] }
end

def format_text(title, url, url_title_time_ary)
  s = "Title: #{title}\nURL: #{url}\n\n"
  url_title_time_ary.each do |aurl, atitle, atime|
    s << "・ (#{atime})#{atitle}\n"
    s << "   #{aurl}\n"
  end
  s
end

puts format_text("WWW.SBCR.JP トピックス", "http://crawler.sbcr.jp/samplepage.html", parse(open('http://crawler.sbcr.jp/samplepage.html', 'r:UTF-8', &:read)))