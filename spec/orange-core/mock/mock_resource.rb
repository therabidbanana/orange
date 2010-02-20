class MockResource < Orange::Resource
  def mock_method
    'MockResource#mock_method'
  end
  def afterLoad
    @options[:mocked] = true
  end
end

class MockHamlParser < Orange::Resource
  def haml(template, packet, opts)
    [template, packet, opts]
  end
end