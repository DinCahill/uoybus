require "httparty"
require "nokogiri"
require "chronic_duration"

# To try out:
#   ruby traveline.rb NAPTAN | less
# Example NAPTAN: 1464633391

auth = {
  :username => "TravelineAPI228",
  :password => "Eequ2koh"
}
url = "http://nextbus.mxdata.co.uk/nextbuses/1.0/1"
ref = ARGV[0].to_i
puts "ref = #{ref.to_s}"

payload = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Siri version="1.0" xmlns="http://www.siri.org.uk/">
  <ServiceRequest>
    <RequestTimestamp>2011-10-24T15:09:12Z</RequestTimestamp>
    <RequestorRef>TravelineAPIxxx</RequestorRef>
    <StopMonitoringRequest version="1.0">
      <RequestTimestamp>2011-10-24T15:09:12Z</RequestTimestamp>
      <MessageIdentifier>12345</MessageIdentifier>
      <MonitoringRef>' + ref.to_s + '</MonitoringRef>
    </StopMonitoringRequest>
  </ServiceRequest>
</Siri>'
puts payload

response = HTTParty.post url, :basic_auth => auth, :body => payload
xml = response.body
puts xml

doc = Nokogiri::XML xml
doc.remove_namespaces!

def nice_until t
  ChronicDuration.output(t.to_i).to_s
end

doc.xpath("//MonitoredStopVisit").each do |stop_visits|
  puts "MonitoringRef = " + stop_visits.xpath("MonitoringRef")[0].inner_html
  puts "VehicleMode = " + stop_visits.xpath("MonitoredVehicleJourney/VehicleMode")[0].inner_html
  puts "PublishedLineName = " + stop_visits.xpath("MonitoredVehicleJourney/PublishedLineName")[0].inner_html
  puts "DirectionName = " + stop_visits.xpath("MonitoredVehicleJourney/DirectionName")[0].inner_html
  puts "OperatorRef = " + stop_visits.xpath("MonitoredVehicleJourney/OperatorRef")[0].inner_html

  stop_visits.xpath("MonitoredVehicleJourney/MonitoredCall").each do |call|
    call.xpath("AimedDepartureTime").each do |aimed_time|
      puts "AimedDepartureTime = " + nice_until(Time.parse(aimed_time.inner_html) - Time.now)
    end
    call.xpath("ExpectedDepartureTime").each do |expected_time|
      puts "ExpectedDepartureTime = " + nice_until(Time.parse(expected_time.inner_html) - Time.now)
    end
  end

  puts "\n"
end
