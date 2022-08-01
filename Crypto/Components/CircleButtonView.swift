//
//  CircleButtonView.swift
//  Crypto
//
//  Created by Yurii on 21.07.2022.
//

import SwiftUI

struct CircleButtonView: View {
    let icon: String
    
    var body: some View {
        Image(systemName: icon)
            .font(.headline)
            .foregroundColor(Color.theme.accent)
            .frame(width: 50, height: 50)
            .background(Circle().foregroundColor(Color.theme.background))
            .shadow(color: Color.theme.accent.opacity(0.25), radius: 10)
            .padding()
    }
}

struct CircleButtonView_Previews: PreviewProvider {
    static var previews: some View {
        CircleButtonView(icon: "plus")
    }
}
