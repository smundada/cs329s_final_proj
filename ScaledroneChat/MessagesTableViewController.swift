//
//  MessagesTableViewController.swift
//  ScaledroneChat
//
//  Created by Surabhi Mundada on 3/12/21.
//  Copyright © 2021 Scaledrone. All rights reserved.
//

import Foundation
import UIKit
import MessageKit

class MessagesTableViewController: UITableViewController {
    
    let cellId = "cellId"
    public var member: Member!
    var contacts = [ContactModel]()
    
    @IBAction func unwindToMainMenu(sender: UIStoryboardSegue) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        member = Member(name: .randomName, color: .random)
        
        do {
            let colorData = try NSKeyedArchiver.archivedData(withRootObject: member.color, requiringSecureCoding: false) as NSData?
            UserDefaults.standard.set(colorData, forKey: "currColor") // UserDefault Built-in Method into Any?
        } catch (let error) {
            print("error with writing color to user defaults")
        }
        
        UserDefaults.standard.set(member.name, forKey: "currName")

        createContactsArray()
        setupTableView()
    }
    
    func setupTableView(){
        //Registers a class for use in creating new table cells.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
}

extension MessagesTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count //5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! MessagesTableViewCell
        let extractedContact = contacts[indexPath.row] //"Hello, World"
        cell.UpdateCellView(contact: extractedContact)
        
        return cell
    }
    
    func createContactsArray() {
        if member.name == "Abuelita" {
            contacts.append(ContactModel(icon:"ana", name:"Ana"))

        } else if member.name == "Ana" {
            contacts.append(ContactModel(icon:"abuelita", name:"Abuelita"))

        }
        
        contacts.append(ContactModel(icon:"captainamerica", name:"Captain America"))
        contacts.append(ContactModel(icon:"hulk", name:"Hulk"))
        contacts.append(ContactModel(icon:"ironman", name:"Iron Man"))
        contacts.append(ContactModel(icon:"blackwidow", name:"Black Widow"))
        contacts.append(ContactModel(icon:"hawkeye", name:"Hawkeye"))
        contacts.append(ContactModel(icon:"thor", name:"Thor"))
        contacts.append(ContactModel(icon:"fury", name:"Nick Fury"))
        contacts.append(ContactModel(icon:"marvel", name:"Captain Marvel"))
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.row == 0 {
//            performSegue(withIdentifier: "toMessagesPage", sender: self)
//        }
//    }
}

class MessagesTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    func UpdateCellView(contact: ContactModel) {
        icon.image = UIImage(named: contact.icon)
        name.text = contact.name
    }
}

struct ContactModel {
    var icon: String
    var name: String
    
    init(icon: String, name:String) {
        self.icon = icon
        self.name = name
    }
}
