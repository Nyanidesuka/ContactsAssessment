//
//  ContactListTableViewController.swift
//  ContactsAssessment
//
//  Created by Haley Jones on 6/7/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import UIKit

class ContactListTableViewController: UITableViewController {

    //Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    
    //dataSource && search handling
    var searching = false
    var searchResults: [Contact] = []
    //this thing is super cool it's basically a variable that knows it will always be an array of contact but will conditionally return either the Source of truth or a temporary array of search results stored on the VC.
    var dataSource: [Contact]{
        get{
            if searching{
                return self.searchResults
            } else {
                return ContactController.shared.contacts
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Contacts"
        searchBar.delegate = self
    }
    
    //if the view is about to appear we're gonna want it to reload its data
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.reloadData()
    }

    // MARK: - Table view data source
    //a number of cells equal to how many contacts are in the SSot
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataSource.count
    }
    
    //configure cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)

        let contact = dataSource[indexPath.row]
        cell.textLabel?.text = contact.name
        return cell
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //target the contact that coresponds to this row
            let targetContact = dataSource[indexPath.row]
            //call our deleter
            ContactController.shared.deleteContact(contact: targetContact) { (success) in
                if success{
                    DispatchQueue.main.async {
                        //delete the tableview row
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
            }
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editContact"{
            //segue stuff. Confirm the identifier, ake sure the destination is correct, target what we wanna pass, pass it.
            guard let index = tableView.indexPathForSelectedRow,
                let destinVC = segue.destination as? ContactDetailViewController else {return}
            destinVC.contact = dataSource[index.row]
        }
    }
}

//let's adopt some delegate functions to use that search bar
extension ContactListTableViewController: UISearchBarDelegate{
    //if they hit the search button(or enter key), do this
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, searchText != "" else {return}
        //empty out search results
        searchResults = []
        //check the SoT for contacts with any text that contains the search term and if you find it, stick it in the results array
        for contact in ContactController.shared.contacts{
            if contact.name.contains(searchText) || contact.email.contains(searchText) || contact.phoneNumber.contains(searchText){
                self.searchResults.append(contact)
            }
        }
        //flip this bool on to tell the datasource to return the search results array
        self.searching = true
        //also reload the table
        self.tableView.reloadData()
    }
    //so the cancel button i think shows up on the touch keyboard only, it's not the X button.
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //flip the bool off so datasource will return the SSoT again
        self.searching = false
        //empty the results array just to be thorough
        self.searchResults = []
        //reload
        self.tableView.reloadData()
    }
    //this is in here to make the X button work to cancel a search.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == ""{
            self.searching = false
            self.searchResults = []
            self.tableView.reloadData()
        }
    }
    
}
