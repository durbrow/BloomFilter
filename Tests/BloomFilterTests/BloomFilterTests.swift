import XCTest
@testable import BloomFilter

final class BloomFilterTests: XCTestCase {
    func testBestPowerOf2() {
        XCTAssertEqual(bestPowerOf2(1.0), 1)
        XCTAssertEqual(bestPowerOf2(2.0), 2)
        XCTAssertEqual(bestPowerOf2(3.0), 4)
        XCTAssertEqual(bestPowerOf2(25.6), 32)
        XCTAssertEqual(bestPowerOf2(pow(2.0, 32.0) - 1.0), 1 << 32)
        XCTAssertEqual(bestPowerOf2(pow(2.0, 32.0) + 1.0), 1 << 33)
    }
    func testIntExample() {
        let N = 500
        var o = BloomFilter<Int>(optimizedForCount: N)
        print(o.falsePositiveRate(forElementCount: N))
        let R = 0..<1000
        R.shuffled()[0..<N].forEach { o.insert($0) }
        let c = R.filter({o[$0]}).count
        XCTAssertEqual(c, N)
    }
    func testStringExample() {
        var o = BloomFilter<String>(optimizedForCount: 1000, falsePositiveRate: 1.0 / 1000.0)
        "Mary had a little lamb".split(separator: " ").forEach { o.insert(String($0)) }
        "Mary had a little lamb".split(separator: " ").forEach { XCTAssertEqual(o[String($0)], true) }
        "Its fleece was white as snow".split(separator: " ").forEach { XCTAssertEqual(o[String($0)], false) }
    }

    static var allTests = [
        ("testBestPowerOf2", testBestPowerOf2),
        ("testIntExample", testStringExample),
        ("testStringExample", testStringExample),
    ]
}
