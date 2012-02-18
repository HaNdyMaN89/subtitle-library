describe 'Command line tool' do
  path = File.join(File.dirname(__FILE__), 'temp')
  exec = File.join(File.dirname(__FILE__), '..', '..', 'bin', 'subtitle-library')

  RSpec.configure do |config|
    config.after(:each) do
      File.delete(path) if File.exists? path
    end
  end

  it 'recognises SubRip format' do
    File.open(path, 'w') do |subs|
      subs.write(<<-eos
                      12
                      00:02:04,240 --> 00:02:05,593
                      It was funny, huh?

                      13
                      00:02:06,320 --> 00:02:07,639
                      Yes, but I have to go.

                      14
                      00:02:07,840 --> 00:02:09,831
                      That'll teach you to excite yourself like this.

                      15
                      00:02:10,040 --> 00:02:12,508
                      Stop somewhere if you can.

                      16
                      00:02:43,560 --> 00:02:46,028
                      Honey, you're not at school.
                      Don't bother poor Elly.
                    eos
                    )
    end

    `ruby #{exec} -f #{path} -op recognise`.should eq "SubRip format.\n"
  end

  it 'recognises MicroDVD format' do
    File.open(path, 'w') do |subs|
      subs.write(<<-eos
                      {5277}{5309}You want some water with that?
                      {5311}{5345}No, no. No, I don't.
                      {5362}{5396}Looks like you had a night.
                      {5529}{5562}They look perfect.
                    eos
                    )
    end

    `ruby #{exec} -f #{path} -op recognise`.should eq "MicroDVD format.\n"
  end

  it 'recognises SubViewer format' do
    File.open(path, 'w') do |subs|
      subs.write(<<-eos
                      00:02:04.240,00:2:5.593
                      It was funny, huh?

                      00:02:06.20,00:02:07.639
                      Yes, but I have to go.

                      00:2:07.840,00:02:09.831
                      That'll teach you to excite yourself like this.

                      00:02:10.00,00:02:12.5
                      Stop somewhere if you can.
                    eos
                    )
    end

    `ruby #{exec} -f #{path} -op recognise`.should eq "SubViewer format.\n"
  end

  it 'validates SubRip syntax' do
    File.open(path, 'w') do |subs|
      subs.write(<<-eos
                      12
                      00:02:04,240 --> 00:02:05,593
                      It was funny, huh?

                      13
                      00:02:06,320 -> 00:02:07,639
                      Yes, but I have to go.

                      14
                      00:02:07,840 --> 00:02:09,831
                      That'll teach you to excite yourself like this.

                      15
                      00:02:10,040 --> 00:02:12,508
                      Stop somewhere if you can.

                      16
                      00:02:43,560 --> 00:02:46,028
                      Honey, you're not at school.
                      Don't bother poor Elly.
                    eos
                    )
    end

    `ruby #{exec} -f #{path} -op verify`.should eq "Syntax error at line 6.\n"
  end

  it 'validates MicroDVD syntax' do
    File.open(path, 'w') do |subs|
      subs.write(<<-eos
                      {5277}{5309}You want some water with that?
                      {5311}{5345}No, no. No, I don't.
                      {5362}{5396Looks like you had a night.
                      {5529}{5562}They look perfect.
                    eos
                    )
    end

    `ruby #{exec} -f #{path} -op verify`.should eq "Syntax error at line 3.\n"
  end

  it 'validates SubViewer syntax' do
    File.open(path, 'w') do |subs|
      subs.write(<<-eos
                      00:02:04.240,00:2:5.593
                      It was funny, huh?

                      00:02:06.20,00:02:07.639
                      Yes, but I have to go.
                      d

                      00:2:07.840,00:02:09.831
                      That'll teach you to excite yourself like this.

                      00:02:10.00,00:02:12.5
                      Stop somewhere if you can.
                    eos
                    )
    end

    `ruby #{exec} -f #{path} -op verify`.should eq "Syntax error at line 6.\n"
  end

  it 'sets the max line length of SubRip format' do
    lines = "1\n"
    lines += "00:03:40,095 --> 00:03:41,429\n"
    lines += "You want some water with that?\n\n"
    lines += "2\n"
    lines += "00:03:41,513 --> 00:03:42,931\n"
    lines += "No, no.\nNo, I don't.\n\n"
    lines += "3\n"
    lines += "00:03:43,640 --> 00:03:45,058\n"
    lines += "Looks like you had a night.\n\n"

    File.open(path, 'w') do |subs|
      subs.write(lines)
    end
    
    `ruby #{exec} -f #{path} -op carriage -cr 14`

    lines = "1\n"
    lines += "00:03:40,095 --> 00:03:41,429\n"
    lines += "You want some water\nwith that?\n\n"
    lines += "2\n"
    lines += "00:03:41,513 --> 00:03:42,931\n"
    lines += "No, no.\nNo, I don't.\n\n"
    lines += "3\n"
    lines += "00:03:43,640 --> 00:03:45,058\n"
    lines += "Looks like you had\na night.\n\n"

    File.open(path, 'r') do |subs|
      subs.read.should eq lines
    end
  end

  it 'sets the max line length of MicroDVD format' do
    lines = "{5277}{5309}You want some water with that?\n"
    lines += "{5311}{5345}No, no.|No, I don't.\n"
    lines += "{5362}{5396}Looks like you had a night.\n"

    File.open(path, 'w') do |subs|
      subs.write(lines)
    end

    `ruby #{exec} -f #{path} -op carriage -cr 14`

    lines = "{1}{1}23.976\n"
    lines += "{5277}{5309}You want some water|with that?\n"
    lines += "{5311}{5345}No, no.|No, I don't.\n"
    lines += "{5362}{5396}Looks like you had|a night.\n"

    File.open(path, 'r') do |subs|
      subs.read.should eq lines
    end

  end

  it 'sets the max line length of SubViewer format' do
    lines = "00:03:40.095,00:03:41.429\n"
    lines += "You want some water with that?\n\n"
    lines += "00:03:41.513,00:03:42.931\n"
    lines += "No, no.[br]No, I don't.\n\n"
    lines += "00:03:43.640,00:03:45.058\n"
    lines += "Looks like you had a night.\n\n"

    File.open(path, 'w') do |subs|
      subs.write(lines)
    end

    `ruby #{exec} -f #{path} -op carriage -cr 14`

    lines = "[STYLE]no\n"
    lines += "00:03:40.095,00:03:41.429\n"
    lines += "You want some water[br]with that?\n\n"
    lines += "00:03:41.513,00:03:42.931\n"
    lines += "No, no.[br]No, I don't.\n\n"
    lines += "00:03:43.640,00:03:45.058\n"
    lines += "Looks like you had[br]a night.\n\n"

  end

  it 'shifts subtitles of SubRip format' do
    lines = "1\n"
    lines += "00:03:40,095 --> 00:03:41,429\n"
    lines += "You want some water with that?\n\n"
    lines += "2\n"
    lines += "00:03:41,513 --> 00:03:42,931\n"
    lines += "No, no.\nNo, I don't.\n\n"
    lines += "3\n"
    lines += "00:03:43,640 --> 00:03:45,058\n"
    lines += "Looks like you had a night.\n\n"

    File.open(path, 'w') do |subs|
      subs.write(lines)
    end

    `ruby #{exec} -f #{path} -op shift -ss 1.5`

    lines = "1\n"
    lines += "00:03:41,595 --> 00:03:42,929\n"
    lines += "You want some water with that?\n\n"
    lines += "2\n"
    lines += "00:03:43,013 --> 00:03:44,431\n"
    lines += "No, no.\nNo, I don't.\n\n"
    lines += "3\n"
    lines += "00:03:45,140 --> 00:03:46,558\n"
    lines += "Looks like you had a night.\n\n"

    File.open(path, 'r') do |subs|
      subs.read.should eq lines
    end
  end

  it 'shift subtitles of MicroDVD format' do
    lines = "{5277}{5309}You want some water with that?\n"
    lines += "{5311}{5345}No, no.|No, I don't.\n"
    lines += "{5362}{5396}Looks like you had a night.\n"

    File.open(path, 'w') do |subs|
      subs.write(lines)
    end

    `ruby #{exec} -f #{path} -op shift -fs 80`

    lines = "{1}{1}23.976\n"
    lines += "{5357}{5389}You want some water with that?\n"
    lines += "{5391}{5425}No, no.|No, I don't.\n"
    lines += "{5442}{5476}Looks like you had a night.\n"

    File.open(path, 'r') do |subs|
      subs.read.should eq lines
    end
  end

  it 'shifts subtitles of SubViewer format' do
    lines = "00:03:40.095,00:03:41.429\n"
    lines += "You want some water with that?\n\n"
    lines += "00:03:41.513,00:03:42.931\n"
    lines += "No, no.[br]No, I don't.\n\n"
    lines += "00:03:43.640,00:03:45.058\n"
    lines += "Looks like you had a night.\n\n"

    File.open(path, 'w') do |subs|
      subs.write(lines)
    end
        
    `ruby #{exec} -f #{path} -op shift -ss 1.5`

    lines = "[STYLE]no\n"
    lines += "00:03:41.595,00:03:42.929\n"
    lines += "You want some water with that?\n\n"
    lines += "00:03:43.013,00:03:44.431\n"
    lines += "No, no.[br]No, I don't.\n\n"
    lines += "00:03:45.140,00:03:46.558\n"
    lines += "Looks like you had a night.\n\n"

    File.open(path, 'r') do |subs|
      subs.read.should eq lines
    end
  end

  it 'stretches subtitles of SubRip format' do
    lines = "1\n"
    lines += "00:03:40,095 --> 00:03:41,429\n"
    lines += "You want some water with that?\n\n"
    lines += "2\n"
    lines += "00:03:41,513 --> 00:03:42,931\n"
    lines += "No, no.\nNo, I don't.\n\n"
    lines += "3\n"
    lines += "00:03:43,640 --> 00:03:45,058\n"
    lines += "Looks like you had a night.\n\n"

    File.open(path, 'w') do |subs|
      subs.write(lines)
    end
        
    `ruby #{exec} -f #{path} -op stretch -ss 1.5`

    lines = "1\n"
    lines += "00:03:40,095 --> 00:03:41,429\n"
    lines += "You want some water with that?\n\n"
    lines += "2\n"
    lines += "00:03:43,013 --> 00:03:44,431\n"
    lines += "No, no.\nNo, I don't.\n\n"
    lines += "3\n"
    lines += "00:03:46,640 --> 00:03:48,058\n"
    lines += "Looks like you had a night.\n\n"

    File.open(path, 'r') do |subs|
      subs.read.should eq lines
    end
  end

  it 'strecthes subtitles of MicroDVD format' do
    lines = "{5277}{5309}You want some water with that?\n"
    lines += "{5311}{5345}No, no.|No, I don't.\n"
    lines += "{5362}{5396}Looks like you had a night.\n"

    File.open(path, 'w') do |subs|
      subs.write(lines)
    end

    `ruby #{exec} -f #{path} -op stretch -fs 80`

    lines = "{1}{1}23.976\n"
    lines += "{5277}{5309}You want some water with that?\n"
    lines += "{5391}{5425}No, no.|No, I don't.\n"
    lines += "{5522}{5556}Looks like you had a night.\n"

    File.open(path, 'r') do |subs|
      subs.read.should eq lines
    end
  end

  it 'stretches subtitles of SubViewer format' do
    lines = "00:03:40.095,00:03:41.429\n"
    lines += "You want some water with that?\n\n"
    lines += "00:03:41.513,00:03:42.931\n"
    lines += "No, no.[br]No, I don't.\n\n"
    lines += "00:03:43.640,00:03:45.058\n"
    lines += "Looks like you had a night.\n\n"

    File.open(path, 'w') do |subs|
      subs.write(lines)
    end

    `ruby #{exec} -f #{path} -op stretch -ss 1.5`

    lines = "[STYLE]no\n"
    lines += "00:03:40.095,00:03:41.429\n"
    lines += "You want some water with that?\n\n"
    lines += "00:03:43.013,00:03:44.431\n"
    lines += "No, no.[br]No, I don't.\n\n"
    lines += "00:03:46.640,00:03:48.058\n"
    lines += "Looks like you had a night.\n\n"

    File.open(path, 'r') do |subs|
      subs.read.should eq lines
    end
  end

  it 'saves from SubRip to Subrip format' do
    lines = "1\n"
    lines += "00:03:40,095 --> 00:03:41,429\n"
    lines += "You want some water with that?\n\n"
    lines += "2\n"
    lines += "00:03:41,513 --> 00:03:42,931\n"
    lines += "No, no.\nNo, I don't.\n\n"
    lines += "3\n"
    lines += "00:03:43640 --> 00:03:45,058\n"
    lines += "Looks like you had a night.\n\n"

    File.open(path, 'w') do |subs|
      subs.write(lines)
    end

    `ruby #{exec} -f #{path} -op save -nf #{path} -t sr`

    lines = "1\n"
    lines += "00:03:40,095 --> 00:03:41,429\n"
    lines += "You want some water with that?\n\n"
    lines += "2\n"
    lines += "00:03:41,513 --> 00:03:42,931\n"
    lines += "No, no.\nNo, I don't.\n\n"

    File.open(path, 'r') do |subs|
      subs.read.should eq lines
    end

  end

  it 'saves from SubRip to MicroDVD format' do
    lines = "1\n"
    lines += "00:03:40,095 --> 00:03:41,429\n"
    lines += "You want some water with that?\n\n"
    lines += "2\n"
    lines += "00:03:41,513 --> 00:03:42,931\n"
    lines += "No, no.\nNo, I don't.\n\n"
    lines += "3\n"
    lines += "00:03:43,640 --> 00:03:45,058\n"
    lines += "Looks like you had a night.\n\n"

    File.open(path, 'w') do |subs|
      subs.write(lines)
    end

    `ruby #{exec} -f #{path} -op save -nf #{path} -t md`

    lines = "{1}{1}23.976\n"
    lines += "{5277}{5309}You want some water with that?\n"
    lines += "{5311}{5345}No, no.|No, I don't.\n"
    lines += "{5362}{5396}Looks like you had a night.\n"

    File.open(path, 'r') do |subs|
      subs.read.should eq lines
    end

  end

  it 'saves from SubRip to SubViewer format' do
    lines = "1\n"
    lines += "00:03:40,095 --> 00:03:41,429\n"
    lines += "You want some water with that?\n\n"
    lines += "2\n"
    lines += "00:03:41,513 --> 00:03:42,931\n"
    lines += "No, no.\nNo, I don't.\n\n"
    lines += "3\n"
    lines += "00:03:43,640 --> 00:03:45,058\n"
    lines += "Looks like you had a night.\n\n"

    File.open(path, 'w') do |subs|
      subs.write(lines)
    end

    `ruby #{exec} -f #{path} -op save -nf #{path} -t sv`

    lines = "[STYLE]no\n"
    lines += "00:03:40.095,00:03:41.429\n"
    lines += "You want some water with that?\n\n"
    lines += "00:03:41.513,00:03:42.931\n"
    lines += "No, no.[br]No, I don't.\n\n"
    lines += "00:03:43.640,00:03:45.058\n"
    lines += "Looks like you had a night.\n\n"

    File.open(path, 'r') do |subs|
      subs.read.should eq lines
    end

  end

  it 'saves from MicroDVD to SubRip format' do
    lines = "{5277}{5309}You want some water with that?\n"
    lines += "{5311}{5345}No, no.|No, I don't.\n"
    lines += "{5362}{5396}Looks like you had a night.\n"

    File.open(path, 'w') do |subs|
      subs.write(lines)
    end

    `ruby #{exec} -f #{path} -op save -nf #{path} -t sr`

    lines = "1\n"
    lines += "00:03:40,095 --> 00:03:41,429\n"
    lines += "You want some water with that?\n\n"
    lines += "2\n"
    lines += "00:03:41,513 --> 00:03:42,931\n"
    lines += "No, no.\nNo, I don't.\n\n"
    lines += "3\n"
    lines += "00:03:43,640 --> 00:03:45,058\n"
    lines += "Looks like you had a night.\n\n"

    File.open(path, 'r') do |subs|
      subs.read.should eq lines
    end

  end

  it 'saves from MicroDVD to MicroDVD format' do
    lines = "{5277}{5309}You want some water with that?\n"
    lines += "{5311{5345}No, no.|No, I don't.\n"
    lines += "{5362}{5396}Looks like you had a night.\n"

    File.open(path, 'w') do |subs|
      subs.write(lines)
    end

    `ruby #{exec} -f #{path} -op save -nf #{path} -t md`

    lines = "{1}{1}23.976\n"
    lines += "{5277}{5309}You want some water with that?\n"
    lines += "{5362}{5396}Looks like you had a night.\n"

    File.open(path, 'r') do |subs|
      subs.read.should eq lines
    end

  end

  it 'saves from MicroDVD to SubViewer format' do
    lines = "{5277}{5309}You want some water with that?\n"
    lines += "{5311}{5345}No, no.|No, I don't.\n"
    lines += "{5362}{5396}Looks like you had a night.\n"

    File.open(path, 'w') do |subs|
      subs.write(lines)
    end

    `ruby #{exec} -f #{path} -op save -nf #{path} -t sv`

    lines = "[STYLE]no\n"
    lines += "00:03:40.095,00:03:41.429\n"
    lines += "You want some water with that?\n\n"
    lines += "00:03:41.513,00:03:42.931\n"
    lines += "No, no.[br]No, I don't.\n\n"
    lines += "00:03:43.640,00:03:45.058\n"
    lines += "Looks like you had a night.\n\n"

    File.open(path, 'r') do |subs|
      subs.read.should eq lines
    end

  end

  it 'saves from SubViewer to SubRip format' do
    lines = "[STYLE]no\n"
    lines += "00:03:40.095,00:03:41.429\n"
    lines += "You want some water with that?\n\n"
    lines += "00:03:41.513,00:03:42.931\n"
    lines += "No, no.[br]No, I don't.\n\n"
    lines += "00:03:43.640,00:03:45.058\n"
    lines += "Looks like you had a night.\n\n"

    File.open(path, 'w') do |subs|
      subs.write(lines)
    end

    `ruby #{exec} -f #{path} -op save -nf #{path} -t sr`

    lines = "1\n"
    lines += "00:03:40,095 --> 00:03:41,429\n"
    lines += "You want some water with that?\n\n"
    lines += "2\n"
    lines += "00:03:41,513 --> 00:03:42,931\n"
    lines += "No, no.\nNo, I don't.\n\n"
    lines += "3\n"
    lines += "00:03:43,640 --> 00:03:45,058\n"
    lines += "Looks like you had a night.\n\n"

    File.open(path, 'r') do |subs|
      subs.read.should eq lines
    end

  end

  it 'saves from SubViewer to MicroDVD format' do
    lines = "[STYLE]no\n"
    lines += "00:03:40.095,00:03:41.429\n"
    lines += "You want some water with that?\n\n"
    lines += "00:03:41.513,00:03:42.931\n"
    lines += "No, no.[br]No, I don't.\n\n"
    lines += "00:03:43.640,00:03:45.058\n"
    lines += "Looks like you had a night.\n\n"

    File.open(path, 'w') do |subs|
      subs.write(lines)
    end

    `ruby #{exec} -f #{path} -op save -nf #{path} -t md`

    lines = "{1}{1}23.976\n"
    lines += "{5277}{5309}You want some water with that?\n"
    lines += "{5311}{5345}No, no.|No, I don't.\n"
    lines += "{5362}{5396}Looks like you had a night.\n"

    File.open(path, 'r') do |subs|
      subs.read.should eq lines
    end

  end

  it 'saves from SubViewer to SubViewer format' do
    lines = "[STYLE]no\n"
    lines += "00:03:40.095,00:03:41.429\n"
    lines += "You want some water with that?\n\n"
    lines += "00:03:41.513,00:03:42.931\n"
    lines += "No, no.[br]No, I don't.\n\n"
    lines += "00:03:43640,00:03:45.058\n"
    lines += "Looks like you had a night.\n\n"

    File.open(path, 'w') do |subs|
      subs.write(lines)
    end

    `ruby #{exec} -f #{path} -op save -nf #{path} -t sv`

    lines = "[STYLE]no\n"
    lines += "00:03:40.095,00:03:41.429\n"
    lines += "You want some water with that?\n\n"
    lines += "00:03:41.513,00:03:42.931\n"
    lines += "No, no.[br]No, I don't.\n\n"

    File.open(path, 'r') do |subs|
      subs.read.should eq lines
    end

  end

end
