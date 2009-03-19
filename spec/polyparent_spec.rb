require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class TestController < ActionController::Base
  include PolyParent
  parent_resources :user, :animal, :shoe, :shoe_string
  before_filter :set_poly_parents
  
  def index
    
  end
end

describe "PolyParent" do
  require 'ostruct'
  def setup_request(path, params)
    request = mock('web request', :path => path, :path_parameters => params.with_indifferent_access)
    @controller.stub!(:request).and_return(request)
  end
  
  before do
    @controller = TestController.new
  end
  
  describe "class methods" do
    describe "keeps a list of resources (models) that can use this controller" do
      it "keeps track of the resources that can use the controller in a nested manner" do
        TestController.parent_resources.should == [:user, :animal, :shoe, :shoe_string]
      end
    end
  end
  
  describe "instance_methods" do
    before do
      setup_request("/users/321/animals/2/shoes", {"action" => "index", "controller" => "shoes", "user_id" => "321", "animal_id" => "2"})
    end
    
    describe "builds an Array of parent resources from the request path, keeping trace of the (hierarchical-)order among them" do
      it "splits the path on the '/' char" do
        pending
      end
      
      it "weeds out any blanks among the path components " do
        pending
      end
      
      it "adds the pieces of the path that appear in the parent_resources collection" do
        pending
      end
      
      it "adds the klassy_name method to the instances in the parents Array" do
        pending
      end
    end
    
    describe "finds an AR instance from a path component" do
      before do
        @shoe_string = ShoeString.new
        Shoe.stub!(:find).and_return(@shoe_string)
        @controller.stub!(:parent_resource_id).and_return(1)
      end
      
      it "finds out the class" do
        path_component = 'shoe_string'
        path_component_classified = 'ShoeString'
        path_component.should_receive(:classify).and_return(path_component_classified)
        path_component_classified.should_receive(:constantize).and_return(ShoeString)
        ShoeString.should_receive(:base_class).and_return(Shoe)
        @controller.send(:instance_from_path_component, path_component)
      end
      
      it "finds the instance of the class" do
        Shoe.should_receive(:find).and_return(@shoe_string)
        @controller.send(:instance_from_path_component, 'shoe_string')
      end
      
      it "casts the instance to the base class to avoid STI surprises" do
        @shoe_string.should_receive(:becomes).with(Shoe)
        @controller.send(:instance_from_path_component, 'shoe_string')
      end
    end
    
    describe "AR instance augmentation" do
      it "can extend an AR instance so it knows its (base-)class name (downcased)" do
        shoe = Shoe.new
        shoe.should_not respond_to(:klassy_name)
        @controller.send(:add_klassy_name, shoe)
        shoe.should respond_to(:klassy_name)
      end
      
      it "returns the base class name, i.e. the name of the class just below ActiveRecord::Base in the inheritance hierarchy" do
        shoe_string = ShoeString.new
        @controller.send(:add_klassy_name, shoe_string)
        shoe_string.klassy_name.should == 'shoe'
      end
    end
    
    describe "extracts the ID of the parent resource instance from the params" do
      it "can extract the ID" do
        @controller.send(:parent_resource_id, 'user').should == '321'
        @controller.send(:parent_resource_id, 'animal').should == '2'
      end
    end
    
    describe "set_poly_parents ensures the @parents collection is available" do
      it "is best used as a before filter" do
        TestController.before_filters.should include(:set_poly_parents)
      end
      
      it "raises ArgumentError if no parent_instances were found, requiring PolyParent-ized controllers to be accessed only in  a nested way" do
        @controller.stub!(:parent_instances).and_return([])
        lambda{
          @controller.send(:set_poly_parents)
        }.should raise_error(ArgumentError)
      end
      
      it "sets @parents to the parent_instances collection" do
        @controller.should_receive(:parent_instances).twice.and_return([:beef])
        @controller.send(:set_poly_parents)
        @controller.instance_variable_get('@parents').should == [:beef]
      end
    end
  end
end
