module Defs
  extend ::Trax::Core::Definitions

  enum :Category do
    define :default,     1
    define :clothing,    2
    define :shoes,       3
    define :accessories, 4
  end

  struct :ShipmentAttributes do
    string :tracking_number
    float :weight
    integer :insurance_amount
    boolean :is_insured
    array :notes
    enum :shipping_type do
      define :standard, 1
      define :overnight, 2
      define :same_day, 3
    end
  end

  struct :ProductAttributes do
    string :name, :default => ""
    float :price, :default => 9.99
    integer :quantity_in_stock, :default => 0
    boolean :is_active, :default => false
    array :categories, :of => "Defs::Category", :default => []
    set :departments, :attributes => { :choices => ['mens', 'womens'] }
  end

  struct :ShoesAttributes, :extends => "Defs::ProductAttributes" do
    enum :size do
      define :mens_8,  1
      define :mens_9,  2
      define :mens_10, 3
      define :mens_11, 4
      define :mens_12, 5
    end
  end

  struct :ShirtAttributes, :extends => "Defs::ProductAttributes" do
    string :name, :default => "Three-Fifty"
    float :price, :default => 3.50
    integer :quantity_in_stock, :default => 5
    boolean :is_active, :default => true
    array :categories, :of => "Defs::Category", :default => [:default, :clothing]
    enum :size, :default => :womens_m do
      define :womens_xs, 1
      define :womens_s,  2
      define :womens_m,  3
      define :womens_l,  4
      define :womens_xl, 5
    end
  end
end
