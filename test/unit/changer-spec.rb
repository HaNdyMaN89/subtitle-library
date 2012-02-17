$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..', 'lib', 'subtitle-library')
require 'changer'
require 'fakefs/safe'

describe SubsReader do
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
end
