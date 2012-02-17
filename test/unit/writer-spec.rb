$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..', 'lib', 'subtitle-library')
require 'writer'
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
end
