require 'erb'

class ContextBase
  def render(component)
    ERB.new(component).result(binding)
  end
end


$memoized_read_table = {}
def memoized_read(path)
  _path = File.expand_path(path)
  $memoized_read_table[_path] or $memoized_read_table[_path] = open(_path).read
end