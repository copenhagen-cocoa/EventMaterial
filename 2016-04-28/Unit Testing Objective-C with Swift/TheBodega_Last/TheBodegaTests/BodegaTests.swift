//
//  BodegaTests.swift
//  TheBodega
//
//  Created by Mikkel Sindberg Eriksen on 26/04/2016.
//  Copyright © 2016 Unwire. All rights reserved.
//

import XCTest

class BodegaTests: XCTestCase {
 
    let bodegaName = "Steve's Den"
    let mockWaitress = MockWaitress()
    let mockStorage = MockBeerStorage()
    
    var bodega: Bodega!
    
    override func setUp() {
        super.setUp()
        
        self.bodega = Bodega(name: self.bodegaName,
                      beerStorage: self.mockStorage,
                         waitress: self.mockWaitress)
    }
    
    
    // MARK: - Test Properties etc.
    
    func testThatItHasABodegaErrorDomain() {
        XCTAssertEqual(BodegaErrorDomain, "Bodega panic!")
    }
    
    func testThatItCanHaveAName() {
        XCTAssertEqual(self.bodegaName, self.bodega.name)
    }
    
    func testThatItCanHaveAWaitress() {
        XCTAssertTrue(self.mockWaitress === self.bodega.waitress)
    }
    
    func testThatItCanHaveABeerStorage() {
        XCTAssertTrue(self.mockStorage === self.bodega.beerStorage)
    }
    
    
    // MARK: - Test Ordering Beer
    
    func testThatOrderingBeerFailsIfWaitressIsBusy() {
    
        let expectation = expectationWithDescription("Expect staff busy error")
        self.mockWaitress.busy = true
        
        self.bodega.orderBeerWithCompletion { beer, error in
            
            if let orderError = error {
                XCTAssertEqual(orderError.code, BodegaErrorCode.StaffBusy.rawValue)
                expectation.fulfill()
            }
            
        }
        
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testThatOrderingBeerSucceedsIfWaitressIsNotBusy() {
    
        let expectation = expectationWithDescription("Expect beer!")
        self.mockWaitress.busy = false
        
        self.bodega.orderBeerWithCompletion { beer, error in
            XCTAssertNotNil(beer)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    
    // MARK: - Mocks

    class MockWaitress: NSObject, BeerFetching{
        
        var busy = false
        
        func fetchBeerFromStorage(beerStorage: BeerStoring!, complete: ((Beer!, NSError!) -> Void)!) {
            
            if (complete != nil) {
                complete(Beer(), nil)
            }
            
        }
    }

    class MockBeerStorage: NSObject, BeerStoring{

        func grabBeer() -> Beer! {
            return Beer()
        }
        
        func storeBeer(beer: Beer!) {}
    }


}
