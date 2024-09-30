//
//  DeadZoneArea.swift
//  TestGeneticAlgorithm
//
//  Created by Uncle Danny on 2024/09/29.
//

import Foundation

struct DeadZoneArea : Identifiable, Hashable, Codable {
    let id : String
    let x : Int
    let y : Int
    let diameter : Int
    static let minDiameter : Int = 5
    
    static func randomDeadZone(maxX: Int, maxY: Int, maxDiameter: Int) -> DeadZoneArea {
        let diameter = Int.random(in: DeadZoneArea.minDiameter..<maxDiameter)
        let x = Int.random(in: 0..<maxX-diameter)
        let y = Int.random(in: 0..<maxY-diameter)
        return DeadZoneArea(id: UUID().uuidString, x: x, y: y, diameter: diameter)
    }
    
    static func generateRandomDeadZones(size: Int, maxX: Int, maxY: Int, maxDiameter: Int) -> [DeadZoneArea] {
        var deadzones : [DeadZoneArea] = []
        while deadzones.count < size {
            deadzones.append(DeadZoneArea.randomDeadZone(maxX: maxX, maxY: maxY, maxDiameter: maxDiameter))
        }
        return deadzones
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
