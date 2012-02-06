class SubsChanger
  require './reader.rb'

  def initialize(subs_path)
    @subs_path = subs_path
    @reader = SubsReader.new subs_path
  end

end
