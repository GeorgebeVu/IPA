//
//  HamburgerMenuView.swift
//  Test
//
//  Created by George Vu on 10/8/24.
//

import SwiftUI

struct HamburgerMenuView: View {
    
    @Binding var showSettings: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.white)
                Text("User")
                    .foregroundColor(.white)
                    .font(.title3)
                Spacer()
                
                Button(action: {
                    showSettings.toggle()
                }) {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            .padding(.top, 60)
            

            Spacer()
        }
        .frame(maxWidth: 250)
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
    }
}

struct HamburgerMenuView_Previews: PreviewProvider {
    static var previews: some View {
        HamburgerMenuView(showSettings: .constant(false))
    }
}
