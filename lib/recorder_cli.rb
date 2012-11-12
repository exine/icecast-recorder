class RecorderCli
  include Celluloid
  include Celluloid::Logger

  def initialize(name)
    info "CLI start"
    @streamchecker = StreamChecker.new
    run_timer
  end

  private
  
  def run_timer
    debug "Timer tick"

    @streamchecker.check
    after(10) { run_timer }
  end
end
