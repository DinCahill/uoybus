require "httparty"
require "json"

page = 0
bus_stops = []
wanted_route_bus_stops = {"44" => [], "4" => []}

=begin
begin
  page = page + 1

  bus_stops_url = "http://transportapi.com/v3/uk/bus/stops/bbox.json"
  bus_stops_url << "?minlon=-1.1014652252197266&minlat=53.93688989068619"
  bus_stops_url << "&maxlon=-1.0086822509765625&maxlat=53.964872165155725"
  bus_stops_url << "&api_key=6fb02444e318401ab1baa1dcd5621abe&app_id=3a6804e2"
  bus_stops_url << "&rpp=25&page=#{page.to_i.to_s}"
  response = HTTParty.get bus_stops_url
  bus_stops_page = JSON.parse response.body

  bus_stops_page["stops"].each do |bus_stop|
    bus_stops.push bus_stop
    print "."
    # puts "atcocode, smscode, name, locality = #{bus_stop["atcocode"].to_s}, #{bus_stop["smscode"].to_s}, #{bus_stop["name"].to_s}, #{bus_stop["locality"].to_s}"
  end
end while !bus_stops_page["stops"].nil? && bus_stops_page["stops"].length > 0

puts bus_stops.to_json
=end

bus_stops_cache = File.read "bus_stop_cache.json"
bus_stops = JSON.parse bus_stops_cache

bus_stops.each do |bus_stop|
  live_buses_url = "http://transportapi.com/v3/uk/bus/stop/#{bus_stop["atcocode"].to_s}/live.json"
  live_buses_url << "?group=route&api_key=6fb02444e318401ab1baa1dcd5621abe&app_id=3a6804e2"
  response = HTTParty.get live_buses_url
  if response.code != 200
    puts "ERROR #{response.code.to_s}! atcocode, smscode, name, locality = #{bus_stop["atcocode"].to_s}, #{bus_stop["smscode"].to_s}, #{bus_stop["name"].to_s}, #{bus_stop["locality"].to_s}"
    next
  end
  live_buses = JSON.parse response.body

  live_buses["departures"].each do |live_bus_line, live_buses|
    line = live_bus_line.to_s
    unless wanted_route_bus_stops[line].nil?
      wanted_route_bus_stops[line].push bus_stop
      puts "Found a #{line}! atcocode, smscode, name, locality = #{bus_stop["atcocode"].to_s}, #{bus_stop["smscode"].to_s}, #{bus_stop["name"].to_s}, #{bus_stop["locality"].to_s}"
    else
      print "."
    end
  end
end
