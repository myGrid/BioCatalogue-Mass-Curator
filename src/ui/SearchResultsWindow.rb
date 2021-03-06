#
#  SearchResultsWindow.rb
#  BioCatalogue-Mass-Curator
#
#  Created by Mannie Tagarira on 07/06/2010.
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

class SearchResultsWindow < JFrame
  
  @@lastSearchResultsWindow = nil

  def initialize(query)
    super("Search results for: " + query)
        
    initUI
        
    return self
  end # initialize
    
private

  def initUI    
    self.setMinimumSize(Dimension.new(300, 100))
    self.setDefaultCloseOperation(JFrame::DISPOSE_ON_CLOSE)
  end # initUI
  
end # SearchResultsWindow
