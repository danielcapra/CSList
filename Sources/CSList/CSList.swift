import SwiftUI

/**
    A container that presents rows of data arranged in a single column, similar to `List`, but with the option to create custom styles.

    Create lists dynamically from an underlying collection of data. The following example shows how to create a simple list from an array of an Ocean type which conforms to Identifiable:
 ```swift
    struct Ocean: Identifiable {
        let name: String
        let id = UUID()
    }

    private var oceans = [
        Ocean(name: "Pacific"),
        Ocean(name: "Atlantic"),
        Ocean(name: "Indian"),
        Ocean(name: "Southern"),
        Ocean(name: "Arctic")
    ]

    var body: some View {
        CSList(oceans) {
            Text($0.name)
        }
    }
 ```

    **Creating a custom style**
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
    **Using the custom style**
 ```swift
    var body: some View {
        CSList(oceans) {
            Text($0.name)
        }
        .csListStyle(MyCustomStyle()) // This will affect all child views
    }
 ```

    **Dot notation**
 ```swift
    extension CSListStyle where Self == MyCustomStyle {
        static var `myCustomStyle`: Self { MyCustomStyle() }
    }

    // Now use like so
    var body: some View {
        CSList(oceans) {
            Text($0.name)
        }
        .csListStyle(.myCustomStyle)
    }
 ```

    - Author: Daniel Capra
 */
public struct CSList<Data, RowContent, Header, Footer> {
    @Environment(\.csListStyle) private var style

    private let configuration: Configuration

    typealias Item = Configuration.Item

    typealias Configuration = CSListConfiguration
}

extension CSList: View {
    @MainActor public var body: some View { AnyView(style.makeBody(configuration: configuration)) }
}

extension CSList where Data : RandomAccessCollection, Data.Element : Identifiable, RowContent : View, Header : View, Footer : View {

    // No Header or Footer
    /**
     Creates a list that computes its rows on demand from an underlying collection of identifiable data, without a header or footer.

     - Parameters:
        - data: A RandomAccessCollection of Identifiable Elements
        - rowContent: A ViewBuilder closure that builds each element's row content

     ```swift
    struct Person: Identifiable {
        let name: String
        let id = UUID()
    }

    let people: [Person] = [
        Person(name: "Rachel"),
        Person(name: "Mike"),
        Person(name: "Harvey"),
        Person(name: "Donna")
    ]

    var body: some View {
        CSList(people) {
            Text($0.name)
        }
    }
     ```

     - Author: Daniel Capra
     */
    @MainActor public init(
        _ data: Data,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
    ) where Header == EmptyView, Footer == EmptyView {
        let items = data.map({ Item.init($0) })
        let buildMethod: (Item) -> any View = { item in
            rowContent(item.value as! Data.Element)
        }

        self.configuration = .init(
            data: items,
            buildMethod: buildMethod,
            header: EmptyView(),
            footer: EmptyView()
        )
    }

    // Only Header
    /**
     Creates a list that computes its rows on demand from an underlying collection of identifiable data, with a header, but no footer.

     - Parameters:
        - data: A RandomAccessCollection of Identifiable Elements
        - rowContent: A ViewBuilder closure that builds each element's row content
        - header: A ViewBuilder closure that builds the header view

     ```swift
    struct Person: Identifiable {
        let name: String
        let id = UUID()
    }

    let people: [Person] = [
        Person(name: "Rachel"),
        Person(name: "Mike"),
        Person(name: "Harvey"),
        Person(name: "Donna")
    ]

    var body: some View {
        CSList(people) {
            Text($0.name)
        } header: {
            Text("Suits characters")
                .font(.headline)
        }
    }
     ```

     - Author: Daniel Capra
     */
    @MainActor public init(
        _ data: Data,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent,
        @ViewBuilder header: () -> Header
    ) where Footer == EmptyView {
        let items = data.map({ Item.init($0) })
        let buildMethod: (Item) -> any View = { item in
            rowContent(item.value as! Data.Element)
        }

        self.configuration = .init(
            data: items,
            buildMethod: buildMethod,
            header: header(),
            footer: EmptyView()
        )
    }

