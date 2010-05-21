#
#  ServiceSelectPanel.rb
#  BioCatalogue-Mass-Curator
#
#  Created by Mannie Tagarira on 20/05/2010.
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

class ServiceSelectPanel < JPanel
  
  attr_reader :serviceURIField
  
  def initialize
    super()
    initUI
  end # initialize
  
private
  
  def initUI
    self.setLayout(BorderLayout.new)
    
    self.add(searchPanel, BorderLayout::NORTH)
    self.add(backButton = JButton.new("Back"), BorderLayout::SOUTH)
    
    backButton.addActionListener(GoBackAction.new(self))
  end # initUI
  
  def searchPanel
    panel = JPanel.new
    panel.setLayout(GridBagLayout.new)    
    c = GridBagConstraints.new
    c.fill = GridBagConstraints::HORIZONTAL
    c.anchor = GridBagConstraints::EAST

    # text field
    c.gridx = 0
    c.weightx = 50
    @serviceURIField = JTextField.new(BioCatalogueClient.services_endpoint.to_s)
    panel.add(@serviceURIField, c)
        
    # preview button
    c.gridx = 1
    c.weightx = 1
    previewButton = JButton.new("Preview")
    previewButton.addActionListener(PreviewAction.new(self))
    panel.add(previewButton, c)
    
    return panel
  end
  
end

