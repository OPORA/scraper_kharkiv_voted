require_relative 'get_page'
require_relative 'read_file'
require 'base32'
require_relative 'voted'

require_relative 'get_mps'

class GetAllVotes
  def self.votes(path, date)

     ReadFile.new.rtf(path).each_with_index do |vot, index |
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
           p v
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
    if hash[:"#{result}"].nil?
      p result
      return raise result
    else
      return hash[:"#{result}"]
    end

  end
end