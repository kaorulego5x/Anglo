//
//  HomeView.swift
//  anglo
//
//  Created by Kaoru Nishihara on 2021/11/28.
//

import SwiftUI
import FASwiftUI
import AVFoundation

let voice = AVSpeechSynthesisVoice.init(language: "en-US")
let haptics = UINotificationFeedbackGenerator()

struct HomeView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State var selectedStage: Stage?
    @State var focusStageIndex: Int = 0
    @State var selectedWordIndex: Int = 0 {
        didSet {
            self.selectedStage = appViewModel.stageList[selectedWordIndex]
        }
    }
    
    var body: some View {
        GeometryReader{ geometry in
            VStack(){
                ZStack(){
                    Text("Getit")
                        .title()
                    
                    HStack(){
                        Spacer()
                        Icon("help", size:21)
                            .foregroundColor(.subtext)
                    }
                }
                
                VStack(){
                    HStack(){
                        HStack(){
                            Icon("progress", size:14)
                                .foregroundColor(.subtext)
                            Text("Progress")
                                .boxtitle()
                        }
                        
                        Spacer()
                        
                        Button(action:{}){
                            Text("Detail")
                        }
                    }
                    HStack(){
                        HStack(){
                            Text("Learn")
                            Spacer()
                            Text("2/3")
                        }
                        .frame(maxWidth:.infinity)
                        
                    }
                }
                .padding()
                .background(Color.boxbg)
                .cornerRadius(20)
            }
            
            VStack(spacing:0){
                    
                VStack(alignment: .leading, spacing:0){
                    VStack(alignment: .leading){
                        HStack(){
                            Spacer()
                        }
                        
                        Spacer()
                        
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack(alignment:.bottom, spacing:24){
                                ForEach(0..<words.count) { wordIndex in
                                    let selected = (wordIndex == selectedWordIndex)
                                    Button(action:{selectedWordIndex = wordIndex}){
                                        Text(words[wordIndex])
                                            .font(.custom("Montserrat-Bold", size:selected ? 48 : 32))
                                            .foregroundColor(Color.white.opacity(selected ? 1 : 0.2))
                                    }
                                }
                            }
                            .padding(.bottom)
                            .padding(.horizontal, 40)
                        }
                    }
                        
                    Rectangle()
                        .fill(Color("bg"))
                        .frame(height:40)
                        .cornerRadius(40, corners: [.topLeft, .topRight])
                        .frame(height:40)
                }
                .frame(height:160)
                .background(LinearGradient(gradient:gradientColors, startPoint: .top, endPoint: .bottom).ignoresSafeArea())
                //.edgesIgnoringSafeArea(.top)
                
                
                HStack(alignment:.bottom){
                    Circle()
                        .strokeBorder(Color("boxbg"), lineWidth: 40)
                        .frame(width:120, height:120)
                        .padding(.trailing, 32)
                    
                    VStack(spacing: 12){
                        HStack(spacing:12){
                            VStack(){
                                Text("マスター")
                                    .font(.custom("NotoSansJP-Regular", size:8))
                                    .foregroundColor(Color("txt"))
                                Text(String(appViewModel.progressList[selectedWordIndex].score[0]))
                                    .font(.custom("Montserrat-Bold", size:24))
                                    .foregroundColor(Color("txt"))
                            }
                            
                            VStack(){
                                Text("苦手")
                                    .font(.custom("NotoSansJP-Regular", size:8))
                                    .foregroundColor(Color("txt"))
                                Text(String(appViewModel.progressList[selectedWordIndex].score[1]))
                                    .font(.custom("Montserrat-Bold", size:24))
                                    .foregroundColor(Color("txt"))
                            }
                            
                            VStack(){
                                Text("未学習")
                                    .font(.custom("NotoSansJP-Regular", size:8))
                                    .foregroundColor(Color("txt"))
                                Text(String(appViewModel.progressList[selectedWordIndex].score[2]))
                                    .font(.custom("Montserrat-Bold", size:24))
                                    .foregroundColor(Color("txt"))
                            }
                        }
                        
                        Button(action:{}){
                            Text("苦手だけ復習")
                                .font(.custom("NotoSansJP-Medium", size:12))
                                .foregroundColor(.white)
                                .frame(height:48)
                                .frame(maxWidth:.infinity)
                                .background(LinearGradient(gradient: gradientColors, startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(24)
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 24)
                
                if let stage = selectedStage {
                    let sum = stage.roadMap.reduce(0, +)
                    ZStack(){
                        ScrollView(showsIndicators:false){
                            VStack(spacing:0){
                                
                                ForEach(0 ..< sum, id:\.self){ index in
                                    ActivityCapsule(index:index, stage:stage, nextStageIndex:appViewModel.nextLevel, focusStageIndex:$focusStageIndex, selectedWordIndex: selectedWordIndex, currentWordIndex: appViewModel.wordIndex, word: words[selectedWordIndex])
                                }
                                .disabled(selectedWordIndex > appViewModel.wordIndex)
                                
                                Spacer().frame(height:geometry.safeAreaInsets.bottom)
                            }
                        }
                        .opacity(selectedWordIndex > appViewModel.wordIndex ? 0.2 : 1)
                        
                        if(selectedWordIndex > appViewModel.wordIndex){
                            VStack(spacing: 8){
                                FAText(iconName:"lock", size:32)
                                    .foregroundColor(.white)
                                
                                Text("locked")
                                    .font(.custom("Montserrat-Medium", size:16))
                                    .foregroundColor(.white)
                            }
                           
                        }
                    }
                }
                
                Spacer()
            }
            .edgesIgnoringSafeArea(.bottom)
            .background(Color("bg").ignoresSafeArea())
            .onAppear(){
                self.selectedStage = appViewModel.stageList[selectedWordIndex]
                self.focusStageIndex = appViewModel.nextLevel
                self.selectedWordIndex = appViewModel.wordIndex
            }
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

internal class Speaker: NSObject, ObservableObject {
    internal var errorDescription: String? = nil
    private let synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    @Published var isSpeaking: Bool = true
    @Published var isShowingSpeakingErrorAlert: Bool = false

    override init() {
        super.init()
        self.synthesizer.delegate = self
    }

    internal func speak(_ text: String, language: String) {
        do {
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: language)
            
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: AVAudioSession.CategoryOptions.mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            self.synthesizer.speak(utterance)
        } catch let error {
            self.errorDescription = error.localizedDescription
            isShowingSpeakingErrorAlert.toggle()
        }
    }
    
    internal func stop() {
        self.synthesizer.stopSpeaking(at: .immediate)
    }
}

extension Speaker: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        self.isSpeaking = true
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        self.isSpeaking = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.isSpeaking = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}


struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ActivityCapsule: View {
    @EnvironmentObject var appViewModel: AppViewModel
    var index: Int
    var stage: Stage
    var nextStageIndex: Int
    @Binding var focusStageIndex: Int
    var selectedWordIndex: Int
    var currentWordIndex: Int
    var word: String
    
    var body: some View {
        let tilSingle = stage.roadMap[0]
        let tilIdiom = tilSingle + stage.roadMap[1]
        let tilFixed = tilIdiom + stage.roadMap[2]
        let sum = tilFixed
        let title = index < tilSingle ? "単体での使い方" : (index < tilIdiom ? "イディオム" : "定型表現")
        let displayIndex = index < tilSingle ? index : (index < tilIdiom ? index - tilSingle : index - tilIdiom)
        let spaceHeight = 60
        var completed = selectedWordIndex < currentWordIndex ? true : (selectedWordIndex == currentWordIndex ?  (index < nextStageIndex) : false)
        let upnext = (index == nextStageIndex && selectedWordIndex == currentWordIndex)
        let focused = (selectedWordIndex <= currentWordIndex) && (index == focusStageIndex)
        let locked = selectedWordIndex < currentWordIndex ? false : (selectedWordIndex == currentWordIndex ?  (index > nextStageIndex) : true)
        
        HStack(){
            if(!focused){
                ZStack(){
                    VStack(){
                        let lineColor = completed ? Color("maingrad1") : Color("boxbg")
                        HStack(){}
                            .frame(width:2, height:CGFloat(spaceHeight/2))
                            .background((upnext && index != 0) ? Color("maingrad1") : (index != 0 ? lineColor : Color.clear))
                        
                        HStack(){}
                            .frame(width:2, height:CGFloat(spaceHeight/2))
                            .background(index != sum - 1 ? lineColor : Color.clear)
                        
                    }
                    HStack(){}
                        .frame(width:12, height:12)
                        .background(LinearGradient(gradient: locked ? Gradient(colors:[Color("boxbg"), Color("boxbg")]) : gradientColors, startPoint: .topLeading, endPoint: .bottomLeading))
                        .cornerRadius(6)
                }
            }
            
            HStack(spacing:0){
                ZStack(){
                    Circle()
                        .fill(Color("bg"))
                        .frame(width:focused ? 48 : 38, height:focused ? 48 : 38)
                    
                    Text(String(index+1))
                        .font(.custom("Montserrat-Bold", size:focused ? 18 : 14))
                        .foregroundColor(Color("txt"))
                }
                .padding(.leading, focused ? 4 : 0)
                .padding(.trailing, focused ? 18 : 12)
                
                VStack(alignment:.leading, spacing:4){
                    if(focused){
                        Text(completed ? "Redo:" : (locked ? "Locked:" : "Up next:"))
                            .font(.custom("Montserrat-Medium", size:12))
                            .foregroundColor(Color("txt"))
                            .offset(y:1)
                    }
                    
                    HStack(spacing:0){
                        if(focused){
                            Text(title)
                                .font(.custom("NotoSansJP-Bold", size:18))
                                .foregroundColor(Color("txt"))
                                .padding(.trailing, 6)
                        } else {
                            Text(title)
                                .font(.custom("NotoSansJP-Medium", size:12))
                                .foregroundColor(Color("txt"))
                                .padding(.trailing, 4)
                        }
                        
                        if(focused){
                            Text("#\(displayIndex+1)")
                                .font(.custom("Montserrat-Bold", size:18))
                                .foregroundColor(Color("txt"))
                                .offset(y:1)
                        } else {
                            Text("#\(displayIndex+1)")
                                .font(.custom("Montserrat-Medium", size:12))
                                .foregroundColor(Color("txt"))
                                .offset(y:1)
                        }
                    }
                }
                
                Spacer()
                
                if(focused){
                    Button(action:{
                        appViewModel.fetchActivitiesData(selectedWordIndex:selectedWordIndex, type:(index < tilSingle ? .single : (index < tilIdiom ? .idiom : .fixed)), index:index, typeIndex: displayIndex)
                    }){
                        FAText(iconName:completed ? "redo-alt" : (locked ? "lock" : "play"), size:16, style:.solid)
                            .foregroundColor(Color("txt"))
                            .frame(width:56, height:56)
                            .background(LinearGradient(gradient:locked ? Gradient(colors:[Color("bg"), Color("bg")]) : gradientColors, startPoint:.topLeading, endPoint:.bottomTrailing))
                            .cornerRadius(32)
                    }
                    .disabled(locked)
                } else if(locked){
                    FAText(iconName:"lock", size:16, style:.solid)
                        .foregroundColor(Color("bg"))
                        .padding(.trailing, 12)
                }
            }
            .padding(focused ? 12 : 5)
            .overlay(
                Capsule()
                    .stroke(LinearGradient(gradient:locked ? Gradient(colors:[Color("boxbg"), Color("boxbg")]) : gradientColors, startPoint:.topLeading, endPoint:.bottomTrailing), lineWidth:focused ? 3 : 0)
            )
            .background(Color("boxbg"))
            .cornerRadius(40)
            .onTapGesture {
                withAnimation(.easeOut(duration:0.08)){focusStageIndex = index}
            }
        }
        .padding(.horizontal, focused ? 8 : 40)
    }
}
