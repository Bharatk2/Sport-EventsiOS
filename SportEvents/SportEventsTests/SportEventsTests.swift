//
//  SportEventsTests.swift
//  SportEventsTests
//
//  Created by Bharat Kumar on 2/9/21.
//

import XCTest
@testable import SportEvents
class SportEventsTests: XCTestCase {

    let timeout: TimeInterval = 5
  
    func testFetchAllEvents() throws {
        let expectation = self.expectation(description: "fetch is succesfull")
        
        EventController.shared.getEvents { events, error in
            XCTAssertNil(error)
            XCTAssertNotNil(events)
            print("these are succefull events : \(events)")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeout)
    }
    
    func testDecoding() throws {
        let url = URL(string: "https://api.seatgeek.com/2/events")!
        let expectation = self.expectation(description: "Data decodes from the backend")
        URLSession.shared.dataTask(with: url) { data, response, error in
          XCTAssertNil(error)
          do {
            let response = try XCTUnwrap(response as? HTTPURLResponse)
            XCTAssertEqual(response.statusCode, 200)

            let data = try XCTUnwrap(data)
           
            XCTAssertNoThrow(
                try JSONDecoder().decode([EventResults.Events].self, from: data)
              
            )
           
          }
          catch { }
        }
        .resume()
        expectation.fulfill()
        waitForExpectations(timeout: timeout)
    }
    
    
    

}
