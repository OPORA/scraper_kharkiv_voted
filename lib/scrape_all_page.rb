require_relative 'get_page'
require_relative 'scrape_all_votes'
require_relative 'get_mps'

class GetPages
  def initialize
    url = "http://www.city.kharkov.ua/uk/gorodskaya-vlast/gorodskoj-sovet/pomenne-golosuvannya.html"
    page = GetPage.page(url)
    @all_page = get_all_page(page)
    $all_mp = GetMp.new
  end
  def get_all_page(page)
    hash = []
    page.css('.container .container_department h3 a').each do |a|
      if a[:href].include?("http:")
        hash << { url: a[:href].gsub(/\n/,''), date: a.text }
      else
        hash << { url: "http://www.city.kharkov.ua" + a[:href].gsub(/\n/,''), date: a.text }
      end
      #p a.text
    end
    return hash
  end
  def get_all_votes
    @all_page.each do |p|
      GetAllVotes.votes(p[:url], p[:date])
    end
  end
end
