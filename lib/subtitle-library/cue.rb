class Cue
  attr_accessor :start, :ending, :text

  def initialize(start, ending, text)
    @start = start
    @ending = ending
    @text = text
  end
end
