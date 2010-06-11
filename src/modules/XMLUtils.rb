#
#  XMLUtils.rb
#  BioCatalogue-Mass-Curator
#
#  Created by Mannie Tagarira on 09/06/2010.
#  Copyright (c) 2010 University of Manchester, UK.

=begin
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see http://www.gnu.org/licenses/gpl.html.
=end

module XMLUtils

  def self.getXMLDocumentFromURI(uri)
    begin
      uri = URI.parse(uri) if uri.class==String
      
      raise "Invalid argument" unless uri.class.name.include?("URI")
      
      userAgent = "BioCatalogue Mass Curator Alpha; JRuby/#{JRUBY_VERSION}"
      xmlContent = open(uri, "Accept" => "application/xml", 
          "User-Agent" => userAgent).read
      
      return LibXMLJRuby::XML::Parser.string(xmlContent).parse
    rescue Exception => ex
      log('e', ex)
      return nil
    end # begin rescue
  end # self.getXMLDocumentFromURI
  
  def self.getAttributeFromNode(attribute, node)
    node.attributes.select { |a| "xlink:href"==a.name }[0]
  end # self.getAttributeFromNode
  
  def self.getValidChildren(node)
    node.children.reject { |n| n.name == "#text" }
  end # self.getValidChildren
  
  def self.getContentOfFirstChild(node)
    node.child.next.content
  end # self.getContentOfFirstChild
  
  def self.selectNodesWithNameFrom(name, parent)
    parent.children.select { |n| n.name == name }
  end # self.selectNodesWithName
  
end # module XMLUtils