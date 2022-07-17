//
//  ios_dca_calculatorTests.swift
//  ios-dca-calculatorTests
//
//  Created by ibrahim uysal on 17.07.2022.
//

import XCTest
@testable import ios_dca_calculator

class ios_dca_calculatorTests: XCTestCase {
    
    var sut: DCAService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = DCAService()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        sut = nil
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    func testResult_givenWinningAssetAndDCAIsUsed_expectPositiveGains() {
        // given
        let initialInvestmentAmount: Double = 5000
        let monthlyDollarCostAveragingAmount: Double = 1500
        let initialDateOfInvestmentIndex: Int = 5
        let asset = buildWinningAsset()
        // when
        let result = sut.calculate(asset: asset,
                                   initialInvestmentAmount: initialInvestmentAmount,
                                   monthlyDollarCostAveragingAmount: monthlyDollarCostAveragingAmount,
                                   initialDateOfInvestmentIndex: initialDateOfInvestmentIndex)
        // then
        // Initial investment: $5000
        // DCA: $1500 X 5 = $7500
        // total: $5000 + $7500 = $12500
        XCTAssertEqual(result.investmentAmount, 12500)
        XCTAssertTrue(result.isProfitable)
        
        // Jan: $5000 / 100 = 50 shares
        // Feb: $1500 / 110 = 13.6363 shares
        // March: $1500 / 120 = 12.5 shares
        // April: $1500 / 130 = 11.5384 shares
        // May: $1500 / 140 = 10.7142 shares
        // June: $1500 / 150 = 10 shares
        // Total shares = 108.3889 shares
        // Total current value = 108.3889 X $160 (latest month closing price) = $17,342.224
        
        XCTAssertEqual(result.currentValue, 17342.224, accuracy: 0.1)
        XCTAssertEqual(result.gain, 4842.224, accuracy: 0.1)
        XCTAssertEqual(result.yield, 0.3873, accuracy: 0.0001)
    }
    
    func testResult_givenWinningAssetAndDCAIsNotUsed_expectPositiveGains() {
        // given
        let initialInvestmentAmount: Double = 5000
        let monthlyDollarCostAveragingAmount: Double = 0
        let initialDateOfInvestmentIndex: Int = 3
        let asset = buildWinningAsset()
        // when
        let result = sut.calculate(asset: asset,
                                   initialInvestmentAmount: initialInvestmentAmount,
                                   monthlyDollarCostAveragingAmount: monthlyDollarCostAveragingAmount,
                                   initialDateOfInvestmentIndex: initialDateOfInvestmentIndex)
        // then
        // Initial investment: $5000
        // DCA: $0 X 3 = $0
        // total: $5000 + $0 = $5000
        XCTAssertEqual(result.investmentAmount, 5000)
        XCTAssertTrue(result.isProfitable)
        
        // March: $5000 / 120 = 41.6666 shares
        // April: $0 / 130 = 0 shares
        // May: $0 / 140 = 0 shares
        // June: $0 / 150 = 0 shares
        // Total shares = 41.6666 shares
        // Total current value = 41.6666 X $160 (latest month closing price) = $6666.666
        // Gains = current value LESS investment amount: 6666.666 - 5000 = 1666.666
        // Yield = gains / investment amount: 1666.666 / 5000 = 0.3333
        XCTAssertEqual(result.currentValue, 6666.666, accuracy: 0.1)
        XCTAssertEqual(result.gain, 1666.666, accuracy: 0.1)
        XCTAssertEqual(result.yield, 0.3333, accuracy: 0.0001)
    }
    
    private func buildWinningAsset() -> Asset {
        let searchResult = buildSearchResult()
        let meta = buildMeta()
        let timeSeries: [String : OHLC] = ["2021-01-25" : OHLC(open: "100", close: "110", adjustedClose: "110"),
                                           "2021-02-25" : OHLC(open: "110", close: "120", adjustedClose: "120"),
                                           "2021-03-25" : OHLC(open: "120", close: "130", adjustedClose: "130"),
                                           "2021-04-25" : OHLC(open: "130", close: "140", adjustedClose: "140"),
                                           "2021-05-25" : OHLC(open: "140", close: "150", adjustedClose: "150"),
                                           "2021-06-25" : OHLC(open: "150", close: "160", adjustedClose: "160")]
        let timeSeriesMonthlyAdjusted = TimeSeriesMonthlyAdjusted(meta: meta,
                                                                  timeSeries: timeSeries)
        return Asset(searchResult: searchResult,
                     timeSeriesMonthlyAdjusted: timeSeriesMonthlyAdjusted)
    }
    
    
    private func buildSearchResult() -> SearchResult {
        return SearchResult(symbol: "XYZ", name: "XYZ Company", type: "ETF", currency: "USD")
    }
    
    private func buildMeta() -> Meta {
        return Meta(symbol: "XYZ")
    }
    
    func testInvestmentAmount_whenDCAIsUsed_expectResult() {
        // given
        let initialInvestmentAmount: Double = 500
        let monthlyDollarCostAveragingAmount: Double = 300
        let initialDateOfInvestmentIndex = 4 // (4 months ago)
        // when
        let investmentAmount = sut.getInvestmentAmount(initialInvestmentAmount: initialInvestmentAmount,
                                                       monthlyDollarCostAveragingAmount: monthlyDollarCostAveragingAmount,
                                                       initialDateOfInvestmentIndex: initialDateOfInvestmentIndex)
        // then
        XCTAssertEqual(investmentAmount, 1700)
    }
    
    func testInvestmentAmount_whenDCAIsNotUsed_expectResult() {
        // given
        let initialInvestmentAmount: Double = 500
        let monthlyDollarCostAveragingAmount: Double = 0
        let initialDateOfInvestmentIndex = 4 // (4 months ago)
        // when
        let investmentAmount = sut.getInvestmentAmount(initialInvestmentAmount: initialInvestmentAmount,
                                                       monthlyDollarCostAveragingAmount: monthlyDollarCostAveragingAmount,
                                                       initialDateOfInvestmentIndex: initialDateOfInvestmentIndex)
        // then
        XCTAssertEqual(investmentAmount, 500)
    }


}
