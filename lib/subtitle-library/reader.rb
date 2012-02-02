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
end
