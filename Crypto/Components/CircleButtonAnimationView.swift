//
//  CircleButtonAnimationView.swift
//  Crypto
//
//  Created by Yurii on 21.07.2022.
//

import SwiftUI

struct CircleButtonAnimationView: View {
    @Binding var isAnimating: Bool
    
    var body: some View {
        Circle()
            .stroke(lineWidth: 5.0)
            .scale(isAnimating ? 1.0 : 0.0)
            .opacity(isAnimating ? 0.0 : 1.0)
            .animation(isAnimating ? Animation.easeOut(duration: 1.0) : nil, value: UUID())
    }
}

struct CircleButtonAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        CircleButtonAnimationView(isAnimating: .constant(false))
    }
}
