class Cue
  attr_reader :start, :ending, :text

  def initialize(start, ending, text)
    @start = start
    @ending = ending
    @text = text
  end
end
