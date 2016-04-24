require 'json'

MAX = 100
raws = Dir.glob('raw/*.json')
freq = Hash.new { |h,k| h[k] = 0 }
raws[0...MAX].each do |raw|
    content = File.read(raw)
    json = JSON.parse(content)
    game = json['game']
    round1s = 0
    placing = true
    m = nil
    game.lines[1..-1].each do |line|
        line.strip!
        # puts ">>> #{line}"
        if line.start_with?('map ')
            m = line
        elsif line.start_with?('round ') || line.include?(' place_armies ')
            #  
            if round1s == 1 && placing && line != 'round 1' && m
                # puts m

                m.split(' ')[1..-1].map { |r| r.split(';') }.reject { |r| r[1] == 'unknown' || r[1] == 'neutral' }.map { |r| r[2].to_i }.each do |armies|
                    freq[armies] += 1
                end

                m = nil
                placing = false
            end
            if line == 'round 1'
                round1s += 1
            end
            if line.start_with?('round ')
                # puts line
                placing = true
            end
        else
            # puts "xxxx #{line}"
        end
    end
    break
end

puts freq.to_a.sort.inspect

puts freq[1]

puts freq[2]

puts (3..10).map { |i| freq[i] }.inject(&:+)

puts (11..100).map { |i| freq[i] }.inject(&:+)