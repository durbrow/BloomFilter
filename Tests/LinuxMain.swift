import XCTest

import BloomFilterTests

var tests = [XCTestCaseEntry]()
tests += BloomFilterTests.allTests()
XCTMain(tests)
