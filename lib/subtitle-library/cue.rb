class Cue
  attr_accessor :start, :ending, :text

  def initialize(start, ending, text)
    @start = start
    @ending = ending
    @text = text
  end

  def ==(other_cue)
    @start == other_cue.start and
      @ending == other_cue.ending and
        @text == other_cue.text
  end
end

