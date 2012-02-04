class SubsWriter
  def initialize(subs_reader)
    @cues = subs_reader.cues
    @fps = subs_reader.fps
    @subs_type = subs_reader.type
  end
end
