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
   along with this program.  If not, see http://www.gnu.org/licenses/gpl.html
=end

# This module contains generic helper methods for the application

# ========================================

module Application
  
  @@storeCredentials = false
  
  # --------------------
  
  # ACCEPTS: a boolean stating whether or not the user's credentials should be written to file
  def self.storeCredentials(store)
    @@storeCredentials = store==true
  end # self.storeCredentials
  
  # ACCEPTS:
  #   jsonContent: JSON data to post
  #   user: username
  #   pass: passwork
  # RETURNS: a boolean containing the success status of the HTTP POST
  def self.postAnnotationData(jsonContent, user, pass)
    begin
      request = Net::HTTP::Post.new("/annotations/bulk_create")
      request.basic_auth(user, pass)
      request.body = jsonContent
      request.content_type = 'application/json'
      request.add_field("Accept", 'application/json')
      request.add_field("User-Agent", BioCatalogueClient::USER_AGENT)
      
      Net::HTTP.new(BioCatalogueClient::HOSTNAME.host).start { |http|
        response = http.request(request)

        case response
          when Net::HTTPSuccess
            Notification.informationDialog("Your annotations have been successfully submitted.", "Success")
            SpreadsheetParsing.performAfterPostActions
          when Net::HTTPClientError
            Notification.errorDialog("Invalid username and/or password")
            raise "Invalid username and/or password"
          when Net::HTTPServerError
            Notification.errorDialog("Error occured")
            raise response.inspect
        end
      } # Net::HTTP.new(BioCatalogueClient::HOSTNAME.host).start
    rescue Exception => ex
      log('e', ex)
      return false
    end # begin rescue
            
    return true
  end # self.postAnnotationData
  
  # ACCEPTS: a URI linking to a BioCatalogue service resource
  # RETURNS: an already existing or newly created service
  def self.serviceWithURI(uriString)
    id = uriString.to_s.split('/')[-1].to_i
    
    service = Cache.services[id]
    service ||= Service.new(uriString.to_s)
    
    return service
  end # self.serviceWithURI
  
  # ACCEPTS: 
  #   id: the BioCatalogue ID of the resource
  #   resource: the biocatalogue resource type; default="services"
  #   format: the representation e.g. "json"; default=nil
  # RETURNS: nil OR a URI with format:
  #     http(s)://{biocatalogue-instance}/{resource}/{id}
  #     http(s)://{biocatalogue-instance}/{resource}/{id}/{format}
  def self.weblinkWithIDForResource(id, resource="services", format=nil)
    return nil if !format.nil? && format.class!=String
    return nil if resource.nil? || resource.class!=String
    
    path = "/#{resource}/#{id}"
    path += ".#{format}" if format
    
    return URI.join(BioCatalogueClient::HOSTNAME.to_s, path)
  end # self.weblinkWithID
  
  # ACCEPTS: a biocatalogue resource type e.g "soap_inputs", "rest_parameter"
  # RETURNS: a display name if one is available for the given resource type
  def self.displayNameForResourceType(type)
    case type.downcase
      when "soap_inputs": "SOAP Input"
      when "soap_outputs": "SOAP Output"
      when "rest_parameters": "REST Parameter"
      when "rest_representations": "REST Representation"
      else type.gsub("_", " ")
    end # case
  end # displayNameForResourceType
  
  # ACCEPTS: a display name e.g. "SOAP Service", "REST Parameter"
  # RETURNS: a biocatalogue resource type e.g "soap_inputs", "rest_parameter" if one is available for the given resource type
  def self.resourceTypeFor(name)
    case name.downcase
      when "soap service": "soap_services"
      when "soap input": "soap_inputs"
      when "soap output": "soap_outputs"
      when "soap operation": "soap_operations"
      when "rest service": "rest_services"
      when "rest method", "rest endpoint": "rest_methods"
      when "rest parameter": "rest_parameters"
      when "rest representation": "rest_representations"
      else nil
    end # case
  end # resourceTypeFor
  
  # This serializes the current CONFIG hash to a file in the folder containing the application named "mass-curator.conf"
  def self.writeConfigFile
    begin
      @configFile = open(CONFIG_FILE_PATH, "w+")

      config = ParseConfig.new(CONFIG_FILE_PATH)

      if @@storeCredentials
        CONFIG['client']['username'] = BioCatalogueClient.currentUser[:username]
        CONFIG['client']['password'] = Base64.encode64(BioCatalogueClient.currentUser[:password])
      else
        CONFIG['client']['username'], CONFIG['client']['password'] = '', ''
      end
        
      config.add('client', CONFIG['client'])
      config.add('application', CONFIG['application'])
      config.add('spreadsheet', CONFIG['spreadsheet'])
      
      # sanitize config
      CONFIG.each do |group, values|
        values.each { |key, value| CONFIG[group][key] = value.to_s }
      end
      
      config.write(@configFile)
    rescue Exception => ex
      log('e', ex)
    ensure
      @configFile.close if @configFile
    end
  end # writeConfigFile
  
end # module Application