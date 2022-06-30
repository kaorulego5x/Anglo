//
//  RearrangeView.swift
//  anglo
//
//  Created by Kaoru Nishihara on 2021/11/27.
//

import SwiftUI

let incorrectGradientColors = Gradient(colors:[Color.orange, Color.red])

struct RearrangeView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State var num: Int = 0 {
        didSet {
            if (num >= usecases.count){
                appViewModel.handleExitActivity()
                num = 0
            }
            filled = false
            checked = false
            components = []
            randomOrder = []
            answerArray = []
            suffix = ""
            self.handleResetComponents(num)
        }
    }
    @State var filled: Bool = false
    @State var checked: Bool = false
    @State var isCorrect: Bool = false
    @State var components: [String] = []
    @State var randomOrder: [Int] = []
    @State var answerArray: [Int] = []
    @State var frame: CGSize = .zero
    @State var suffix: String = ""
    @State var isAlertPresented: Bool = false
    
    @State var usecases: [Usecase] = [Usecase]()
    @State var arrayFilled: Bool = false
    
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
                            
                            
                            Capsule()                      .fill(LinearGradient(gradient:gradientColors,startPoint: .leading, endPoint: .trailing))
                                .frame(width:frame.width/CGFloat(usecases.count) * CGFloat(num+1), height:8)
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
                                      primaryButton: .cancel(Text("キャンセル")),
                                      secondaryButton: .destructive(Text("Quit"), action: {appViewModel.tab = .home}))
                            }
                }
                
                Text("- Rearrange -")
                    .font(.custom("Montserrat-Medium", size:18))
                    .frame(maxWidth:.infinity, alignment: .leading)
                    .foregroundColor(Color("txt"))
                    .padding(.top, 8)
                
                Spacer()
                
                Text(appViewModel.activityType == .fixed ? usecases[num].sentence : usecases[num].choices[0])
                    .font(.custom("NotoSansJP-Medium", size:20))
                    .frame(maxWidth:.infinity, alignment: .leading)
                    .padding(.bottom, 0)
                    
                VStack(){
                    AnswerCloudView(components:components, answerArray: $answerArray, checked: $checked)
                    Spacer()
                }
                .frame(height:100)
                
                if(!checked){
                    Spacer()
                    
                    VStack(){
                        ChoiceCloudView(components: components, randomOrder: $randomOrder, answerArray: $answerArray, filled:$filled)
                        .frame(maxWidth:.infinity, alignment:.leading)
                        Spacer()
                    }
                    .frame(height:120)
                }
                
                if(checked){
                    VStack(){
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
                            
                            Spacer()
                        }
                        
                        if(!isCorrect){
                            Text("A. " + usecases[num].sentence)
                                .font(.custom("Montserrat-Medium", size:18))
                                .foregroundColor(Color("txt"))
                                .frame(maxWidth:.infinity, alignment: .leading)
                        }
                    }
                }
                
                Spacer()
                
                Button(action:{
                    if checked {
                        num += 1;
                    } else {
                        self.handleAnswer()
                    }
                }){
                    ZStack(){
                        Capsule()
                            .fill(LinearGradient(gradient: filled ? gradientColors : Gradient(colors:[Color("boxbg"), Color("boxbg")]),startPoint: .leading, endPoint: .trailing))
                            .frame(height:48)
                        
                        Text(checked ? "got it!" : "Let's see...")
                            .font(.custom("Montserrat-Medium", size:14))
                            .foregroundColor(filled ? .white : Color("boxbg"))
                    }
                }
                .disabled(!filled)
            }
        }
        .padding(.vertical)
        .padding(.horizontal, 32)
        .background(Color("bg").ignoresSafeArea())
        .onAppear(){
            self.usecases = appViewModel.usecases
            self.arrayFilled = true
            self.handleResetComponents(0)
        }
    }
    
    func handleAnswer() -> Void {
        var answerComponents = [String]()
        for answerIndex in answerArray {
            answerComponents.append(components[answerIndex])
        }
        self.isCorrect = (components == answerComponents)
        haptics.notificationOccurred(isCorrect ? .success : .error)
        withAnimation(.easeOut(duration:0.2)){ checked = true }
    }
    
    func makeView(_ geometry: GeometryProxy) {
            DispatchQueue.main.async { self.frame = geometry.size }
    }
    
    func handleResetComponents(_ useCaseIndex: Int) {
        var baseSentence:String = (appViewModel.activityType == .fixed ? usecases[useCaseIndex].choices[0] : usecases[useCaseIndex].sentence)
        baseSentence = extractSentenceForDisplay(baseSentence)
        if baseSentence.hasSuffix("?") {
            suffix = "?"
            baseSentence = String(baseSentence.dropLast()).lowercased()
        } else if baseSentence.hasSuffix(".") {
            suffix = "."
            baseSentence = String(baseSentence.dropLast()).lowercased()
        } else if baseSentence.hasSuffix("!") {
            suffix = "."
            baseSentence = String(baseSentence.dropLast()).lowercased()
        } else if baseSentence.hasSuffix("!?") {
            suffix = "!?"
            baseSentence = String(baseSentence.dropLast().dropLast()).lowercased()
        }
        let correctComponents = baseSentence.components(separatedBy: " ")
        components = correctComponents
        answerArray = [Int](repeating: -1, count: components.count)
        randomOrder = Array(0..<correctComponents.count)
        randomOrder.shuffle()
    }
}

