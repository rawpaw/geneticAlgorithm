//
//  Evolution.swift
//  TestGeneticAlgorithm
//
//  Created by Uncle Danny on 2024/09/28.
//

import Foundation

struct Evolution {
    static func performCrossOver(genomeA: String, genomeB: String) -> String {
        let length = genomeA.count
        let randomIndex = genomeA.index(genomeA.startIndex, offsetBy: Int.random(in: 1..<length-1))
        
        let partA = genomeA[..<randomIndex]
        let partB = genomeB[randomIndex...]
        return "\(partA)\(partB)"
    }
    
    static func performMutation(genome: String) -> String {
        let randomIndex = genome.index(genome.startIndex, offsetBy: Int.random(in: 0..<genome.count-1))
        var bit = genome[randomIndex]
        if bit == "1" {
            bit = "0"
        } else {
            bit = "1"
        }
        return genome.replacingCharacters(in: randomIndex...randomIndex, with: "\(bit)")
    }
}
