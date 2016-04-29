# [fit] Learning 
# [fit] **F**unctional 
# [fit] ~~**R**eactive~~ 
# [fit] **P**rogramming

^
- Rave/hype in the iOS community 
- Prepare for the risk of FRP code base

—
# [fit] CollectionType
# [fit] **.filter**
# [fit] **.reduce**
# [fit] **.map**

^
JSON parser first, functional Swift stuff next.

—
# CollectionType**.filter**
[]()

```swift
[1, 2, 3, 4].filter { even($0) }

[2, 4]
```

^
WTF is $0??

—

# CollectionType**.reduce**
[]()

```swift
[1, 2, 3, 4].reduce(0) { $0 + $1 }

10
```

—

# CollectionType**.map**
[]()

```swift
[1, 2, 3, 4].map { ordinal($0) }

["1st", "2nd", "3rd", "4th"]
```

—

# CollectionType**.map**
[]()

```swift
["First" : 1, "Second" : 2]
    .map { $0 + ":" + ordinal($1) }

["Second : 2nd", "First : 1st"]
```

^
Also works on dictionary

—
# [fit] CollectionType
# [fit] **.flatten**
# [fit] **.flatMap**
# [fit] **.split**

—
# CollectionType**.flatten**
[]()
[]()

```swift
[[1, 2], [3, 4]].flatten().map { ordinal($0) }

["1st", "2nd", "3rd", "4th"]
```

—
# CollectionType**.flatMap**
[]()

```swift
[1, 2, 3, 4].flatMap { evenOrdinal($0) }

["2nd", "4th"]
```

—
# CollectionType**.flatMap**
[]()

```swift
[1, 2, 3, 4]
    .map { evenOrdinal($0) }
    .filter { $0 != nil }
    .map { $0! }

["2nd", "4th"]
```

^
map {} -> filter { $0 != nil }

—
# CollectionType**.split**
[]()

```swift
[1, 2, 3, 4].split { even($0) }

[ArraySlice([1]), ArraySlice([3])]
```


—
# [fit] Optional
# [fit] **.map**
# [fit] **.flatMap**

—
# Optional**.map**
[]()

```swift
evenOrdinal(2).map { $0 + "!" }

Optional("2nd!")
```

^
Apply something to value “inside” optional. Returns another optional that might have a value, of course mapped/transformed.

—
# Optional**.map**
[]()

```swift
evenOrdinal(1).map { $0 + "!" }

Optional(nil)
```

—
# Optional**.map** 
```swift
let bar1 = {
    if let value = foo {
        return ordinal(value)
    } else {
        return "-"
    }
}()
// vs
let bar2 = foo.map { ordinal($0) } ?? "-" 
```

^
Swift encourages us to use let's

—
# Optional**.flatMap**
[]()

```swift
let foo: Int? = 2
foo.map    { evenOrdinal($0) } // "Optional(Optional("2nd"))
// vs
foo.flatMap { evenOrdinal($0) } // "Optional("2nd")
```

[]()

`.flatMap` allows failable transforms[^1]


