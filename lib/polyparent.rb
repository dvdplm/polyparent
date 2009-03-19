# Copyright (c) 2009 David Palm, Peer Allan
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module PolyParent #:nodoc:

  def self.included(base) # :nodoc:
    base.extend ClassMethods
  end

  module ClassMethods
    def parent_resources(*parents)
      @parent_resources ||= parents
    end
  end

  def parent_instances
    @parent_instances ||=
      request.path.split('/').reject(&:blank?).inject([]) do |parents, path_component|
        path_component = path_component.singularize
        if self.class.parent_resources.include?(path_component.to_sym)
          instance = instance_from_path_component(path_component)
          parents << add_klassy_name(instance)
        end
        parents
      end
  end

protected
  def set_poly_parents
    if parent_instances.blank?
      raise ArgumentError, "No parent resources found in the request path \"#{request.path}\". #{self.class} has to be accessed through a PolyParent route!"
    else
      @parents = parent_instances
    end
  end
  
private
  def parent_resource_id(parent)
    request.path_parameters["#{ parent }_id"]
  end
  
  def instance_from_path_component(path_component)
    klass = path_component.classify.constantize.base_class
    klass.find(parent_resource_id(path_component)).becomes(klass)
  end

  def add_klassy_name(instance)
    returning instance do
      instance.instance_eval do
        def klassy_name
          self.class.class_name.downcase
        end
      end
    end
  end
end
