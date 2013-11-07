require "sinatra"
require "httparty"
require "json"

areas = [
  "hes_east",
  "hes_west",
  "hes_road",
  "city_centre",
  "railway"
]
area_nicename_lookup = {
  "hes_east" => "UOY Hes East",
  "hes_west" => "UOY Hes West",
  "hes_road" => "Heslington Road",
  "city_centre" => "Piccadilly",
  "railway" => "Railway Station"
}
area_atcocode_lookup = {
  "hes_east" => {
    "east" => ["3290YYA03630", "3290YYA01011"],
    "west" => ["3290YYA03646", "3290YYA03608"]
  },
  "hes_west" => {
    "east" => ["3290YYA00282"],
    "west" => ["3290YYA00279"]
  },
  "hes_road" => {
    "east" => ["3290YYA00188"],
    "west" => ["3290YYA00186"]
  },
  "city_centre" => {
    "east" => ["3290YYA01672", "3290YYA00168"],
    "west" => ["3290YYA00103", "3290YYA00167"]
  },
  "railway" => {
    "east" => ["3290YYA00145"],
    "west" => ["3290YYA00133", "3290YYA00134"]
  }
}

directions = ["east", "west"]
direction_nicename_lookup = {
  "east" => "towards the University",
  "west" => "towards the Railway Station"
}

bus_lines = ["4", "44"]

def lookup_buses lines, atcocodes
  buses = []

  atcocodes.each do |atcocode|
    live_buses_url = "http://transportapi.com/v3/uk/bus/stop/#{atcocode.to_s}/live.json"
    live_buses_url << "?group=route&api_key=6fb02444e318401ab1baa1dcd5621abe&app_id=3a6804e2"
    response = HTTParty.get live_buses_url
    if response.code != 200
      puts "ERROR #{response.code.to_s}! atcocode = #{atcocode.to_s}"
      next
    end
    live_buses = JSON.parse response.body

    live_buses["departures"].each do |live_bus_line, live_buses|
      if lines.include?(live_bus_line.to_s)
        live_buses.each do |live_bus|
          buses.push live_bus
        end
      end
    end
  end

  buses.sort! do |a, b|
    a["best_departure_estimate"].sub(":", "").to_i <=> b["best_departure_estimate"].sub(":", "").to_i
  end
  return buses
end

get "/" do
  @areas = areas
  @directions = directions
  @area_nicenames = area_nicename_lookup
  @direction_nicenames = direction_nicename_lookup

  erb :welcome
end

post "/live" do
  redirect "/#{params[:area]}/#{params[:direction]}"
end

get "/:area" do |area|
  @area = area
  @direction = directions[1]

  redirect "/#{@area}/#{@direction}"
end

get "/:area/:direction" do |area, direction|
  @area = area
  @direction = direction

  @area_nicename = area_nicename_lookup[@area]
  @direction_nicename = direction_nicename_lookup[@direction]
  if @area_nicename.nil? || @direction_nicename.nil?
    redirect "/"
  end

  @time = Time.now
  @buses = lookup_buses bus_lines, area_atcocode_lookup[@area][@direction]

  erb :buses
end
