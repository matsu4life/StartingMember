//
//  ContentView.swift
//  StartingMember
//
//  Created by 松本貴幸 on 2026/06/13.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        SplashView()
    }
}

#Preview {
    ContentView()
        .environmentObject(AppStore())
}
