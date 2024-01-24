# CSList

**CSList** is a versatile component for SwiftUI that aims to help data-heavy apps in keeping their SwiftUI design system neat and native-like.
It is by no means a replacement for SwiftUI's `List`, more a helper for when you have to display lots of data in multiple different lists across your app, all with different customisation. 

# Usage

`CSList` and `CSListStyle` are made to resemble the native SwiftUI APIs as much as possible, so they're very easy to use and implement.

An example of code without the use of `CSList`.
```swift
struct MyView: View {
    let songs: [String] = [
        "To. X",
        "Melt Away",
        "Burn It Down",
        "Nightmare",
        "All For Nothing",
        "Fabulous"
    ]

    var body: some View {
        VStack(alignment: .leading) {
            LabeledContent("Artist", value: "TAEYEON")
            LabeledContent("Album", value: "To. X - The 5th Mini Album")
            List(songs, id: \.self) { song in
                Text(song)
            }
            .listStyle(.plain)
        }
        .padding()
    }
}
```

This is great and all, but as soon as you want to customise the way your `List` looks, you can't (unfortunately) just create your own `ListStyle` and pop that into the `.listStyle` modifier. So what do you do? Well you go and create your own custom list-like component with a `ForEach` and customise that to your needs. And that works wonders. Until you get to another screen where you need another list customised in a completely different way. Ok, you go and make a new custom list-like component, or you make a switch statement inside your already present component and you pass in a style in the init. Both ways work. But you can imagine how quickly in a big, data-heavy app you will end up with either 20 list-like components or 20 cases inside your switch statement. And if that all sounds perfectly fine to you, then read no further because `CSList` is not for you.

Now, for those that would like a more cohesive, SwiftUI-like way of doing things. Let's look at how `CSList` can help you. So to reiterate the code written above with the use of `CSList`, it will look something like this.

```swift
var body: some View {
    VStack(alignment: .leading) {
        LabeledContent("Artist", value: "TAEYEON")
        LabeledContent("Album", value: "To. X - The 5th Mini Album")
        CSList(songs, id: \.self) { song in
            Text(song)
        }
        .csListStyle(MyCustomListStyle())
    }
    .padding()
}
```

If you're anything like me and have already built SwiftUI design systems with the use of its Style APIs, this will feel right at home for you.

So let's talk about what this changes. Well, when you only have 1 or 2 different lists in your app, there's really no need to bring in `CSList`. However, for those of you with a need to display lots of data across your apps, you can see how now instead of creating 20 components you only need to create 20 styles for the same component. Arguably it's a similar amount of work, but I believe it to be so much better for keeping a cohesive and easy to maintain SwiftUI design system. Considering you probably already have dozens of button and label styles, `CSListStyle`s will fit right in.

# Installation

## Swift Package Manager
Add `https://github.com/danielcapra/CSList` to your project.

## Manual
Download and add [`CSList.swift`](./Sources/CSList/CSList.swift) to your project.

# API

## Creating a custom style
```swift
// Create a custom style by defining a struct that conforms to CSListStyle protocol
struct MyCustomStyle: CSListStyle {
    func makeBody(configuration: Configuration) -> some View {
        ScrollView { // CSList isn't automatically scrollable, so we need to define the ScrollView in each CSListStyle
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

var body: some View {
    CSList(/*...*/) {
        Text($0.name)
    }
    .csListStyle(.myCustomStyle)
}
```

## Differences between List & CSList

First of all, `CSList` is not meant to be a replacement for SwiftUI's `List`. It is meant for *displaying* collections of data, where as `List` can also be used for actionable menus. `CSList` also lacks the 'content' initialiser that `List` comes with, because of the limitations of SwiftUI's public APIs.

#### CSListExperimental
That being said, [CSListExperimental](https://github.com/danielcapra/CSListExperimental) (documentation not written yet) is an **experimental!** version of `CSList` that does provide the 'content' initialiser, alongside all the other initialisers. It uses `VariadicView` APIs which aren't documented and not *entirely* public. While I don't have first-hand experience in using `VariadicView` APIs in App Store accepted applications, I have heard of other people using them with no issues. As they aren't documented and publicly recognized by Apple, they could break or be removed at any time without a deprecation period or notice so I don't recommend using `CSListExperimental` in production apps unless you're completely sure of what you're doing.

#### Section
Using `Section` in a `List` will have its own special behaviour which cannot be recreated with `CSList` because of the limiting APIs. Instead, `CSList` has `header` & `footer` initialisers to replace the use of `Section`.

```swift
var body: some View {
    List(/*...*/) {
        // ...
        Section {
            // ...
        } header: { 
            // ...
        } footer: {
            // ...
        }
    }
}
```
To recreate this behaviour we're going to NOT include ScrollView in our CSListStyle and instead use multiple CSList initialisers to sort of resemble the use of Sections. You might have to break down your data into chunks to accomodate to this behaviour.

```swift
var body: some View {
    ScrollView { // Define a ScrollView at the top level
        // First section
        CSList(/*...*/) {

        } header: {
            // ...
        } footer: {
            // ...
        }
        // Second section
        CSList(/*...*/) {

        } header: {
            // ...
        }
        // And so on...
    }
}
```