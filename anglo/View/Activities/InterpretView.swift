//
//  CasesSelect.swift
//  anglo
//
//  Created by Kaoru Nishihara on 2021/11/27.
//

import SwiftUI
import AVFoundation

struct InterpretView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State var randomIdiomChoiceIndex = [0,1,2]
    @State var randomFixedChoiceIndex = [0,1]
    @State var num = 0 {
        didSet{
            self.speaker.stop();
            self.answered = false
            self.isCorrect = false
            if (num >= usecases.count){
                num = 0
                appViewModel.tab = .rearrange
            }
            randomIdiomChoiceIndex.shuffle()
            randomFixedChoiceIndex.shuffle()
            if(num != 0){ self.speechText(usecases[num].sentence) }
        }
    }
    @State var answered: Bool = false
    @State var isCorrect: Bool = false
    @State var frame: CGSize = .zero
    @State var isAlertPresented: Bool = false
    @StateObject var speaker: Speaker = Speaker()
    
    @State var usecases: [Usecase] = [Usecase]()
    @State var arrayFilled: Bool = false
    
    func makeView(_ geometry: GeometryProxy) {
            DispatchQueue.main.async { self.frame = geometry.size }
        }
    
    func handleAnswer(_ isCorrect: Bool) {
        self.isCorrect = isCorrect
        withAnimation(.easeOut(duration:0.2)) {self.answered = true}
        haptics.notificationOccurred(isCorrect ? .success : .error)
    }
    
    func speechText(_ text:String){
        if(appViewModel.activityType != .fixed){
            self.speaker.speak(text, language: "en-US")
        }
    }
    
    func extractSentenceForDisplay(_ sentence: String) -> String {
        var tempSentence = sentence
        if let i = tempSentence.firstIndex(of: "["){
            tempSentence.remove(at: i)
        }
        if let i = tempSentence.firstIndex(of: "]"){
            tempSentence.remove(at: i)
        }
        return tempSentence
    }
    
    var body: some View {
        VStack(){
            if(arrayFilled){
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
                                .frame(width:frame.width/CGFloat(usecases.count) * CGFloat(num+1), height:8)
                        }
                    }
                    
                    Button(action:{ isAlertPresented = true }){
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
                        primaryButton: .cancel(Text("キャンセル")),
                        secondaryButton: .destructive(Text("Quit"), action: {appViewModel.tab = .home}))
                    }
                }
                
                Text("- Interpretation -")
                    .font(.custom("Montserrat-Medium", size:18))
                    .frame(maxWidth:.infinity, alignment: .leading)
                    .foregroundColor(Color("txt"))
                    .padding(.top, 8)
                
                Spacer()
                
                Text(extractSentenceForDisplay(usecases[num].sentence))
                    .font(appViewModel.activityType == .fixed ? .custom("NotoSansJP-Medium", size:30) : .custom("Montserrat-Medium", size:30))
                    .frame(maxWidth:.infinity, alignment: .leading)
                
                Spacer()
                
                HStack(){
                    if(isCorrect){
                        LinearGradient(gradient:gradientColors, startPoint:.topLeading, endPoint:.bottomTrailing)
                            .frame(width:21, height:21)
                            .mask(
                                Image("check")
                                    .resizable()
                                    .renderingMode(.template)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width:21, height:21)
                            )
                    } else {
                        LinearGradient(gradient:incorrectGradientColors, startPoint:.topLeading, endPoint:.bottomTrailing)
                            .frame(width:18, height:18)
                            .mask(
                                Image("x")
                                    .resizable()
                                    .renderingMode(.template)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width:18, height:18)
                            )
                    }
                    
                    Text(isCorrect ? "Correct!" : "inCorrect...")
                        .font(.custom("Montserrat-Medium", size:18))
                        .foregroundColor(Color("txt"))
                }
                .opacity(answered ? 1 : 0)
                .offset(y: answered ? 0 : 6)
                
                
                ForEach(0..<usecases[num].choices.count){ i in
                    let choiceIndex = appViewModel.activityType == .fixed ? randomFixedChoiceIndex[i] : randomIdiomChoiceIndex[i]
                    Button(action:{ handleAnswer(choiceIndex == 0) }){
                        HStack(){
                            Text(usecases[num].choices[choiceIndex])
                                .font(appViewModel.activityType == .fixed ? .custom("Montserrat-Medium", size:12) : .custom("NotoSansJP-Medium", size:12))
                                .foregroundColor(Color("txt"))
                            
                            Spacer()
                            
                            if(answered && choiceIndex == 0){
                                LinearGradient(gradient:gradientColors, startPoint:.topLeading, endPoint:.bottomTrailing)
                                    .frame(width:14, height:14)
                                    .mask(
                                        Image("check")
                                            .resizable()
                                            .renderingMode(.template)
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width:14, height:14)
                                    )
                            }
                            
                            if(answered && choiceIndex != 0){
                                LinearGradient(gradient:gradientColors, startPoint:.topLeading, endPoint:.bottomTrailing)
                                    .frame(width:12, height:12)
                                    .mask(
                                        Image("x")
                                            .resizable()
                                            .renderingMode(.template)
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width:12, height:12)
                                    )
                            }
                        }
                    }
                    .disabled(answered)
                    .frame(maxWidth:.infinity, alignment: .leading)
                    .padding()
                    .cornerRadius(8)
                    .overlay(
                        Capsule()
                            .stroke(LinearGradient(gradient: (answered && choiceIndex == 0) ? gradientColors : Gradient(colors:[Color("boxbg"), Color("boxbg")]), startPoint:.topLeading, endPoint:.bottomTrailing))
                    )
                }
                
                Button(action:{num += 1}){
                    ZStack(){
                        Capsule()                            .fill(LinearGradient(gradient: answered ? gradientColors : Gradient(colors:[Color("boxbg"), Color("boxbg")]),startPoint: .leading, endPoint: .trailing))
                            .frame(height:48)
                        
                        Text("got it!")
                            .font(.custom("Montserrat-Medium", size:14))
                            .foregroundColor(answered ? .white : Color("boxbg"))
                    }
                }
                .disabled(!answered)
            }
        }
        .padding(.vertical)
        .padding(.horizontal, 32)
        .background(Color("bg").ignoresSafeArea())
        .onAppear(){
            self.usecases = appViewModel.usecases
            self.arrayFilled = true
            self.randomIdiomChoiceIndex.shuffle()
            self.randomFixedChoiceIndex.shuffle()
            self.speechText(usecases[num].sentence)
        }
    }
}

struct InterpretView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
