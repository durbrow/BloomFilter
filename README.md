# BloomFilter

A Bloom filter in Swift.


A Bloom filter can tell you if something is **not** in a set; it can **not** definitely tell you if it is in a set.
In other words, the test for membership can have false positives but not false negatives.
However, if that is acceptable, Bloom filters are very small and fast.

For more information, see Wikipedia [article](https://en.wikipedia.org/wiki/Bloom_filter) on Bloom filters.

 - *insert* adds elements.
 - *subscript* tests membership.
 - *inserted* tests membership and adds element, more efficient than separate calls

### Example
```swift
var filter = BloomFilter<String>(optimizedForCount: 10)

filter.insert("Foo")
filter.insert("Bar")

if filter["bar"] { print("'bar' shouldn't be in the set!") }
```
