$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..', 'lib', 'subtitle-library')
require 'changer'
require 'fakefs/safe'

describe SubsChanger do
  include FakeFS

  def setup
    FakeFS.activate!
    FileSystem.clear
  end

  def teardown
    FakeFS.deactivate!
  end

  def new_changer(path)
    SubsChanger.new path
  end

  describe 'shifting subrip format' do
    path = 'subs.srt'

    it 'shifts the subtitles by seconds' do
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
        
        new_changer(path).shift('ss', 1.5)

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

        new_changer(path).shift('ss', -3.4)

        lines = "1\n"
        lines += "00:03:38,195 --> 00:03:39,529\n"
        lines += "You want some water with that?\n\n"
        lines += "2\n"
        lines += "00:03:39,613 --> 00:03:41,031\n"
        lines += "No, no.\nNo, I don't.\n\n"
        lines += "3\n"
        lines += "00:03:41,740 --> 00:03:43,158\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end
      end
    end

    it 'shifts the subtitles by frames' do
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
        
        new_changer(path).shift('fs', 45)

        lines = "1\n"
        lines += "00:03:41,971 --> 00:03:43,305\n"
        lines += "You want some water with that?\n\n"
        lines += "2\n"
        lines += "00:03:43,389 --> 00:03:44,807\n"
        lines += "No, no.\nNo, I don't.\n\n"
        lines += "3\n"
        lines += "00:03:45,516 --> 00:03:46,934\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

        new_changer(path).shift('fs', -15, 25)

        lines = "1\n"
        lines += "00:03:40,971 --> 00:03:42,305\n"
        lines += "You want some water with that?\n\n"
        lines += "2\n"
        lines += "00:03:42,389 --> 00:03:43,807\n"
        lines += "No, no.\nNo, I don't.\n\n"
        lines += "3\n"
        lines += "00:03:44,516 --> 00:03:45,934\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end
      end
    end

    it "doesn't shift when an invalid timing is calculated" do
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
        
        new_changer(path).shift('fs', -5280)

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

        new_changer(path).shift('ss', -221)

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end
      end
    end


  end
end