struct AnswerCloudView: View {
    var components: [String]
    @Binding var answerArray: [Int]
    @Binding var checked: Bool

    @State private var totalHeight
    //      = CGFloat.zero       // << variant for ScrollView/List
        = CGFloat.infinity   // << variant for VStack

    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
    //    .frame(height: totalHeight)// << variant for ScrollView/List
        .frame(maxHeight: totalHeight) // << variant for VStack
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(0..<components.count, id:\.self) { i in
                item(text: (answerArray.count == components.count && answerArray[i] != -1) ? components[answerArray[i]] : nil, displayIndex: i, answerIndex: answerArray.count == components.count ? answerArray[i] : 0)
                    .padding(.vertical, 4)
                    .padding(.trailing, 8)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width)
                        {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if i == self.components.count-1 {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if i == self.components.count-1 {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }.background(viewHeightReader($totalHeight))
    }

    private func item(text: String?, displayIndex:Int, answerIndex:Int) -> some View {
        Button(action:{
            answerArray[displayIndex] = -1
        }){
            if let text = text {
                let displayText = displayIndex == 0 ? text.capitalizingFirstLetter() : text
                Text(displayText)
                    .font(.custom("Montserrat-Medium", size:13))
                    .foregroundColor(Color("txt"))
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius:8)
                            .stroke(LinearGradient(gradient: !checked ? Gradient(colors:[Color("boxbg")]) : (components[displayIndex] == components[answerIndex] ? gradientColors : incorrectGradientColors), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth:1)
                    )
            } else {
                Text("aaaa")
                    .font(.custom("Montserrat-Medium", size:13))
                    .foregroundColor(Color.clear)
                    .padding(8)
                    .background(Color("boxbg"))
                    .cornerRadius(8)
            }
        }
        .disabled(checked)
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}

struct ChoiceCloudView: View {
    var components: [String]
    @Binding var randomOrder: [Int]
    @Binding var answerArray: [Int]
    @Binding var filled: Bool

    @State private var totalHeight
    //      = CGFloat.zero       // << variant for ScrollView/List
        = CGFloat.infinity   // << variant for VStack

    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
    //    .frame(height: totalHeight)// << variant for ScrollView/List
        .frame(maxHeight: totalHeight) // << variant for VStack
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(randomOrder, id: \.self) { i in
                let tag = components[i]
                item(text: tag, index: i)
                    .padding(.vertical, 4)
                    .padding(.trailing, 8)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width)
                        {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if i == self.randomOrder.last! {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if i == self.randomOrder.last! {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }.background(viewHeightReader($totalHeight))
    }

    private func item(text: String, index:Int) -> some View {
        let used = answerArray.contains(index)
        return Button(action:{
            if(!used){
                if let space = self.answerArray.firstIndex(of: -1){
                    self.answerArray[space] = index
                    if let _ = self.answerArray.firstIndex(of: -1){
                        filled = false
                    } else { filled = true }
                }
            }
        }){
            if(used){
                Text(text)
                    .font(.custom("Montserrat-Medium", size:14))
                    .foregroundColor(Color.clear)
                    .padding()
                    .background(Color("boxbg"))
                    .cornerRadius(8)
            } else {
                Text(text)
                    .font(.custom("Montserrat-Medium", size:14))
                    .foregroundColor(Color("txt"))
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius:8)
                            .stroke(Color("boxbg"), lineWidth:1)
                    )
            }
        }
        .disabled(used)
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}

struct RearrangeView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
