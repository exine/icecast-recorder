class RecorderCli
  include Celluloid
  include Celluloid::Logger

  def initialize
    debug "CLI start"
    @supervisor = StreamChecker.supervise
    @streamchecker = @supervisor.actors.first
    run_timer
  end

  private
  
  def run_timer
    debug "Timer tick"

    @streamchecker.check
    after(10) { run_timer }
  end
end
