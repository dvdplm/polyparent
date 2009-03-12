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

  def parent_instance
    parent_class && parent_class.find(parent_resource_id(parent_resource_type))
  end

  def parent_class
    parent_resource_type && parent_resource_type.to_s.classify.constantize
  end

  def parent_resource_type
    self.class.parent_resources.detect { |parent| parent_resource_id(parent) }
  end

  def parent_resource_id(parent)
    request.path_parameters["#{ parent }_id"]
  end
  
  private :parent_resource_id, :parent_resource_type
end
