require 'json'

def preferences(regions, game_file)
    content = File.read(game_file)
    json = JSON.parse(content)
    line = json['game'].lines[0].strip
    sorted_regions = line.strip.split(' ')[1..-1].map { |r| r.split(';') }.reject { |r| r[1] == 'neutral' }.map(&:first).map(&:to_i).sort_by { |id| -regions[id][:average] }
    # best = [sorted_regions[0]]
    # sorted_regions = sorted_regions[1..-1]
    # markovs = regions[best[0]][:markov]
    # while best.size < 3
    #     preferences = markovs.to_a.select { |id,value| sorted_regions.include?(id) }.reject { |id, value| best.include?(id) }
    #     preferences.sort_by! { |id, value| -value }
    #     puts preferences.inspect
    #     if preferences.size > 0
    #         addition = preferences[0][0]
    #         best << addition
    #         markovs = regions[addition][:markov]
    #     end
    # end
    # best
end

sample = "5715e8864ee9c602c4dfda62"
MAX = 10000
raws = Dir.glob('raw/*.json')
raws.delete(sample)
regions = Hash.new { |h,k| h[k] = {freq:0, sum:0, average:0, markov:Hash.new { |h,k| h[k] = 0 }} }
{
    1 => 'Alaska',
    2 => 'Northwest Territory',
    3 => 'Greenland',
    4 => 'Alberta',
    5 => 'Ontario',
    6 => 'Quebec',
    7 => 'Western United States',
    8 => 'Eastern United States',
    9 => 'Central America',
    10 => 'Venezuela',
    11 => 'Peru',
    12 => 'Brazil',
    13 => 'Argentina',
    14 => 'Iceland',
    15 => 'Great Britain',
    16 => 'Scandinavia',
    17 => 'Ukraine',
    18 => 'Western Europe',
    19 => 'Northern Europe',
    20 => 'Southern Europe',
    21 => 'North Africa',
    22 => 'Egypt',
    23 => 'East Africa',
    24 => 'Congo',
    25 => 'South Africa',
    26 => 'Madagascar',
    27 => 'Ural',
    28 => 'Siberia',
    29 => 'Yakutsk',
    30 => 'Kamchatka',
    31 => 'Irkutsk',
    32 => 'Kazakhstan',
    33 => 'China',
    34 => 'Mongolia',
    35 => 'Japan',
    36 => 'Middle East',
    37 => 'India',
    38 => 'Siam',
    39 => 'Indonesia',
    40 => 'New Guinea',
    41 => 'Western Australia',
    42 => 'Eastern Australia'
}.each do |k,v|
    regions[k][:name] = v
end
raws[0...MAX].each do |raw|
    content = File.read(raw)
    json = JSON.parse(content)
    line = json['game'].lines[0].strip
    rs = line.strip.split(' ')[1..-1].map { |r| r.split(';') }.reject { |r| r[1] == 'neutral' }
    # puts rs.inspect
    player_region_ids = [[], []]
    rs.each do |r|
        id, player, armies = r
        id = id.to_i
        player_id = player[-1].to_i
        regions[id][:freq] += 1
        regions[id][:sum] += json['meta']['scores'][player_id-1]
        regions[id][:average] = regions[id][:sum] / regions[id][:freq]
        player_region_ids[player_id-1] << id
    end

    # puts player_region_ids.inspect
    player_region_ids.each_with_index do |region_ids, player_id|
        player_id += 1 # Meh
        region_ids.each do |id|
            other = region_ids.dup
            other.delete(id)
            # puts other.inspect
            other.each do |other_id|
                # puts regions[id][:markov][other_id].inspect
                regions[id][:markov][other_id] += json['meta']['scores'][player_id-1]
            end
        end
    end
end
# puts regions.sort_by { |id, r| -r[:average] }.map { |id, r| "#{id}: #{r[:freq]} #{r[:sum]} #{r[:average]} '#{r[:name]}" }

# puts "http://theaigames.com/competitions/warlight-ai-challenge/games/#{sample} : #{preferences(regions, "raw/#{sample}.json").map {|id| regions[id]}.inspect}"

puts "[#{regions.sort_by { |id, r| -r[:average] }.map { |id,_| id }.join(', ')}}]"