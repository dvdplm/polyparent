require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class TestController < ActionController::Base
  include BeefExtras::ActionController::PolyParent
  parent_resources :user, :animal, :shoe, :string
end

describe "PolyParent" do
  
  def setup_request(params)
    params = HashWithIndifferentAccess.new(params)
    request = mock('web request', :path_parameters => params)
    @controller.stub!(:request).and_return(request)
  end
  
  before do
    @controller = TestController.new
  end
  
  describe "class methods" do
    describe "keeps a list of resources (models) that can use this controller" do
      it "keeps track of the resources that can use the controller in a nested manner" do
        TestController.parent_resources.should == [:user, :animal, :shoe, :string]
      end
    end
  end
  
  describe "instance_methods" do
    before do
      setup_request(:action => "show", :id => "123", :stuff => "somestring", :controller => "test_controller", :user_id => 321)
    end
    
    it "extracts the ID of the parent resource instance from the params" do
      @controller.send(:parent_resource_id, 'user').should == 321
    end
    
    describe "extracts the type of the parent resource using the params and the parent resources" do
      
      it "does exactly that" do
        @controller.send(:parent_resource_type).should == :user
      end
    
      describe "copes with a whacky params hash" do
        it "doesn't choke on other something_id in the params hash" do
          setup_request(:action => "show", :id => "123", :stuff => "somestring", :controller => "test_controller", :ginger_id => 'dsas', 'id_entify' => :stuff, 'shoe_id' => 456 )
          @controller.send(:parent_resource_type).should == :shoe
        end
      
        it "doesn't choke on duplicates" do
          setup_request(:shoe_id => "show", :shoe_id => "123", :shoe_id => "somestring")
          @controller.send(:parent_resource_type).should == :shoe
        end
      end
    end

    describe "extracts the class of the parent resource using the params and the parent resources" do
      
      it "returns the class" do
        setup_request(:string_id => 123)
        @controller.parent_class.should == String
      end
    end
    
    describe "retrieves the instance" do
      it "fetches the instance identified by the ID in the params hash from the DB" do
        setup_request(:string_id => 123)
        String.should_receive(:find).with(123).and_return "one two three"
        @controller.parent_instance.should == "one two three"
      end
    end
    
    
    
  end
end
