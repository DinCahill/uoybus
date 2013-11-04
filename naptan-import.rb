require "httparty"
require "nokogiri"

stop_queries_file = File.open "uoy-stops.md"
stop_queries = {}
while line = stop_queries_file.gets
  naptan_code = line.split(" ")[0].to_i
  if naptan_code != 0
    stop_queries[naptan_code] = line
  end
end
stop_queries_file.close

xml = File.read "./NaPTAN.xml" # "./mini-naptan.xml"
doc = Nokogiri::XML xml
doc.remove_namespaces!

doc.xpath("//StopPoint").each do |stop_point|
  naptan_code_0 = stop_point.xpath("NaptanCode")[0]
  if naptan_code_0.nil?
    # naptan_code = false
    next
  else
    naptan_code = naptan_code_0.inner_html.gsub("\n", "").gsub("\r", "").gsub("\t", "").gsub(" ", "")
  end

  if stop_queries[naptan_code.to_i].nil?
    next
  end

  atco_code_0 = stop_point.xpath("AtcoCode")[0]
  if atco_code_0.nil?
    atco_code = false
  else
    atco_code = atco_code_0.inner_html.gsub("\n", "").gsub("\r", "").gsub("\t", "").gsub(" ", "")
  end

  puts stop_queries[naptan_code.to_i]
  puts "=> atco_code = #{atco_code.to_s}, naptan_code = #{naptan_code.to_s}"
end
