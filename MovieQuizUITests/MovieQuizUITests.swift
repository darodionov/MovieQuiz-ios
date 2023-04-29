//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Dmitry Rodionov on 25.04.2023.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!
    var buttons: [XCUIElement]?
    
    func pushButtons() {
        for _ in 1...10 {
            sleep(3)
            let button = buttons?.randomElement()
            button?.tap()
        }
    }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        app = XCUIApplication()
        app.launch()
        buttons = [app.buttons["Yes"], app.buttons["No"]]
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app.terminate()
        app = nil
    }
    
    //    func testScreenCast() throws {
    //        app.buttons["Нет"].tap()
    //
    //    }
    
    func testYesButton() throws {
        sleep(3)
        let beginPoster = app.images["Poster"]
        let beginPosterData = beginPoster.screenshot().pngRepresentation
        let yesButton = app.buttons["Yes"]
        
        yesButton.tap()
        sleep(3)
        
        let endPoster = app.images["Poster"]
        let endPosterData = endPoster.screenshot().pngRepresentation
        
        let indexLable = app.staticTexts["Index"]
        
        XCTAssertTrue(beginPoster.exists)
        XCTAssertTrue(endPoster.exists)
        XCTAssertFalse(beginPoster == endPoster)
        XCTAssertNotEqual(beginPosterData, endPosterData)
        XCTAssertEqual(indexLable.label, "2/10")
    }
    
    func testNoButton() throws {
        sleep(3)
        let beginPoster = app.images["Poster"]
        let beginPosterData = beginPoster.screenshot().pngRepresentation
        
        let noButton = app.buttons["No"]
        noButton.tap()
        sleep(3)
        
        let endPoster = app.images["Poster"]
        let endPosterData = endPoster.screenshot().pngRepresentation
        
        let indexLable = app.staticTexts["Index"]
        
        XCTAssertTrue(beginPoster.exists)
        XCTAssertTrue(endPoster.exists)
        XCTAssertNotEqual(beginPosterData, endPosterData)
        XCTAssertEqual(indexLable.label, "2/10")
    }
    
    func testAlert() throws {
        pushButtons()
        sleep(3)
        
        let alert = app.alerts["Game results"]
        
        //print(alert.buttons.firstMatch.label)
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть еще раз")
    }
    
    func testAlertDismiss() throws {
        pushButtons()
        sleep(3)
        
        let alert = app.alerts["Game results"]
        alert.buttons.firstMatch.tap()
        sleep(3)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
        
    }
}
