# ![](https://raw.githubusercontent.com/toggl/superday/master/teferi/Assets.xcassets/icSuperday.imageset/icSuperday.png) Superday's Swift Style Guide
##### AKA "The Dos And Don'ts Of This Codebase"

____________________

##### Classes use PascalCase
```swift
//Do
class Foo { }

//Don't 
class bar { }
```

##### Fields, methods, properties and variables use camelCase
```swift
//Do
func foo(bar: Int) -> Int
{
    let baz = bar + 1
    return baz
}

//Don't
func Foo(Bar: Int) -> Int
{
    let Baz = Bar + 1
    return Baz
}
```

##### Use spaces over tabs and indent using 4 spaces
```swift
//Do
func foo()
{
    //Something
}

//Don't (use tabs)
func bar()
{
	//Something
}

//Don't (use less than four spaces)
func baz()
{
  //Something
}
```

##### Open braces on a new line

```swift
//Do
func foo()
{
}

//Don't
func bar() {
}
```

##### Prefer `let` over `var` unless `var` is need

```swift
//Do
func foo(bar: Int) -> Int
{
    let maxVal = 10
    return min(maxVal, bar)
}

//Don't 
func foo(bar: Int) -> Int
{
    var maxVal = 10
    return min(maxVal, bar)
}
```

#####  Use `self.` whenever refering to a property/method of the class you're using

```swift
class Foo
{
    private let bar = 0
    
    //Do
    func baz() -> Int
    {
        return self.bar + 1
    }
    
    //Don't
    func qux() -> Int
    {
        return bar + 1
    }
}
``` 

##### Use the guard statement for early returning and property unwrapping

```swift

//Do
func boo(bar: String?)
{
    guard let unwrapped = bar else { return } 
    //Magic goes here
}

//Don't 

func boo(bar: String?)
{
    if bar != nil { return } 
    let unwrapped = bar!
    //Magic goes here
}
```

##### Prefer early returning over nesting

```swift
//Do
func foo(bar: Int)
{
    guard bar > 0 else { return }
    
    let someValue = self.calculateSomething(bar)
    
    guard someValue > 0 else { return }
    
    // Magic goes here
}

//Don't 
func foo(bar: Int)
{
    if bar > 0
    {
        let someValue = self.calculateSomething(bar)
        if someValue > 0
        {
            //Magic goes here
        }
    }
}
```

##### Use constraints (via .storyboard/.xib files or via [SnapKit](http://snapkit.io/)) and not hardcoded frames

```swift

//Do
func setupButton()
{
    let customView = MyCustomView()
    self.view.addSubview(customView)
    
    customView.snp.makeConstraints { make in make.edges.equalTo(self.view) }
}

//Don't
func setupButton()
{
    let customView = MyCustomView(frame: self.view.frame)
    self.view.addSubview(customView)
}

```
