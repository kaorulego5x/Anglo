//
//  LoadingView.swift
//  anglo
//
//  Created by Kaoru Nishihara on 2021/11/29.
//

import SwiftUI
import PolyKit

struct LoadingView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State var rotateDegree:Double = -270
    @State var baseOpacity: Double = 0
    
    private let gradient = AngularGradient(
        gradient: Gradient(colors: [Color.white.opacity(0), Color.white.opacity(0), Color.white.opacity(0), Color.white.opacity(0), Color.white.opacity(0), .white]),
        center: .center)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(){
                RadialGradient(gradient: Gradient(colors:[Color("bggrad1"), Color("bggrad2")]), center: .topLeading, startRadius: /*@START_MENU_TOKEN@*/5/*@END_MENU_TOKEN@*/, endRadius: /*@START_MENU_TOKEN@*/500/*@END_MENU_TOKEN@*/)
                    .ignoresSafeArea()
                
                BackPatternView()
                    .opacity(baseOpacity)
                    
                Text("Loading...")
                    .font(.custom("Montserrat-Medium", size:28))
                    .foregroundColor(Color.white)
                    
                Circle()
                    .stroke(gradient, style: StrokeStyle(lineWidth: 1, lineCap: .round))
                    .frame(width:geometry.size.width, height:geometry.size.width)
                    .scaleEffect(geometry.size.height / geometry.size.width)
                    .rotationEffect(Angle(degrees: rotateDegree))
                    .offset(y:geometry.size.height/2+30)
                    
                }
            .onAppear(){
                withAnimation(.linear(duration:3)){
                    rotateDegree = 720-270
                }
                DispatchQueue.main.asyncAfter(deadline: .now()+3){
                    withAnimation(.easeOut(duration:0.2)){
                        if(appViewModel.type == .single) {appViewModel.tab = .interpret}
                        else { appViewModel.tab = .phrase }
                    }
                }
            }
            .onAppear(){
                DispatchQueue.main.asyncAfter(deadline:.now()+0.3){
                    withAnimation(.easeOut(duration:0.3)){
                        baseOpacity = 1
                    }
                    DispatchQueue.main.asyncAfter(deadline:.now()+0.5){
                        withAnimation(.easeOut(duration:0.3)){
                            baseOpacity = 0
                        }
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline:.now()+1.8){
                    withAnimation(.easeOut(duration:0.3)){
                        baseOpacity = 1
                    }
                    DispatchQueue.main.asyncAfter(deadline:.now()+0.5){
                        withAnimation(.easeOut(duration:0.3)){
                            baseOpacity = 0
                        }
                    }
                }
                
                /*DispatchQueue.main.asyncAfter(deadline:.now()+1){
                    withAnimation(.easeOut(duration:1)){
                        baseOpacity = 0
                    }
                }
                DispatchQueue.main.asyncAfter(deadline:.now()+2){
                    withAnimation(.easeOut(duration:1)){
                        baseOpacity = 1
                    }
                 }*/
            }
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
