require 'celluloid'

# Used for recording. Controls mplayer instance used for ripping the stream bit-by-bit.
class Recorder
  include Celluloid
  include Celluloid::Logger

  attr_accessor :command, :filename, :audition_info, :recording

  # Creates a new recorder instance. Accepts AuditionInfo as input.
  def initialize(audition_info)
    debug "Recorder created"
    @recording = false # It's not recording till record is called
    @dir = $CFG.directory # Read the directory from config

    @audition_info = audition_info

    # String used as filename for .mp3 file.
    # Contains date and time of (observed) audition start and presenter data.
    @filename = audition_info.datetime.strftime("%Y%m%dT%H%M%S%z") + "_" +
      audition_info.presenter + "_" + audition_info.name + ".mp3"
  end

  # Start recording audition
  def record
    debug "Starting recording..."
    if !@recording # Start recording only if we are not recording already
      # Mplayer's command line. Logging disabled (unless there's an error), lirc, cache and ipv6 (generated errors) disabled.
      # -dumpstream is for stream's url
      # -dumpfile is said filename
      commandline = "mplayer -quiet -nocache -nolirc -prefer-ipv4 -dumpstream \"#{@audition_info.streamurl}\" -dumpfile \"#{@dir}/#{@filename}\""
      @command = IO.popen(commandline) # Starts mplayer
    
      @recording = true
      info "Recorder spawned, pid #{@command.pid}"
    end    
  end

  def stop
    if @recording # If we are recording, kill it
      Process.kill 'INT', @command.pid

      debug "Recorder #{@command.pid} terminated"
    end

    self.terminate # Terminate the actor
  end

end
