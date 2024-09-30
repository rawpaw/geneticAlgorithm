//
//  GASimulation.swift
//  TestGeneticAlgorithm
//
//  Created by Uncle Danny on 2024/09/28.
//

import Foundation

class GASimulation : ObservableObject {
    static let sharedInstance = GASimulation()
    @Published var champion : Chromosome? = nil
    @Published var currentSolution : Chromosome? = nil
    let workerQueue : OperationQueue
    @Published var currentGeneration : Int = 0
    @Published var isRunning : Bool = false
    var chunkSize : Int?
    var startTime : Date? = nil
    @Published var timeToReachChampion : TimeInterval = 0
    var lastChampionOnFile : Chromosome? = nil
    
    private init() {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        self.workerQueue = queue
    }
    
    func run(maxX: Float, maxY: Float, maxDiameter: Float, populationSize: Int, deadzones: [DeadZoneArea], randomPopulationSize: Int, childPopulationSize: Int, numberOfGenerations: Int, lastChampion: Chromosome?) async {
        let chunkSize = String(Int(maxDiameter), radix: 2)
        let startTime = Date()
        await MainActor.run { [weak self] in
            self?.timeToReachChampion = 0
            self?.chunkSize = chunkSize.count
            self?.currentSolution = nil
            self?.currentGeneration = 0
            self?.champion = nil
            self?.isRunning = true
            self?.startTime = startTime
        }
        
        
        Task.detached { [weak self] in
            if let strongSelf = self {
                var endTime : Date? = nil
                var timeInterval : TimeInterval? = nil
                var generation : Population = CirclesPopulation(generation: Chromosome.generateRandomPopulation(maxX: Int(maxX), maxY: Int(maxY), maxDiameter: Int(maxDiameter), size: populationSize, chunkSize: chunkSize.count), deadzones: deadzones, maxX: maxX, maxY: maxY, maxDiameter: maxDiameter, chunkSize: chunkSize.count)
                var results : (champion:Chromosome?,currentSolution:Chromosome?)? = nil
                for i in 0..<numberOfGenerations {

                    results = generation.evalutePopulation(currentChampion: strongSelf.champion)
                    if let results = results, 
                        let champion = results.champion,
                        let newSolution = results.currentSolution {
                        if let lastChampion = lastChampion {
                            if champion.diameter >= lastChampion.diameter {
                                if (endTime == nil) {
                                    let end = Date()
                                    endTime = end
                                    timeInterval = end.timeIntervalSince(startTime)
                                    print("Found new best in \(timeInterval!) seconds")
                                }
                            }
                        }
                        //Evolve population
                        let newPopulation = generation.generateNewPopulation(fromParents: champion, entityB: newSolution, randomPopulationSize: randomPopulationSize, childPopulationSize: childPopulationSize)
                        generation = newPopulation
                        await MainActor.run {
                            strongSelf.champion = results.champion
                            strongSelf.currentSolution = newSolution
                            strongSelf.currentGeneration = i
                            strongSelf.isRunning = false
                        }
                    }
//                    do {
//                        try await Task.sleep(nanoseconds: 100000000)
//                    } catch {
//                        print(error)
//                    }
                }
                Task { [endTime, timeInterval] in
                    await MainActor.run { [endTime] in
                        strongSelf.currentSolution = nil
                        
                        if let _ = endTime, let timeInterval = timeInterval {
                            //New champion to write to file
//                            if let champion = strongSelf.champion {
//                                strongSelf.writeSolutionToFile()
//                            }
                            strongSelf.timeToReachChampion = timeInterval
                        }
                    }
                }
                print("Evolved \(numberOfGenerations) generations")
            }
        }
    }
}

protocol Population {
    func evalutePopulation(currentChampion: Chromosome?) -> (champion: Chromosome?, currentSolution: Chromosome?)
    var size : Int { get }
    func generateNewPopulation(fromParents entityA: Chromosome, entityB: Chromosome, randomPopulationSize: Int, childPopulationSize: Int) -> Population
}

class CirclesPopulation : Population {
    var generation : [Chromosome]
    let deadzones : [DeadZoneArea]
    let maxX : Float
    let maxY : Float
    let maxDiameter : Float
    var size: Int
    let chunkSize : Int
    
