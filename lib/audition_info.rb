require 'nokogiri'
require 'open-uri'

class AuditionInfo
  attr_accessor :datetime, :presenter, :name, :streamurl

  def self.from_xspf(url = "http://streaming.pixelmeal.com:8000/stream")
    begin
      xmlio = open(url + ".xspf")
    rescue
      xmlio = ""
    end

    data = Hash.new
    xml = Nokogiri::XML(xmlio)

    # Map station data to data object
    rawdata = xml.css('annotation').text.split("\n")
    rawdata.each do |r|
      tmp = r.split(": ")
      data[tmp[0]] = tmp[1]
    end

    presenter = data["Stream Genre"]
    name = data["Stream Title"]
    datetime = DateTime.now

    return AuditionInfo.new(datetime, presenter, name, url)
  end

  def initialize(datetime, presenter, name, url)
    @datetime = datetime
    @presenter = presenter
    @name = name
    @streamurl = url
  end

  def to_s
    "#<AuditionInfo Stream: #{@streamurl} Presenter: #{@presenter} Audition: #{@name}>"
  end
end
