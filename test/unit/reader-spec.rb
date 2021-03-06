require 'subtitle-library'
require 'fakefs/safe'

describe SubsReader do
  include FakeFS

  RSpec.configure do |config|
    config.before(:each) do
      FakeFS.activate!
      FileSystem.clear
    end 
  end 
  
  RSpec.configure do |config|
    config.after(:each) do
      FakeFS.deactivate!
    end
  end

  def new_reader(path)
    SubsReader.new path
  end

  describe 'type finding' do
    path = 'subs.sub'

    it 'validates the type correctly' do
      FakeFS do
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
        new_reader(path).type.should eq 'sr'

        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                        {5277}{5309}You want some water with that?
                        {5311}{5345}No, no. No, I don't.
                        {5362}{5396}Looks like you had a night.
                        {5529}{5562}They look perfect.
                        eos
                    )
        end
        new_reader(path).type.should eq 'md'

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
        new_reader(path).type.should eq 'sv'

        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                        some
                        other
                        format
                        eos
                    )
        end
        new_reader(path).type.should eq 'uk'
      end
    end
  end
end

describe SubRipReader do
  include FakeFS

  def setup
    FakeFS.activate!
    FileSystem.clear
  end

  def teardown
    FakeFS.deactivate!
  end

  def new_reader(path)
    SubRipReader.new path
  end

  describe 'syntax checking' do
    path = 'subs.srt'

    it 'validates correct syntax' do
      FakeFS do
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
        new_reader(path).read_subs(true).should eq "No errors were found."

        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                      12
                      00:02:04,240--> 00:02:05,593
                      It was funny, huh?

                      13
                      00:02:06,20 --> 00:02:07,639
                      Yes, but I have to go.

                      1
                      00:2:07,840-->00:02:09,831
                      That'll teach you to excite yourself like this.

                      15
                      00:02:10,00 --> 00:02:12,5
                      Stop somewhere if you can.
                    eos
                    )
        end
        new_reader(path).read_subs(true).should eq "No errors were found."

        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                      12
                      00:02:04,240 --> 00:02:05,593
                      It was funny, huh?

                      13
                      00:02:06,320-->00:02:07,639
                      Yes, but I have to go.


                      00:02:07,840 --> 00:02:09,831
                      That'll
                      teach you to
                      excite yourself

                      like this.

                      15
                      00:02:10,040 --> 00:02:12,508
                      Stop somewhere if you can.

                      16
                      00:02:43,560 --> 0:2:46,028
                      Honey,
                      you're not at school.
                      Don't bother poor Elly.
                    eos
                    )
        end
        new_reader(path).read_subs(true).should eq "No errors were found."
      end
      
    end

    it 'validates invalid timing' do
      FakeFS do
        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                      12
                      00:02:04,240 --> 00:02:04,3
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

        new_reader(path).read_subs(true).should eq "Invalid timing at line 2."

        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                      12
                      00:02:04,240 --> 00:02:05,593
                      It was funny, huh?

                      13
                      00:02:06,320 --> 00:02:06,320
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

        new_reader(path).read_subs(true).should eq "Invalid timing at line 6."

        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                      12
                      00:02:04,240 --> 00:02:03,593
                      It was funny, huh?

                      13
                      00:02:06,320 --> 00:02:07,639
                      Yes, but I have to go.

                      14
                      00:02:07,840 --> 00:02:07,831
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

        new_reader(path).read_subs(true).should eq "Invalid timing at line 2.\nInvalid timing at line 10."
      end
      
    end

    it 'validates invalid start-end time format' do
      FakeFS do
        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                      12
                      00:02:04,240 --> 00:02:05,593
                      It was funny, huh?

                      13
                      00:02:06320 --> 00:02:07,639
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

        new_reader(path).read_subs(true).should eq "Syntax error at line 6."

        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                      12
                      00:02:04,240 --> 00:02:05593
                      It was funny, huh?

                      13
                      00:02:06,320 --> 00:02:07,639
                      Yes, but I have to go.

                      14
                      00:02:07,840 -> 00:02:09,831
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

        new_reader(path).read_subs(true).should eq "Syntax error at line 2.\nSyntax error at line 10."

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
                      00:02:43,560 -- 00:02:46,028
                      Honey, you're not at school.
                      Don't bother poor Elly.
                    eos
                    )
        end

        new_reader(path).read_subs(true).should eq "Syntax error at line 18."
      end
      
    end

    it 'validates invalid text between index and start-end time lines' do
      FakeFS do
        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                      12
                      00:02:04,240 --> 00:02:05,593
                      It was funny, huh?

                      1
                      s
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
        new_reader(path).read_subs(true).should eq "Syntax error at line 6."

        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                      12
                      00:02:04,240 --> 00:02:05,593
                      It was funny, huh?

                      1
                      s
                      00:02:06,320 --> 00:02:07,639
                      Yes, but I have to go.

                      14
                      00:02:07,840 --> 00:02:09,831
                      That'll teach you to excite yourself like this.

                      15
                      00:02:10,040 --> 00:02:12,508
                      Stop somewhere if you can.

                      16
                      a
                      00:02:43,560 --> 00:02:46,028
                      Honey, you're not at school.
                      Don't bother poor Elly.
                    eos
                    )
        end
        new_reader(path).read_subs(true).should eq "Syntax error at line 6.\nSyntax error at line 19."

      end
    end
  end

  describe 'cue loading' do
    path = 'subs.srt'

    it 'loads all cues when syntax is correct' do
      FakeFS do
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
                      That'll teach you to excite
                      yourself like this.
                      eos
                      )
        end
        cues = []
        cues << Cue.new(Time.mktime(1, 1, 1, 0, 2, 4, 240000), Time.mktime(1, 1, 1, 0, 2, 5, 593000), "It was funny, huh?")
        cues << Cue.new(Time.mktime(1, 1, 1, 0, 2, 6, 320000), Time.mktime(1, 1, 1, 0, 2, 7, 639000), "Yes, but I have to go.")
        cues << Cue.new(Time.mktime(1, 1, 1, 0, 2, 7, 840000), Time.mktime(1, 1, 1, 0, 2, 9, 831000), "That'll teach you to excite\nyourself like this.")
        
        new_reader(path).read_subs(false)[0].should eq cues
      end
    end

    it 'loads the valid cues when syntax is incorrect' do
      FakeFS do
        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                      12
                      00:02:04,240 --> 00:02:05,593
                      It was funny, huh?

                      13
                      00:02:06,320 -- 00:02:07,639
                      Yes, but I have to go.

                      14
                      00:02:07,840 --> 00:02:09,831
                      That'll teach you to excite
                      yourself like this.
                      eos
                      )
        end
        cues = []
        cues << Cue.new(Time.mktime(1, 1, 1, 0, 2, 4, 240000), Time.mktime(1, 1, 1, 0, 2, 5, 593000), "It was funny, huh?")
        cues << Cue.new(Time.mktime(1, 1, 1, 0, 2, 7, 840000), Time.mktime(1, 1, 1, 0, 2, 9, 831000), "That'll teach you to excite\nyourself like this.")
        
        new_reader(path).read_subs(false)[0].should eq cues

        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                      12
                      00:02:04240 --> 00:02:05,593
                      It was funny, huh?

                      13
                      00:02:06,320 --> 00:02:07,639
                      Yes, but I have to go.

                      14
                      00:02:07,840 --> 00:02:03,831
                      That'll teach you to excite
                      yourself like this.
                      eos
                      )
        end
        cues = []
        cues << Cue.new(Time.mktime(1, 1, 1, 0, 2, 6, 320000), Time.mktime(1, 1, 1, 0, 2, 7, 639000), "Yes, but I have to go.")

        new_reader(path).read_subs(false)[0].should eq cues
      end
    end

  end
