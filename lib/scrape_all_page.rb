require_relative 'get_page'
require_relative 'scrape_all_votes'
require_relative 'get_mps'
require 'tmpdir'
class GetPages
  def initialize
    #url = "http://www.city.kharkov.ua/uk/gorodskaya-vlast/gorodskoj-sovet/pomenne-golosuvannya.html"
    #page = GetPage.page(url)
    @all_page = get_all_page()
    $all_mp = GetMp.new
  end
  def get_all_page()

    hash = []
    Dir.glob("#{File.dirname(__FILE__)}/../files/*").each do |f|
       hash << { path: f, date:  f.split('/').last }
    end
    return hash
  end
  def get_all_votes
    @all_page.each do |p|
      GetAllVotes.votes(p[:path], p[:date])
    end
  end
end
