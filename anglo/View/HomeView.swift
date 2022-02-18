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
    @Binding var tab: Tab
    @State var selectedStage: Stage?
    @State var focusStageIndex: Int = 3
    @State var selectedWordIndex: Int = 0
    
    private let words = ["Get", "Have", "Run", "Give"]
    private let nextStageIndex = 3
    
    var body: some View {
        VStack(spacing:0){
                
            VStack(alignment: .leading, spacing:0){
                VStack(alignment: .leading){
                    HStack(){
                        Spacer()
                        
                        Button(action:{}){
                            FAText(iconName: "sliders-h", size: 20, style:.solid)
                                .foregroundColor(.white)
                        }
                        .padding([.top, .trailing], 24)
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
                            Text("21")
                                .font(.custom("Montserrat-Bold", size:24))
                                .foregroundColor(Color("txt"))
                        }
                        
                        VStack(){
                            Text("苦手")
                                .font(.custom("NotoSansJP-Regular", size:8))
                                .foregroundColor(Color("txt"))
                            Text("18")
                                .font(.custom("Montserrat-Bold", size:24))
                                .foregroundColor(Color("txt"))
                        }
                        
                        VStack(){
                            Text("未学習")
                                .font(.custom("NotoSansJP-Regular", size:8))
                                .foregroundColor(Color("txt"))
                            Text("10")
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
                ScrollView(){
                    VStack(spacing:0){
                        ForEach(0 ..< sum, id:\.self){ index in
                            ActivityCapsule(index:index, stage:stage, nextStageIndex:nextStageIndex, focusStageIndex:$focusStageIndex, tab:$tab)
                        }
                        
                    }
                }
            }
            
            Spacer()
        }
        .background(Color("bg").ignoresSafeArea())
        .onAppear(){
            self.fetchStageData()
        }
    }
    
    func fetchStageData() -> Void {
        if let stage = mockStages.first(where: {$0.word == "get"}){
            selectedStage = stage
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
            
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
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
    var index: Int
    var stage: Stage
    var nextStageIndex: Int
    @Binding var focusStageIndex: Int
    @Binding var tab: Tab
    
    var body: some View {
        let tilSingle = stage.roadMap[0]
        let tilIdiom = stage.roadMap[0] + stage.roadMap[1]
        let sum = stage.roadMap[0] + stage.roadMap[1]
        let title = index < tilSingle ? "単体での使い方" : (index < tilIdiom ? "イディオム" : "テスト")
        let displayIndex = index < tilSingle ? index : index - tilSingle
        let spaceHeight = 60
        let completed = index < nextStageIndex
        let upnext = (index == nextStageIndex)
        let focused = (index == focusStageIndex)
        let locked = index > nextStageIndex
        
        HStack(){
            if(!focused){
                ZStack(){
                    VStack(){
                        let lineColor = completed ? Color("maingrad1") : Color("boxbg")
                        HStack(){}
                            .frame(width:2, height:CGFloat(spaceHeight/2))
                            .background(upnext ? Color("maingrad1") : (index != 0 ? lineColor : Color.clear))
                        
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
                        withAnimation(.easeOut(duration:0.2)){
                            tab = .loading
                        }
                    }){
                        FAText(iconName:completed ? "redo-alt" : (locked ? "lock" : "play"), size:16, style:.solid)
                            .foregroundColor(Color.white)
                            .frame(width:56, height:56)
                            .background(LinearGradient(gradient:locked ? Gradient(colors:[Color("bg"), Color("bg")]) : gradientColors, startPoint:.topLeading, endPoint:.bottomTrailing))
                            .cornerRadius(32)
                    }
                    .disabled(locked)
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
        
            /*HStack(spacing:0){
                ZStack(){
                    Circle()
                        .fill(Color.white)
                        .frame(width:48, height:48)
                               
                    Text(String(index+1))
                        .font(.custom("Montserrat-Bold", size:18))
                        .foregroundColor(Color("txt"))
                }
                .padding(.leading, 4)
                .padding(.trailing, 18)
                        
                VStack(alignment:.leading, spacing:4){
                    Text("Next up:")
                        .font(.custom("Montserrat-Medium", size:12))
                        .foregroundColor(Color("txt"))
                        .offset(y:1)
                            
                    HStack(spacing:0){
                        Text(title)
                            .font(.custom("NotoSansJP-Bold", size:18))
                            .foregroundColor(Color("txt"))
                            .padding(.trailing, 6)
                                
                        Text("#\(displayIndex+1)")
                            .font(.custom("Montserrat-Bold", size:18))
                            .foregroundColor(Color("txt"))
                            .offset(y:1)
                    }
                }
                
                Spacer()
                        
                Button(action:{
                    withAnimation(.easeOut(duration:0.2)){
                        tab = .loading
                    }
                }){
                    FAText(iconName:"play", size:16)
                        .foregroundColor(Color.white)
                        .frame(width:56, height:56)
                        .background(LinearGradient(gradient:gradientColors, startPoint:.topLeading, endPoint:.bottomTrailing))
                        .cornerRadius(32)
                }
            }
            .padding(12)
            .overlay(Capsule()
                .stroke(LinearGradient(gradient:gradientColors, startPoint:.topLeading, endPoint:.bottomTrailing), lineWidth:3)
            )
            .background(Color("boxbg"))
            .cornerRadius(40)
            .padding(.horizontal, 8)
        }*/
    }
}