end

describe MicroDVDReader do
  include FakeFS

  def setup
    FakeFS.activate!
    FileSystem.clear
  end

  def teardown
    FakeFS.deactivate!
  end

  def new_reader(path)
    MicroDVDReader.new path
  end

  describe 'syntax checking' do
    path = 'subs.sub'

    it 'validates correct syntax' do
      FakeFS do
        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                        {5277}{5309}You want some water with that?
                        {5311}{5345}No, no. No, I don't.
                        {5362}{5396}Looks like you had a night.
                        {5529}{5562}They look perfect.
                        eos
                    )
        end

        new_reader(path).read_subs(true).should eq "No errors were found."

        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                        {5277}{5309}{y:i}You want some water with that?
                        {5311}{5345}No, no. No, I don't.
                        {5362}{5396}Looks like you had a night.
                        {5529}{5562}They look perfect.
                        eos
                    )
        end

        new_reader(path).read_subs(true).should eq "No errors were found."

      end
    end

    it 'validates invalid frames' do
      FakeFS do
        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                        {5277}{309}You want some water with that?
                        {5311}{5345}No, no. No, I don't.
                        {5362}{5396}Looks like you had a night.
                        {5529}{5562}They look perfect.
                        eos
                    )
        end

        new_reader(path).read_subs(true).should eq "Syntax error at line 1."

        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                        {5277}{5309}{y:i}You want some water with that?
                        {5311}{535}No, no. No, I don't.
                        {5362}{5396}Looks like you had a night.
                        {552}{5562}They look perfect.
                        eos
                    )
        end

        new_reader(path).read_subs(true).should eq "Syntax error at line 2.\nSyntax error at line 4."

      end
    end

    it 'validates invalid frame format' do
      FakeFS do
        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                        {5277}5309}You want some water with that?
                        {5311}{5345}No, no. No, I don't.
                        {5362}{5396}Looks like you had a night.
                        {5529}{5562}They look perfect.
                        eos
                    )
        end

        new_reader(path).read_subs(true).should eq "Syntax error at line 1."

        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                        {5277}{5309}{y:i}You want some water with that?
                        {5311}{5345}No, no. No, I don't.
                        {,5362}{5396}Looks like you had a night.
                        {5529{5562}They look perfect.
                        eos
                    )
        end

        new_reader(path).read_subs(true).should eq "Syntax error at line 3.\nSyntax error at line 4."

      end
    end

  end

  describe 'reading finds the fps if available' do
    path = 'subs.sub'

    it 'validates correct syntax' do
      FakeFS do
        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                        {5277}{5309}You want some water with that?
                        {5311}{5345}No, no. No, I don't.
                        {5362}{5396}Looks like you had a night.
                        {5529}{5562}They look perfect.
                        eos
                    )
        end

        new_reader(path).read_subs(false)[1].should eq 23.976

        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                        {1}{1}25
                        {5311}{5345}No, no. No, I don't.
                        {5362}{5396}Looks like you had a night.
                        {5529}{5562}They look perfect.
                        eos
                    )
        end

        new_reader(path).read_subs(false)[1].should eq 25
      end
    end
  end

  describe 'cue loading' do
    path = 'subs.sub'

    it 'loads all cues when syntax is correct' do
      FakeFS do
        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                        {5277}{5309}You want some water with that?
                        {5311}{5345}No, no.|No, I don't.
                        {5362}{5396}Looks like you had a night.
                        eos
                    )
        end

        cues = []
        cues << Cue.new(5277, 5309, "You want some water with that?")
        cues << Cue.new(5311, 5345, "No, no.\nNo, I don't.")
        cues << Cue.new(5362, 5396, "Looks like you had a night.")
        
        new_reader(path).read_subs(false)[0].should eq cues
      end
    end

    it 'loads valid cues when syntax is incorrect' do
      FakeFS do
        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                        {5277}{309}You want some water with that?
                        {5311}{5345}No, no.|No, I don't.
                        {5362}{5396}Looks like you had a night.
                        eos
                    )
        end

        cues = []
        cues << Cue.new(5311, 5345, "No, no.\nNo, I don't.")
        cues << Cue.new(5362, 5396, "Looks like you had a night.")
        
        new_reader(path).read_subs(false)[0].should eq cues

        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                        {5277{5309}You want some water with that?
                        {5311}{5345}No, no.|No, I don't.
                        {532}{5396}Looks like you had a night.
                        eos
                    )
        end

        cues = []
        cues << Cue.new(5311, 5345, "No, no.\nNo, I don't.")
        
        new_reader(path).read_subs(false)[0].should eq cues
      end
    end

  end

