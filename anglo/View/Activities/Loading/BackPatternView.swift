//
//  BackPatternView.swift
//  anglo
//
//  Created by Kaoru Nishihara on 2021/11/29.
//

import SwiftUI
import PolyKit

struct BackPatternView: View {
    var body: some View {
        GeometryReader { geometry in
            let horizontalNum = Int(geometry.size.width/120)+2
            let horizontalMargin = (geometry.size.width - CGFloat(120 * (horizontalNum-2)))/2.0
            let verticalNum = Int(geometry.size.height/120)+2
            let verticalMargin = (geometry.size.height - CGFloat(120 * (verticalNum-2)))/2.0
            
            ForEach(0..<verticalNum){ vTempIndex in
                ForEach(0..<horizontalNum){ hTempIndex in
                    let vIndex = vTempIndex - 1
                    let hIndex = hTempIndex - 1
                    let randomHDouble = Double.random(in: 0...80) - 40
                    let randomVDouble = Double.random(in: 0...80) - 40
                    let randomInt = Int.random(in: 0...2)
                    let xPosition = CGFloat(hIndex*120) + horizontalMargin+60 + CGFloat(randomHDouble)
                    let yPosition = CGFloat(vIndex*120) + verticalMargin+60 + CGFloat(randomVDouble)
                    let iconOpacity = Double(yPosition / geometry.size.height * 0.4)
                    let color = Color.white.opacity(iconOpacity)
                    HStack(){
                        if(randomInt == 0){
                            Poly(count: 3, cornerRadius:4)
                                .stroke(lineWidth: 2)
                                .foregroundColor(color)
                                .frame(width:24, height:24)
                                
                        } else if(randomInt == 1){
                            RoundedRectangle(cornerRadius: 4)
                                .strokeBorder(color, lineWidth: 2)
                                .frame(width:16, height:16)
                        } else {
                            Circle()
                                .strokeBorder(color, lineWidth: 2)
                                .frame(width:16, height:16)
                        }
                    }
                    .position(x:xPosition, y:yPosition)
                    
                }
            }
        }
    }
}

struct BackPatternView_Previews: PreviewProvider {
    static var previews: some View {
        BackPatternView()
    }
}
