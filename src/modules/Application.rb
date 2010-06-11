#
#  Application.rb
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

module Application
  
  def self.postAnnotationData(jsonContent, user, pass)
    begin
      request = Net::HTTP::Post.new("/annotations/bulk_create")
      request.basic_auth(user, pass)
      request.body = jsonContent
      request.content_type = 'application/json'
      request.add_field("Accept", 'application/json')
      
      Net::HTTP.new(BioCatalogueClient.HOST.host).start { |http|
        response = http.request(request)
        
        case response
          when Net::HTTPSuccess
            Notification.informationDialog(
                "Your annotations have been successfully sent.", "Success")
          when Net::HTTPClientError
            Notification.errorDialog("Invalid username and/or password")
            raise "Invalid username and/or password"
          when Net::HTTPServerError
            Notification.errorDialog("Error occured")
            raise response.inspect
        end
      } # Net::HTTP.new(BioCatalogueClient.HOST.host).start
    rescue Exception => ex
      log('e', ex)
      return nil
    end # begin rescue
            
    return true
  end # self.postAnnotationData
  
  def self.serviceWithURI(uriString)
    id = uriString.split('/')[-1].to_i
    
    service = Cache.services[id]
    service ||= Service.new(uriString.to_s)
    
    return service
  end # self.serviceWithURI
  
  def self.weblinkWithIDForResource(id, resource="services", format=nil)
    return nil if !format.nil? && format.class!=String
    return nil if resource.nil? || resource.class!=String
    
    path = "/#{resource}/#{id}"
    path += ".#{format}" if format
    
    return URI.join(BioCatalogueClient.HOST.to_s, path)
  end # self.weblinkWithID
  
  def self.resourceNameFor(thing)
    case thing.downcase
      when "soap service": "soap_services"
      when "soap input": "soap_inputs"
      when "soap output": "soap_outputs"
      when "soap operation": "soap_operations"
      else nil
    end # case
  end # resourceNameFor
    
end # module Application