$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..', 'lib', 'subtitle-library')
require 'reader'
require 'fakefs/safe'

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
  end
end
