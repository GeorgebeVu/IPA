//
//  RootView.swift
//  Test
//
//  Created by George Vu on 10/8/24.
//

import SwiftUI

struct RootView: View {
    @State private var isLoggedIn = false

    var body: some View {
        if isLoggedIn {
            MainView(isLoggedIn: $isLoggedIn)  
        } else {
            LoginView(isLoggedIn: $isLoggedIn)
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
