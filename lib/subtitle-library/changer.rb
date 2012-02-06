class SubsChanger
  require './reader.rb'
  require './writer.rb'

  def initialize(subs_path)
    @subs_path = subs_path
    @reader = SubsReader.new subs_path
  end

  def shift(disp_type, pos, fps)
    fps = @reader.fps if fps == -1
    if @reader.type == 'md'
      disposition_microdvd pos, fps, false, disp_type == 'ss'
    else
      disposition_timing pos, fps, false, disp_type == 'ss'
    end
  end

  def stretch(disp_type, pos, fps)
    fps = @reader.fps if fps == -1
    if @reader.type == 'md'
      disposition_microdvd pos, fps, true, disp_type == 'ss'
    else
      disposition_timing pos, fps, true, disp_type == 'ss'
    end
  end

  def set_max_line(max_line)
    line_break = @reader.type == 'sr' ? "\n" : (@reader.type == 'md' ? '|' : '[br]')
    @reader.cues.each do |cue|
      text = cue.text
      lines = text.split "(#{Regexp.escape(line_break)})+"
      carriage_needed = false
      lines.each do |line|
        if line.length > max_line
          carriage_needed = true
          break
        end
      end
      if carriage_needed
        new_text = ''
        words = text.split "\s*(#{Regexp.escape(line_break)})*\s*"
        current_line = ''
        for i in (0 .. words.length - 1)
          current_line += (current_line == '' ? ' ' : '') + words[i]
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
