//
//  Phrase.swift
//  anglo
//
//  Created by Kaoru Nishihara on 2021/11/27.
//

import SwiftUI
import AVFoundation

struct PhraseView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State var frame: CGSize = .zero
    @State var num:Int = 0 {
        didSet {
            if(num >= phrases.count){
                num = 0
                appViewModel.tab = .interpret
            }
            if (num != 0) { self.speechText(phrases[num].phrase) }
        }
    }
    //@State var isVoicePlayed = false
    @State var isAlertPresented = false
    @StateObject var speaker: Speaker = Speaker()
    
    @State var phrases: [Phrase] = [Phrase]()
    @State var filled: Bool = false
    
    var body: some View {
        VStack(){
            if(filled){
                HStack(spacing:16){
                    VStack(alignment: .leading, spacing:8){
                        Text("\(ActivityTypeText(appViewModel.activityType)) - \(words[appViewModel.selectedWordIndex].capitalizingFirstLetter()) Pt.\(appViewModel.typeIndex + 1)")
                            .font(.custom("Montserrat-Medium", size:14))
                            .foregroundColor(Color("txt"))
                        
                        ZStack(alignment:.leading){
                            GeometryReader { geometry in
                                Capsule()
                                    .fill(Color("txt").opacity(0.1))
                                    .frame(height:8)
                                    .onAppear(){
                                        self.makeView(geometry)
                                    }
                            }
                            .frame(height:8)
                            
                            Capsule()
                                .fill(LinearGradient(gradient:gradientColors,startPoint: .leading, endPoint: .trailing))
                                .frame(width:frame.width/CGFloat(phrases.count) * CGFloat(num+1), height:8)
                            
                        }
                    }
                    
                    Button(action:{isAlertPresented = true}){
                        Image("x")
                            .resizable()
                            .renderingMode(/*@START_MENU_TOKEN@*/.template/*@END_MENU_TOKEN@*/)
                            .foregroundColor(Color("txt"))
                            .aspectRatio(contentMode: .fit)
                            .frame(width:18, height:18)
                            .offset(y:11)
                    }
                    .alert(isPresented: $isAlertPresented) {
                                Alert(title: Text("Back home"),
                                      message: Text("データが保存されませんが、\nよろしいですか？"),
                                      primaryButton: .cancel(Text("キャンセル")),    // キャンセル用
                                      secondaryButton: .destructive(Text("Quit"), action: {appViewModel.tab = .home}))   // 破壊的変更用
                            }
         
                }
                
                Spacer()
                
                VStack(spacing:0){
                    LinearGradient(gradient:gradientColors, startPoint: .top, endPoint: .bottom)
                        .frame(height:90)
                        .mask(Text(phrases[num].phrase)
                                .font(.custom("Montserrat-Bold", size:500))
                                        .minimumScaleFactor(0.01))
                    
                    Text(phrases[num].meaning)
                        .font(.custom("NotoSansJP-Medium", size:24))
                        .foregroundColor(Color("txt"))
                }
                
                Spacer()
                
                Button(action:{num += 1}){
                    ZStack(){
                        Capsule()
                            .fill(LinearGradient(gradient:self.speaker.isSpeaking ? Gradient(colors:[Color("boxbg"), Color("boxbg")]) : gradientColors, startPoint: .leading, endPoint: .trailing))
                            .frame(height:48)
                        
                        Text("got it!")
                            .font(.custom("Montserrat-Medium", size:14))
                            .foregroundColor(self.speaker.isSpeaking ? Color("boxbg") : Color.white)
                    }
                }
                .disabled(self.speaker.isSpeaking)
            }
        }
        .padding(.vertical)
        .padding(.horizontal, 32)
        .background(Color("bg").ignoresSafeArea())
        .onAppear(){
            self.phrases = appViewModel.phrases
            filled = true
            self.speechText(phrases[num].phrase)
        }
    }
    
    func makeView(_ geometry: GeometryProxy) {
        DispatchQueue.main.async { self.frame = geometry.size }
    }
    
    func speechText(_ text:String){
        self.speaker.speak(text, language: "en-US")
    }
}

struct Phrase_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
