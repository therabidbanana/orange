class MockCarton < Orange::Carton
  def self.scaffold_properties
    @scaffold_properties
  end
  id
  admin do
    text :admin
  end
  orange do
    text :orange
  end
  front do
    text :front
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

class MockCartonBlank < Orange::Carton
  def self.levels
    @levels
  end
end

class MockCartonBlankTwo < Orange::Carton
end