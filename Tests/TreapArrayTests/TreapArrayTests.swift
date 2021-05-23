import XCTest
import Foundation
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
        var arrResult: Array<Int> = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        arrResult.insert(contentsOf: arrResult, at: 9)
        
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
    
    func testItterator() {
        var treap: TreapArray<Int> = []
        let testSize = 2048 * 8
        
        for i in 0...testSize {
            treap.append(i)
        }
        
        var count = 0
        for i in treap {
            XCTAssertEqual(i, count)
            count += 1
        }
    }
    
    func evaluateProblem(_ problemBlock: () -> Void, _ msg:String="") -> Double {
        let start = DispatchTime.now() // <<<<<<<<<< Start time
        problemBlock()
        let end = DispatchTime.now()   // <<<<<<<<<<   end time
        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1_000_000_000
        if (msg != ""){
            print("Elapsed \(timeInterval) - \(msg)")
        }
        return timeInterval
    }
    
    func testSpeedRandomInsertions(){
        let generalSize = 200000
        let testSize = 50000
        var treap = TreapArray<Int>(repeating: 0, count: generalSize)
        var array = Array<Int>(repeating: 0, count: generalSize)
        
        var mutation:[(Int, Int)] = []
        
        for _ in 0..<testSize {
            mutation.append((Int.random(in: 0..<generalSize), Int.random(in: 0...Int.max)))
        }
        
        let arrayTest = {
            for i in mutation {
                array.insert(i.1, at: i.0)
            }
        }
        
        let treapTest = {
            for i in mutation {
                treap.insert(i.1, at: i.0)
            }
        }
        
        XCTAssertLessThan(evaluateProblem(treapTest, "Treap time insertions"),
                          evaluateProblem(arrayTest, "Array time insertions"))
        
    }
    
    func testSpeedFrontInsertions(){
        let generalSize = 200000
        let testSize = 50000
        var treap = TreapArray<Int>(repeating: 0, count: generalSize)
        var array = Array<Int>(repeating: 0, count: generalSize)
        
        var mutation:[(Int, Int)] = []
        
        for _ in 0..<testSize {
            mutation.append((0, Int.random(in: 0...Int.max)))
        }
        
        let arrayTest = {
            for i in mutation {
                array.insert(i.1, at: i.0)
            }
        }
        
        let treapTest = {
            for i in mutation {
                treap.insert(i.1, at: i.0)
            }
        }
        
        XCTAssertLessThan(evaluateProblem(treapTest, "Treap time insertions front"),
                          evaluateProblem(arrayTest, "Array time insertions front"))
        
    }
    
    func testRemovalsSpeed(){
        let generalSize = 400000
        let testSize = 100000
        
        var array = Array<Int>(repeating: 0, count: generalSize)
        for i in 0..<array.count {
            array[i] = Int.random(in: 0...Int.max)
        }
        var treap = TreapArray<Int>(array)
        
        var mutation:[Int] = []
        
        for _ in 0..<testSize {
            mutation.append(Int.random(in: 0..<(array.count - mutation.count)))
        }
        
        let arrayTest = {
            for i in mutation {
                array.remove(at: i)
            }
        }
        
        let treapTest = {
            for i in mutation {
                treap.remove(at: i)
            }
        }
        
        XCTAssertLessThan(evaluateProblem(treapTest, "Treap time removals"),
                          evaluateProblem(arrayTest, "Array time removals"))
        
        XCTAssertEqual(treap.count, array.count)
        for i in 0..<array.count {
            XCTAssertEqual(treap[i], array[i])
        }
    }
    
    func testDesription () {
        var treap:TreapArray<Int> = [1, 2, 3]
        XCTAssertNoThrow(String(describing: treap))
        
        treap = TreapArray<Int>()
        XCTAssertNoThrow(String(describing: treap))
    }
    
    func testDebugDesription () {
        var treap:TreapArray<Int> = [1, 2, 3]
        XCTAssertNoThrow(treap.debugDescription)
        
        treap = TreapArray<Int>()
        XCTAssertNoThrow(treap.debugDescription)
    }
    
    func testAppendSeq(){
        let generalSize = 100000
        
        var array = Array<Int>(repeating: 0, count: generalSize)
        for i in 0..<array.count {
            array[i] = Int.random(in: 0...Int.max)
        }
        var treap = TreapArray<Int>(array)
        
        array.append(contentsOf: array)
        treap.append(contentsOf: treap)
        
        XCTAssertEqual(array, treap.array)
    }
    
    func testRemoveSubrange(){
        let generalSize = 100000
        
        var array = Array<Int>(repeating: 0, count: generalSize)
        for i in 0..<array.count {
            array[i] = Int.random(in: 0...Int.max)
        }
        var treap = TreapArray<Int>(array)
        
        array.removeSubrange(5...123)
        treap.removeSubrange(5...123)
        
        XCTAssertEqual(array, treap.array)
        
        array.removeSubrange(5..<123)
        treap.removeSubrange(5..<123)
        
        XCTAssertEqual(array, treap.array)
        
        
        XCTAssertEqual(array, treap.array)
    }
}