    // Only Footer
    /**
     Creates a list that computes its rows on demand from an underlying collection of identifiable data, with a footer, but no header.

     - Parameters:
        - data: A RandomAccessCollection of Identifiable Elements
        - rowContent: A ViewBuilder closure that builds each element's row content
        - footer: A ViewBuilder closure that builds the footer view

     ```swift
    struct Person: Identifiable {
        let name: String
        let id = UUID()
    }

    let people: [Person] = [
        Person(name: "Rachel"),
        Person(name: "Mike"),
        Person(name: "Harvey"),
        Person(name: "Donna")
    ]

    var body: some View {
        CSList(people) {
            Text($0.name)
        } footer: {
            Text("Suits is an American legal drama television series created and written by Aaron Korsh.")
                .font(.caption)
        }
    }
     ```

     - Author: Daniel Capra
     */
    @MainActor public init(
        _ data: Data,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent,
        @ViewBuilder footer: () -> Footer
    ) where Header == EmptyView {
        let items = data.map({ Item.init($0) })
        let buildMethod: (Item) -> any View = { item in
            rowContent(item.value as! Data.Element)
        }

        self.configuration = .init(
            data: items,
            buildMethod: buildMethod,
            header: EmptyView(),
            footer: footer()
        )
    }

    // Both Header & Footer
    /**
         Creates a list that computes its rows on demand from an underlying collection of identifiable data, with a header and a footer.

         - Parameters:
            - data: A RandomAccessCollection of Identifiable Elements
            - rowContent: A ViewBuilder closure that builds each element's row content
            - header: A ViewBuilder closure that builds the header view
            - footer: A ViewBuilder closure that builds the footer view

         ```swift
        struct Person: Identifiable {
            let name: String
            let id = UUID()
        }

        let people: [Person] = [
            Person(name: "Rachel"),
            Person(name: "Mike"),
            Person(name: "Harvey"),
            Person(name: "Donna")
        ]

        var body: some View {
            CSList(people) {
                Text($0.name)
            } header: {
                Text("Suits characters")
                    .font(.headline)
            } footer: {
                Text("Suits is an American legal drama television series created and written by Aaron Korsh.")
                    .font(.caption)
            }
        }
         ```

         - Author: Daniel Capra
    */
    @MainActor public init(
        _ data: Data,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent,
        @ViewBuilder header: () -> Header,
        @ViewBuilder footer: () -> Footer
    ) {
        let items = data.map({ Item.init($0) })
        let buildMethod: (Item) -> any View = { item in
            rowContent(item.value as! Data.Element)
        }

        self.configuration = .init(
            data: items,
            buildMethod: buildMethod,
            header: header(),
            footer: footer()
        )
    }
}

extension CSList where Data : RandomAccessCollection, RowContent : View, Header: View, Footer : View {

