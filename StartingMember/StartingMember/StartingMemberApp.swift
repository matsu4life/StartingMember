//
//  StartingMemberApp.swift
//  StartingMember
//
//  Created by 松本貴幸 on 2026/06/13.
//

import SwiftUI

@main
struct StartingMemberApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
