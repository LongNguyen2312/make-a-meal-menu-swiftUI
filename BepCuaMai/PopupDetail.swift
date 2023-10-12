//
//  PopupDetail.swift
//  BepCuaMai
//
//  Created by Long Nguyễn văn on 12/10/2023.
//

import SwiftUI

struct PopupDetail: View {
    @Binding var content: String
    
    var body: some View {
        VStack {
            Text(content).font(.title).foregroundColor(Color(hue: 0.035, saturation: 0.914, brightness: 0.949)).frame(maxWidth: .infinity).foregroundColor(.orange).accentColor(.orange).padding().padding(.top, 20)
            Spacer()
        }
        .padding()
    }
}


