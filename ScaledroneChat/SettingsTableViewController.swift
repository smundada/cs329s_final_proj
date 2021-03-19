//
//  SettingsTableViewController.swift
//  ScaledroneChat
//
//  Created by Surabhi Mundada on 3/13/21.
//  Copyright © 2021 Scaledrone. All rights reserved.
//

import Foundation
import UIKit
import MessageKit

let availableLangs = ["English", "Spanish", "Hindi"]
let availableTranslationStyles = ["Both", "Click", "One", "None"]
let PREFERRED_LANGUAGE_SECTION = 0
let TRANSLATION_STYLE_SECTION = 1

class SettingsTableViewController: UITableViewController {
    
    let cellId = "settingsCellId"
    public var member: Member!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    func setupTableView(){
        //Registers a class for use in creating new table cells.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
}

extension SettingsTableViewController {
    
//    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        if let cell = tableView.cellForRow(at: indexPath) {
//            cell.accessoryType = .none
//        }
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("in did select row")
//        print(indexPath.section)
        
        // handle Preferred language section ( section  0)
        if indexPath.section == PREFERRED_LANGUAGE_SECTION {
            // make sure everything else is de-selected
            for i in 0...3 { //self.numberOfSections(in: self.tableView) {
                if i != indexPath.row {
                    let otherIndexPath = IndexPath(row: i, section: indexPath.section)
                    let otherCell = tableView.cellForRow(at: otherIndexPath)
                    otherCell?.accessoryType = .none
                }
            }
            
            // select the user-selected option and
            // update user defaults
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .checkmark
                UserDefaults.standard.set(availableLangs[indexPath.row], forKey: "selectedLang")
            }
        }
        
        if indexPath.section == TRANSLATION_STYLE_SECTION {
            // make sure everything else is de-selected
            for i in 0...4 { //self.numberOfSections(in: self.tableView) {
                if i != indexPath.row {
                    let otherIndexPath = IndexPath(row: i, section: indexPath.section)
                    let otherCell = tableView.cellForRow(at: otherIndexPath)
                    otherCell?.accessoryType = .none
                }
            }
            
            // TODO
            // select the user-selected option and
            // update user defaults
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .checkmark
                UserDefaults.standard.set(availableTranslationStyles[indexPath.row], forKey: "translationStyle")
            }
        }
        
//        print(indexPath.row)
//        print(indexPath.section)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        print(indexPath.row)
//        print(indexPath.section)
        if indexPath.section == PREFERRED_LANGUAGE_SECTION {
            let selectedLang = UserDefaults.standard.string(forKey: "selectedLang")
            if selectedLang == "" || selectedLang == nil {   // set English as default
                if indexPath.row == 0 {
                    UserDefaults.standard.set(availableLangs[indexPath.row], forKey: "selectedLang") // set the default here in user defaults to avoid any errors with accessing value
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
            } else { // match user's settings
                if indexPath.row == availableLangs.index(of: selectedLang!) {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
            }
        }
        
        if indexPath.section == TRANSLATION_STYLE_SECTION {
            let translationStyle = UserDefaults.standard.string(forKey: "translationStyle")
            if translationStyle == "" || translationStyle == nil {   // set English as default
                if indexPath.row == 0 {
                    UserDefaults.standard.set(availableTranslationStyles[indexPath.row], forKey: "translationStyle") // set the default here in user defaults to avoid any errors with accessing value
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
            } else { // match user's settings
                if indexPath.row == availableTranslationStyles.index(of: translationStyle!) {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
            }
        }
    }
}
