require "json"

info = File.read "buses-4-44.md"
info.gsub(".", "") # Hide progress indicators

stops = {}

info_lines = info.split "\n"
info_lines.each do |info_line|
  match = info_line.match /Found a ([0-9]+)! atcocode, smscode, name, locality = ([A-Za-z0-9]+), /
  next if match.nil?
  line = match[1]
  atcocode = match[2]
  stops[atcocode] = [] if stops[atcocode].nil?
  stops[atcocode].push line
end

# puts stops.to_json

bus_stops_cache = File.read "bus_stop_cache.json"
bus_stops = JSON.parse bus_stops_cache

active_bus_stops = []

bus_stops.each do |bus_stop|
  unless stops[bus_stop["atcocode"]].nil?
    bus_stop["x_lines"] = stops[bus_stop["atcocode"]]
    active_bus_stops.push bus_stop
  end
end

puts active_bus_stops.to_json
