//
//  ViewController.swift
//  ScaledroneChatTest
//
//  Created by Marin Benčević on 08/09/2018.
//  Copyright © 2018 Scaledrone. All rights reserved.
//

import UIKit
import MessageKit

class ViewController: MessagesViewController {
    
    var chatService: ChatService!
    var messages: [Message] = []
    var member: Member!
    
    let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressHappened))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(recognizer)
        
        var currColor: UIColor?
        do {
            if let colorData = UserDefaults.standard.data(forKey: "currColor") {
                currColor =  try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData as! Data)
            }
        } catch (let error) {
            print("Error with unarchiving color data")
        }
        
        var currName = UserDefaults.standard.string(forKey: "currName")
        member = Member(name: currName!, color: currColor!)
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        
        chatService = ChatService(member: member, onRecievedMessage: {
            [weak self] message in
            self?.messages.append(message)
            
            let translationStyle = UserDefaults.standard.string(forKey: "translationStyle")!
            
            if translationStyle == "Both" {
                // check for translated message
                if (message.translation == true && message.member.name != self!.member.name) {
                    var translatedMessage = Message(member: message.member, text: message.sentence, messageId: UUID().uuidString, translation: false, sentence: message.text)
                    translatedMessage.member.color = UIColor.clear
                    self?.messages.append(translatedMessage)
                }
            }
            else if translationStyle == "Click" || translationStyle == "None" {
                print("only show 1 message")
            }
            else if translationStyle == "One" {
                //                let index = self?.messages.index(where: { (item) -> Bool in
                //                    item.messageId == message.messageId // test if this is the item you're looking for
                //                })
                self?.messages.removeLast()
                let newMessage = Message(member: message.member, text: message.sentence, messageId: message.messageId, translation: message.translation, sentence: message.text)
                self?.messages.append(newMessage)
                
                //                if let indexPath = messagesCollectionView.indexPath(for: cell) {
                //                    let message = messages[indexPath.section]
                //                    let newMessage = Message(member: message.member, text: message.sentence, messageId: message.messageId, translation: message.translation, sentence: message.sentence)
                //                    messages[indexPath.section] = newMessage
                //                    self.messagesCollectionView.reloadData()
                //                }
            }
            
            self?.messagesCollectionView.reloadData()
            self?.messagesCollectionView.scrollToBottom(animated: true)
        })
        
        chatService.connect()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //        setUpHeader()
        self.navigationController!.navigationItem.prompt = NSLocalizedString("Name", comment: "")

        let containView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let imageview = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        
        if member.name == "Ana" {
            imageview.image = UIImage(named: "abuelita")
        } else {
            imageview.image = UIImage(named: "ana")
        }
        imageview.layer.cornerRadius = 15
        imageview.layer.masksToBounds = true
        imageview.clipsToBounds = true
        containView.addSubview(imageview)
        self.navigationItem.titleView = containView
        containView.sizeToFit()
        
    }
    
    
}

extension ViewController: MessagesDataSource {
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func currentSender() -> Sender {
        return Sender(id: member.name, displayName: member.name)
    }
    
    func messageForItem(at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        //        var currMessage = messages[indexPath.section]
        //        if currMessage.translation {
        //            var translatedMessage = Message(member: member, text: currMessage.sentence, messageId: UUID().uuidString, translation: false, sentence: "")
        //            return translatedMessage
        //        }
        
        return messages[indexPath.section]
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 12
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        var attributedText = message.sender.displayName
        
        let unwrappedMessage = message as! Message
        print("HEYLO")
        print(message)
        print(unwrappedMessage)
        if unwrappedMessage.translation == false {
            attributedText += " (Translated)"
        }
        
        return NSAttributedString(
            string: attributedText, //message.sender.displayName,
            attributes: [.font: UIFont.systemFont(ofSize: 12)])
    }
}