    // No Header or Footer
    /**
     Creates a list that identifies its rows based on a key path to the identifier of the underlying data, without a header or footer.

     - Parameters:
        - data: A RandomAccessCollection
        - id: A key path to the identifier of the data
        - rowContent: A ViewBuilder closure that builds each element's row content

     ```swift
     struct Album {
         let artist: String
         let songs: [String]
     }

     let album = Album(artist: "TAEYEON", songs: [
         "To. X",
         "Melt Away",
         "Burn It Down",
         "Nightmare",
         "All For Nothing",
         "Fabulous"
     ])

    var body: some View {
        CSList(album.songs, id: \.self) {
            Text($0)
        }
    }
     ```

     - Author: Daniel Capra
     */
    @MainActor public init<ID>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
    ) where ID : Hashable, Header == EmptyView, Footer == EmptyView {
        let items = data.map({ Item.init($0, id: $0[keyPath: id]) })
        let buildMethod: (Item) -> any View = { item in
            rowContent(item.value as! Data.Element)
        }

        self.configuration = .init(
            data: items,
            buildMethod: buildMethod,
            header: EmptyView(),
            footer: EmptyView()
        )
    }

    // Only Header
    /**
     Creates a list that identifies its rows based on a key path to the identifier of the underlying data, with a header, but no footer.

     - Parameters:
        - data: A RandomAccessCollection
        - id: A key path to the identifier of the data
        - rowContent: A ViewBuilder closure that builds each element's row content
        - header: A ViewBuilder closure that builds the header view

     ```swift
    struct Album {
        let artist: String
        let songs: [String]
    }

     let album = Album(artist: "TAEYEON", songs: [
         "To. X",
         "Melt Away",
         "Burn It Down",
         "Nightmare",
         "All For Nothing",
         "Fabulous"
     ])

    var body: some View {
        CSList(album.songs, id: \.self) {
            Text($0)
        } header: {
            Text(album.artist)
                .font(.headline)
        }
    }
     ```

     - Author: Daniel Capra
     */
    @MainActor public init<ID>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent,
        @ViewBuilder header: () -> Header
    ) where ID : Hashable, Footer == EmptyView {
        let items = data.map({ Item.init($0, id: $0[keyPath: id]) })
        let buildMethod: (Item) -> any View = { item in
            rowContent(item.value as! Data.Element)
        }

        self.configuration = .init(
            data: items,
            buildMethod: buildMethod,
            header: header(),
            footer: EmptyView()
        )
    }

    // Only Footer
    /**
     Creates a list that identifies its rows based on a key path to the identifier of the underlying data, with a footer, but no header.

     - Parameters:
        - data: A RandomAccessCollection
        - id: A key path to the identifier of the data
        - rowContent: A ViewBuilder closure that builds each element's row content
        - footer: A ViewBuilder closure that builds the footer view

     ```swift
    struct Album {
        let artist: String
        let songs: [String]
    }

     let album = Album(artist: "TAEYEON", songs: [
         "To. X",
         "Melt Away",
         "Burn It Down",
         "Nightmare",
         "All For Nothing",
         "Fabulous"
     ])

    var body: some View {
        CSList(album.songs, id: \.self) {
            Text($0)
        } footer: {
            Text("Kim Tae-yeon, known mononymously as Taeyeon, is a South Korean singer. She debuted as a member of girl group Girls' Generation in August 2007, which went on to become one of the best-selling artists in South Korea and one of the most popular K-pop groups worldwide.")
                .font(.caption)
        }
    }
     ```

     - Author: Daniel Capra
     */
    @MainActor public init<ID>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent,
        @ViewBuilder footer: () -> Footer
    ) where ID : Hashable, Header == EmptyView {
        let items = data.map({ Item.init($0, id: $0[keyPath: id]) })
        let buildMethod: (Item) -> any View = { item in
            rowContent(item.value as! Data.Element)
        }

        self.configuration = .init(
            data: items,
            buildMethod: buildMethod,
            header: EmptyView(),
            footer: footer()
        )
    }

    // Both Header & Footer
    /**
     Creates a list that identifies its rows based on a key path to the identifier of the underlying data, with both a header and a footer.

     - Parameters:
        - data: A RandomAccessCollection
        - id: A key path to the identifier of the data
        - rowContent: A ViewBuilder closure that builds each element's row content
        - header: A ViewBuilder closure that builds the header view
        - footer: A ViewBuilder closure that builds the footer view

     ```swift
    struct Album {
        let artist: String
        let songs: [String]
    }

     let album = Album(artist: "TAEYEON", songs: [
         "To. X",
         "Melt Away",
         "Burn It Down",
         "Nightmare",
         "All For Nothing",
         "Fabulous"
     ])

    var body: some View {
        CSList(album.songs, id: \.self) {
            Text($0)
        } header: {
            Text(album.artist)
                .font(.headline)
        } footer: {
            Text("Kim Tae-yeon, known mononymously as Taeyeon, is a South Korean singer. She debuted as a member of girl group Girls' Generation in August 2007, which went on to become one of the best-selling artists in South Korea and one of the most popular K-pop groups worldwide.")
                .font(.caption)
        }
    }
     ```

     - Author: Daniel Capra
     */
    @MainActor public init<ID>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent,
        @ViewBuilder header: () -> Header,
        @ViewBuilder footer: () -> Footer
    ) where ID : Hashable {
        let items = data.map({ Item.init($0, id: $0[keyPath: id]) })
        let buildMethod: (Item) -> any View = { item in
            rowContent(item.value as! Data.Element)
        }

        self.configuration = .init(
            data: items,
            buildMethod: buildMethod,
            header: header(),
            footer: footer()
        )
    }

}

extension CSList where Data == Range<Int>, RowContent : View, Header : View, Footer : View {

