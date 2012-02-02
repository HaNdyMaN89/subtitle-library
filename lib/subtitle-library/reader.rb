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
