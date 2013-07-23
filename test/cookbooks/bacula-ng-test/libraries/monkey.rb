# chef-solo-search's `search(:node, ...)` returns an array of
# hashes. We need to be able to pretend they're nodes, at least to
# respond to `#name`. It shouldn't hurt too bad to just blanket-add
# method to Hash... it's just for the tests, y'know.
class Hash
  def name
    self['id']
  end
end
