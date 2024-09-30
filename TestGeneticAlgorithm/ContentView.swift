//
//  ContentView.swift
//  TestGeneticAlgorithm
//
//  Created by Uncle Danny on 2024/08/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        SimulationView(simulation: GASimulation.sharedInstance)
    }
}

#Preview {
    ContentView()
}
