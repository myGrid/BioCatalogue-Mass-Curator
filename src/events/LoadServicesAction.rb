#
#  LoadServicesAction.rb
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
   along with this program.  If not, see http://www.gnu.org/licenses/gpl.html
=end

# This handles the page loading when browsing between service pages.

# ========================================

class LoadServicesAction
  java_implements ActionListener

  @@resultsPanelForPage = {} # The local (previously browsed) page cache
  @@serviceSelectPanel = nil # The currently visible ServiceSelectPanel
  
  # ACCEPTS: the container of the button, and the page number to load
  # RETURNS: self
  def initialize(container, pageNumber)
    super()
    @buttonContainer = container
    @pageNumber = pageNumber
    return self
  end # initialize

  # ACCEPTS: an integer for the page number
  def setLoadPageNumber(page)
    @pageNumber = page
  end # setLoadPageNumber

# --------------------
  
  # RETURNS: the current page number
  def self.currentPage
    @@currentPage
  end # self.currentPage
  
  # ACCEPTS: a boolean to set the ServiceSelectPanel visibility
  def self.setServicesPanelVisible(visible)
    @@serviceSelectPanel.setVisible(visible) if @@serviceSelectPanel
  end # self.setServicesPanelVisible
  
  # Hide or show components based on the application's export status
  # ACCEPTS: a boolean - whether the application is current exporting or not
  def self.setBusyExporting(exporting)
    Component.searchPanel.setVisible(!exporting)
    Component.browsingStatusPanel.setVisible(!exporting)
    @@serviceSelectPanel.previousPageButton.setVisible(!exporting)
    @@serviceSelectPanel.nextPageButton.setVisible(!exporting)
    @@serviceSelectPanel.mainPanel.setVisible(!exporting)
    
    Component.flash(@@serviceSelectPanel)
  end # self.setBusyExporting
  
# --------------------
  
  def actionPerformed(event)
    # set page number to be used by the GoBackAction
    @@currentPage = @pageNumber

    Thread.new("Loading page ##{@pageNumber}") {
      # disable browsing buttons in panel      
      if @buttonContainer.class==MainPanel
        originalCaption = event.getSource.getText
        event.getSource.setText("Loading...")
        event.getSource.setEnabled(false)
      else
        previousPageEnabled = @buttonContainer.previousPageButton.isEnabled
        nextPageEnabled = @buttonContainer.nextPageButton.isEnabled
        backButtonEnabled = Component.browsingStatusPanel.backButton.isEnabled
        exportButtonEnabled = Component.exportButton.isEnabled
        searchEnabled = Component.searchButton.isEnabled
        
        @buttonContainer.previousPageButton.setEnabled(false)
        @buttonContainer.nextPageButton.setEnabled(false)
        Component.browsingStatusPanel.backButton.setEnabled(false)
        Component.exportButton.setEnabled(false)
        Component.searchField.setEnabled(false)
        Component.searchButton.setEnabled(false)
      end
      
      # update source icon
      originalIcon = event.getSource.getIcon
      event.getSource.setIcon(Resource.iconFor('busy'))

      # load new service select panel
      if (panel = @@resultsPanelForPage[@pageNumber]) # used cached panel
        @@serviceSelectPanel = panel
              
        panel.add(Component.searchPanel, BorderLayout::NORTH)
        panel.add(Component.browsingStatusPanel, BorderLayout::SOUTH)
        
        Cache.syncWithCollection(panel.localServiceCache)
        Cache.updateServiceListings(panel.localListingCache)
      else # create new panel and add to local cache
        @@serviceSelectPanel = ServiceSelectPanel.new(@pageNumber)
        @@resultsPanelForPage.merge!(@pageNumber => @@serviceSelectPanel)
      end
      
      # update status.actions panel
      Component.browsingStatusPanel.currentPage = @pageNumber
      selectionMade = !Cache.selectedServices.empty?
      Component.browsingStatusPanel.exportButton.setEnabled(selectionMade) unless GenerateSpreadsheetAction.isBusyExporting
      Component.browsingStatusPanel.refresh
      
      # update full view to show new services
      @buttonContainer.setVisible(false)
      UploadSpreadsheetAction.setUploadPanelVisible(false)
      @@serviceSelectPanel.setVisible(true)
      
      MAIN_WINDOW.getContentPane.add(@@serviceSelectPanel)
      MAIN_WINDOW.getContentPane.repaint
      Component.flash(@@serviceSelectPanel)
      
      # update source icon
      event.getSource.setIcon(originalIcon)
      
      # re-enable browsing buttons in panel
      if @buttonContainer.class==MainPanel
        event.getSource.setText(originalCaption) 
        event.getSource.setEnabled(true)
      else        
        Component.searchButton.setEnabled(searchEnabled)
        Component.searchField.setEnabled(true)

        Component.exportButton.setEnabled(exportButtonEnabled)
        Component.browsingStatusPanel.backButton.setEnabled(backButtonEnabled)
        @buttonContainer.nextPageButton.setEnabled(nextPageEnabled)
        @buttonContainer.previousPageButton.setEnabled(previousPageEnabled)
      end
    }
  end # actionPerformed

end # LoadServicesAction
