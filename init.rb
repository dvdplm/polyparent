if defined?(ActionController) and defined?(ActionController::Base)
  require 'polyparent'
  ActionController::Base.send :include, BeefExtras::ActionController::PolyParent
end