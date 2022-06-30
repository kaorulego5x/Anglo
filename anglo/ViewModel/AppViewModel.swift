//
//  AppViewModel.swift
//  anglo
//
//  Created by Kaoru Nishihara on 2021/12/03.
//

import SwiftUI
import Foundation
import FirebaseAuth
import FirebaseFirestore

enum ActivityType {
    case single, idiom, fixed
}

let ActivityTypeText = { (type: ActivityType) -> String in
    switch(type){
    case .single:
    return "Stand-alone usage"
    case .idiom:
    return "Idiom Usage"
    case .fixed:
    return "Practical usage"
    }
}

let words = ["get", "give", "take"]

class AppViewModel: ObservableObject {
    @Published var tab: Tab = .home
    @Published var word: String = ""
    @Published var isFirstTime: Bool = false
    @Published var showMain: Bool = false
    @Published var loaded: Bool = false
    @Published var stageList: [Stage] = [Stage]()
    @Published var progressList: [Progress] = [Progress]()
    @Published var nextLevel: Int = 0
    @Published var wordIndex: Int = 0
    @Published var selectedWordIndex: Int = 0;
    @Published var activityType: ActivityType = .single
    @Published var typeIndex: Int = 0;
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    var type: ActivityType = .single
    var phrases = [Phrase]()
    var usecases = [Usecase]()
    var isNewActivity = false
    
    init(){
        
    }
    
    func handleLaunch() {
        if let currentUser = auth.currentUser { //登録済み
            print("Already Registered!")
            print(currentUser.uid)
            self.getUserData(uid: currentUser.uid, completion:{
                self.getMetaData {
                    self.enterSandman()
                }
            })
        } else { //新規登録
            auth.signInAnonymously() { [weak self] authResult, error in
                print("Newly Registered!")
                guard let newUser = authResult?.user else {
                    print("Error in creating a new account!")
                    return
                }
                self?.getUserData(uid: newUser.uid, completion:{
                    self?.getMetaData {
                        self?.enterSandman()
                    }
                })
            }
        }
    }
    
    func getUserData(uid:String, completion: @escaping () -> Void){
        let userDocRef = self.db.collection("Users").document(uid)
        let metaDataDocRef = self.db.collection("Metadata").document("Beta")
        userDocRef.getDocument(){(document, err) in
            if let document = document, document.exists {
                let userData = document.data()!
                self.nextLevel = userData["nextLevel"] as? Int ?? 0
                self.wordIndex = userData["currentStageIndex"] as? Int ?? 0
                let tempProgressList = userData["progress"] as! [[String:Any]]
                for progress in tempProgressList {
                    let word = progress["word"] as? String ?? ""
                    let weaks = progress["weaks"] as? [String] ?? []
                    let score = progress["score"] as? [Int] ?? []
                    self.progressList.append(Progress(word:word, score:score, weaks:weaks))
                }
                completion()
            } else { //newly registered or version update
                self.isFirstTime = true
                metaDataDocRef.getDocument(){(document, err) in
                    if let document = document, document.exists {
                        let metadata = document.data()!
                        let userInitialData = metadata["userInitialData"] as! [String:Any]
                        let tempProgressList = userInitialData["progress"] as! [[String:Any]]
                        for progress in tempProgressList {
                            let word = progress["word"] as? String ?? ""
                            let weaks = progress["weaks"] as? [String] ?? []
                            let score = progress["score"] as? [Int] ?? []
                            self.progressList.append(Progress(word:word, score:score, weaks:weaks))
                        }
                        userDocRef.setData(userInitialData) {err in
                            if(err != nil) { print("Failed at getting initial data") }
                            else {
                                completion()
                            }
                        }
                    } else {
                        print("Document not found")
                    }
                }
            }
        }
    }
    
    func getMetaData(completion: @escaping () -> Void){
        let metadataDocRef = self.db.collection("Metadata").document("Beta")
        metadataDocRef.getDocument(){(document, err) in
            if let document = document, document.exists {
                let data = document.data()!
                let stageDatas = data["stageData"] as! [[String:Any]]
                for stageData in stageDatas {
                    let roadMap = stageData["roadMap"] as? [Int] ?? []
                    let word = stageData["word"] as? String ?? ""
                    self.stageList.append(Stage(word: word, roadMap: roadMap))
                    completion()
                }
            }
        }
    }
    
    func enterSandman(){
        //if(isFirstTime){self.setTab(.tutorial)}
        self.showMain = true
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0){
            withAnimation(.easeOut(duration: 0.2)){ self.loaded = true }
        }
    }
    
    func fetchActivitiesData(selectedWordIndex:Int, type: ActivityType, index:Int, typeIndex: Int){
        self.activityType = type;
        self.selectedWordIndex = selectedWordIndex
        self.typeIndex = typeIndex;
        if(selectedWordIndex == wordIndex && index == nextLevel){
            self.isNewActivity = true
        }
        self.phrases = [Phrase]()
        self.usecases = [Usecase]()
        self.type = type
        withAnimation(.easeOut(duration:0.2)){
            tab = .loading
        }
        let playlistdocRef = db.collection("Playlists").document(words[selectedWordIndex] + String(describing: type) + String(typeIndex))
        playlistdocRef.getDocument(){(document, err) in
            if let document = document, document.exists {
                let data = document.data()!
                let hashes = data["hashes"] as? [Int] ?? []
                var phraseDatas = [[String:Any]]()
                if(type == .fixed){
                    phraseDatas = data["fixeds"] as! [[String:Any]]
                } else if(type == .idiom){
                    phraseDatas = data["idioms"] as! [[String:Any]]
                }
                //let phraseDatas = (type == .fixed && data["fixeds"] : data["idioms"]) as! [[String:Any]]
                for phraseData in phraseDatas {
                    let meaning = phraseData["meaning"] as? String ?? ""
                    let phrase = phraseData["phrase"] as? String ?? ""
                    self.phrases.append(Phrase(phrase: phrase, meaning: meaning))
                }
                
                let group = DispatchGroup()
                for hash in hashes {
                    group.enter()
                    self.db.collection("Activities").document(String(hash)).getDocument(){(document, err) in
                        if let document = document, document.exists {
                            let data = document.data()!
                            let sentence = data["sentence"] as? String ?? ""
                            let choices = data["choices"] as? [String] ?? []
                            self.usecases.append(Usecase(sentence: sentence, choices: choices))
                            group.leave()
                        }
                    }
                }
                
                group.notify(queue:.main, execute:{
                    
                })
                
            } else {
                print("Where the Hood At?")
            }
        }
    }
    
    func handleExitActivity(){
        print("Yes")
        if(isNewActivity){
            let activitySum = self.stageList[self.wordIndex].roadMap.reduce(0, +)
            if(activitySum == nextLevel+1){
                if(wordIndex + 1 != self.stageList.count){
                    wordIndex += 1
                    nextLevel = 0
                }
            } else {
                nextLevel += 1
                print(nextLevel)
            }
            self.db.collection("Users").document(auth.currentUser!.uid).updateData(["currentStageIndex":wordIndex, "nextLevel":nextLevel])
        }
        isNewActivity = false
        tab = .home
    }
    
}
