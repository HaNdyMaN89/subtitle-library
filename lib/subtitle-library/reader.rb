class SubsReader
  require 'regex-patterns'
  require 'cue'
  include Patterns

  attr_reader :type, :fps
  attr_accessor :cues

  def initialize(subs_path)
    @subs_path = subs_path
    @type = recognize
    case @type
      when 'sr'
        @inner_reader = SubRipReader.new subs_path
      when 'md'
        @inner_reader = MicroDVDReader.new subs_path
      when 'sv'
        @inner_reader = SubviewerReader.new subs_path
    end
    @fps = 23.976
  end

  def recognize
    File.open(@subs_path, 'r') do |subs|
      while line = subs.gets
        return 'sr' if SUB_RIP_LINE =~ line
        return 'md' if MICRO_DVD_LINE =~ line
        return 'sv' if SUBVIEWER_LINE =~ line
      end
    end
    'uk'
  end

  def load_cues
    if @inner_reader
      @cues, @fps = @inner_reader.read_subs false
    else
      'Unknown file format'
    end
  end

  def check_syntax
    if @inner_reader
      @inner_reader.read_subs true
    else
      'Unknown file format'
    end
  end

end

class SubRipReader
  include Patterns

  def initialize(subs_path)
    @subs_path = subs_path
    @fps = 23.976
  end

  def read_subs(check_syntax)
    cues = []
    actual_lines = 0
    error_log = ""
    is_eof = false
    last_end_time = Time.new 1, 1, 1
    File.open(@subs_path, 'r') do |subs|
      while true
        is_eof, actual_lines, strip_line = read_until_timing(subs, actual_lines)
        break if is_eof
        if SUB_RIP_LINE =~ strip_line
          start_time, end_time = parse_timing strip_line
          valid_timing, error_log = check_timing start_time, end_time, last_end_time, error_log, check_syntax, actual_lines
          unless valid_timing
            is_eof, actual_lines, strip_line = read_until_index subs, actual_lines, line, false
            break if is_eof
            next
          end
          last_end_time = end_time
          line = subs.gets
          break unless line
          actual_lines += 1
          text = line.strip
          strip_line = line.strip
          while strip_line != ''
            line = subs.gets
            unless line
              is_eof = true
              break
            end
            actual_lines += 1
            strip_line = line.strip
            text += "\n" + strip_line
          end
          if is_eof
            cues << Cue.new(start_time, end_time, text.rstrip) unless check_syntax
            break
          end
          line = subs.gets
          unless line
            cues << Cue.new(start_time, end_time, text.rstrip) unless check_syntax
            break
          end
          actual_lines += 1
          is_eof, actual_lines, strip_line, text = read_until_index subs, actual_lines, line, true, text
          cues << Cue.new(start_time, end_time, text.strip) unless check_syntax
          break if is_eof
        elsif check_syntax
          error_log += "Syntax error at line #{actual_lines}.\n"
          line = subs.gets
          break unless line
          actual_lines += 1
          is_eof, actual_lines, strip_line = read_until_index subs, actual_lines, line, false
          break if is_eof
        else
          line = subs.gets
          break unless line
          actual_lines += 1
          is_eof, actual_lines, strip_line = read_until_index subs, actual_lines, line, false
          break if is_eof
        end
      end
    end
    if check_syntax
      error_log == '' ? 'No errors were found.' : error_log.rstrip
    else
      [cues, @fps]
    end
  end

  def check_timing(start_time, end_time, last_end_time, error_log, check_syntax, actual_lines)
    if start_time.year + start_time.month + start_time.day +
      end_time.year + end_time.month + end_time.day != 6 or
        start_time >= end_time or start_time < last_end_time
          if check_syntax
            error_log += "Invalid timing at line #{actual_lines}.\n"
          else
            puts "Invalid timing at #{actual_lines}.\n"
          end
          [false, error_log]
    end
    [true, error_log]
  end

  def read_until_timing(subs, actual_lines)
    line = subs.gets
    return true unless line
    actual_lines += 1
    strip_line = line.strip
    while strip_line == '' or /\A\d+$/ =~ strip_line
      line = subs.gets
      unless line
        is_eof = true
        break
      end
      actual_lines += 1
      strip_line = line.strip
    end
    [is_eof, actual_lines, strip_line]
  end

  def parse_timing(line)
    match = SUB_RIP_TIMING.match line
    time_args = [1, 1, 1] + match.to_s.split(/,|:/).collect(&:to_i)
    time_args[6] *= 1000
    start_time = Time.mktime *time_args
    match = SUB_RIP_TIMING.match match.post_match
    time_args = [1, 1, 1] + match.to_s.split(/,|:/).collect(&:to_i)
    time_args[6] *= 1000
    [start_time, Time.mktime(*time_args)]
  end

  def read_until_index(subs, actual_lines, line, append, text = nil)
    strip_line = line.strip
    while not /\A\d+$/ =~ strip_line
      text += "\n" + strip_line if append
      line = subs.gets
      unless line
        is_eof = true
        break
      end
      actual_lines += 1
      strip_line = line.strip
    end
    [is_eof, actual_lines, strip_line] + (append ? [text] : [])
  end

