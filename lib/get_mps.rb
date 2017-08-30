require 'open-uri'
require 'json'
class GetMp
  def initialize
    @data_hash = JSON.load(open('https://scraperkharkivdeputy.herokuapp.com/'))
  end
  def serch_mp(full_name)
   name =full_name.gsub(/'/,'’').gsub(/ Депутатські повноваження складено/,'')
   data = @data_hash.find {|k| k["full_name"] == name  }
    unless data.nil?
       if data["deputy_id"] == "Дегтярев Николай Иванович"
         return 2002
       else
         return data["deputy_id"]
       end
    end
  end
end