extension ViewController: MessagesLayoutDelegate {
    func heightForLocation(message: MessageType,
                           at indexPath: IndexPath,
                           with maxWidth: CGFloat,
                           in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
}

extension ViewController: MessagesDisplayDelegate {
    func configureAvatarView(
        _ avatarView: AvatarView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) {
        
        let message = messages[indexPath.section]
        let color = message.member.color
        avatarView.backgroundColor = color
        
        // add image based on name for now
        // handle the translated message to not have an image
        
        
        if message.member.name == "Ana"  {
            avatarView.image =  UIImage(named: "ana")
        } else {
            avatarView.image =  UIImage(named: "abuelita")
        }
        
        if color == UIColor.clear {
            avatarView.image =  UIImage(named: "clearimage")
            print("Do nothing")
        }
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor.systemBlue : UIColor.lightGray
    }
}

extension ViewController: MessageInputBarDelegate {
    func messageInputBar(
        _ inputBar: MessageInputBar,
        didPressSendButtonWith text: String) {
        
        chatService.sendMessage(text)
        inputBar.inputTextView.text = ""
    }
}

// not functional
extension ViewController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
        
        // handle this here for now - can put in double tap later
        let optInAlert = UIAlertController(title:"Bilingual Buddy would like your permission to use your translations to improve our app", message: "No identifying informatin will be collected. You can always adjust this in the Settings app", preferredStyle: .alert)
        optInAlert.addAction(UIAlertAction(title: "Allow", style: .default, handler: { optInAction in
            let alert = UIAlertController(title:"Rate translation", message: "Is this a good translation?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                if let indexPath = self.messagesCollectionView.indexPath(for: cell) {
                    let message = self.messages[indexPath.section]
                    let bilingualText = message.text
                    let goodTranslation = message.sentence
                    let name = "bilingual_spaeng_translation_data.txt" //this is the file. we will write to and read from it
                    
                    var logFile: URL? {
                        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
                        let fileName = name
                        return documentsDirectory.appendingPathComponent(fileName)
                    }
                    self.createCSV(logFile: logFile!, colA: bilingualText, colB: goodTranslation)
                    print(logFile)
                }
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }))
        optInAlert.addAction(UIAlertAction(title: "Don't Allow", style: .default, handler: nil))
        self.present(optInAlert, animated:true)
    }
    
    func createCSV(logFile: URL, colA: String, colB: String) {
        guard let data = ("\(colA),\(colB)\n").data(using: String.Encoding.utf8) else { return }
        
        if FileManager.default.fileExists(atPath: logFile.path) {
            if let fileHandle = try? FileHandle(forWritingTo: logFile) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            }
        } else {
            var csvText = "BilingualText,GoodTranslation\n"
            
            let newLine = "\(colA),\(colB)\n"
            csvText.append(newLine)
            
            do {
                try csvText.write(to: logFile, atomically: true, encoding: String.Encoding.utf8)
                
            } catch {
                print("Failed to create file")
                print("\(error)")
            }
            print(logFile)
        }
    }
    
    //    func writeDataToFile(file:String)-> Bool{
    //            // check our data exists
    //            guard let data = textView.text else {return false}
    //            print(data)
    //            //get the file path for the file in the bundle
    //            // if it doesnt exist, make it in the bundle
    //            var fileName = file + ".txt"
    //            if let filePath = NSBundle.mainBundle().pathForResource(file, ofType: "txt"){
    //                fileName = filePath
    //            } else {
    //                fileName = NSBundle.mainBundle().bundlePath + fileName
    //            }
    //
    //            //write the file, return true if it works, false otherwise.
    //            do{
    //                try data.writeToFile(fileName, atomically: true, encoding: NSUTF8StringEncoding )
    //                return true
    //            } catch{
    //                return false
    //            }
    //    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        // handle click here
        print("Message Tapped")
        
        let translationStyle = UserDefaults.standard.string(forKey: "translationStyle")!
        
        // if click-to-translate is enabled
        if translationStyle == "Click" {
            if let indexPath = messagesCollectionView.indexPath(for: cell) {
                let message = messages[indexPath.section]
                let newMessage = Message(member: message.member, text: message.sentence, messageId: message.messageId, translation: message.translation, sentence: message.text)
                messages[indexPath.section] = newMessage
                self.messagesCollectionView.reloadData()
            }
        }
        
        print(self.isKind(of: UILongPressGestureRecognizer.self))
        
        
        //        view.addGestureRecognizer(recognizer)
        //
        //        let touchPoint = gestureRecognizer.location(in: self)
        //        gestureRecognizer.isKind(of: UILongPressGestureRecognizer.self) else { return false }
    }
    
    @objc func longPressHappened(sender: UILongPressGestureRecognizer) {
        print("in long press!")
    }
    
}

//var message = Message(
//    member: member,
//    text: text,
//    messageId: UUID().uuidString,
//    translation: true,
//    sentence: translatedSent
//)
