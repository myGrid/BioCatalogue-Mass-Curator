#
#  Service.rb
#  BioCatalogue-Mass-Curator
#
#  Created by Mannie Tagarira on 21/05/2010.
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

class Service
  
  attr_reader :components
  attr_reader :id, :name, :description, :technology
  
  @componentsFetched = false
  
  def initialize(serviceURIString)
    begin
      @id = serviceURIString.split('/')[-1].to_i
 
      if (cachedService = BioCatalogueClient.cachedServices[@id]) # cached
        @name = cachedService.name
        @description = cachedService.description
        #@technology = cachedService.technology
        cachedService = self
      else # not cached
        serviceURIString << "/variants.xml"

        serviceURI = URI.parse(serviceURIString)
        
        xmlContent = open(serviceURI).read
        xmlDocument = LibXMLJRuby::XML::Parser.string(xmlContent).parse
      
        propertyNodes = Utilities::XML.getValidChildren(xmlDocument.root)
        propertyNodes.each do |propertyNode|
          case propertyNode.name
            when 'name'
              @name = propertyNode.content
            when 'dc:description'
              @description = propertyNode.content
            when 'serviceTechnologyTypes'
              @technology = Utilities::XML.getContentOfFirstChild(propertyNode)
            when 'variants'
              variants = Utilities::XML.selectNodesWithNameFrom(
                  "#{@technology.downcase}Service", propertyNode)
              variants.each { |node|
                @variantURI = Utilities::XML.getAttributeFromNode(
                  "xlink:href", node).value
                break if @variantURI
              }
              
              @variantURI = URI.parse(@variantURI + '.xml')
          end # case
        end # propertyNodes.each
      end # if else cached
      
      BioCatalogueClient.addServiceToCache(self)
      
    rescue Exception => ex
      LOG.error "#{ex.class.name} - #{ex.message}\n" << ex.backtrace.join("\n")
      BioCatalogueClient.removeServiceFromCache(self)
    end # begin rescue
    
    if @name.nil?
      BioCatalogueClient.removeServiceFromCache(self)
      @id = -1
    end
    
    return self
  end # initialize
  
  def weblink(format=nil)
    Service.weblinkWithID(@id, format)
  end # weblink

  def fetchComponents
    return true if @componentsFetched

    @components = {}
  
    begin
      xmlContent = open(@variantURI).read
      xmlDocument = LibXMLJRuby::XML::Parser.string(xmlContent).parse
      
      nodeName = (@technology=="SOAP" ? "operations" : nil)
      raise "Only support for SOAP is currently available" if nodeName.nil?
      
      operationsNode = Utilities::XML.selectNodesWithNameFrom(nodeName, 
          xmlDocument.root)[0]
      
      Utilities::XML.getValidChildren(operationsNode).each { |op|
        uriString = Utilities::XML.getAttributeFromNode("xlink:href", op).value
        
        component = ServiceComponent.new(uriString)
        next if component.id == -1
        
        @components.merge!(component.id => component)
      }
      
      BioCatalogueClient.addServiceToCache(self)
      @componentsFetched = true
      
      return true
    rescue Exception => ex
      LOG.error "#{ex.class.name} - #{ex.message}\n" << ex.backtrace.join("\n")
      return false
    end # begin rescue
  end # fetchComponents

  def to_s
    "#{@technology}::#{@id}::#{@name}"
  end # to_s

# --------------------

  def self.weblinkWithID(id, format=nil)
    if !format.nil? && !format.empty? && format.class.name=="String"
      URI.join(BioCatalogueClient.HOST.to_s, "/services/#{id}.#{format}")
    else
      URI.join(BioCatalogueClient.HOST.to_s, "/services/#{id}")
    end
  end # self.weblinkWithID

end
