require 'subtitle-library'
require 'fakefs/safe'

describe SubsWriter do
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

  def new_writer(path)
    reader = SubsReader.new path
    reader.load_cues
    SubsWriter.new reader
  end

  describe 'saving from subrip to subrip format' do
    path = 'subs.srt'

    it 'saves the file as is when syntax is correct' do
      FakeFS do
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
        
        new_writer(path).save_as(path, 'sr')

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

      end
    end

    it 'saves the valid cues when syntax is incorrect' do
      FakeFS do
        lines = "1\n"
        lines += "00:03:40095 --> 00:03:41,429\n"
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
        
        new_writer(path).save_as(path, 'sr')

        lines = "1\n"
        lines += "00:03:41,513 --> 00:03:42,931\n"
        lines += "No, no.\nNo, I don't.\n\n"
        lines += "2\n"
        lines += "00:03:43,640 --> 00:03:45,058\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

        lines = "1\n"
        lines += "00:03:40,095 --> 00:03:41,429\n"
        lines += "You want some water with that?\n\n"
        lines += "2\n"
        lines += "00:03:41,513 -> 00:03:42,931\n"
        lines += "No, no.\nNo, I don't.\n\n"
        lines += "3\n"
        lines += "00:03:43,640 --> 0003:45,058\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end
        
        new_writer(path).save_as(path, 'sr')

        lines = "1\n"
        lines += "00:03:40,095 --> 00:03:41,429\n"
        lines += "You want some water with that?\n\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

      end
    end
  end

  describe 'saving from subrip to microdvd format' do
    path = 'subs.sub'

    it 'saves all the cues when syntax is correct' do
      FakeFS do
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
        
        new_writer(path).save_as(path, 'md')

        lines = "{1}{1}23.976\n"
        lines += "{5277}{5309}You want some water with that?\n"
        lines += "{5311}{5345}No, no.|No, I don't.\n"
        lines += "{5362}{5396}Looks like you had a night.\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

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
        
        new_writer(path).save_as(path, 'md', 25)

        lines = "{1}{1}25.0\n"
        lines += "{5503}{5536}You want some water with that?\n"
        lines += "{5538}{5574}No, no.|No, I don't.\n"
        lines += "{5591}{5627}Looks like you had a night.\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

      end
    end

    it 'saves the valid cues when syntax is incorrect' do
      FakeFS do
        lines = "1\n"
        lines += "00:03:40,095 --> 00:03:41,429\n"
        lines += "You want some water with that?\n\n"
        lines += "2\n"
        lines += "00:03:41,513 -> 00:03:42,931\n"
        lines += "No, no.\nNo, I don't.\n\n"
        lines += "3\n"
        lines += "00:03:43,640 --> 00:03:45,058\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end
        
        new_writer(path).save_as(path, 'md')

        lines = "{1}{1}23.976\n"
        lines += "{5277}{5309}You want some water with that?\n"
        lines += "{5362}{5396}Looks like you had a night.\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

        lines = "1\n"
        lines += "00:03:40095 --> 00:03:41,429\n"
        lines += "You want some water with that?\n\n"
        lines += "2\n"
        lines += "00:03:41,513 --> 00:03:42,931\n"
        lines += "No, no.\nNo, I don't.\n\n"
        lines += "3\n"
        lines += "00:03:43,640 --> 00:035,058\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end
        
        new_writer(path).save_as(path, 'md', 25)

        lines = "{1}{1}25.0\n"
        lines += "{5538}{5574}No, no.|No, I don't.\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

      end

    end
  end

  describe 'saving from subrip to subviewer format' do
    path = 'subs.sub'

    it 'saves all the cues when syntax is correct' do
      FakeFS do
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
        
        new_writer(path).save_as(path, 'sv')

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
    end

    it 'saves the valid cues when syntax is incorrect' do
      FakeFS do
        lines = "1\n"
        lines += "00:03:40095 --> 00:03:41,429\n"
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
        
        new_writer(path).save_as(path, 'sv')

        lines = "[STYLE]no\n"
        lines += "00:03:41.513,00:03:42.931\n"
        lines += "No, no.[br]No, I don't.\n\n"
        lines += "00:03:43.640,00:03:45.058\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

        lines = "1\n"
        lines += "00:03:40,095 --> 00:03:41,429\n"
        lines += "You want some water with that?\n\n"
        lines += "2\n"
        lines += "00:03:41,513 -> 00:03:42,931\n"
        lines += "No, no.\nNo, I don't.\n\n"
        lines += "3\n"
        lines += "00:03:43,640 --> 0003:45,058\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end
        
        new_writer(path).save_as(path, 'sv')

        lines = "[STYLE]no\n"
        lines += "00:03:40.095,00:03:41.429\n"
        lines += "You want some water with that?\n\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

      end
    end
  end

  describe 'saving from microdvd to subrip format' do
    path = 'subs.srt'

    it 'saves all the cues when syntax is correct' do
      FakeFS do
        lines = "{5277}{5309}You want some water with that?\n"
        lines += "{5311}{5345}No, no.|No, I don't.\n"
        lines += "{5362}{5396}Looks like you had a night.\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end
        
        new_writer(path).save_as(path, 'sr')

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

        lines = "{5277}{5309}You want some water with that?\n"
        lines += "{5311}{5345}No, no.|No, I don't.\n"
        lines += "{5362}{5396}Looks like you had a night.\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end
        
        new_writer(path).save_as(path, 'sr', 25)

        lines = "1\n"
        lines += "00:03:31,080 --> 00:03:32,360\n"
        lines += "You want some water with that?\n\n"
        lines += "2\n"
        lines += "00:03:32,439 --> 00:03:33,800\n"
        lines += "No, no.\nNo, I don't.\n\n"
        lines += "3\n"
        lines += "00:03:34,479 --> 00:03:35,840\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

      end
    end

    it 'saves the valid cues when syntax is incorrect' do
      FakeFS do
        lines = "{5277{5309}You want some water with that?\n"
        lines += "{5311}{5345}No, no.|No, I don't.\n"
        lines += "{5362}{5396}Looks like you had a night.\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end
        
        new_writer(path).save_as(path, 'sr')

        lines = "1\n"
        lines += "00:03:41,513 --> 00:03:42,931\n"
        lines += "No, no.\nNo, I don't.\n\n"
        lines += "2\n"
        lines += "00:03:43,640 --> 00:03:45,058\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

        lines = "{5277}{5309}You want some water with that?\n"
        lines += "{5311}{345}No, no.|No, I don't.\n"
        lines += "{5362}{5396}Looks like you had a night.\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end
        
        new_writer(path).save_as(path, 'sr', 25)

        lines = "1\n"
        lines += "00:03:31,080 --> 00:03:32,360\n"
        lines += "You want some water with that?\n\n"
        lines += "2\n"
        lines += "00:03:34,479 --> 00:03:35,840\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

      end
    end
  end

  describe 'saving from microdvd to microdvd format' do
    path = 'subs.sub'

    it 'saves the file as is when syntax is correct' do
      FakeFS do
        lines = "{5277}{5309}You want some water with that?\n"
        lines += "{5311}{5345}No, no. No, I don't.\n"
        lines += "{5362}{5396}Looks like you had a night.\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end

        new_writer(path).save_as(path, 'md')

        lines = "{1}{1}23.976\n" + lines

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end
      end
    end

    it 'saves only the valid cues when syntax is incorrect' do
      FakeFS do
        lines = "{5277}{5309}You want some water with that?\n"
        lines += "{5311}5345}No, no. No, I don't.\n"
        lines += "{5362}{5396}Looks like you had a night.\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end

        new_writer(path).save_as(path, 'md')

        lines = "{1}{1}23.976\n" + "{5277}{5309}You want some water with that?\n"
        lines += "{5362}{5396}Looks like you had a night.\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end
      end
    end
  end

  describe 'saving from microdvd to subviewer format' do
    path = 'subs.sub'

    it 'saves all the cues when syntax is correct' do
      FakeFS do
        lines = "{5277}{5309}You want some water with that?\n"
        lines += "{5311}{5345}No, no.|No, I don't.\n"
        lines += "{5362}{5396}Looks like you had a night.\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end
        
        new_writer(path).save_as(path, 'sv')

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

        lines = "{5277}{5309}You want some water with that?\n"
        lines += "{5311}{5345}No, no.|No, I don't.\n"
        lines += "{5362}{5396}Looks like you had a night.\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end
        
        new_writer(path).save_as(path, 'sv', 25)

        lines = "[STYLE]no\n"
        lines += "00:03:31.080,00:03:32.360\n"
        lines += "You want some water with that?\n\n"
        lines += "00:03:32.439,00:03:33.800\n"
        lines += "No, no.[br]No, I don't.\n\n"
        lines += "00:03:34.479,00:03:35.840\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

      end
    end

    it 'saves the valid cues when syntax is incorrect' do
      FakeFS do
        lines = "{5277{5309}You want some water with that?\n"
        lines += "{5311}{5345}No, no.|No, I don't.\n"
        lines += "{5362}{5396}Looks like you had a night.\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end
        
        new_writer(path).save_as(path, 'sv')

        lines = "[STYLE]no\n"
        lines += "00:03:41.513,00:03:42.931\n"
        lines += "No, no.[br]No, I don't.\n\n"
        lines += "00:03:43.640,00:03:45.058\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

        lines = "{5277}{5309}You want some water with that?\n"
        lines += "{5311}{345}No, no.|No, I don't.\n"
        lines += "{5362}{5396}Looks like you had a night.\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end
        
        new_writer(path).save_as(path, 'sv', 25)

        lines = "[STYLE]no\n"
        lines += "00:03:31.080,00:03:32.360\n"
        lines += "You want some water with that?\n\n"
        lines += "00:03:34.479,00:03:35.840\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

      end
    end
  end

  describe 'saving from subviewer to subrip format' do
    path = 'subs.srt'

    it 'saves all the cues when syntax is correct' do
      FakeFS do
        lines = "00:03:40.095,00:03:41.429\n"
        lines += "You want some water with that?\n\n"
        lines += "00:03:41.513,00:03:42.931\n"
        lines += "No, no.[br]No, I don't.\n\n"
        lines += "00:03:43.640,00:03:45.058\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end

        lines = "1\n"
        lines += "00:03:40,095 --> 00:03:41,429\n"
        lines += "You want some water with that?\n\n"
        lines += "2\n"
        lines += "00:03:41,513 --> 00:03:42,931\n"
        lines += "No, no.\nNo, I don't.\n\n"
        lines += "3\n"
        lines += "00:03:43,640 --> 00:03:45,058\n"
        lines += "Looks like you had a night.\n\n"
        
        new_writer(path).save_as(path, 'sr')

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

      end
    end

    it 'saves the valid cues when syntax is incorrect' do
      FakeFS do

        lines = "00:03:40,095,00:03:41.429\n"
        lines += "You want some water with that?\n\n"
        lines += "00:03:41.513,00:03:42.931\n"
        lines += "No, no.[br]No, I don't.\n\n"
        lines += "00:03:43.640,00:03:45.058\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end
        
        new_writer(path).save_as(path, 'sr')

        lines = "1\n"
        lines += "00:03:41,513 --> 00:03:42,931\n"
        lines += "No, no.\nNo, I don't.\n\n"
        lines += "2\n"
        lines += "00:03:43,640 --> 00:03:45,058\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

        lines = "00:03:40.095,00:03:41.429\n"
        lines += "You want some water with that?\n\n"
        lines += "00:03:41.,00:03:42.931\n"
        lines += "No, no.[br]No, I don't.\n\n"
        lines += "00:03:43.64000:03:45.058\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end
        
        new_writer(path).save_as(path, 'sr')

        lines = "1\n"
        lines += "00:03:40,095 --> 00:03:41,429\n"
        lines += "You want some water with that?\n\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

      end
    end
  end

  describe 'saving from subviewer to microdvd format' do
    path = 'subs.sub'

    it 'saves all the cues when syntax is correct' do
      FakeFS do

        lines = "00:03:40.095,00:03:41.429\n"
        lines += "You want some water with that?\n\n"
        lines += "00:03:41.513,00:03:42.931\n"
        lines += "No, no.[br]No, I don't.\n\n"
        lines += "00:03:43.640,00:03:45.058\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end
        
        new_writer(path).save_as(path, 'md')

        lines = "{1}{1}23.976\n"
        lines += "{5277}{5309}You want some water with that?\n"
        lines += "{5311}{5345}No, no.|No, I don't.\n"
        lines += "{5362}{5396}Looks like you had a night.\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

        lines = "00:03:40.095,00:03:41.429\n"
        lines += "You want some water with that?\n\n"
        lines += "00:03:41.513,00:03:42.931\n"
        lines += "No, no.[br]No, I don't.\n\n"
        lines += "00:03:43.640,00:03:45.058\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end
        
        new_writer(path).save_as(path, 'md', 25)

        lines = "{1}{1}25.0\n"
        lines += "{5503}{5536}You want some water with that?\n"
        lines += "{5538}{5574}No, no.|No, I don't.\n"
        lines += "{5591}{5627}Looks like you had a night.\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

      end
    end

    it 'saves the valid cues when syntax is incorrect' do
      FakeFS do

        lines = "00:03:40.095,00:03:41.429\n"
        lines += "You want some water with that?\n\n"
        lines += "00:03:41.51300:03:42.931\n"
        lines += "No, no.[br]No, I don't.\n\n"
        lines += "00:03:43.640,00:03:45.058\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end
        
        new_writer(path).save_as(path, 'md')

        lines = "{1}{1}23.976\n"
        lines += "{5277}{5309}You want some water with that?\n"
        lines += "{5362}{5396}Looks like you had a night.\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

        lines = "00:03:40.095,0003:41.429\n"
        lines += "You want some water with that?\n\n"
        lines += "00:03:41.513,00:03:42.931\n"
        lines += "No, no.[br]No, I don't.\n\n"
        lines += "00:03:43;640,00:03:45.058\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end
        
        new_writer(path).save_as(path, 'md', 25)

        lines = "{1}{1}25.0\n"
        lines += "{5538}{5574}No, no.|No, I don't.\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

      end

    end
  end

  describe 'saving from subviewer to subviewer format' do
    path = 'subs.sub'

    it 'saves the file as is when syntax is correct' do
      FakeFS do

        lines = "00:03:40.095,00:03:41.429\n"
        lines += "You want some water with that?\n\n"
        lines += "00:03:41.513,00:03:42.931\n"
        lines += "No, no.[br]No, I don't.\n\n"
        lines += "00:03:43.640,00:03:45.058\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end
        
        new_writer(path).save_as(path, 'sv')

        lines = "[STYLE]no\n" + lines

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

      end
    end

    it 'saves the valid cues when syntax is incorrect' do
      FakeFS do

        lines = "00:03:40.095,00:03:34.429\n"
        lines += "You want some water with that?\n\n"
        lines += "00:03:41.513,00:03:42.931\n"
        lines += "No, no.[br]No, I don't.\n\n"
        lines += "00:03:43.640,00:03:45.058\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end
        
        new_writer(path).save_as(path, 'sv')

        lines = "[STYLE]no\n"
        lines += "00:03:41.513,00:03:42.931\n"
        lines += "No, no.[br]No, I don't.\n\n"
        lines += "00:03:43.640,00:03:45.058\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

        lines = "00:03:40.095,00:03:41.429\n"
        lines += "You want some water with that?\n\n"
        lines += "00:03:41.513,00:03;42.931\n"
        lines += "No, no.[br]No, I don't.\n\n"
        lines += "00:03:43.640.00:03:45.058\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end
        
        new_writer(path).save_as(path, 'sv')

        lines = "[STYLE]no\n"
        lines += "00:03:40.095,00:03:41.429\n"
        lines += "You want some water with that?\n\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

      end
    end
  end

end
