//
//  ViewController.swift
//  K0HYD To Do
//
//  Created by Dale Puckett on 11/26/16.
//  Copyright © 2016 k0hyd. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    // Link Outlets to Main.storyboard here after defining class
    @IBOutlet weak var importantCheckbox: NSButton!
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var deleteButton: NSButton!
    
    var toDoItems : [ToDoItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // Get the list of To Do Items before doing anything else
        getToDoItems()
    }
    
    func getToDoItems() {
        // Function to Get the To Do Items from CoreData
        if let context = (NSApplication.shared().delegate as? AppDelegate)?.managedObjectContext {
            do {
                // Set the To Do Items to the Class Properties
                // Use the context.fetch call with a fetchRequest to do this
                toDoItems = try context.fetch(ToDoItem.fetchRequest())
            } catch {}
        }
        
        // Update the table view
        // Reload the table data each time it changes
        tableView.reloadData()
        
    }
    
    @IBAction func addClicked(_ sender: Any) {
        
        // Create function to add new item to class and Core Data
        if textField.stringValue != "" {
            if let context = (NSApplication.shared().delegate as? AppDelegate)?.managedObjectContext {
                let toDoItem = ToDoItem(context: context)
                toDoItem.name = textField.stringValue
                if importantCheckbox.state == 0 {
                    // It is NOT important
                    toDoItem.important = false
                } else {
                    // It is Important
                    toDoItem.important = true
                }
                
                // Save the information in CoreData
                (NSApplication.shared().delegate as? AppDelegate)?.saveAction(nil)
                
                // Now Clear all the fields in the table view
                importantCheckbox.state = 0
                textField.stringValue = ""
                
                // Make sure to update the list of items in the table after any change
                getToDoItems()
                
            }
        }
        
    }
    
    @IBAction func deleteClicked(_ sender: Any) {
        
        // Create function to delete a selected To Do item
        let toDoItem = toDoItems[tableView.selectedRow]
        if let context = (NSApplication.shared().delegate as? AppDelegate)?.managedObjectContext {
            
            // Call to do the actual delete from coredata
            context.delete(toDoItem)
            
            // Call to save the deletion in coredata
            (NSApplication.shared().delegate as? AppDelegate)?.saveAction(nil)
            
            // Update the items in the table view after this change
            getToDoItems()
            
            // Hide the delete button when nothing is selected
            deleteButton.isHidden = true
        }
        
        
    }
    
    
    // MARK: TableView Stuff
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        // Function to get count of items in table view
        return toDoItems.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        // Find out which row we are pointed to
        let toDoItem = toDoItems[row]
        
        // Check the identifier of the column we are in and handle accordingly
        if tableColumn?.identifier == "importantColumn" {
            // Important Column
            if let cell = tableView.make(withIdentifier: "importantCell", owner: self) as? NSTableCellView {
                
                // If it is an important item, place an Exclamation point in the text field
                // Otherwise make sure it is empty
                if toDoItem.important {
                    cell.textField?.stringValue = "❗️"
                } else {
                    cell.textField?.stringValue = ""
                }
                
                return cell
                
            }
        } else {
            // If it is not the Important cell it must be the Name cell as there are only two
            // So set the name of the item into the table's textField
            if let cell = tableView.make(withIdentifier: "todoItems", owner: self) as? NSTableCellView {
                cell.textField?.stringValue = toDoItem.name!
                return cell
            }
            
        }
        
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        deleteButton.isHidden = false
    }
    
}


