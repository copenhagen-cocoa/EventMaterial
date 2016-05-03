//
//  WaitressTests.swift
//  TheBodega
//
//  Created by Mikkel Sindberg Eriksen on 26/04/2016.
//  Copyright © 2016 Unwire. All rights reserved.
//

import XCTest

class WaitressTests: XCTestCase {

    let waitressName = "Cindy"
    
    var waitress: Waitress!
    
    override func setUp() {
        super.setUp()
        
        self.waitress = Waitress(name: self.waitressName)
    }
    
    
    // MARK: - Test Initialization and Properties etc.
    
    func testThatItInitializes() {
        XCTAssertNotNil(self.waitress)
    }
    
    func testThatItCanHaveAName() {
        XCTAssertEqual(self.waitress.name, self.waitressName)
    }
    
    
    // MARK: - Test Beer Fetching
    
    func testThatItCanBeBusyWhileFetching() {
    
        keyValueObservingExpectationForObject(self.waitress, keyPath: "busy") { object, changes -> Bool in
            return object.busy
        }
        
        self.waitress.fetchBeerFromStorage(MockBeerStore()) { beer, error in
            // Drink beer!
        }
        
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testThatItCanFetchBeer() {
        
        let fineBeer = Beer()
        let beerStore = MockBeerStore()
        let expectation = expectationWithDescription("Expect beer!")
        
        beerStore.storeBeer(fineBeer)
        
        self.waitress.fetchBeerFromStorage(beerStore) { beer, error in
            XCTAssertEqual(beer, fineBeer)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    
    }

    
    // MARK: - Mocks

    class MockBeerStore: NSObject, BeerStoring {

        var storedBeer: Beer?
    
        func grabBeer() -> Beer! {
            return self.storedBeer
        }
    
        func storeBeer(beer: Beer!) {
            self.storedBeer = beer
        }

    }

}
