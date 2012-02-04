class SubsWriter
  def initialize(subs_reader)
    @cues = subs_reader.cues
    @fps = subs_reader.fps
    @subs_type = subs_reader.type
  end

  def save_as(new_path, new_type)
    if @subs_type == 'md'
      if new_type == 'md'
        save_frames_to_frames new_path
      else
        save_frames_to_timing new_path, new_type
      end
    else
      if new_type == 'md'
        save_timing_to_frames new_path
      else
        save_timing_to_timing new_path, new_type
      end
    end
  end     
end
