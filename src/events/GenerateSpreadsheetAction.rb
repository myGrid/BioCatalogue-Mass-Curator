#
#  GenerateSpreadsheetAction.rb
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
   along with this program.  If not, see http://www.gnu.org/licenses/gpl.html
=end

class GenerateSpreadsheetAction
  java_implements ActionListener

  @@isBusyExporting = false
  
  def initialize(container)
    super()
    @buttonContainer = container
    return self
  end # initialize

# --------------------
  
  def self.setBusyExporting(busy)
    @@isBusyExporting = busy
  end # self.setBusyExporting

  def self.isBusyExporting
    @@isBusyExporting
  end # isBusyExporting
  
# --------------------

  def actionPerformed(event)
    @@fileSelector ||= JFileChooser.new
    @@fileSelector.setFileSelectionMode(JFileChooser::DIRECTORIES_ONLY)

    LoadServicesAction.setBusyExporting(true)

    if @@fileSelector.showOpenDialog(MAIN_WINDOW) == 
        JFileChooser::APPROVE_OPTION
      dir = @@fileSelector.getSelectedFile()
      return if dir.nil? || !dir.isDirectory
      
      Thread.new("Generating spreadsheet") { |t|
        GenerateSpreadsheetAction.setBusyExporting(true)

        event.getSource.setEnabled(false)
        event.getSource.setText("Exporting...")
        event.getSource.setIcon(Resource.iconFor('busy'))
        
        file = SpreadsheetGeneration.generateSpreadsheet(
            Cache.selectedServices, dir.path)

        if file
          Notification.informationDialog(
              "The selected services have been successfully exported to:\n" + 
              file.path, "Export Complete")
        else
          Notification.errorDialog(
              "An error occured while trying to export the selected services.")
        end
        
        event.getSource.setIcon(Resource.iconFor('excel'))
        event.getSource.setText("Export")
        event.getSource.setEnabled(true)
                
        GenerateSpreadsheetAction.setBusyExporting(false)
      } # thread
    end # if file selected
    
    LoadServicesAction.setBusyExporting(false)
      
  end # actionPerformed
  
end
