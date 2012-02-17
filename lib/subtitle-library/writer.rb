class SubsWriter
  def initialize(subs_reader)
    @cues = subs_reader.cues
    @fps = subs_reader.fps
    @subs_type = subs_reader.type
  end

  def save_as(new_path, new_type, fps = -1)
    fps = @fps if fps == -1
    if @subs_type == 'md'
      if new_type == 'md'
        save_frames_to_frames new_path
      else
        save_frames_to_timing new_path, new_type, fps
      end
    else
      if new_type == 'md'
        save_timing_to_frames new_path, fps
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

  def save_frames_to_timing(new_path, new_type, fps)
    line_count = 1
    bef_mil, bet_start_end = new_type == 'sr' ? [',', ' --> '] : ['.', ',']
    File.open(@subs_path, 'w') do |subs|
      subs.write("[STYLE]no\n") if sub_type == 'sv'
      @cues.each do |cue|
        start = Time.mktime(1,1,1) + cue.start / fps
        ending = Time.mktime(1,1,1) + cue.ending / fps
        timing_line = start.to_s.split(' ')[1] + bef_mil + ("%03d" % (start.usec / 1000)) + bet_start_end
        timing_line += ending.to_s.split(' ')[1] + bef_mil + ("%03d" % (ending.usec / 1000))
        if start.year + start.month + start.day + ending.year + ending.month + ending.day != 6
          puts 'Invalid timing'
          break
        end
        if new_type == 'sr'
          subs.write(line_count.to_s + "\n" + timing_line + "\n")
          subs.write(cue.text + "\n\n")
          line_count += 1
        else
          subs.write(timing_line + "\n")
          subs.write(cue.text.gsub("\n", '[br]') + "\n\n")
        end
      end
    end
  end

  def save_timing_to_frames(new_path, fps)
    File.open(@subs_path, 'w') do |subs|
      subs.write('{1}{1}' + fps.to_s + "\n")
      bottom_time = Time.mktime 1, 1, 1
      @cues.each do |cue|
        start_frame = ((cue.start - bottom_time) * fps).ceil
        end_frame = ((cue.ending - bottom_time) * fps).ceil
        subs.write('{' + start_frame.to_s + '}{' + end_frame.to_s + '}' + + cue.text.gsub("\n", "|") + "\n")
      end
    end
  end

  def save_timing_to_timing(new_path, new_type)
    line_count = 1
    bef_mil, bet_start_end = new_type == 'sr' ? [',', ' --> '] : ['.', ',']
    File.open(@subs_path, 'w') do |subs|
      subs.write("[STYLE]no\n") if sub_type == 'sv'
      @cues.each do |cue|
        timing_line = cue.start.to_s.split(' ')[1] + bef_mil + ("%03d" % (cue.start.usec / 1000)) + bet_start_end
        timing_line += cue.ending.to_s.split(' ')[1] + bef_mil + ("%03d" % (cue.ending.usec / 1000))
        if new_type == 'sr'
          subs.write(line_count.to_s + "\n" + timing_line + "\n")
          subs.write(cue.text + "\n\n")
          line_count += 1
        else
          subs.write(timing_line + "\n")
          subs.write(cue.text.gsub("\n", '[br]') + "\n\n")
        end
      end
    end
  end
end
