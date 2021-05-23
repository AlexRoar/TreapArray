struct TreapArray<T>: CustomStringConvertible, Collection, Sequence,
    RangeReplaceableCollection, MutableCollection,
    ExpressibleByArrayLiteral, CustomDebugStringConvertible {
    
    typealias ArrayLiteralElement = T
    
    enum TreapArrayError: Error {
        case indexNotFound(x: UInt)
    }
    
    private class Identity {}
    
    class TreapNode: CustomStringConvertible {
        var key:T? = nil
        var priority:UInt = 0
        var depth:UInt = 1
        
        var left:TreapNode? = nil
        var right:TreapNode? = nil
        
        init(key: T?, left: TreapNode? = nil, right: TreapNode? = nil) {
            self.key = key
            self.left = left
            self.right = right
            priority = UInt.random(in: 0..<UInt.max)
            update()
        }
        
        var leftDepth: UInt {
            left?.depth ?? 0
        }
        
        var rightDepth: UInt {
            right?.depth ?? 0
        }
        
        func update() {
            depth = leftDepth + rightDepth + 1
        }
        
        static func merge(left: TreapNode? = nil, right: TreapNode? = nil) -> TreapNode?{
            if left == nil {
                return right
            }
            
            if right == nil {
                return left
            }

            if left!.priority > right!.priority {
                left!.right = merge(left: left!.right, right: right);
                left!.update();
                return left;
            } else {
                right!.left = merge(left: left, right: right!.left);
                right!.update();
                return right;
            }
        }
        
        func split(no:UInt) -> (TreapNode?, TreapNode?) {
            var newTree:TreapNode? = nil
            let curKey = leftDepth
            
            var ret:(left: TreapNode?, right: TreapNode?) = (nil, nil)
            
            if curKey < no {
                if (right == nil){
                    ret.right = nil
                } else {
                    (newTree, ret.right) = right!.split(no: no - curKey - 1)
                }
                right = newTree
                ret.left = self
            } else {
                if (left == nil){
                    ret.left = nil
                } else {
                    (ret.left, newTree) = left!.split(no: no)
                }
                left = newTree
                ret.right = self
            }
            
            if ret.left != nil {
                ret.left!.update()
            }
            
            if ret.right != nil {
                ret.right!.update()
            }
            
            return ret
        }
        
        func insert(x:UInt, key:T) -> TreapNode? {
            let splitted = split(no: x)
            
            let m = TreapNode(key: key)
            return TreapArray<T>.TreapNode.merge(
                left: TreapArray<T>.TreapNode.merge(
                            left: splitted.0,
                            right: m),
                         right: splitted.1)
        }
        
        func remove(x:UInt) throws -> (TreapNode?, TreapNode?) {
            let splitRes = split(no: x)
            
            if splitRes.1 == nil {
                throw TreapArrayError.indexNotFound(x: x)
            }
        
            let splittedSecond = splitRes.1!.split(no: 1)
            return (TreapArray<T>.TreapNode.merge(left: splitRes.0, right: splittedSecond.1), splittedSecond.0)
        }
        
        func get(x:UInt) -> TreapNode? {
            let curKey = leftDepth
            if curKey < x {
                if right == nil {
                    return nil
                }
                return right!.get(x: x - curKey - 1)
            } else if curKey > x {
                if left == nil {
                    return nil
                }
                return left!.get(x: x);
            }
            return self
        }
        
        func set(x:UInt, value: T) throws {
            let node = get(x: x)
            if node == nil {
                throw TreapArrayError.indexNotFound(x: x)
            }
            node!.key = value
        }
        
        func dump(str: inout String, depthPrint: UInt = 1) {
            let strValue = "<\(String(describing: key))>\n"
            
            if right != nil {
                right!.dump(str: &str, depthPrint: depthPrint + UInt(strValue.count))
            }
            
            str += String(repeating: " ", count: Int(depthPrint - 1)) + "|"
            str += strValue
            
            if left != nil {
                left!.dump(str: &str, depthPrint: depthPrint + UInt(strValue.count))
            }
        }
        
        public var description: String {
            var out: String = ""
            dump(str: &out)
            return out
        }
        
        var copy: TreapNode {
            TreapNode(key: key, left: left?.copy, right: right?.copy)
        }
    }
    
    private var head: TreapNode? = nil
    private var size: UInt = 0
    private var id = Identity()
    
    init() {
        
    }
    
    init (_ content: Array<T>) {
        for i in content{
            append(i)
        }
    }
    
    init(arrayLiteral elements: T...) {
        for i in elements{
            append(i)
        }
    }
    
    public func index(after i: Int) -> Int {
        i + 1
    }
    
    public var startIndex: Int {
        0
    }
    
    public var endIndex: Int {
        Int(size)
    }
    
    var array: [T] {
        var result = Array<T>()
        result.reserveCapacity(Int(size))
        for i in self{
            result.append(i)
        }
        return result
    }
    
    public var description: String {
        let mirror = Mirror(reflecting: self)
        var out:String = "\(mirror.subjectType) {\n"
        for i in 0..<size {
            out += "\t" + String(describing: self[i]) + "\n"
        }
        out += "}"
        return out
    }
    
    public var debugDescription: String {
        let mirror = Mirror(reflecting: self)
        var out:String = "\(mirror.subjectType) {\n"
        out += head?.description ?? "<Empty>"
        out += "\n}"
        return out
    }
    
    public var getSize: UInt {
        size
    }
    
    public var isEmpty: Bool {
        size == 0
    }
    
    mutating func copyOnWrite() {
        if !isKnownUniquelyReferenced(&self.id) {
            self.id = Identity()
            head = head?.copy
        }
    }
    
    mutating public func append(_ value: T) {
        copyOnWrite()
        if head == nil {
            head = TreapNode(key: value)
        } else {
            head = head!.insert(x: size, key: value)
        }
        size += 1
    }
    
    mutating public func appendFront(_ value: T) {
        copyOnWrite()
        if head == nil {
            head = TreapNode(key: value)
        } else {
            head = head?.insert(x: 0, key: value)
        }
        size += 1
    }
    
    @discardableResult mutating func remove(at i: Int) -> T {
        copyOnWrite()
        return remove(at: UInt(i))
    }
    
    mutating func removeAll(keepingCapacity keepCapacity: Bool) {
        copyOnWrite()
        head = nil
        size = 0
    }
    
    mutating func removeAll(where shouldBeRemoved: (T) throws -> Bool) rethrows {
        copyOnWrite()
        for i in (0..<size).reversed() {
            if try shouldBeRemoved(self[i]) {
                remove(at: i)
            }
        }
    }
    
    
    mutating func removeFirst() -> T {
        copyOnWrite()
        return remove(at: 0)
    }
    
    mutating func removeFirst(_ k: Int) {
        copyOnWrite()
        for _ in (0..<k) {
            remove(at: 0)
        }
    }
    
    @discardableResult mutating public func remove(at i: UInt) -> T {
        copyOnWrite()
        if (i > size) {
            fatalError("Index \(i)/ out of range in structure of size \(size)")
        }
        
        if let newHead = try? head?.remove(x: i) {
            if newHead.0 == nil || newHead.1 == nil {
                fatalError("Index \(i)/ out of range in structure of size \(size)")
            }
            head = newHead.0
            size -= 1
            return newHead.1!.key!
        }
        fatalError("Index \(i)/ out of range in structure of size \(size)")
    }
    
    public subscript(_ x: Int) -> T {
        get {
            self[UInt(x)]
        }
        mutating set(value) {
            self[UInt(x)] = value
        }
    }
    
    public subscript(_ x: UInt) -> T {
        get {
            if let val = head?.get(x: x)?.key {
                return val
            }
            fatalError("Index \(x)/ out of range in structure of size \(size)")
        }
        mutating set(value) {
            copyOnWrite()
            if head == nil && x == 0 {
                head = TreapNode(key: value)
                size = 1
                return
            }
            if head == nil || x >= size {
                fatalError("Index \(x)/ out of range in structure of size \(size)")
            }
            head!.get(x: x)!.key = value
        }
    }
    
    mutating func insert(_ newElement: T, at i: Int) {
        copyOnWrite()
        insert(newElement, at: UInt(i))
    }
    
    mutating public func insert(_ newElement: T, at i: UInt) {
        copyOnWrite()
        if (i > size) {
            fatalError("Index \(i)/ out of range in structure of size \(size)")
        }
        if head == nil {
            head = TreapNode(key: newElement)
        } else {
            head = head!.insert(x: i, key: newElement)
        }
        size += 1
    }

    
    mutating public func insert<S>(contentsOf newElements: S, at i: Int) where S : Collection, T == S.Element {
        copyOnWrite()
        var pos = i
        for elem in newElements{
            self.insert(elem, at: pos)
            pos += 1
        }
    }
    
    init<S>(_ elements: S) where S : Sequence, T == S.Element {
        for i in elements {
            append(i)
        }
    }
    
    init(repeating repeatedValue: T, count: Int) {
        for _ in 0..<count {
            append(repeatedValue)
        }
    }
    
    mutating func append<S>(contentsOf newElements: S) where S : Sequence, T == S.Element {
        copyOnWrite()
        for elem in newElements {
            append(elem)
        }
    }
    
    mutating func removeSubrange(_ bounds: Range<Int>) {
        copyOnWrite()
        for i in bounds.reversed() {
            remove(at: i)
        }
    }
}
