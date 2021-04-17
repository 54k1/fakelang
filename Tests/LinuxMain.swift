import ScannerTests
import XCTest
import fakelangTests

var tests = [XCTestCaseEntry]()
tests += fakelangTests.allTests()
tests += ScannerTests.allTests()
XCTMain(tests)
