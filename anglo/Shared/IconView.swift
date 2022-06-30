//
//  IconView.swift
//  anglo
//
//  Created by Kaoru Nishihara on 2022/02/19.
//

import SwiftUI

struct Icon: View {
    var name: String
    var size: CGFloat
        
    init(_ name: String, size:CGFloat){
        self.name = name
        self.size = size
    }
        
    var body: some View {
        Image(name)
            .resizable()
            .renderingMode(.template)
            .aspectRatio(contentMode: .fit)
            .frame(width:size, height:size)
    }
}

struct Icon_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
