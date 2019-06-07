//
//  FetchViewController.swift
//  ContactsAssessment
//
//  Created by Haley Jones on 6/7/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//
//This ViewController is gonna fetch the user and also that user's contacts.
import UIKit

class FetchViewController: UIViewController {
    //Outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    //cool stuff
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //start spinning the spinny boy
        activityIndicator.startAnimating()
        //tell the user what the app is working on
        messageLabel.text = "Fetching User Data..."
        //make tme magic happen. This is the initial view so this function should get called right as the app launches.
        //see if the user already exists
        UserController.shared.fetchUser { (userExists) in
            if userExists{
                //if the user exists, grab their contacts before segue-ing for a smooth user experience
                guard let user = UserController.shared.currentUser else {print("there is no current user"); return}
                DispatchQueue.main.async {
                    self.messageLabel.text = "Fetching Contacts..."
                }
                ContactController.shared.fetchContacts(forUser: user, completion: { (success) in
                    if success{
                        DispatchQueue.main.async {
                            self.moveToNavigationController()
                        }
                    }
                })
                
            } else {
                //if we got here, there was no user for the icloud account using the app. Make one.
                DispatchQueue.main.async {
                    self.messageLabel.text = "Creating New User..."
                }
                UserController.shared.createUser(completion: { (success) in
                    if success{
                        DispatchQueue.main.async {
                            //If there's no user, there's also no posts. So no need to fetch posts. Just head to the contact list.
                            self.moveToNavigationController()
                        }
                    }
                })
            }
        }
    }
    
    func moveToNavigationController(){
        print("moving to the nagivation controller")
        //if we've finished fetching contacts without errors, head over to the contact list
        //identify the storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //identify the VC we want to go to. It's the main navigation controller.
        let viewController = storyboard.instantiateViewController(withIdentifier: "navigationController")
        //so this one here, we're gonna set the root view to be the navigation controller because we dont want this fetch controller just sitting in memory doing nothing forever.
        UIApplication.shared.windows.first?.rootViewController = viewController
        //and then we're gonna segue to the navigation controller
        self.performSegue(withIdentifier: "toNavigationController", sender: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
