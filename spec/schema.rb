ActiveRecord::Schema.define(:version => 0) do
  create_table :shoes, :force => true do |t|
    t.column :name, :string
    t.column :type, :string
  end
  
  create_table :users, :force => true do |t|
    t.column :name, :string
  end
  
  create_table :animals, :force => true do |t|
    t.column :species, :string
  end
end