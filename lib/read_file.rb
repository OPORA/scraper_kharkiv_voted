require 'yomu'
class ReadFile
  def rtf(file_name)
    votes = []
    p file_name
    yomu = Yomu.new file_name
    p yomu.metadata['Content-Type']
    # p yomu.text
    text_pages = yomu.text.split(/Вопрос:/)
     text_pages.each do |page|
       page.split(/\n/).each do |r|
         next if r[/Поименное голосование. Сессия:/]
         next if r[/Поименные голосования. Сессия:/]
         next if r[/Поименное голосования. Сессия:/]
         next if r[/MERGEFORMAT/]
         next if r[/\tФ.И.О./]
         next if r[/ФИО/]
         next if r.strip == ""
         next if r[/Решение/]
         next if r[/~ПРОЦЕДУРНОЕ~/]
         next if r[/~ОБЫЧНОЕ~/]
         next if r[/�/]
         if r[/Кворум -/]
           votes.last[:result] = r.split(';').last.strip
         elsif r[/\d+\.\d+\.\d{4}\s\d{2}:\d{2}:\d{2}/]
           if votes.last[:date].nil? and not votes.last[:name].nil?
             votes.last[:date] = r[/\d+\.\d+\.\d{4}\s\d{2}:\d{2}:\d{2}/]
           else
             votes << {name: r.gsub(/\d+\.\d+\.\d{4}\s\d{2}:\d{2}:\d{2}/,'').strip, votes: []}
             votes.last[:date] = r[/\d+\.\d+\.\d{4}\s\d{2}:\d{2}:\d{2}/]
           end
         else
           result = r.gsub(/\t/,'').strip
           if result.split(' ').size == 3 and mp_res = $all_mp.serch_mp(result)
               votes.last[:votes] << {mp: mp_res}
           elsif result == "Горошко Елена Игорьевна" or result == "Дегтярев Николай Иванович" or result == "Коринько Иван Васильевич" or result == "Лесик Андрей Анатольевич"
              votes.last[:votes] << {mp: result}
           elsif result == "Зинченко Владимир Анатольевич"
             votes.last[:votes] << {mp: "Зинченко Владимир Анатолиевич"}
           elsif result.split(' ').size < 3
             votes.last[:votes].last[:vote] = result
           else
             unless votes.empty?
               if votes.last[:votes].empty?
                 votes.last[:name] = votes.last[:name] + " " + r.strip
               else
                 votes << {name: r.strip, votes: []}
               end
             else
               votes << {name: r.strip, votes: []}
             end
           end
         end
       end
     end
    return votes
  end
end
