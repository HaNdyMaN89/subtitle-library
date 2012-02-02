class SubsReader
  require './regex-patterns.rb'
  include LinePatterns

  def initialize(subs_path)
    @subs_path = subs_path
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

  def check_syntax
    case recognize
      when 'sr'
        check_sub_rip_syntax
      when 'md'
        check_micro_dvd_syntax
      when 'sv'
        check_subviewer_syntax
      else
        'Unknown file format'
    end
  end
end
