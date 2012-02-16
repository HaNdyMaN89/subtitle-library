class SubsChanger
  require 'reader'
  require 'writer'

  def initialize(subs_path)
    @subs_path = subs_path
    @reader = SubsReader.new subs_path
    @reader.load_cues
  end

  def shift(disp_type, pos, fps = -1)
    fps = @reader.fps if fps == -1
    if @reader.type == 'md'
      disposition_microdvd pos, fps, false, disp_type == 'ss'
    else
      disposition_timing pos, fps, false, disp_type == 'ss'
    end
  end

  def stretch(disp_type, pos, fps = -1)
    fps = @reader.fps if fps == -1
    if @reader.type == 'md'
      disposition_microdvd pos, fps, true, disp_type == 'ss'
    else
      disposition_timing pos, fps, true, disp_type == 'ss'
    end
  end

  def disposition_microdvd(pos, fps, stretch, disp_seconds)
    bottom_time = Time.mktime 1, 1, 1
    invalid_timing = false
    if stretch
      step = disp_seconds ? pos * fps : pos
      disposition = 0
    else
      disposition = disp_seconds ? (pos * fps).ceil : pos.ceil
    end
    @reader.cues.each do |cue|
      cue.start += disposition
      cue.ending += disposition
      new_start = bottom_time + cue.start / fps
      new_end = bottom_time + cue.ending / fps
      if new_start.year + new_start.month + new_start.day +
        new_end.year + new_end.month + new_end.day != 6 or
          new_start < bottom_time or new_end < bottom_time
            invalid_timing = true
            puts 'Invalid timing'
            break
      end
      disposition = (disposition + step).ceil if stretch
    end
    SubsWriter.new(@reader).save_as(@subs_path, @reader.type) unless invalid_timing
  end

  def disposition_timing(pos, fps, stretch, disp_seconds)
    bottom_time = Time.mktime 1, 1, 1
    invalid_timing = false
    if stretch
      step = disp_seconds ? pos : pos / fps
      disposition = 0
    else
      disposition = disp_seconds ? pos : pos / fps
    end
    @reader.cues.each do |cue|
      cue.start += disposition
      cue.ending += disposition
      if cue.start.year + cue.start.month + cue.start.day +
        cue.ending.year + cue.ending.month + cue.ending.day != 6 or
          cue.start < bottom_time or cue.ending < bottom_time
            invalid_timing = true
            puts 'Invalid timing'
            break
      end
      disposition += step if stretch
    end
    SubsWriter.new(@reader).save_as(@subs_path, @reader.type) unless invalid_timing
  end

  def set_max_line(max_line)
    line_break = @reader.type == 'sr' ? "\n" : (@reader.type == 'md' ? '|' : '[br]')
    @reader.cues.each do |cue|
      text = cue.text
      lines = text.split /(#{Regexp.escape(line_break)})+/
      carriage_needed = false
      lines.each do |line|
        if line.length > max_line
          carriage_needed = true
          break
        end
      end
      if carriage_needed
        new_text = ''
        words = lines.collect { |line| line.split /\s+/ }.flatten
        current_line = ''
        for i in (0 .. words.length - 1)
          current_line += (current_line == '' ? '' : ' ') + words[i]
          if i == words.length - 1
            new_text += current_line
            break
          end
          if current_line.length > max_line
            new_text += current_line + line_break
            current_line = ''
          end
        end
        cue.text = new_text
      end
    end
    SubsWriter.new(@reader).save_as @subs_path, @reader.type
  end
end
