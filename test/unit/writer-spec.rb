$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..', 'lib', 'subtitle-library')
require 'writer'
require 'reader'
require 'fakefs/safe'

describe SubsWriter do
  include FakeFS

  def setup
    FakeFS.activate!
    FileSystem.clear
  end

  def teardown
    FakeFS.deactivate!
  end

  def new_writer(path)
    SubsWriter.new (SubsReader.new path)
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

  describe 'saving from microdvd to subrip format' do
    path = 'subs.sub'

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
end
