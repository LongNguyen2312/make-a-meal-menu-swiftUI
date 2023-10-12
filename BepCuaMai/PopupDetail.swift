//
//  PopupDetail.swift
//  BepCuaMai
//
//  Created by Long Nguyễn văn on 12/10/2023.
//

import SwiftUI

struct PopupDetail: View {
    let content: String
    
    var body: some View {
        VStack {
            Text(content)
            Button("Ô sờ kê") {
                // Đóng popup detail
            }
        }
        .padding()
    }
}

struct PopupDetail_Previews: PreviewProvider {
    static var previews: some View {
        PopupDetail(content: "")
    }
}
