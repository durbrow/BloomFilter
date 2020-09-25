//
//  BloomFilter.swift
//
//  Created by Kenneth Durbrow on 9/23/20.
//

import Foundation

func uniqueRandomInts(count: Int) -> [Int]
{
    var set = Set<Int>()
    while set.count < count {
        set.insert(Int.random(in: 0..<Int.max))
    }
    return [Int](set)
}

/// the smallest integer power of 2 than is greater than or equal to x
func bestPowerOf2(_ x: Double) -> Int
{
    1 << Int(log2(x).rounded(.up))
}

/// Bloom Filter
///
/// [article]: https://en.wikipedia.org/wiki/Bloom_filter
///
/// A Bloom filter can tell you if something is **not** in a set; it can **not** definitely tell you if it is in a set.
/// In other words, the test for membership can have false positives but not false negatives.
/// However, if that is acceptable, Bloom filters are incredibly small and fast.
///
/// For more information, see Wikipedia [article] on Bloom filters.
///
/// - *insert* adds elements.
/// - *subscript* tests membership.
public struct BloomFilter<Element: Hashable>
{
    private typealias HashFunction = Int
    private typealias HashFunctions = [HashFunction]

    /// used for the hash functions
    private let K: HashFunctions
    public var k: Int { K.count }

    private typealias State = [Bool]

    /// stores the Bloom filter state
    private var M: State
    public var m: Int { M.count }

    /// The theoretical false positive rate.
    /// - parameter n: the number of elements in the set.
    /// - returns: the theoretical false positive rate if the set contained n elements.
    public func falsePositiveRate(forElementCount n: Int) -> Double {
        pow(1.0 - exp(-Double(k) * Double(n) / Double(m)), Double(k))
    }

    /// - returns: An array of which bits in *M* correspond to *el*
    private func bits(for el: Element) -> [State.Index] {
        func hash(_ x: Int) -> Int {
            var h = Hasher()
            h.combine(el)
            h.combine(x) //< this distinguishes the several hash functions
            return abs(h.finalize()) % M.count
        }
        return K.map(hash)
    }

    private mutating func set(_ idx: [State.Index]) {
        idx.forEach { M[$0] = true }
    }

    private func allset(_ idx: [State.Index]) -> Bool {
        idx.allSatisfy { M[$0] }
    }

    /// - parameter n: the number of elements.
    /// - parameter e: the acceptable false positive rate.
    /// - returns: the optimal bit count *m* and hash function count *k*
    static func optimalFor(elementCount n: Int, falsePositiveRate e: Double) -> (Double, Double)
    {
        let k = -log(e) / log(2.0)
        let m = Double(n) * k / log(2.0)
        return (m, k)
    }

    /// A Bloom Filter
    ///
    /// - parameter count: the number of bits in the filter
    /// - parameter hashes: the number of hash functions to use
    public init(count: Int, hashes: Int) {
        M = Array(repeating: false, count: count)
        K = uniqueRandomInts(count: hashes)
    }

    /// A Bloom filter optimized for a certain number of items.
    ///
    /// - Theoretically statistically optimal
    /// - Not guaranteed to be actually optimal for any set of values.
    /// - Might be non-optimal for rounding to whole integer values and/or other practical considerations.
    ///
    /// - note: The target false positive rate is 1 / (*n* + 1)
    ///
    /// - parameter n: the number of elements you want to track
    public init(optimizedForCount n: Int) {
        let (bits, hashes) = Self.optimalFor(elementCount: n, falsePositiveRate: 1.0 / Double(n + 1))
        M = Array(repeating: false, count: bestPowerOf2(bits))
        K = uniqueRandomInts(count: Int(hashes.rounded(.down)))
    }

    /// A Bloom filter optimized for a certain number of items and false positive rate.
    ///
    /// - Theoretically statistically optimal
    /// - Not guaranteed to be actually optimal for any set of values.
    /// - Might be non-optimal for rounding to whole integer values and/or other practical considerations.
    ///
    /// - parameter n: the number of items you want to track
    /// - parameter e: the acceptable false positive rate
    public init(optimizedForCount n: Int, falsePositiveRate e: Double) {
        let (bits, hashes) = Self.optimalFor(elementCount: n, falsePositiveRate: e)
        M = Array(repeating: false, count: bestPowerOf2(bits))
        K = uniqueRandomInts(count: Int(hashes.rounded(.down)))
    }

    /// Insert an element into the set.
    /// - complexity: O(*k*), where *k* is the number of hashes
    /// - parameter addend: the element to add to the set
    public mutating func insert(_ addend: Element) {
        set(bits(for: addend))
    }

    /// Check if an element might have been added to the set.
    ///
    /// - complexity: O(*k*), where *k* is the number of hashes
    /// - note: Can return false positives.
    ///
    /// - parameter el: the element to test.
    ///
    /// - returns: false if the value is not in the set.
    public subscript(_ el: Element) -> Bool {
        allset(bits(for: el))
    }

    /// If not already in set, add it and return true else return false
    public mutating func inserted(_ el: Element) -> Bool {
        let idx = bits(for: el)
        if !allset(idx) {
            set(idx)
            return true
        }
        return false
    }
}
