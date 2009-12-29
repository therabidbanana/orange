class MockCarton < Orange::Carton
  id
  admin do
    text :banana
  end
end

class MockCartonTwo < Orange::Carton
  id
  def self.get(id)
    'mock_get'
  end
  def self.all
    'mock_all'
  end
  def save
    raise 'mock_save'
  end
  def destroy!
    raise 'mock_destroy'
  end
  def update(*args)
    raise 'mock_update'
  end
end