end

class MicroDVDReader
  include Patterns

  def initialize(subs_path)
    @subs_path = subs_path
    @fps = 23.976
  end

  def read_subs(check_syntax)
    cues = []
    error_log = ""
    last_end_frame = 0
    File.open(@subs_path, 'r') do |subs|
      line, actual_lines = find_out_fps subs
      while line
        actual_lines += 1
        strip_line = line.strip
        if strip_line != ''
          if MICRO_DVD_LINE =~ strip_line
            last_end_frame, error_log = add_new_line strip_line, cues, last_end_frame, error_log, check_syntax
          elsif check_syntax
            error_log += "Syntax error at line #{actual_lines}.\n"
          end
        end
        line = subs.gets
      end
    end
    if check_syntax
      error_log == '' ? 'No errors were found.' : error_log
    else
      [cues, @fps]
    end
  end

  def find_out_fps(subs)
    line = subs.gets
    actual_lines = 0
    while line
      actual_lines += 1
      strip_line = line.strip
      if strip_line != ''
        if MICRO_DVD_LINE =~ strip_line
          first_line = MICRO_DVD_LINE.match(strip_line).post_match.strip
          if /\A\d*\.?\d*$/ =~ first_line
            @fps = first_line.to_f
            line = subs.gets
          end
          break
        end
      end
      line = subs.gets
    end
    [line, actual_lines]
  end

  def add_new_line(line, cues, last_end_frame, error_log, check_syntax)
    match = /\d+/.match line
    start_frame = match.to_s.to_i
    match = /\d+/.match match.post_match
    end_frame = match.to_s.to_i
    if start_frame <= end_frame and start_frame >= last_end_frame
      unless check_syntax
        text = MICRO_DVD_LINE.match(line).post_match
        cues << Cue.new(start_frame, end_frame, text.gsub('|', "\n"))
      end
      last_end_frame = end_frame
    elsif check_syntax
      error_log += "Syntax error at line #{actual_lines}.\n"
    end
    [last_end_frame, error_log]
  end

end

class SubviewerReader
  include Patterns

  def initialize(subs_path)
    @subs_path = subs_path
    @fps = 23.976
  end

  def read_subs(check_syntax)
    cues = []
    error_log = ''
    last_end_time = Time.mktime 1, 1, 1
    File.open(@subs_path, 'r') do |subs|
      actual_lines, error_log, line = read_metadata subs, check_syntax 
      while line
        actual_lines += 1
        strip_line = line.strip
        if strip_line != ''
          if SUBVIEWER_LINE =~ strip_line
            start_time, end_time = parse_timing strip_line
            valid_timing, error_log = check_timing start_time, end_time, last_end_time, error_log, check_syntax
            unless valid_timing
              break unless subs.gets
              line = subs.gets
              next
            end
            line = subs.gets
            break unless line
            actual_lines += 1
            cues << Cue.new(start_time, end_time, line.strip.gsub('[br]', "\n")) unless check_syntax
            last_end_time = end_time
          elsif check_syntax
            error_log += "Syntax error at line #{actual_lines}.\n"
          end
        end
        line = subs.gets
      end
    end
    if check_syntax
      error_log == '' ? 'No errors were found.' : error_log
    else
      [cues, @fps]
    end
  end

  def read_metadata(subs, check_syntax)
    actual_lines = 0
    error_log = ''
    metadata = ''
    while line = subs.gets
      actual_lines += 1
      strip_line = line.strip
      if strip_line != ''
        if /\A\d/ =~ strip_line
          error_log += "Syntax error in metadata.\n" if check_syntax and not SUBVIEWER_METADATA =~ metadata
          break
        end
        metadata += strip_line
      end
    end
    [actual_lines, error_log, line]
  end

  def parse_timing(line)
    start_end = line.split ','
    time_args = [1,1,1] + start_end[0].split(/\.|:/).collect(&:to_i)
    time_args[6] *= 1000
    start_time = Time.mktime *time_args
    time_args = [1,1,1] + start_end[1].split(/\.|:/).collect(&:to_i)
    time_args[6] *= 1000
    [start_time, Time.mktime(*time_args)]
  end

  def check_timing(start_time, end_time, last_end_time, error_log, check_syntax)
    if start_time.year + start_time.month + start_time.day +
      end_time.year + end_time.month + end_time.day != 6 or
        start_time >= end_time or start_time < last_end_time
          if check_syntax
            error_log += "Invalid timing at #{actual_lines}.\n"
          else
            puts "Invalid timing at #{actual_lines}.\n"
          end
          [false, error_log]
    end
    [true, error_log]
  end

end

