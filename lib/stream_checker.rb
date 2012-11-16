require 'celluloid'

class StreamChecker
  include Celluloid
  include Celluloid::Logger

  def initialize
    debug "StreamChecker created"

    @running = true
    @audition_info = AuditionInfo.new(nil, nil, nil, nil)
    @recorder = nil
    @recording = false
  end

  def disable
    debug "StreamChecker disabled"

    @running = false
    @recorder.stop
  end

  def check
    if @running
      debug "StreamChecker will check audition info..."
      
      ai = AuditionInfo.from_xspf
      debug "AuditionInfo acquired: #{ai.to_s}"

      if @audition_info.presenter != ai.presenter or @audition_info.name != ai.name
        @recorder.stop if @recording
        @recording = false
        info "New presenter detected: #{ai.presenter}"
        if recorded_presenter?(ai.presenter)
          @recorder = Recorder.new(ai)
          @recorder.record
          info "Presenter on list, recording started"
          @recording = true
        end
        @audition_info = ai
      end
    else
      raise "StreamChecker is disabled!"
    end
  end

  private

  def recorded_presenter?(name)
    ["DJ Burakku", "Kira"].include?(name)
  end
end
