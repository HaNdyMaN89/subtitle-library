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

  def save_frames_to_frames(new_path)
    File.open(@subs_path, 'w') do |subs|
      subs.write('{1}{1}' + @fps.to_s + "\n")
      @cues.each do |cue|
        subs.write('{' + cue.start.to_s + '}{' + cue.ending.to_s + '}' + cue.text.gsub("\n", "|") + "\n")
      end
    end
  end

  def save_timing_to_frames(new_path)
    File.open(@subs_path, 'w') do |subs|
      subs.write('{1}{1}' + @fps.to_s + "\n")
      bottom_time = Time.mktime 1, 1, 1
      @cues.each do |cue|
        start_frame = ((cue.start - bottom_time) * fps).ceil
        end_frame = ((cue.ending - bottom_time) * fps).ceil
        subs.write('{' + start_frame.to_s + '}{' + end_frame.to_s + '}' + + cue.text.gsub("\n", "|") + "\n")
      end
    end
  end
end
