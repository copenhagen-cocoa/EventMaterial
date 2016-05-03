//
//  BeerTests.swift
//  TheBodega
//
//  Created by Mikkel Sindberg Eriksen on 27/04/2016.
//  Copyright © 2016 Unwire. All rights reserved.
//

import XCTest

class BeerTests: XCTestCase {

    let beerName = "Bitches Brew"
    let percentage = 7.5
    let centiliters = 50
    
    var beer: Beer!

    override func setUp() {
        super.setUp()
        
        self.beer = Beer(name: self.beerName,
            alcoholPercentage: self.percentage,
                  centiliters: self.centiliters)
    }
    
    
    // MARK: - Test Properties etc.
    
    func testThatItInitializes() {
        XCTAssertNotNil(self.beer)
    }
    
    func testThatItCanHaveAName() {
        XCTAssertEqual(self.beerName, self.beer.name)
    }
    
    func testThatItCanHaveAnAlcoholPercentage() {
        XCTAssertEqual(self.percentage, self.beer.percentage)
    }
    
    func testThatItCanHaveCentiliters() {
        XCTAssertEqual(self.centiliters, self.beer.centiliters)
    }

}