end

describe SubviewerReader do
  include FakeFS

  def setup
    FakeFS.activate!
    FileSystem.clear
  end

  def teardown
    FakeFS.deactivate!
  end

  def new_reader(path)
    SubviewerReader.new path
  end

  describe 'syntax checking' do
    path = 'subs.sub'

    it 'validates correct syntax' do
      FakeFS do
        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                      00:02:04.240,00:02:05.593
                      It was funny, huh?

                      00:02:06.320,00:02:07.639
                      Yes, but I have to go.

                      00:02:07.840,00:02:09.831
                      That'll teach you to excite yourself like this.

                      00:02:10.040,00:02:12.508
                      Stop somewhere if you can.

                      00:02:43.560,00:02:46.028
                      Honey, you're not at school.[br]Don't bother poor Elly.
                    eos
                    )
        end
        new_reader(path).read_subs(true).should eq "No errors were found."

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
        new_reader(path).read_subs(true).should eq "No errors were found."

      end
      
    end

    it 'validates invalid timing' do
      FakeFS do
        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                      00:02:04.240,00:02:04.003
                      It was funny, huh?

                      00:02:06.320,00:02:07.639
                      Yes, but I have to go.

                      00:02:07.840,00:02:09.831
                      That'll teach you to excite yourself like this.

                      00:02:10.040,00:02:12.508
                      Stop somewhere if you can.

                      00:02:43.560,00:02:46.028
                      Honey, you're not at school.[br]Don't bother poor Elly.
                    eos
                    )
        end

        new_reader(path).read_subs(true).should eq "Invalid timing at line 1."

        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                      00:02:04.240,00:02:05.593
                      It was funny, huh?

                      00:02:06.320,00:02:06.320
                      Yes, but I have to go.

                      00:02:07.840,00:02:09.831
                      That'll teach you to excite yourself like this.

                      00:02:10.040,00:02:12.508
                      Stop somewhere if you can.

                      00:02:43.560,00:02:46.028
                      Honey, you're not at school.[br]Don't bother poor Elly.
                    eos
                    )
        end

        new_reader(path).read_subs(true).should eq "Invalid timing at line 4."

        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                      00:02:04.240,00:02:03.593
                      It was funny, huh?

                      00:02:06.320,00:02:07.639
                      Yes, but I have to go.

                      00:02:07.840,00:02:07.831
                      That'll teach you to excite yourself like this.

                      00:02:10.040,00:02:12.508
                      Stop somewhere if you can.

                      00:02:43.560,00:02:46.028
                      Honey, you're not at school.[br]Don't bother poor Elly.
                    eos
                    )
        end

        new_reader(path).read_subs(true).should eq "Invalid timing at line 1.\nInvalid timing at line 7."
      end
      
    end

    it 'validates invalid start-end time format' do
      FakeFS do
        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                      00:02:04.240,00:02:05.593
                      It was funny, huh?

                      00:02:06320,00:02:07.639
                      Yes, but I have to go.

                      00:02:07.840,00:02:09.831
                      That'll teach you to excite yourself like this.

                      00:02:10.040,00:02:12.508
                      Stop somewhere if you can.

                      00:02:43.560,00:02:46.028
                      Honey, you're not at school.[br]Don't bother poor Elly.
                    eos
                    )
        end

        new_reader(path).read_subs(true).should eq "Syntax error at line 4."

        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                      00:02:04.240,00:02:05593
                      It was funny, huh?

                      00:02:06.320,00:02:07.639
                      Yes, but I have to go.

                      00:02:07.84000:02:09.831
                      That'll teach you to excite yourself like this.

                      00:02:10.040,00:02:12.508
                      Stop somewhere if you can.

                      00:02:43.560,00:02:46.028
                      Honey, you're not at school.[br]Don't bother poor Elly.
                    eos
                    )
        end

        new_reader(path).read_subs(true).should eq "Syntax error at line 1.\nSyntax error at line 7."

        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                      00:02:04.240,00:02:05.593
                      It was funny, huh?

                      00:02:06.320,00:02:07.639
                      Yes, but I have to go.

                      00:02:07.840,00:02:09.831
                      That'll teach you to excite yourself like this.

                      00:02:10.040,00:02:12.508
                      Stop somewhere if you can.

                      00:02:43,560,00:02:46.028
                      Honey, you're not at school.[br]Don't bother poor Elly.
                    eos
                    )
        end

        new_reader(path).read_subs(true).should eq "Syntax error at line 13."
      end
      
    end

    it 'validates invalid text after a line of valid text' do
      FakeFS do
        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                      00:02:04.240,00:02:05.593
                      It was funny, huh?
                      s

                      00:02:06.320,00:02:07.639
                      Yes, but I have to go.

                      00:02:07.840,00:02:09.831
                      That'll teach you to excite yourself like this.

                      00:02:10.040,00:02:12.508
                      Stop somewhere if you can.

                      00:02:43.560,00:02:46.028
                      Honey, you're not at school.[br]Don't bother poor Elly.
                    eos
                    )
        end
        new_reader(path).read_subs(true).should eq "Syntax error at line 3."

        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                      00:02:04.240,00:02:05.593
                      It was funny, huh?

                      00:02:06.320,00:02:07.639
                      Yes, but I have to go.

                      00:02:07.840,00:02:09.831
                      That'll teach you to excite yourself like this.
                      s

                      00:02:10.040,00:02:12.508
                      Stop somewhere if you can.

                      00:02:43.560,00:02:46.028
                      Honey, you're not at school.[br]Don't bother poor Elly.
                    eos
                    )
        end
        new_reader(path).read_subs(true).should eq "Syntax error at line 9."

      end
    end
  end

  describe 'cue loading' do
    path = 'subs.sub'

    it 'loads all cues when syntax is correct' do
      FakeFS do
        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                      00:02:04.240,00:02:05.593
                      It was funny, huh?

                      00:02:06.320,00:02:07.639
                      Yes, but I have to go.

                      00:02:07.840,00:02:09.831
                      That'll teach you to excite[br]yourself like this.
                      eos
                      )
        end
        cues = []
        cues << Cue.new(Time.mktime(1, 1, 1, 0, 2, 4, 240000), Time.mktime(1, 1, 1, 0, 2, 5, 593000), "It was funny, huh?")
        cues << Cue.new(Time.mktime(1, 1, 1, 0, 2, 6, 320000), Time.mktime(1, 1, 1, 0, 2, 7, 639000), "Yes, but I have to go.")
        cues << Cue.new(Time.mktime(1, 1, 1, 0, 2, 7, 840000), Time.mktime(1, 1, 1, 0, 2, 9, 831000), "That'll teach you to excite\nyourself like this.")
        
        new_reader(path).read_subs(false)[0].should eq cues
      end
    end

    it 'loads the valid cues when syntax is incorrect' do
      FakeFS do
        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                      00:02:04.240,00:02:05.593
                      It was funny, huh?

                      00:02:06.320.00:02:07.639
                      Yes, but I have to go.

                      00:02:07.840,00:02:09.831
                      That'll teach you to excite[br]yourself like this.
                      eos
                      )
        end
        cues = []
        cues << Cue.new(Time.mktime(1, 1, 1, 0, 2, 4, 240000), Time.mktime(1, 1, 1, 0, 2, 5, 593000), "It was funny, huh?")
        cues << Cue.new(Time.mktime(1, 1, 1, 0, 2, 7, 840000), Time.mktime(1, 1, 1, 0, 2, 9, 831000), "That'll teach you to excite\nyourself like this.")
        
        new_reader(path).read_subs(false)[0].should eq cues

        File.open(path, 'w') do |subs|
          subs.write(<<-eos
                      00:02:04240,00:02:05.593
                      It was funny, huh?

                      00:02:06.320,00:02:07.639
                      Yes, but I have to go.

                      00:02:07.840,00:02:.831
                      That'll teach you to excite[br]yourself like this.
                      eos
                      )
        end
        cues = []
        cues << Cue.new(Time.mktime(1, 1, 1, 0, 2, 6, 320000), Time.mktime(1, 1, 1, 0, 2, 7, 639000), "Yes, but I have to go.")

        new_reader(path).read_subs(false)[0].should eq cues
      end
    end

  end
end
