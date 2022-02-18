//
//  ContentView.swift
//  anglo
//
//  Created by Kaoru Nishihara on 2021/11/27.
//

import SwiftUI

let gradientColors = Gradient(colors:[Color("maingrad1"), Color("maingrad2")])
enum Tab {
    case home, phrase, interpret, rearrange, loading
}

struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State var tab: Tab = .home
    
    var body: some View{
        ZStack(){
            if(tab == .home){
                HomeView(tab: $tab)
            }
            if(tab == .phrase){
                PhraseView(tab: $tab)
            } else if(tab == .interpret){
                InterpretView(tab: $tab)
            } else if(tab == .rearrange) {
                RearrangeView(tab: $tab)
            } else if(tab == .loading) {
                LoadingView(tab: $tab)
            }
        }
        .onAppear(){
            appViewModel.handleLaunch()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
