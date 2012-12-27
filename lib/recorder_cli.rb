class RecorderCli
  include Celluloid
  include Celluloid::Logger

  def initialize
    debug "CLI start"
    StreamChecker.supervise_as :checker
    run_timer
  end

  private
  
  def run_timer
    debug "Timer tick"

    Actor[:checker].check
    after(10) { run_timer }
  end
end