    // No Header or Footer
    /**
     Creates a list that identifies its views on demand over a constant range, with no header or footer.

     - Parameters:
        - data: A constant range of integers
        - rowContent: A ViewBuilder closure that builds each row content

     ```swift
     var body: some View {
         CSList(0..<3) { number in
             Text(number, format: .number)
         }
     }
     ```

     - Author: Daniel Capra
     */
    @MainActor public init(
        _ data: Data,
        @ViewBuilder rowContent: @escaping (Int) -> RowContent
    ) where Header == EmptyView, Footer == EmptyView {
        let items = data.map({ Item.init($0, id: $0) })
        let buildMethod: (Item) -> any View = { item in
            rowContent(item.value as! Int)
        }

        self.configuration = .init(
            data: items,
            buildMethod: buildMethod,
            header: EmptyView(),
            footer: EmptyView()
        )
    }

    // Only Header
    /**
     Creates a list that identifies its views on demand over a constant range, with a header, but no footer.

     - Parameters:
        - data: A constant range of integers
        - rowContent: A ViewBuilder closure that builds each row content
        - header: A ViewBuilder closure that builds the header view

     ```swift
     var body: some View {
         CSList(0..<3) { number in
             Text(number, format: .number)
         } header: {
             Text("Some numbers")
                .font(.headline)
         }
     }
     ```

     - Author: Daniel Capra
     */
    @MainActor public init(
        _ data: Data,
        @ViewBuilder rowContent: @escaping (Int) -> RowContent,
        @ViewBuilder header: () -> Header
    ) where Footer == EmptyView {
        let items = data.map({ Item.init($0, id: $0) })
        let buildMethod: (Item) -> any View = { item in
            rowContent(item.value as! Int)
        }

        self.configuration = .init(
            data: items,
            buildMethod: buildMethod,
            header: header(),
            footer: EmptyView()
        )
    }

    // Only Footer
    /**
     Creates a list that identifies its views on demand over a constant range, with a footer, but no header.

     - Parameters:
        - data: A constant range of integers
        - rowContent: A ViewBuilder closure that builds each row content
        - footer: A ViewBuilder closure that builds the footer view

     ```swift
     var body: some View {
         CSList(0..<3) { number in
             Text(number, format: .number)
         } footer: {
             Text("An integer is a whole number that can be positive, negative, or zero.")
                .font(.caption)
         }
     }
     ```

     - Author: Daniel Capra
     */
    @MainActor public init(
        _ data: Data,
        @ViewBuilder rowContent: @escaping (Int) -> RowContent,
        @ViewBuilder footer: () -> Footer
    ) where Header == EmptyView {
        let items = data.map({ Item.init($0, id: $0) })
        let buildMethod: (Item) -> any View = { item in
            rowContent(item.value as! Int)
        }

        self.configuration = .init(
            data: items,
            buildMethod: buildMethod,
            header: EmptyView(),
            footer: footer()
        )
    }

    // Both Header & Footer
    /**
     Creates a list that identifies its views on demand over a constant range, with both a header and a footer.

     - Parameters:
        - data: A constant range of integers
        - rowContent: A ViewBuilder closure that builds each row content
        - header: A ViewBuilder closure that builds the header view
        - footer: A ViewBuilder closure that builds the footer view

     ```swift
     var body: some View {
         CSList(0..<3) { number in
             Text(number, format: .number)
         } header: {
             Text("Some numbers")
                .font(.headline)
         } footer: {
             Text("An integer is a whole number that can be positive, negative, or zero.")
                .font(.caption)
         }
     }
     ```

     - Author: Daniel Capra
     */
    @MainActor public init(
        _ data: Data,
        @ViewBuilder rowContent: @escaping (Int) -> RowContent,
        @ViewBuilder header: () -> Header,
        @ViewBuilder footer: () -> Footer
    ) {
        let items = data.map({ Item.init($0, id: $0) })
        let buildMethod: (Item) -> any View = { item in
            rowContent(item.value as! Int)
        }

        self.configuration = .init(
            data: items,
            buildMethod: buildMethod,
            header: header(),
            footer: footer()
        )
    }
}

// MARK: - CONFIGURATION
public struct CSListConfiguration {
    public struct Item: Identifiable, Equatable {
        public static func == (lhs: CSListConfiguration.Item, rhs: CSListConfiguration.Item) -> Bool {
            return lhs.id == rhs.id
        }

        public let id: AnyHashable
        let value: Any

        init<T>(_ item: T) where T : Identifiable {
            self.value = item
            self.id = AnyHashable(item.id)
        }

        init<ID>(_ item: Any, id: ID) where ID: Hashable {
            self.value = item
            self.id = AnyHashable(id)
        }
    }

    struct ItemLabel: View {
        let label: AnyView

