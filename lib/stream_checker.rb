require 'celluloid'

# It's used for detecting audition changes on air.
class StreamChecker
  include Celluloid
  include Celluloid::Logger

  def initialize
    debug "StreamChecker created"

    @audition_info = AuditionInfo.new(nil, nil, nil, nil, nil) # Initialize empty audition info
    @recording = false
  end

  def check
    debug "StreamChecker will check audition info..."
      
    ai = AuditionInfo.from_xspf # Current audition info
    debug "AuditionInfo acquired: #{ai.to_s}"

    if @audition_info.presenter != ai.presenter or @audition_info.name != ai.name # Check if current presenter's info match those from earlier.
      stop_recorder # If not, stop recording
      @audition_info = ai

      info "New presenter detected: #{ai.presenter}"
      
      if recorded_presenter?(ai.presenter) and ai.valid?
        start_recorder
      
        info "Presenter on list, recording started"
      end
    
    end
  end

  private

  def recorded_presenter?(name)
    $CFG.recorded.include?(name)
  end

  def stop_recorder
    Actor[:recorder].stop if @recording
    @recording = false
  end

  def start_recorder
    Recorder.supervise_as(:recorder, @audition_info)
    Actor[:recorder].start
    @recording = true
  end
end
