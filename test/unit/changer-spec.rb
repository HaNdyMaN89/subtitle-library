require 'subtitle-library'
require 'fakefs/safe'

describe SubsChanger do
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

  describe 'shifting microdvd format' do
    path = 'subs.sub'

    it 'shifts the subtitles by frames' do
      FakeFS do
        lines = "{5277}{5309}You want some water with that?\n"
        lines += "{5311}{5345}No, no.|No, I don't.\n"
        lines += "{5362}{5396}Looks like you had a night.\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end

        new_changer(path).shift('fs', 80)

        lines = "{1}{1}23.976\n"
        lines += "{5357}{5389}You want some water with that?\n"
        lines += "{5391}{5425}No, no.|No, I don't.\n"
        lines += "{5442}{5476}Looks like you had a night.\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

        new_changer(path).shift('fs', -100)

        lines = "{1}{1}23.976\n"
        lines += "{5257}{5289}You want some water with that?\n"
        lines += "{5291}{5325}No, no.|No, I don't.\n"
        lines += "{5342}{5376}Looks like you had a night.\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end
      end
    end

    it 'shifts the subtitles by seconds' do
      FakeFS do
        lines = "{5277}{5309}You want some water with that?\n"
        lines += "{5311}{5345}No, no.|No, I don't.\n"
        lines += "{5362}{5396}Looks like you had a night.\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end

        new_changer(path).shift('ss', 10)

        lines = "{1}{1}23.976\n"
        lines += "{5517}{5549}You want some water with that?\n"
        lines += "{5551}{5585}No, no.|No, I don't.\n"
        lines += "{5602}{5636}Looks like you had a night.\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

        new_changer(path).shift('ss', -21.2, 25)

        lines = "{1}{1}23.976\n"
        lines += "{4987}{5019}You want some water with that?\n"
        lines += "{5021}{5055}No, no.|No, I don't.\n"
        lines += "{5072}{5106}Looks like you had a night.\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end
      end
    end

    it "doesn't shift when an invalid timing is calculated" do
      FakeFS do
        lines = "{5277}{5309}You want some water with that?\n"
        lines += "{5311}{5345}No, no.|No, I don't.\n"
        lines += "{5362}{5396}Looks like you had a night.\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end

        new_changer(path).shift('fs', -5300)

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

        new_changer(path).shift('ss', -212, 25)

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end
      end
    end

  end


  describe 'shifting subviewer format' do
    path = 'subs.sub'

    it 'shifts the subtitles by seconds' do
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
        
        new_changer(path).shift('ss', 1.5)

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

        new_changer(path).shift('ss', -3.4)

        lines = "[STYLE]no\n"
        lines += "00:03:38.195,00:03:39.529\n"
        lines += "You want some water with that?\n\n"
        lines += "00:03:39.613,00:03:41.031\n"
        lines += "No, no.[br]No, I don't.\n\n"
        lines += "00:03:41.740,00:03:43.158\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end
      end
    end

    it 'shifts the subtitles by frames' do
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
        
        new_changer(path).shift('fs', 45)

        lines = "[STYLE]no\n"
        lines += "00:03:41.971,00:03:43.305\n"
        lines += "You want some water with that?\n\n"
        lines += "00:03:43.389,00:03:44.807\n"
        lines += "No, no.[br]No, I don't.\n\n"
        lines += "00:03:45.516,00:03:46.934\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

        new_changer(path).shift('fs', -15, 25)

        lines = "[STYLE]no\n"
        lines += "00:03:40.971,00:03:42.305\n"
        lines += "You want some water with that?\n\n"
        lines += "00:03:42.389,00:03:43.807\n"
        lines += "No, no.[br]No, I don't.\n\n"
        lines += "00:03:44.516,00:03:45.934\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end
      end
    end

    it "doesn't shift when an invalid timing is calculated" do
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

  describe 'stretching subrip format' do
    path = 'subs.srt'

    it 'stretches the subtitles by seconds' do
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
        
        new_changer(path).stretch('ss', 1.5)

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

        new_changer(path).stretch('ss', -1.1)

        lines = "1\n"
        lines += "00:03:40,095 --> 00:03:41,429\n"
        lines += "You want some water with that?\n\n"
        lines += "2\n"
        lines += "00:03:41,912 --> 00:03:43,330\n"
        lines += "No, no.\nNo, I don't.\n\n"
        lines += "3\n"
        lines += "00:03:44,439 --> 00:03:45,857\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end
      end
    end

    it 'stretches the subtitles by frames' do
      FakeFS do
        lines = "1\n"
        lines += "00:03:40,095 --> 00:03:40,429\n"
        lines += "You want some water with that?\n\n"
        lines += "2\n"
        lines += "00:03:41,513 --> 00:03:42,931\n"
        lines += "No, no.\nNo, I don't.\n\n"
        lines += "3\n"
        lines += "00:03:44,640 --> 00:03:46,058\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end
        
        new_changer(path).stretch('fs', 25)

        lines = "1\n"
        lines += "00:03:40,095 --> 00:03:40,429\n"
        lines += "You want some water with that?\n\n"
        lines += "2\n"
        lines += "00:03:42,555 --> 00:03:43,973\n"
        lines += "No, no.\nNo, I don't.\n\n"
        lines += "3\n"
        lines += "00:03:46,725 --> 00:03:48,143\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

        new_changer(path).stretch('fs', -15, 25)

        lines = "1\n"
        lines += "00:03:40,095 --> 00:03:40,429\n"
        lines += "You want some water with that?\n\n"
        lines += "2\n"
        lines += "00:03:41,555 --> 00:03:42,973\n"
        lines += "No, no.\nNo, I don't.\n\n"
        lines += "3\n"
        lines += "00:03:44,725 --> 00:03:46,143\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end
      end
    end

    it "doesn't stretch when an invalid timing is calculated" do
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
        
        new_changer(path).stretch('fs', -10)

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

        new_changer(path).stretch('ss', -0.1)

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end
      end
    end

  end

  describe 'stretching microdvd format' do
    path = 'subs.sub'

    it 'stretchs the subtitles by frames' do
      FakeFS do
        lines = "{5277}{5309}You want some water with that?\n"
        lines += "{5311}{5345}No, no.|No, I don't.\n"
        lines += "{5362}{5396}Looks like you had a night.\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end

        new_changer(path).stretch('fs', 80)

        lines = "{1}{1}23.976\n"
        lines += "{5277}{5309}You want some water with that?\n"
        lines += "{5391}{5425}No, no.|No, I don't.\n"
        lines += "{5522}{5556}Looks like you had a night.\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

        new_changer(path).stretch('fs', -10)

        lines = "{1}{1}23.976\n"
        lines += "{5277}{5309}You want some water with that?\n"
        lines += "{5381}{5415}No, no.|No, I don't.\n"
        lines += "{5502}{5536}Looks like you had a night.\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end
      end
    end

    it 'stretchs the subtitles by seconds' do
      FakeFS do
        lines = "{5277}{5309}You want some water with that?\n"
        lines += "{5311}{5345}No, no.|No, I don't.\n"
        lines += "{5362}{5396}Looks like you had a night.\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end

        new_changer(path).stretch('ss', 10)

        lines = "{1}{1}23.976\n"
        lines += "{5277}{5309}You want some water with that?\n"
        lines += "{5551}{5585}No, no.|No, I don't.\n"
        lines += "{5842}{5876}Looks like you had a night.\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

        new_changer(path).stretch('ss', -1.2, 25)

        lines = "{1}{1}23.976\n"
        lines += "{5277}{5309}You want some water with that?\n"
        lines += "{5521}{5555}No, no.|No, I don't.\n"
        lines += "{5782}{5816}Looks like you had a night.\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end
      end
    end

    it "doesn't stretch when an invalid timing is calculated" do
      FakeFS do
        lines = "{5277}{5309}You want some water with that?\n"
        lines += "{5311}{5345}No, no.|No, I don't.\n"
        lines += "{5362}{5396}Looks like you had a night.\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end

        new_changer(path).stretch('fs', -3)

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

        new_changer(path).stretch('ss', -1, 25)

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end
      end
    end

  end

  describe 'stretching subviewer format' do
    path = 'subs.sub'

    it 'stretches the subtitles by seconds' do
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
        
        new_changer(path).stretch('ss', 1.5)

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

        new_changer(path).stretch('ss', -1.1)

        lines = "[STYLE]no\n"
        lines += "00:03:40.095,00:03:41.429\n"
        lines += "You want some water with that?\n\n"
        lines += "00:03:41.912,00:03:43.330\n"
        lines += "No, no.[br]No, I don't.\n\n"
        lines += "00:03:44.439,00:03:45.857\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end
      end
    end

    it 'stretches the subtitles by frames' do
      FakeFS do
        lines = "00:03:40.095,00:03:40.429\n"
        lines += "You want some water with that?\n\n"
        lines += "00:03:41.513,00:03:42.931\n"
        lines += "No, no.[br]No, I don't.\n\n"
        lines += "00:03:44.640,00:03:46.058\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end
        
        new_changer(path).stretch('fs', 25)

        lines = "[STYLE]no\n"
        lines += "00:03:40.095,00:03:40.429\n"
        lines += "You want some water with that?\n\n"
        lines += "00:03:42.555,00:03:43.973\n"
        lines += "No, no.[br]No, I don't.\n\n"
        lines += "00:03:46.725,00:03:48.143\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

        new_changer(path).stretch('fs', -15, 25)

        lines = "[STYLE]no\n"
        lines += "00:03:40.095,00:03:40.429\n"
        lines += "You want some water with that?\n\n"
        lines += "00:03:41.555,00:03:42.973\n"
        lines += "No, no.[br]No, I don't.\n\n"
        lines += "00:03:44.725,00:03:46.143\n"
        lines += "Looks like you had a night.\n\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end
      end
    end

    it "doesn't stretch when an invalid timing is calculated" do
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
        
        new_changer(path).stretch('fs', -10)

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end

        new_changer(path).stretch('ss', -1)

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end
      end
    end

  end

  describe 'setting the max line length of the subrip format' do
    path = 'subs.srt'

    it 'sets the max line length where needed' do
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
        
        new_changer(path).set_max_line(14)

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
    end

    it "doesn't change the subtitles when not needed" do
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
        
        new_changer(path).set_max_line(32)

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end
      end
    end

  end

  describe 'setting the max line length of the microdvd format' do
    path = 'subs.sub'

    it 'sets the max line length where needed' do
      FakeFS do
        lines = "{5277}{5309}You want some water with that?\n"
        lines += "{5311}{5345}No, no.|No, I don't.\n"
        lines += "{5362}{5396}Looks like you had a night.\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end

        new_changer(path).set_max_line(14)

        lines = "{1}{1}23.976\n"
        lines += "{5277}{5309}You want some water|with that?\n"
        lines += "{5311}{5345}No, no.|No, I don't.\n"
        lines += "{5362}{5396}Looks like you had|a night.\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end
      end
    end

    it "doesn't change the subtitles when not needed" do
      FakeFS do
        lines = "{1}{1}23.976\n"
        lines += "{5277}{5309}You want some water with that?\n"
        lines += "{5311}{5345}No, no.|No, I don't.\n"
        lines += "{5362}{5396}Looks like you had a night.\n"

        File.open(path, 'w') do |subs|
          subs.write(lines)
        end

        new_changer(path).set_max_line(32)

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end
      end
    end
  end


  describe 'setting the max line length of the subviewer format' do
    path = 'subs.sub'

    it 'sets the max line length where needed' do
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

        new_changer(path).set_max_line(14)

        lines = "[STYLE]no\n"
        lines += "00:03:40.095,00:03:41.429\n"
        lines += "You want some water[br]with that?\n\n"
        lines += "00:03:41.513,00:03:42.931\n"
        lines += "No, no.[br]No, I don't.\n\n"
        lines += "00:03:43.640,00:03:45.058\n"
        lines += "Looks like you had[br]a night.\n\n"

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end
      end
    end

    it "doesn't change the subtitles when not needed" do
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

        new_changer(path).set_max_line(32)

        lines = "[STYLE]no\n" + lines

        File.open(path, 'r') do |subs|
          subs.read.should eq lines
        end
      end
    end
  end

end
