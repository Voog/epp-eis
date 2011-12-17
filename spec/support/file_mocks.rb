def legal_mock(name)
  File.read(File.expand_path(File.join('../../legaldocs', name), __FILE__))
end

def xml_mock(name)
  File.read(File.expand_path(File.join('../../xml/', name), __FILE__))
end