    init(generation: [Chromosome], deadzones: [DeadZoneArea], maxX: Float, maxY: Float, maxDiameter: Float, chunkSize: Int) {
        self.generation = generation
        self.deadzones = deadzones
        self.maxX = maxX
        self.maxY = maxY
        self.maxDiameter = maxDiameter
        self.size = generation.count
        self.chunkSize = chunkSize
    }
    
    func evalutePopulation(currentChampion: Chromosome?) -> (champion: Chromosome?, currentSolution: Chromosome?) {
        if (!generation.isEmpty) {
            var champion = currentChampion
            var currentSolution : Chromosome? = nil
            var maxDiameter : Float = 0
            for entity in generation {
                let fitness = self.calculateFitness(entity: entity)
                //Check if next best solution
                if (fitness > maxDiameter) {
                    maxDiameter = fitness
                    currentSolution = entity
                    //Check if new champion
                    if let currentChampion = currentChampion {
                        if (fitness > Float(currentChampion.diameter)) {
                            champion = entity
                        }
                    } else {
                        champion = entity
                    }
                }
            }
            return (champion, currentSolution)
        }
        return (nil,nil)
    }
    
    static func touchesDeadZone(entity: Chromosome, deadzones: [DeadZoneArea]) -> Bool {
        for deadzone in deadzones {
            let xDiffs = abs(entity.x - deadzone.x)
            let yDiffs = abs(entity.y - deadzone.y)
            
            let distanceBetweenPoints = sqrtf(pow(Float(xDiffs), 2) + pow(Float(yDiffs), 2))
            let r1 = Float(entity.diameter/2)
            let r2 = Float(deadzone.diameter/2)
            let sumOfRadii = r1 + r2
            
            
            if (distanceBetweenPoints < sumOfRadii)
            {
                return true
            }
        }
        return false
    }
    
    static func isWithinBounds(entity: Chromosome, maxX: Float, maxY: Float) -> Bool {
        let radius = Float(entity.diameter/2)
        let x = Float(entity.x)
        let y = Float(entity.y)
        if ((x < maxX - radius) && (x > radius) && (y < maxY - radius) && (y > radius))
        {
            return true;
        }
        return false;
    }
    
    func calculateFitness(entity: Chromosome) -> Float {
        if (CirclesPopulation.touchesDeadZone(entity: entity, deadzones: self.deadzones) || !CirclesPopulation.isWithinBounds(entity: entity, maxX: self.maxX, maxY: self.maxY)) {
            return 0
        }
        return Float(entity.diameter)
    }
    
    func generateNewPopulation(fromParents entityA: Chromosome, entityB: Chromosome, randomPopulationSize: Int, childPopulationSize: Int) -> any Population {
        let probCrossOver = Float.random(in: 0...1)
        let probMutation = Float.random(in: 0...1)
        let probParentA = Float.random(in: 0...1)
        let probParentB = Float.random(in: 0...1)
        var childGenome : String
        var newPopulation : [Chromosome] = []
        while newPopulation.count < childPopulationSize {
            if (probCrossOver > probMutation)
            {
                if (probParentA > probParentB)
                {
                    childGenome = Evolution.performCrossOver(genomeA: entityA.genome, genomeB: entityB.genome)
                }
                else {
                    childGenome = Evolution.performCrossOver(genomeA: entityB.genome, genomeB: entityA.genome)
                }
            }
            else
            {
                if (probParentA > probParentB)
                {
                    childGenome = Evolution.performMutation(genome: entityA.genome)
                }
                else
                {
                    childGenome = Evolution.performMutation(genome: entityB.genome)
                }
            }
            if let child = Chromosome.makeChromosome(fromGenome: childGenome, chunkSize: chunkSize) {
                newPopulation.append(child)
            }
        }
        //Insert random population
        while newPopulation.count < childPopulationSize + randomPopulationSize {
            let randomEntity = Chromosome.generateRandomEntity(maxX: Int(maxX), maxY: Int(maxY), maxDiameter: Int(maxDiameter), chunkSize: chunkSize)
            if (CirclesPopulation.isWithinBounds(entity: randomEntity, maxX: maxX, maxY: maxY)) {
                newPopulation.append(randomEntity)
            }
        }
        return CirclesPopulation(generation: newPopulation, deadzones: deadzones, maxX: maxX, maxY: maxY, maxDiameter: maxDiameter, chunkSize: chunkSize)
    }
    
    
}

