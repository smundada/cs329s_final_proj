//
//  ChatService.swift
//  ScaledroneChatTest
//
//  Created by Marin Benčević on 08/09/2018.
//  Copyright © 2018 Scaledrone. All rights reserved.
//

import Foundation
import Scaledrone
import PromiseKit
import ROGoogleTranslate

class ChatService {
    
    private let scaledrone: Scaledrone
    private let messageCallback: (Message)-> Void
    
    // Private variables to keep track of translations
    private var langIdentifications: String
    
    private var room: ScaledroneRoom?
    
    init(member: Member, onRecievedMessage: @escaping (Message)-> Void) {
        self.messageCallback = onRecievedMessage
        //    #error("Make sure to input your channel ID and delete this line.")
        
        // Initialize variables to keep track of translations
        self.langIdentifications = ""
        
        self.scaledrone = Scaledrone(
            channelID: "4a0eACumUcvr9h78",
            data: member.toJSON)
        scaledrone.delegate = self
    }
    
    func connect() {
        scaledrone.connect()
    }
    
    func sendMessage(_ message: String) {
        room?.publish(message: message)
    }
    
    func getLanguageIdentifications(inputMessage: String) -> Promise<NSArray> {
        return Promise { promise in
            let serverAddress = "https://api-inference.huggingface.co/models/sagorsarker/codeswitch-spaeng-lid-lince"
            let apiKey = "api_dYDRRqHDSfQzdCqVvBmvfILMuMVCgsWbnL"
            
            var request = URLRequest(url: URL(string: serverAddress)!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            
            // Input text
            request.httpBody = inputMessage.data(using: .utf8)
            
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
                guard let data = data else {return}
                // print("Results of language identification model")
                // print(langIdentifications)
                
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                print(json!)
                print(error)
                promise.fulfill(json as! NSArray)
            })
            task.resume()
        }
    }
    
    func googleTranslate(inputMessage: String, selectedLang: String) -> Promise<String> {
        return Promise { promise in
            // figure out source and target languages we are translating
            var sourceLang = ""
            var targetLang = ""
            if selectedLang == "English" {
                sourceLang = "es"
                targetLang = "en"
            } else if selectedLang == "Spanish" {
                sourceLang = "en"
                targetLang = "es"
            }
            
            // Translation with OUR fine-tuned pretrained models
            // choose the correct server based on which way we want to translate
            let spanishToEnglish = "https://api-inference.huggingface.co/models/judicarta/cs329-test3"
            let englishToSpanish = "https://api-inference.huggingface.co/models/judicarta/test4"
            var serverAddress = ""
            if selectedLang == "English" {
                serverAddress = spanishToEnglish
            } else if selectedLang == "Spanish" {
                serverAddress = englishToSpanish
            }
            
            let apiKey = "api_dYDRRqHDSfQzdCqVvBmvfILMuMVCgsWbnL"
            
            var request = URLRequest(url: URL(string: serverAddress)!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            
            // Input text
            request.httpBody = inputMessage.data(using: .utf8)
            
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
                guard let data = data else {return}
                print("The translation from our model")
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as! NSArray
                let generatedText = json![0]
                print(generatedText)
                
                //                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                //                print(json!)
                //                promise.fulfill(json as! NSArray)
                promise.fulfill(generatedText as! String)
            })
            task.resume()
        }
    }
    
    func getMonolingualSentence(input: NSArray, selectedLang: String) -> Promise<String> {
        return Promise { promise in
            // figure out which language we are translating
            var targetEntityGroup = ""
            if selectedLang == "English" {
                targetEntityGroup = "spa"
            } else if selectedLang == "Spanish" {
                targetEntityGroup = "en"
            }
            
            // Put together whole sentence
            var bilingualSent = ""
            // Create a dictionary of what we need to translate
            // Contains {Spanish: English}
            var translationDict = [String: String]()
            for object in input as! [NSDictionary] {
                let entityGroup = object["entity_group"] as! String
                let word = object["word"] as! String
                
                bilingualSent += word + " "
                if entityGroup == targetEntityGroup {
                    translationDict[word] = ""
                }
            }
            //            print("Bilingual Sentence:")
            //            print(bilingualSent)
            print("Words that need to be translated:")
            print(translationDict)
            
            // Asynchronously loop through the words that we need to translate
            // And use the google translate API to get the translation
            // Have to use DispatchGroup() so that we work with the translations
            // Once the entire for loop is done
            let myGroup = DispatchGroup()
            
            for (word, _) in translationDict {
                myGroup.enter()
                
                self.googleTranslate(inputMessage: word, selectedLang: selectedLang).done { translation in
                    translationDict[word] = translation
                    myGroup.leave()
                }
            }
            
            // Once all words have been translated, construct the monolingual sentence and return
            myGroup.notify(queue: .main) {
                print("Words that need to be translated WITH translations:")
                print(translationDict)
                
                var monolingualSent = ""
                for object in input as! [NSDictionary] {
                    let entityGroup = object["entity_group"] as! String
                    let word = object["word"] as! String
                    
                    if entityGroup == targetEntityGroup {
                        monolingualSent += translationDict[word]! + " "
                    } else {
                        monolingualSent += word + " "
                    }
                }
                //                print("Monolingual sentence:")
                //                print(monolingualSent)
                
                promise.fulfill(monolingualSent)
            }
        }
    }
    
    //    func getFinalTranslation(monolingualSent: String) -> Promise<String> {
    //        return Promise { promise in
    //            googleTranslate(inputMessage: monolingualSent).done { translation in
    //                promise.fulfill(translation)
    //            }
    //        }
    //    }
}


