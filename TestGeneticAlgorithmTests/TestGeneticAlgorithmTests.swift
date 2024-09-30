//
//  TestGeneticAlgorithmTests.swift
//  TestGeneticAlgorithmTests
//
//  Created by Uncle Danny on 2024/09/28.
//

import XCTest
@testable import TestGeneticAlgorithm

final class TestGeneticAlgorithmTests: XCTestCase {

    var simulation : GASimulation?
    
    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testCircleWithinBounds() async {
        let expectation = expectation(description: "simlation created")
        
        Task {
            simulation = GASimulation.sharedInstance
            let chromosome = Chromosome(x: 20, y: 20, diameter: 50, chunkSize: 8)
            XCTAssert(CirclesPopulation.isWithinBounds(entity: chromosome, maxX: 100, maxY: 100) == false)
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    func testChromosomeCreation() async {
        let expectation = expectation(description: "simlation created")
        
        Task {
            simulation = GASimulation.sharedInstance
            let chromosomeA = Chromosome(x: 224, y: 113, diameter: 69, chunkSize: 8)
            XCTAssert(chromosomeA.genome == "111000000111000101000101")
            let genome = "010001100000111011010001101"
            let chromosomeB = Chromosome.makeChromosome(fromGenome: genome, chunkSize: genome.count/3)
            XCTAssertNotNil(chromosomeB)
            XCTAssert(chromosomeB?.x == 140)
            XCTAssert(chromosomeB?.y == 59)
            XCTAssert(chromosomeB?.diameter == 141)
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    func testCircleOverlaps() async {
        let expectation = expectation(description: "simlation created")
        
        Task {
            simulation = GASimulation.sharedInstance
            let chromosomeA = Chromosome(x: 224, y: 113, diameter: 69, chunkSize: 8)
            let deadzone = DeadZoneArea(id: UUID().uuidString, x: 241, y: 188, diameter: 99)
            let chromosomeB = Chromosome(x: 100, y: 30, diameter: 10, chunkSize: 8)
            XCTAssert(CirclesPopulation.touchesDeadZone(entity: chromosomeA, deadzones: [deadzone]) == true)
            XCTAssert(CirclesPopulation.touchesDeadZone(entity: chromosomeB, deadzones: [deadzone]) == false)
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    func testCrossOver() async {
        let expectation = expectation(description: "simlation created")
        
        Task {
            simulation = GASimulation.sharedInstance
            let genomeA = "1011010100011011000111010"
            let genomeB = "00001111"
            let crossOver = Evolution.performCrossOver(genomeA: genomeA, genomeB: genomeB)
            XCTAssert(crossOver.count == 8)
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    func testMutation() async {
        let expectation = expectation(description: "simlation created")
        
        Task {
            simulation = GASimulation.sharedInstance
            let genomeA = "1011010100011011000111010"
            let mutation = Evolution.performMutation(genome: genomeA)
            XCTAssert(mutation.count == genomeA.count)
            XCTAssert(genomeA != mutation)
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 5.0)
    }
}
