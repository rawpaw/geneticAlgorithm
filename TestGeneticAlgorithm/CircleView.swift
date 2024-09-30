//
//  CircleView.swift
//  TestGeneticAlgorithm
//
//  Created by Uncle Danny on 2024/08/23.
//

import SwiftUI

struct CircleView: View {
    @State var diameter : CGFloat
    @State var color : Color
    @State var position : CGPoint
    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: diameter)
            Circle()
                .stroke(lineWidth: 1.0)
                .frame(width: diameter)
            Text("\(Int(diameter))")
        }
        .position(position)
    }
}

#Preview {
    CircleView(diameter: 30, color: .yellow, position: CGPointMake(0, 0))
}
