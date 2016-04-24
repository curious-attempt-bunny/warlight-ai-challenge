#!/usr/bin/env ruby

require 'set'
require 'json'

leaderboard = `curl http://theaigames.com/competitions/warlight-ai-challenge/leaderboard/global/a/`
leaders = Set.new(leaderboard.scan(/(?mi)<td class="cell-table cell-table-pointRight"><div class="bot-name">(.*?)<\/div>/)[0...40].map(&:first).map(&:strip))
points = Set.new(leaderboard.scan(/(?mi)<td class="cell-table cell-table-square"><em>([0-9]+)<\/em>/)[0...40].map(&:first).map(&:strip)).map(&:to_i)
leader_points = Hash[leaders.zip(points)]

1.upto(10000) do |page|
    puts "*** page #{page}"
    response = `curl http://theaigames.com/competitions/warlight-ai-challenge/game-log/a/#{page}`
    response.scan(/(?mi)<div class="div-botName-gameLog">(.*?)<\/div>.*?<div class="div-botName-gameLog">(.*?)<\/div>.*?href="[^"]+\/games\/([0-9a-f]+)"/).each do |match|
        players = [match[0].strip, match[1].strip]
        next unless leaders.include?(players[0]) && leaders.include?(players[1])
        game = match[2]
        url = "http://theaigames.com/competitions/warlight-ai-challenge/games/#{game}/data"
        puts players
        puts url
        if File.exists?("raw/#{game}.json")
            # exit(0)
        else
            content = `curl #{url}`
            json = {'game' => content}
            json["meta"] = {
                players: players,
                scores: players.map { |p| leader_points[p] }
            }
            content = JSON.generate(json)
            File.write("raw/#{game}.json", content)
        end
    end
    # break if Dir.glob('raw/*.json').size >= 5000
end