[^1]: Thanks to Harlan Haskins [@harlanhaskins](https://twitter.com/harlanhaskins) for clarifying

—
# [fit] Odd
# [fit] **.zip**([], [])

—
# **zip**(Array, Array)
[]()
[]()

```swift
zip(["1st", "2nd", "3rd", "4th"], ["!", "?", "¡", "¿"])
    .map { $0 + $1 }

["1st!", "2nd?", "3rd¡", "4th¿"]
```
	
^
The result of zip is just tuples of value pairs. I've transformed them into something else.

—
# **Result**
[]()

```swift
enum Result<T> {
    case Success(T)
    case Failure(ErrorType)
}
```

—
# **Optional**
[]()

```swift
enum Optional<T> {
    case Some(T)
    case None
}
```

^
Similar to optionals, just with descriptive error instead of nil

—
# **Result**
[]()

```swift
enum Result<T> {
    case Success(T)
    case Failure(ErrorType)
}
```

^
Similar to optionals, just with descriptive error instead of nil

—
# **Result**
```swift
extension Result<T> {
    func flatMap<U>(f: T -> Result<U>) -> Result<U> {
        switch self {
        case let .Success(t): return f(t)
        case let .Failure(err): return .Failure(err)
        }
    }
}
```

—
# **Result**
```swift
func readFile(name: String) -> Result<Data> {}
func toJson(data: Data) -> Result<Dictionary> {}
func toCar(dict: Dictionary) -> Result<Car> {}

let userResult = readFile("car.json")
    .flatMap(toJson)
    .flatMap(toCar)
```

^
- The error at a given state i propagated through
- Should I go over these three steps again?

—
# **Result** Async
```swift
extension Result<T> -> Void {
    func flatMap<U>(f: (T, Result<U> -> Void)) 
                      -> (Result<U> -> Void) {
        return { completion in
            switch self {
            case let .Success(t): f(t, completion))
            case let .Failure(err): return .Failure(err)
            }
        }
    }
}
```

^
- a.k.a. Promises/Futures
- Pseudo code
- Of course the same can be done for the `.map`

—
# **Result** Async
```swift
func readFile(file: String) -> (Result<Data> -> Void) {}
func toJson(data: Data) -> (Result<Dictionary> -> Void) {}
func toCar(dict: Dictionary) -> (Result<Car> -> Void) {}

let userResult = readFile("car.json")
    .flatMap(toJson)
    .flatMap(toCar)
```

—
# [fit] Learning 
# [fit] **F**unctional 
# [fit] **Reactive** 
# [fit] **P**rogramming

^
Highly reactive already

—
# [fit] **Observable**
# [fit] Signal
# [fit] Stream
# [fit] Channel
# [fit] Pipe

^
As async result, but with multiple calls on supplied completion block

—

```swift
class Observable<T> {
    private var value: Result<T>?
    private var callbacks: [Result<T> -> Void] = []

    func subscribe(f: Result<T> -> Void) -> Observable<T> {
        if let value = value { f(value) }
        callbacks.append(f)
        return self
    }
    func update(result: Result<T>) {
        value = result
        callbacks.forEach { $0(result) }
    }
}
```

—
# **Observable** Sync

```swift
extension Observable<T> {
    func flatMap<U>(f: T -> Result<U>) -> Observable<U> {
        let observable = Observable<U>()
        subscribe { result in
            observable(result.flatMap(f))
        }
        return observable
    }
}
```

—
# **Observable** Async

```swift
extension Observable<T> {
    func flatMap<U>(f: (T, Result<U> -> Void) -> Void) 
        -> Observable<U> {
            let observable = Observable<U>()
            subscribe { result in
                observable.update(result.flatMap(f))
            }
            return observable
        }
}
```

—
# **Observable**
```swift
extension Observable<T> {
    func flatMap<U>(f:  T -> Result<U>)              -> Observable<U>
    func flatMap<U>(f: (T, Result<U>->Void) -> Void) -> Observable<U>
    func flatMap<U>(f: (T -> Observable<U>))         -> Observable<U>

    // Bonus
    func map<U>(f: T -> U)                          -> Observable<U> 
    func flatMap<U>(f: T throws -> U)                -> Observable<U>
}
```

^
- I won’t go in to this
- But note that you can `flatMap` from a sync/async `Result` as well as an `Observable`

—
# **Observable**
[]()

```swift
extension Observable<T> {
    func filter(f: T -> Bool) -> Observable<T>
    func merge<U>(merge: Observable<U>) -> Observable<(T,U)>
}
```

—
# Create an **Observable**

```swift
class Button {	
    let observable = Observable<Bool>(value: false)

    private var selected: Bool {
        didSet {
            guard oldValue != selected else { return }
            observable.update(value: selected)
        }	
    }
}
```

^
Creating a observable for i.e. a select button
"Create"-example first to remove magic

—
# Use **Observable**s
```swift
class VC: UIViewController {	
    let (button0, button1) = (Button(), Button())
    func viewDidLoad() {
       button0.observable
            .merge(button1.observable)).
            .map { ($0.peek() ?? false) && ($1.peek() ?? false) }
            .next { self.valid = $0 } }
    }
}
```

^
Listen to a two selectable buttons

—
# Extend **UIKit** :confused:
```swift
var SwitchHandle: UInt8 = 0
extension UISwitch {
    private(set) var valueObservable: Observable<Bool> {
        let observer: Observable<Bool>
        if let handle = objc_getAssociatedObject(self, &SwitchHandle) as? Observable<Bool> {
            observer = handle
        } else {
            observer = Observable()
            addTarget(self, action: #selector(UISwitch(_:)), forControlEvents: .ValueChanged)
            objc_setAssociatedObject(self, &SwitchHandle, observer, .OBJC_ASS…_RETAIN_NONATOMIC)
        }
        return observer
    }
    public func didChangeValue(sender: AnyObject) {
        valueObservable.update(on)
    }
}
```

—
# [fit] **Links**
* [The Best FRP Resources *by Javi Lorbada*](https://gist.github.com/JaviLorbada/4a7bd6129275ebefd5a6)
* [Interstellar *by Jens Ravens*](https://github.com/JensRavens/Interstellar)
* [Async Errors *by Crunchy Development*](http://alisoftware.github.io/swift/async/error/2016/02/06/async-errors/)
* [Blending Cultures *by Daniel Steinberg*](https://realm.io/news/tryswift-daniel-steinberg-blending-cultures)

—
# [fit] **Videos**
* [Functioning as a Functionalist *by Andy Matuschak*](http://kcy.me/22o45)
* [Controlling Complexity in Swift — or — Making Friends with Value Types *by Andy Matuschak*](http://kcy.me/22o45)
* [Functional Programming in Swift *by Chris Eidhof*](http://kcy.me/240su)
* [Protocol-Oriented Programming Swift *WWDC 2015*](http://kcy.me/24ef7)
* [Building Better Apps with Value Types in Swift *WWDC 2015*](http://kcy.me/24mic)

—
# [fit] **Books**
* [Functional Swift *by objc.io*](https://www.objc.io/books/functional-swift/)

—
# [fit] Learning 
# [fit] **F**unctional 
# [fit] **R**eactive 
# [fit] **P**rogramming

^
I’m new to public speaking, so please come over and give me some pointers on how to improve afterwards!

—

![right 100%](tobias.png)

[]()

# [fit] **Tobias Due Munk**
# [fit] [@**tobiasdm**](twitter.com/tobiasdm)
# [fit] [github.com/**duemunk**](github.com/duemunk)
# [fit] [**developmunk**.dk](developmunk.dk)

^
I promise, I’ll use this avatar forever


