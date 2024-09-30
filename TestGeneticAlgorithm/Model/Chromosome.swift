//
//  Chromosome.swift
//  TestGeneticAlgorithm
//
//  Created by Uncle Danny on 2024/09/28.
//

import Foundation

/*
  The solution 
 */

struct Chromosome : Codable {
    let x : Int
    let y : Int
    let diameter : Int
    let genome : String
    let chunkSize : Int
    
    init(x: Int, y: Int, diameter: Int, chunkSize: Int) {
        self.x = x
        self.y = y
        self.diameter = diameter
        self.chunkSize = chunkSize
        self.genome = Chromosome.buildGenome(x: x, y: y, diameter: diameter, chunkSize: chunkSize)
    }
    
    static func makeChromosome(fromGenome genome: String, chunkSize: Int) -> Chromosome? {
        let parts = genome.components(withMaxLength: chunkSize)
        if (parts.count == 3) {
            let xPart = parts[0]
            let yPart = parts[1]
            let diameterPart = parts[2]
            if let x = Chromosome.binaryToInt(binary: xPart), let y = Chromosome.binaryToInt(binary: yPart), let diameter = Chromosome.binaryToInt(binary: diameterPart) {
                return Chromosome(x: x, y: y, diameter: diameter, chunkSize: genome.count/3)
            }
        }
        return nil
    }
    
    static func buildGenome(x: Int, y: Int, diameter: Int, chunkSize: Int) -> String {
        var xBin = String(x, radix: 2)
        while xBin.count < chunkSize {
            xBin = "0\(xBin)"
        }
        var yBin = String(y, radix: 2)
        while yBin.count < chunkSize {
            yBin = "0\(yBin)"
        }
        var dBin = String(diameter, radix: 2)
        while dBin.count < chunkSize {
            dBin = "0\(dBin)"
        }
        let genome = "\(xBin)\(yBin)\(dBin)"
        if (genome.count > chunkSize*3) {
            print("wtf")
        }
        return genome
    }
    
    static func binaryToInt(binary:String) -> Int? {
        return Int(binary, radix: 2)
    }
    
    static func generateRandomEntity(maxX:Int, maxY: Int, maxDiameter: Int, chunkSize: Int) -> Chromosome {
        let randomDiameter = Int.random(in: 0..<maxDiameter)
        let randX = Int.random(in: 0..<maxX)
        let randY = Int.random(in: 0..<maxY)
        let entity = Chromosome(x: randX, y: randY, diameter: randomDiameter, chunkSize: chunkSize)
        return entity
    }
    
    static func generateRandomPopulation(maxX: Int, maxY: Int, maxDiameter: Int, size: Int, chunkSize: Int) -> [Chromosome] {
        var population : [Chromosome] = []
        while population.count < size {
            let entity = Chromosome.generateRandomEntity(maxX: maxX, maxY: maxY, maxDiameter: maxDiameter, chunkSize: chunkSize)
            population.append(entity)
        }
        return population
    }
}

extension String {
    func components(withMaxLength length: Int) -> [String] {
        return stride(from: 0, to: self.count, by: length).map {
            let start = self.index(self.startIndex, offsetBy: $0)
            let end = self.index(start, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            return String(self[start..<end])
        }
    }
}