        init(item: Item, buildMethod: (Item) -> any View) {
            self.label = AnyView(buildMethod(item))
        }

        @MainActor public var body: some View { label }
    }

    init<Data: RandomAccessCollection>(
        data: Data,
        buildMethod: @escaping (Data.Element) -> any View,
        header: some View,
        footer: some View
    ) where Data.Element == Item {
        self.data = AnyRandomAccessCollection(data)
        self.buildMethod = buildMethod
        self.header = AnyView(header)
        self.footer = AnyView(footer)
    }

    private let buildMethod: (Item) -> any View

    public let data: AnyRandomAccessCollection<Item>
    public let header: AnyView
    public let footer: AnyView

    @ViewBuilder
    public func label(for item: Item) -> some View {
        ItemLabel(item: item, buildMethod: buildMethod)
    }
}

// MARK: - Protocol
public protocol CSListStyle {
    associatedtype Body: View

    @ViewBuilder func makeBody(configuration: Configuration) -> Body

    typealias Configuration = CSListConfiguration
}

// MARK: - Default Style
public struct CSListDefaultStyle: CSListStyle {
    public func makeBody(configuration: Configuration) -> some View {
        CSListDefaultView(configuration: configuration)
    }
}

private extension CSListDefaultStyle {
    struct CSListDefaultView: View {
        @Environment(\.colorScheme) private var colorScheme
        private let configuration: Configuration

        init(configuration: Configuration) {
            self.configuration = configuration
        }

        // Dark mode
        private let darkBgColor = Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 1.0)
        private let darkSurfaceColor = Color(red: 0.11, green: 0.11, blue: 0.118, opacity: 1.0)
        private let darkHeaderColor = Color(red: 0.641, green: 0.641, blue: 0.667, opacity: 1.0)
        private let darkTextColor = Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 1.0)

        // Light mode
        private let lightBgColor = Color(red: 0.949, green: 0.949, blue: 0.971, opacity: 1.0)
        private let lightSurfaceColor = Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 1.0)
        private let lightHeaderColor = Color(red: 0.437, green: 0.437, blue: 0.459, opacity: 1.0)
        private let lightTextColor = Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 1.0)

        // Colors
        private var bgColor: Color { colorScheme == .light ? lightBgColor : darkBgColor }
        private var surfaceColor: Color { colorScheme == .light ? lightSurfaceColor : darkSurfaceColor }
        private var headerColor: Color { colorScheme == .light ? lightHeaderColor : darkHeaderColor }
        private var textColor: Color { colorScheme == .light ? lightTextColor : darkTextColor }

        var body: some View {
            ZStack {
                background()
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        configuration.header
                            .font(.footnote)
                            .padding(.horizontal)
                            .color(headerColor)
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(configuration.data) { item in
                                configuration.label(for: item)
                                    .color(textColor)

                                if item != configuration.data.last {
                                    Divider()
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(surfaceColor)
                        )
                        configuration.footer
                            .font(.footnote)
                            .padding(.horizontal)
                            .color(headerColor)
                    }
                    .padding(.horizontal)
                }
            }

        }

        @ViewBuilder
        private func background() -> some View {
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *) {
                bgColor
                    .ignoresSafeArea()
            } else {
                bgColor
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

// MARK: ForegroundColor & ForegroundStyle View extension
fileprivate extension View {
    func color(_ color: Color) -> some View {
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
            return foregroundStyle(color)
        } else {
            return foregroundColor(color)
        }
    }
}

// MARK: Dot notation for default list style
public extension CSListStyle where Self == CSListDefaultStyle {
    static var `default`: Self { CSListDefaultStyle() }
}


// MARK: - View Modifier
public struct CSListStyleModifier: ViewModifier {
    let style: any CSListStyle

    init(style: some CSListStyle) {
        self.style = style
    }

    public func body(content: Content) -> some View {
        content
            .environment(\.csListStyle, style)
    }
}

public extension View {
    func csListStyle(_ style: some CSListStyle) -> some View {
        modifier(CSListStyleModifier(style: style))
    }
}

// MARK: - Environment
public struct CSListStyleKey: EnvironmentKey {
    public static var defaultValue: any CSListStyle = CSListDefaultStyle()
}

public extension EnvironmentValues {
    var csListStyle: any CSListStyle {
        get { self[CSListStyleKey.self] }
        set { self[CSListStyleKey.self] = newValue }
    }
}
