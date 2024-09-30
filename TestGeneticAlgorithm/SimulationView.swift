//
//  InitialConditionView.swift
//  TestGeneticAlgorithm
//
//  Created by Uncle Danny on 2024/08/23.
//

import SwiftUI

struct SimulationView: View {
    @State var numberOfCircles : String = "50"
    @State var populationSize : String = "1000"
    @State var randomPopulationSize : String = "700"
    @State var childPopulationSize : String = "300"
    @State var numberOfGenerations : String = "1000"
    @ObservedObject var simulation : GASimulation
    private let minDiameter : Int = 5
    @State var deadzones : [DeadZoneArea] = []
    @FocusState var keyboardVisible : Bool
    @State var newGenerationSplit : Float = 0.5
    @State var championOnFile : Chromosome? = nil
    @State var timeToReachChampion : TimeInterval = 0
    @State var isLoadingFromFile : Bool = false
    var body: some View {
        VStack {
            HStack {
                Text("Number of deadzones:")
                TextField(text: $numberOfCircles) {
                    Text("Enter the number of deadzones")
                        .multilineTextAlignment(.center)
                }
                .keyboardType(.numberPad)
                .focused($keyboardVisible)
            }
            HStack {
                Text("Number of generations:")
                TextField(text: $numberOfGenerations) {
                    Text("Enter the number of generations to run")
                        .multilineTextAlignment(.center)
                }
                .keyboardType(.numberPad)
                .focused($keyboardVisible)
            }
            HStack {
                Text("Population size:")
                TextField(text: $populationSize) {
                    Text("Enter the population size")
                        .multilineTextAlignment(.center)
                }
                .keyboardType(.numberPad)
                .focused($keyboardVisible)
            }
            Slider(value: $newGenerationSplit, in: 0...100)
                .onChange(of: newGenerationSplit) { oldValue, newValue in
                    if let popSize = Int(populationSize) {
                        let randPopSize = Int(Float(popSize) * Float(newGenerationSplit/100))
                        randomPopulationSize = String(randPopSize)
                        childPopulationSize = String(popSize - randPopSize)
                        print(childPopulationSize)
                    }
                }
            Text("Random generated population \(Int(newGenerationSplit))%")
            GeometryReader(content: { geometry in
                VStack {
                    ZStack {
                        ForEach(deadzones, id: \.self) { deadzone in
                            CircleView(diameter: CGFloat(deadzone.diameter), color: .gray, position: CGPoint(x: deadzone.x, y: deadzone.y))
                        }
                        if (!numberOfCircles.isEmpty && !populationSize.isEmpty && !randomPopulationSize.isEmpty && !numberOfGenerations.isEmpty && !childPopulationSize.isEmpty) {
                            VStack {
                                Button {
                                    keyboardVisible = false
                                    if let randPopSize = Int(randomPopulationSize), let childPopSize = Int(childPopulationSize), let numberOfGenerations = Int(numberOfGenerations) {
                                        let maxDiameter = Float(geometry.size.width)
                                        if (isLoadingFromFile == false) {
                                            let chunkSize = String(Int(maxDiameter), radix: 2).count
                                            self.addDeadZones(geometry: geometry, chunkSize: chunkSize)
                                        } else {
                                            self.deadzones = self.fetchDeadZonesFromFile()
                                            self.fetchChampionFromFile()
                                        }

                                        Task {
                                            await self.simulation.run(maxX: Float(geometry.size.width), maxY: Float(geometry.size.width), maxDiameter: maxDiameter, populationSize: 100, deadzones: self.deadzones, randomPopulationSize: randPopSize, childPopulationSize: childPopSize, numberOfGenerations: numberOfGenerations, lastChampion: self.championOnFile)
                                        }
                                    }
                                } label: {
                                    Text("Begin simulation")
                                }
                                Text("Generation: \(simulation.currentGeneration)")
                            }
                        }
                        if let currentSolution = simulation.currentSolution {
                            CircleView(diameter: CGFloat(currentSolution.diameter), color: .cyan, position: CGPoint(x: CGFloat(currentSolution.x), y: CGFloat(currentSolution.y)))
                                .opacity(0.5)
                                .id(currentSolution.genome)
                        }
                        if let champion = simulation.champion {
                            CircleView(diameter: CGFloat(champion.diameter), color: .yellow, position: CGPoint(x: CGFloat(champion.x), y: CGFloat(champion.y)))
                                .id(champion.genome)
                        }
                        if (isLoadingFromFile) {
                            if let championOnFile = championOnFile {
                                CircleView(diameter: CGFloat(championOnFile.diameter), color: .orange, position: CGPoint(x: CGFloat(championOnFile.x), y: CGFloat(championOnFile.y)))
                                    .opacity(0.5)
                            }
                        }
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.width)
                .border(Color.black)
            })
            Text("Time to reach best solution = \(simulation.timeToReachChampion) seconds")
            Button {
                self.isLoadingFromFile.toggle()
            } label: {
                Text("Load from file")
                    .foregroundStyle(.white)
                    .padding()
                    .fontWeight(isLoadingFromFile ? .bold : .regular)
            }
            .background(.green)
            .clipShape(Capsule())
            Button {
                self.writeDeadZonesToFile(zones: self.deadzones)
            } label: {
                Text("Save deadzones")
                    .foregroundStyle(.white)
                    .padding()
            }
            .background(.green)
            .clipShape(Capsule())
            Button {
                self.writeSolutionToFile()
            } label: {
                Text("Save champion")
                    .foregroundStyle(.white)
                    .padding()
            }
            .background(.blue)
            .clipShape(Capsule())
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button(action: {
                        keyboardVisible = false
                    }, label: {
                        Text("Done")
                    })
                }
            }
        }
    }
    
    private func addDeadZones(geometry: GeometryProxy, chunkSize: Int) {
        var zones : [DeadZoneArea] = []
        if let numberOfDeadzones = Int(numberOfCircles) {
            while zones.count < numberOfDeadzones {
                let deadzone = DeadZoneArea.randomDeadZone(maxX: Int(geometry.size.width), maxY: Int(geometry.size.width), maxDiameter: Int(geometry.size.width))
                let chromosome = Chromosome(x: deadzone.x, y: deadzone.y, diameter: deadzone.diameter, chunkSize: chunkSize)
                let boundsMaxX = Float(geometry.size.width-CGFloat(chromosome.diameter/2))
                let boundsMaxY = boundsMaxX 
                let isWithinBounds = CirclesPopulation.isWithinBounds(entity: chromosome, maxX: boundsMaxX, maxY: boundsMaxY)
                let doesIntersectAnotherZone = CirclesPopulation.touchesDeadZone(entity: chromosome, deadzones: zones)
                if (zones.isEmpty) {
                    if (isWithinBounds) {
                        zones.append(deadzone)
                    }
                } else if (isWithinBounds && !doesIntersectAnotherZone) {
                    zones.append(deadzone)
                }
                
            }
            deadzones = zones
        }
    }
    
    private func fetchDeadZonesFromFile() -> [DeadZoneArea] {
        if let url = Bundle.main.url(forResource: "deadzones", withExtension: "dat") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let deadzones = try decoder.decode([DeadZoneArea].self, from: data)
                return deadzones
            } catch {
                print(error)
                return []
            }
        }
        return []
    }
    
    private func addDeadZone(geometry: GeometryProxy, chunkSize: Int) {
        let deadzone = DeadZoneArea.randomDeadZone(maxX: Int(geometry.size.width), maxY: Int(geometry.size.height), maxDiameter: min(Int(geometry.size.width), Int(geometry.size.height)))
        let chromosome = Chromosome(x: deadzone.x, y: deadzone.y, diameter: deadzone.diameter, chunkSize: chunkSize)
        let boundsMaxX = Float(geometry.size.width-CGFloat(chromosome.diameter/2))
        let boundsMaxY = Float(geometry.size.height-CGFloat(chromosome.diameter/2))
        let isWithinBounds = CirclesPopulation.isWithinBounds(entity: chromosome, maxX: boundsMaxX, maxY: boundsMaxY)
        let doesIntersectAnotherZone = CirclesPopulation.touchesDeadZone(entity: chromosome, deadzones: self.deadzones)
        if (self.deadzones.isEmpty) {
            if (isWithinBounds) {
                self.deadzones.append(deadzone)
            }
        } else if (isWithinBounds && !doesIntersectAnotherZone) {
            self.deadzones.append(deadzone)
        }
    }
    
    private func writeDeadZonesToFile(zones: [DeadZoneArea]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(zones)
            if let url = Bundle.main.url(forResource: "deadzones", withExtension: "dat") {
                try data.write(to: url, options: [.atomic])
            }
        } catch {
            print(error)
        }
    }
    
    private func writeSolutionToFile() {
        if let champion = simulation.champion {
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(champion)
                if let url = Bundle.main.url(forResource: "champion", withExtension: "dat") {
                    try data.write(to: url, options: [.atomic])
                }
            } catch {
                print(error)
            }
        }
    }
    
    private func fetchChampionFromFile() {
        do {
            if let url = Bundle.main.url(forResource: "champion", withExtension: "dat") {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let champion = try decoder.decode(Chromosome.self, from: data)
                self.championOnFile = champion
            }
        } catch {
            print(error)
        }
    }
}

struct SimulationViewPreviewProvider: PreviewProvider {
    @State static var sim : GASimulation = GASimulation.sharedInstance
    static var previews: some View {
        SimulationView(simulation: sim)
    }
}
