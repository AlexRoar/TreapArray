    import XCTest
    @testable import TreapArray

    final class TreapArrayTests: XCTestCase {
        func testSimple() {
            var treap = TreapArray<Int>()
            var array = Array<Int>()
            
            let testSize = 1024
            
            for _ in 0..<testSize {
                let rand = Int.random(in: 0...Int.max)
                array.append(rand)
                treap.append(rand)
            }
            
            for i in 0..<testSize {
                XCTAssertEqual(array[i], treap[i])
            }
        }
        
        func testSimpleFront() {
            var treap = TreapArray<Int>()
            var array = Array<Int>()
            
            let testSize = 2048
            
            for _ in 0..<testSize {
                let rand = Int.random(in: 0...Int.max)
                array.insert(rand, at: 0)
                XCTAssertNoThrow(treap.insert(rand, at: 0))
            }
            
            for i in 0..<testSize {
                XCTAssertEqual(array[i], treap[i])
            }
        }
        
        func testCopyOnWrite() {
            var treap = TreapArray<Int>()
            var array = Array<Int>()
            
            let testSize = 2048 * 8
            
            for _ in 0..<testSize {
                let rand = Int.random(in: 0...Int.max)
                array.insert(rand, at: 0)
                treap.insert(rand, at: 0)
            }
            
            for i in 0..<testSize {
                XCTAssertEqual(array[i], treap[i])
            }
            
            let otherTreap = treap
            
            for i in 0..<testSize {
                XCTAssertEqual(array[i], otherTreap[i])
            }
            
            for i in 0..<testSize {
                treap[i] = Int.random(in: 0...Int.max)
            }
            
            for i in 0..<testSize {
                XCTAssertEqual(array[i], otherTreap[i])
            }
        }
        
        func testArrayLiteral() {
            let treap:TreapArray<Int> = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
            
            for i in 0...10 {
                XCTAssertEqual(treap[i], i)
            }
        }
        
        func testSeqInsert() {
            var treap:TreapArray<Int> = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
            let arrResult = [0, 1, 2, 3, 4, 5, 6, 7, 8, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 9, 10]
            
            for i in 0...10 {
                XCTAssertEqual(treap[i], i)
            }
            
            treap.insert(contentsOf: treap.array, at: 9)
            
            for i in 0..<arrResult.count {
                XCTAssertEqual(treap[i], arrResult[i])
            }
        }
        
        func testRepeating() {
            let treap = TreapArray<Int>(repeating: 10, count: 100)
            
            for i in 0..<treap.count {
                XCTAssertEqual(treap[i], 10)
            }
        }
        
        func testFiltering() {
            var treap: TreapArray<Int> = []
            let testSize = 2048 * 8
            
            for _ in 0...testSize {
                treap.append(Int.random(in: 0...Int.max))
            }
            
            let filter =  {
                (i: Int) -> Bool in
                i > Int.max / 2
            }
            var countFilter = 0
            for i in treap {
                if (filter(i)){
                    countFilter += 1
                }
            }
            
            let filtered = treap.filter(filter)
            
            XCTAssertEqual(filtered.count, countFilter)
            
            for i in filtered{
                XCTAssertTrue(filter(i))
            }
        }
        
    }
