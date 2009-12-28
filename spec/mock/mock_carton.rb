class MockCarton < Orange::Carton
  id
  admin do
    text :banana
  end
end

class MockCartonTwo < Orange::Carton
  def self.get(id)
    'mock_get'
  end
  def self.all
    'mock_all'
  end
end