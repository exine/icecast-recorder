require 'nokogiri'
require 'open-uri'

# Connects to Icecast server and parses the .xspf to get information about current presenter
# and audition. It's variables are:
# - datetime: date and time of the check
# - streamurl: url of the audio stream
# - presenter: name of the presenter
# - audition: the audition title
class AuditionInfo
  attr_accessor :datetime, :presenter, :audition, :streamurl

  # Create new AuditionInfo object from xspf data.
  # Accepts audio stream URL as an argument. If the URL
  # isn't valid or server is down, returns an empty object
  # with unset valid flag.
  def self.from_xspf
    valid = true
    url = $CFG.url

    begin
      xmlio = open(url + ".xspf") # Tries to open .xspf file
    rescue
      # Make the xml io empty (Nokogiri accepts empty strings) and mark info as invalid
      xmlio = ""
      valid = false
    end

    data = Hash.new # Hash will contain data from .xspf
    xml = Nokogiri::XML(xmlio) # .xspf is a normal XML file, so let's parse it as such

    # Map station data to data object
    # The data is in name: value format, so we split it to process it
    # line by line, and then we split the lines using that ": " character.
    rawdata = xml.css('annotation').text.split("\n") # Get the text from annotation element and then split it to array of lines
    rawdata.each do |r| # Let's put that data in a hash, so we can use it in a much simpler way
      tmp = r.split(": ")
      data[tmp[0]] = tmp[1]
    end

    # Comes from parsed xspf data, we only care about those two.
    presenter = data["Stream Genre"] 
    audition = data["Stream Title"]
    datetime = DateTime.now # Let's get a timestamp

    return AuditionInfo.new(url, datetime, presenter, audition, valid) # Create a new object with those values
  end

  # Parameters:
  # - url: URL of the stream
  # - datetime: date and time of the check
  # - presenter: the current presenter's name
  # - audition: the audition's name
  # - valid: if check suceeded
  def initialize(url, datetime, presenter, audition, valid)
    @datetime = datetime
    @presenter = presenter
    @audition = audition
    @streamurl = url
    @valid = valid
  end

  # Make a string. Used for debugging.
  def to_s
    "#<AuditionInfo Stream: #{@streamurl} Presenter: #{@presenter} Audition: #{@name}>"
  end

  # Check validity of the data.
  # If it's not valid, you shouldn't trust it.
  def valid?
    @valid
  end

  # Works in reverse to #valid?
  def invalid?
    !@valid
  end
end
