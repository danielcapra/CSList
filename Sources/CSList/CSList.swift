import SwiftUI

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

    // TODO: Add Documentation
    // No Header or Footer
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

    // TODO: Add documentation
    // No Header or Footer
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

    // TODO: Add documentation
    // No Header or Footer
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
