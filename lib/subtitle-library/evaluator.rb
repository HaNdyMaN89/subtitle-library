class SubsEvaluator
  def initialize(subs_path)
    @subs_path = subs_path
  end

  def recognize
    File.open(@subs_path, "r") do |subs|
      while line = subs.gets
        return 'sr' if /\A(\d{1,2}):\1:\1,\d{1,3}[ \t\r\f\v]?\-\->[ \t\r\f\v]?\1:\1:\1,\d{1,3}$/ =~ line
        return 'md' if /\A\{\d+\}( |\t)?\{\d+\}( |\t)?(\{(y|Y):[ibus]{1,4}\})?(\{C:$[0-9a-fA-F]{6}\})?$/ =~ line
        return 'sv' if /\A(\d{1,2}):\1:\1\.\d{1,3},\1:\1:\1\.\d{1,3}$/ =~ line
      end
    end
    'uk'
  end
end
