PolyParent
==========
_PolyParent_ is a plugin designed to help DRY up your controllers and views for polymorphic objects. In other words you want both these URLs to map to the same controller action:

    /customers/123/phone_numbers/new
    /customers/123/locations/321/phone_numbers/new

You start out with a `PhoneNumber` model that you associate to both your `Customer` and `Location` models (through a polymorphic association) with `Location` nested below `Customer` like so:

    map.resources :customers do |customers|
      customers.resources :locations
    end

To make both URLs map to the same controller action you modify the above to become:

    map.resources :customers do |customers|
      customers.resources :phone_numbers
      customers.resources :locations do |locations|
        locations.resources :phone_numbers
      end
    end

Now you have an issue though. When processing requests to `PhoneNumbersController` you have no way of knowing where to attach the new `PhoneNumber`. How can you avoid havoing two different controller actions doing exactly the same thing? Or even worse, having two different controllers, one dealing with `PhoneNumber`s associated to `Customer`s and the other to `Location`s?

Let's look at how the 'normal' controller actions would look.

The following snippet works when the `PhoneNumbersController` was invoked from a `Customer` (POST to `/customers/123/phone_numbers`).

    class PhoneNumbersController < ApplicationController
      def new
        @phone_number = PhoneNumber.new
      end
    
      def create
        @customer = Customer.find(params[:id])
        @customer.phone_numbers.build(params[:phone_number])
        if @customer.save
          flash[:info] = 'A crazy success! A new PhoneNumber is born!'
          redirect_to customer_phone_numbers_path(@customer)
        else
          flash[:error] = @customer.errors.full_messages.to_sentence
          render :action => :new
        end
      end
    end

When accessed from a `Location` context the create action would look like this:

    def create
      @location = Location.find(params[:id])
      @location.phone_numbers.build(params[:phone_number])
      if @location.save
        flash[:info] = 'A crazy success! A new PhoneNumber is born!'
        redirect_to customer_location_phone_numbers_path(@location.customer, @location)
      else
        flash[:error] = @location.errors.full_messages.to_sentence
        render :action => :new
      end
    end
  
The logic is exactly the same but the objects ivolved are different and the paths that need to be generated after the save need different parameters.

Ecce _PolyParent_. 

By analyzing the request path _PolyParent_ extracts the hierarchy of the nested routes and helps you build generic controller actions that work for all cases.

Step one: prepare the controller
--------------------------------
First of all we include the PolyParent module and name the models we wish allow as possible 'parents' of the requests. This allows us to call the controller through other URLs if we need to invoke the it without involving PolyParent.
We call the `set_poly_parents` in a before_filter that provides us with a `@parents` instance variable (this is not strictly necessary, but mighty convenient for views. See below):

    class PhoneNumbersController < ApplicationController
      include PolyParent
      parent_resources :location, :customer
      before_filter :set_poly_parents
    end
    
    
Step two: dry up the actions
----------------------------
Then we proceed by rewriting the controller actions not to make assumptions on the 'parent' resource we're attaching our new PhoneNumber.

    def create
      @parents.last.phone_numbers.build(params[:phone_number])
      if @parents.last.save
        flash[:info] = 'A crazy success! A new PhoneNumber is born!'
        redirect_to polymorphic_path([@parents, :phone_numbers].flatten)
      else
        flash[:error] = @parents.last.errors.full_messages.to_sentence
        render :action => :new
      end
    end

When the create action is invoked for a `PhoneNumber` associated with a `Customer`, `@parents` will be a one-element Array containing the `Customer` instance defined by the `:customer_id` key in the params Hash. 
When accessed through a `Location`, the first element will be the parent `Customer` and the last element the parent `Location` instance to which we want to attach the `PhoneNumber`. The `@parents` Array is ordered the same way the routes are nested, thus containing the hierarchy information we need to generate the right paths.

Step three: parent agnostic views
---------------------------------
Maybe the messiest part of building a reusable controller for our PhoneNumber is the views. The UI will contain the form of course but also a link back to a page listing all the phone numbers (the index view will need links to edit and new as well). All those paths need to be generated polymorphically so they can be used in both the `Customer` and `Location` contexts.

An example new.html.haml view:

      %h2
        New Phone Number:
      - form_for @phone_number, :url => polymorphic_path([@parents, :phone_numbers].flatten) do |f|
        %fieldset
          %ul
            %li.form-field
              = f.label :number, "Phone Number"
              = f.text_field :number
            %li.form-field
              = submit_tag "Create"
              = link_to 'Cancel', polymorphic_path([@parents, :phone_numbers].flatten)
              
To generate a 'new' link, use:

    link_to 'new Phone Number', polymorphic_path([:new, @parents, :phone_number].flatten)
    
To generate an 'edit' link to `@phone_number`, use: 

    link_to 'edit', polymorphic_path([:edit, @parents, @phone_number].flatten)

Extras
------
For some complicated views it is sometimes necessary to know the class of the object being edited/created (for instance for nested forms). 
While possible to access the class through `@parents.last.class.class_name`, _PolyParent_ provides a `#klassy_name` instance method that will return the downcased class name of the parent *base* class. The base class is the superclass of your model class that inherits from ActiveRecord::Base so it's the same as the class_name for normal models, while for STIed models it returns the base class.

If, for instance, the `Customer` model from the examples above inherits from a `Person` model, then `klassy_name` will return 'person' and the instance in the `@parents` Array will be a `Person` and not a `Customer`, thus allowing you to use the `PhoneNumbersController` for all subclasses of `Person`.