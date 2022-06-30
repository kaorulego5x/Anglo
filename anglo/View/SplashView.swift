//
//  SplashView.swift
//  anglo
//
//  Created by Kaoru Nishihara on 2021/12/14.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack(){
            RadialGradient(gradient: Gradient(colors:[Color("bggrad1"), Color("bggrad2")]), center: .topLeading, startRadius: /*@START_MENU_TOKEN@*/5/*@END_MENU_TOKEN@*/, endRadius: /*@START_MENU_TOKEN@*/500/*@END_MENU_TOKEN@*/)
                .ignoresSafeArea()
            
            Text("G")
                .font(.custom("Montserrat-Bold", size:84))
                .foregroundColor(Color.white)
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
