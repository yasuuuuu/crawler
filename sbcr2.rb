require 'cgi'
require 'open-uri'
require 'rss'


class Site
  attr_reader :url, :title
  def initialize(url: '', title: '')
    @url, @title = url, title
  end

  def page_source
    @page_source ||= open
  end
end

class SbcrTopics < Site
  def parse
    dates = page_source.scan(%r{(\d+)年\s?(\d+)月\s?(\d+)日<br />?})
    url_titles = page_source.scan(%r{^<a href="(.+?)">(.+?)</a><br />})
    url_titles.zip(dates).map{ |(aurl, atitle), ymd| [CGI.unescapeHTML(aurl), CGI.unescapeHTML(atitle), Time.local(*ymd)] }
  end
end

class Formatter
  attr_reader :title, :url
  def initialize(site)
    @title = site.title
    @url = site.url
  end
end

class TextFormatter < Formatter
  def format(url_title_time_ary)
    s = "Title: #{title}\nURL: #{url}\n\n"
    url_title_time_ary.each do |aurl, atitle, atime|
      s << "・ (#{atime})#{atitle}\n"
      s << "   #{aurl}\n"
    end
    s
  end
end

class RSSFormatter < Formatter
  def format(url_title_time_ary)
    RSS::Maker.make("2.0") do |maker|
      maker.channel.updated = Time.now.to_s
      maker.channel.link = url
      maker.channel.title = title
      maker.channel.description = title
      url_title_time_ary.each do |aurl, atitle, atime|
        maker.items.new_item do |item|
          item.link = aurl
          item.title = atitle
          item.updated = atime
          item.description = atitle
        end
      end
    end
  end
end

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

site = SbcrTopics.new(url:"http://crawler.sbcr.jp/samplepage.html",title:"WWW.SBCR.JP トピックス")
case ARGV.first
  when "rss-output"
    puts site.output RSSFormatter
  when "text-output"
    puts site.output TextFormatter
end

puts format_text("WWW.SBCR.JP トピックス", "http://crawler.sbcr.jp/samplepage.html", parse(open('http://crawler.sbcr.jp/samplepage.html', 'r:UTF-8', &:read)))