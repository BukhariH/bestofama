require 'api/reddit.com'

namespace :find do
  
  # Find NEW AMAs
  task :new => :environment do
    reddit = Reddit.new
    result = reddit.getIAMAs()
    result["data"]["children"].each do |a| 
 
      # Create AMA if :
      # * Karma greater than 100
      # * Isn't an AMA Request
      # * Isn't in the Trash
      if a["data"]["score"].to_i > 100 && !a["data"]["title"].to_s.match(/ama request/i) && !Trash.find_by_key(a["data"]["id"])
        @ama = Ama.new
        @ama.create_by_json(a["data"]) unless Ama.find_by_key(a["data"]["id"]) 
      end      
    end

  end
  
  # Find OLD AMAs
  # NOTE: This function does not work
  task :old => :environment do
  
    #get query variables to build reddit query
    count = Metum.find_by_name("find_old_ama-count")
    after = Metum.find_by_name("find_old_ama-after")
    time = Metum.find_by_name("find_old_ama-time")
  
    puts "========================"
    puts "find_old_amas"
    puts "count: " + count.value
    puts "after: " + after.value
  
    result = Reddit.get("http://www.reddit.com/r/IAmA/top/.json?sort=top&count=" + count.value + "&after=" + after.value + "&t=" + time.value)
    result["data"]["children"].each do |a|
  
      # Create AMA if :
      # * Karma greater than 100
      # * Isn't an AMA Request
      # * Isn't in the Trash
      if a["data"]["score"].to_i > 100 && !a["data"]["title"].to_s.match(/ama request/i) && !Trash.find_by_key(a["data"]["id"])
        @ama = Ama.new
        @ama.create_by_json(a["data"]) unless Ama.find_by_key(a["data"]["id"]) 
      end
    end
  
    # Update meta the query variables for the next run
    count.update_attribute(:value, count.value.to_i + 25)
    after.update_attribute(:value, result["data"]["after"])
  end
  
end