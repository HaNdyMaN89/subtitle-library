class SubsReader
  require './regex-patterns.rb'
  require './cue.rb'
  include Patterns

  def initialize(subs_path)
    @subs_path = subs_path
    @type = recognize
    @fps = 23.976
    @cues = []
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
    read_subs false
  end

  def check_syntax
    read_subs true
  end

  def read_subs(check_syntax)
    case @type
      when 'sr'
        read_sub_rip check_syntax
      when 'md'
        read_micro_dvd check_syntax
      when 'sv'
        read_subviewer check_syntax
      else
        'Unknown file format'
    end
  end

  def read_sub_rip(check_syntax)
    actual_lines = 0
    error_log = ""
    is_eof = false
    last_end_time = Time.new 1, 1, 1
    File.open(@subs_path, 'r') do |subs|
      while true
        line = subs.gets
        actual_lines += 1
        break unless line
        strip_line = line.strip
        while strip_line == '' or /\d+$/ =~ strip_line
          actual_lines += 1
          line = subs.gets
          unless line
            is_eof = true
            break
          end
          strip_line = line.strip
        end
        break if is_eof
        if SUB_RIP_LINE =~ strip_line
          match = SUB_RIP_TIMING.match(strip_line)
          time_args = [1,1,1] + match.to_s.split(/,|:/).collect(&:to_i)
          time_args[6] *= 1000
          start_time = Time.mktime *time_args
          match = SUB_RIP_TIMING.match match.post_match
          time_args = [1,1,1] + match.to_s.split(/,|:/).collect(&:to_i)
          time_args[6] *= 1000
          end_time = Time.mktime *time_args
          if start_time.day + end_time.day != 2 or start_time >= end_time or start_time < last_end_time
            if check_syntax
              error_log += "Invalid timing at #{actual_lines}.\n"
            else
              puts "Invalid timing at #{actual_lines}.\n"
            end
            break
          end
          last_end_time = end_time
          line = subs.gets
          unless line
            @cues << Cue.new(start_time, end_time, '') unless check_syntax
            break
          end
          text = line
          actual_lines += 1
          strip_line = line.strip
          while strip_line != ''
            actual_lines += 1
            line = subs.gets
            unless line
              is_eof = True
              break
            end
            text += line
            strip_line = line.strip
          end
          if is_eof
            @cues << Cue.new(start_time, end_time, text.rstrip) unless check_syntax
            break
          end
          line = subs.gets
          unless line
            @cues << Cue.new(start_time, end_time, text.rstrip) unless check_syntax
            break
          end
          actual_lines += 1
          strip_line = line.strip
          while not /\A\d+$/ =~ strip_line
            text += line
            actual_lines += 1
            line = subs.gets
            unless line
              @cues << Cue.new(start_time, end_time, text.rstrip) unless check_syntax
              is_eof = True
              break
            end
            strip_line = line.strip
          end
          break if is_eof
        elsif check_syntax
          error_log += "Syntax error at line #{actual_lines}.\n"
        else
          line = subs.gets
          break unless line
          strip_line = line.strip
          while not /\d+$/ =~ strip_line
            line = subs.gets
            unless line
              is_eof = true
              break
            end
            strip_line = line.strip
          end
          break if is_eof
        end
      end
    end
    if check_syntax
      error_log == '' ? 'No errors were found.' : error_log
    end
  end

  def read_micro_dvd(check_syntax)
    actual_lines = 0
    error_log = ""
    last_end_frame = 0
    File.open(@subs_path, 'r') do |subs|
      line = subs.gets
      while line
        actual_lines += 1
        strip_line = line.strip
        if strip_line != ''
          if MICRO_DVD_LINE =~ strip_line
            first_line = MICRO_DVD_LINE.match(strip_line).post_match.strip
            if /\d+\.?\d+/ =~ first_line
              @fps = first_line.to_f
              line = subs.gets
            end
          end
        end
        line = subs.gets
      end
      while line
        actual_lines += 1
        strip_line = line.strip
        if strip_line != ''
          if MICRO_DVD_LINE =~ strip_line
            match = /\d+/.match strip_line
            start_frame = match.to_s.to_i
            match = /\d+/.match match.post_match
            end_frame = match.to_s.to_i
            if start_frame <= end_frame and start_frame >= last_end_frame
              unless check_syntax
                text = MICRO_DVD_LINE.match(strip_line).post_match
                @cues << Cue.new(start_frame, end_frame, text.gsub('|', "\n"))
              end
              last_end_frame = end_frame
            elsif check_syntax
              error_log += "Syntax error at line #{actual_lines}.\n"
            end
          elsif check_syntax
            error_log += "Syntax error at line #{actual_lines}.\n"
          end
        end
        line = subs.gets
      end
    end
    if check_syntax
      error_log == '' ? 'No errors were found.' : error_log
    end
  end
end

puts 'a'
