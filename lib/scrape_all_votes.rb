require_relative 'get_page'
require_relative 'read_file'
require 'base32'
require_relative 'voted'

require_relative 'get_mps'

class GetAllVotes
  def self.votes(url, date)
     file_path = url
     p file_path
     if file_path == "http://www.city.kharkov.ua/documents/uploaded/%D0%9E%D0%9A2%20%D1%81%D0%B5%D1%81%D1%81%D0%B8%D1%8F_%D0%BF%D0%BE%D0%B8%D0%BC%D1%91%D0%BD%D0%BD%D0%BE%D0%B5-%D0%A1%20%D0%9D%D0%90%D0%97%D0%92%D0%90%D0%9D%D0%98%D0%AF%D0%9C%D0%98%20%D0%92%D0%9E%D0%9F%D0%A0%D0%9E%D0%A1%D0%9E%D0%92%20-%20%D0%B4%D0%BB%D1%8F%20%D1%81%D0%BB%D0%B8%D1%8F%D0%BD%D0%B8%D1%8F.rtf"
       file_name = "#{File.dirname(__FILE__)}/../files/2s.doc"
     elsif file_path == "http://www.city.kharkov.ua/assets/files/docs/session/4sespoimen.rtf" #or
       file_name = "#{File.dirname(__FILE__)}/../files/4sespoimen.doc"
     elsif file_path == "http://www.city.kharkov.ua/assets/files/docs/session/piimen_7-7.rtf"
       file_name = "#{File.dirname(__FILE__)}/../files/piimen_7-7.doc"
     else
       file_name = "#{File.dirname(__FILE__)}/../files/#{Base32.encode(file_path)}"
     end

     if (!File.exists?(file_name) || File.zero?(file_name))
        # uri = URI.encode(file_path.gsub(/%20/,' '))
        puts ">>>>  File not found, Downloading...."
        File.write(file_name, open(url).read)
        p "end download"
     end

     ReadFile.new.rtf(file_name).each_with_index do |vot, index |
         next if vot[:votes].nil?
         number = index + 1
         event = VoteEvent.first(name: vot[:name], date_vote: vot[:date], number: number, date_caden: date, rada_id: 2, option: vot[:result])
         if event.nil?
            events = VoteEvent.new(name: vot[:name], date_vote: vot[:date], number: number, date_caden: date, rada_id: 2, option: vot[:result])
            events.date_created = Date.today
            events.save
          else
            events = event
            events.votes.destroy!
          end
         vot[:votes].each do |v|
           next if v.empty?
           vote = events.votes.new
           vote.voter_id = v[:mp]
           vote.result = short_voted_result(v[:vote])
           vote.save
         end
     end
  end
  def self.short_voted_result(result)
    hash = {
        "Не голосовал":  "not_voted",
        відсутній: "absent",
        Против:  "against",
        За: "aye",
        Воздержался: "abstain"
    }
    hash[:"#{result}"]
  end
end