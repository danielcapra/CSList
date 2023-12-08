//
//  ContentView.swift
//  CSListDemo
//
//  Created by Daniel Capra on 08/12/2023.
//

import CSList
import SwiftUI

struct Item: Identifiable {
    let id = UUID()

    let name: String
    let data: Int
}

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
                // The provided header in CSList init
                // If no header was provided this will be an emptyview
                configuration.footer
                    .font(.caption)
                    .padding(.leading)
            }
        }
    }
}

// That sweet sweet dot notation
extension CSListStyle where Self == MyCustomStyle {
    static var custom: Self { MyCustomStyle() }
}

struct ContentView: View {
    let items: [Item] = [
        .init(name: "First", data: 1),
        .init(name: "Second", data: 2),
        .init(name: "Third", data: 3),
        .init(name: "Fourth", data: 4),
        .init(name: "Fifth", data: 5),
    ]

    var body: some View {
        NavigationView {
            CSList(items) { item in
                // build your label for each item
                // same as with List / ForEach
                HStack {
                    Text(item.name)
                    Spacer()
                    Text("\(item.data)")
                }
            } header: {
                Text("This is a header.")
            } footer: {
                Text("And you guessed it, this is a footer.")
            }
            .padding(.horizontal)
            // use your custom style
            // this modifier will affect all child views
            .csListStyle(.custom)
            .navigationTitle("CSList Demo")
        }
    }
}

#Preview {
    ContentView()
}
