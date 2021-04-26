//
//  FeedsScreen.swift
//  RSS App
//
//  Created by Nicolas Polomack on 16/04/2021.
//

import SwiftUI

struct FeedsScreen: View {
    @State private var feeds

    @EnvironmentObject private var state: AppState

    var items: [String] = [
        
    ]

    var body: some View {
        NavigationView {
            if items.isEmpty {
                List {
                    ForEach(["No feeds"], id: \.self) { item in
                        Text(item).foregroundColor(.secondary).frame(maxWidth: .infinity)
                    }
                }.navigationTitle("Feeds")
            } else {
                List(items, id: \.self) { item in
                    Text(item)
                }.navigationTitle("Feeds")
            }
        }
    }
}

struct FeedsScreen_Previews: PreviewProvider {
    static var previews: some View {
        FeedsScreen()
    }
}
