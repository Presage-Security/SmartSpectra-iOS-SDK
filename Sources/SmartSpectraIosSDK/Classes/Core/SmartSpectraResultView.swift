//
//  SmartSpectraResultView.swift
//
//
//  Created by Ashraful Islam on 8/13/24.
//

import Foundation
import SwiftUI

struct SmartSpectraResultView: View {
    var resultText: String

    var body: some View {
        HStack {
            Spacer()
            Text(resultText)
                .foregroundColor(.gray)
                .font(.system(size: 25, weight: .bold))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(red: 0.94, green: 0.34, blue: 0.36), lineWidth: 3)
        )
    }
    
    
}

#Preview {
    SmartSpectraResultView(resultText: "Test\nTest")
}
