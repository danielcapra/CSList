# CSList

**CSList** stands as a versatile component for SwiftUI, bringing the possibility of customising lists through the Style APIs. 

# The Problem

If you're anything like me, you enjoy building SwiftUI design systems through the use of Style APIs. So this code should look very natural to you:

```swift
var body: some View {
    GroupBox {
        Button("Click Me") { /*...*/ }
            .buttonStyle(.myCustomButtonStyle)
        Label("I am a label", systemImage: "placeholdertext.fill")
            .labelStyle(.myCustomLabelStyle)
    }
    .groupBoxStyle(.myCustomGroupBoxStyle)
}
```

But then picture this: you're about to start making a custom list in your SwiftUI app. You're all like, "that's easy enough, I'll just make a custom ListStyle to fit the rest of my design system." But then, out of the blue, you hit a wall – turns out, making custom ListStyles isn't actually possible. Talk about a disappointment.

So now your code has to look like this:

```swift
struct MyCustomList: View {
    let items: [/*...*/]

    var body: some View {
        ForEach(items) { item in
            //...
       }
    }
}

// ...

var body: some View {
    ScrollView {
        Label("I am a label", systemImage: "placeholdertext.fill")
            .labelStyle(.myCustomLabelStyle)
        MyCustomList(items: [/*...*/])
        Button("Click Me") { /*...*/ }
            .buttonStyle(.myCustomButtonStyle)
    }
}
```

While that's totally fine, here's what ends up happening when you have multiple styles of your list across your app:

```swift
var body: some View {
    ScrollView {
        MyCustomListOne(/*...*/)
        MyCustomListTwo(/*...*/)
        MyCustomListThree(/*...*/)
    }
}

// Or

var body: some View {
    ScrollView {
        MyCustomList(style: .one, /*...*/)
        MyCustomList(style: .two, /*...*/)
        MyCustomList(style: .three, /*...*/)
    }
}
```

Both work. And I've done that multiple times in my projects. But creating multiple components for the same concept just with different customisation, or having a long switch statement in my 'CustomList' component doesn't feel very SwiftUI-ey to me.

So one day, I hit my limit and decided to investigate if it's truly impossible to create custom ListStyles. That's when the idea for **CSList** was born.

# The Solution

After delving into it for hours, I've come to the same conclusion that Apple keeps ListStyle creation APIs private (reasons unknown – if anyone's got the inside scoop, do spill!). However, we can still craft a custom component that switches up its style using a style modifier. So putting that to use, we create a custom List component with a ForEach, as usual, except this time we make it accept a custom ListStyle object through a modifier to customise it to our needs. And that's all that **CSList** is basically.

# API

## Creating a custom style
```swift
// Create a custom style by defining a struct that conforms to CSListStyle protocol
struct MyCustomStyle: CSListStyle {
    func makeBody(configuration: Configuration) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                // The provided header in CSList init
                // If no header was provided this will be an emptyview
                configuration.header
                    .font(.headline)
                    .padding(.leading)
                VStack(spacing: 8) {
                    // loop over the input data defined in CSList init
                    ForEach(configuration.data) { item in
                        // the label defined in CSList init
                        configuration.label(for: item)
                        
                        // Divider between items
                        if item.id != configuration.data.last?.id {
                            Divider()
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.green)
                        .opacity(0.8)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.foreground, lineWidth: 2)
                )
                // The provided footer in CSList init
                // If no header was provided this will be an emptyview
                configuration.footer
                    .font(.caption)
                    .padding(.leading)
            }
        }
    }
}
```

## Usage in Views
```swift
var body: some View {
    CSList(/*...*/) {
        Text($0.name)
    }
    .csListStyle(MyCustomStyle())
}
```

### That sweet sweet dot notation
```swift
extension CSListStyle where Self == MyCustomStyle {
    static var myCustomStyle: Self { MyCustomStyle() }
}

// Now use like so
var body: some View {
    CSList(/*...*/) {
        Text($0.name)
    }
    .csListStyle(.myCustomStyle)
}
```

## Differences between List & CSList
