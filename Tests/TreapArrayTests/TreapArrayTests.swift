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
            
            for i in 0..<testSize {
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
                XCTAssertNoThrow(treap.insert(rand, at: 0))
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
        
    }