extension ChatService: ScaledroneDelegate {
    
    func scaledroneDidConnect(scaledrone: Scaledrone, error: NSError?) {
        print("Connected to Scaledrone")
        room = scaledrone.subscribe(roomName: "observable-room")
        room?.delegate = self
    }
    
    func scaledroneDidReceiveError(scaledrone: Scaledrone, error: NSError?) {
        print("Scaledrone error", error ?? "")
    }
    
    func scaledroneDidDisconnect(scaledrone: Scaledrone, error: NSError?) {
        print("Scaledrone disconnected", error ?? "")
    }
    
}

extension ChatService: ScaledroneRoomDelegate {
    
    func scaledroneRoomDidConnect(room: ScaledroneRoom, error: NSError?) {
        print("Connected to room!")
    }
    
    func scaledroneRoomDidReceiveMessage(
        room: ScaledroneRoom,
        message: Any,
        member: ScaledroneMember?) {
        
        guard
            var text = message as? String,
            let memberData = member?.clientData,
            var member = Member(fromJSON: memberData)
        else {
            print("Could not parse data.")
            return
        }
        
        // Promise Kit sources
        // https://swiftrocks.com/avoiding-callback-hell-in-swift.html
        // https://medium.com/@oleary.audio/fun-with-promisekit-e271be8e324
        
        // Steps
        // 1) Language Identification and tagging
        // 2) Run Spanish words through Google Translate API and piece together
        // Returns: complete English Sentence
        
        print("Received text message:")
        print(text)
        
        print("Selected language for translation")
        let selectedLang = UserDefaults.standard.string(forKey: "selectedLang")!
        print(selectedLang)
        
        //        let translationStyle = UserDefaults.standard.string(forKey: "translationStyle")!
        //        print(translationStyle)
        
        var finalTranslation = ""
        //        let promise = getLanguageIdentifications(inputMessage: text).then { langIds in
        //            self.getMonolingualSentence(input: langIds, selectedLang: selectedLang)
        //        }.done { translatedSent in
        let promise = googleTranslate(inputMessage: text, selectedLang: selectedLang).done { translatedSent in
            print("Final Translated Sentence:")
            print(translatedSent)
            finalTranslation = translatedSent
            
            // original message
            var message = Message(
                member: member,
                text: text,
                messageId: UUID().uuidString,
                translation: true,
                sentence: translatedSent
            )
            self.messageCallback(message)
        }
    }
}

