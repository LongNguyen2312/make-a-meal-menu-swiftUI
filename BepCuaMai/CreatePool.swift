//
//  CreatePool.swift
//  BepCuaMai
//
//  Created by Long Nguyễn văn on 06/10/2023.
//

import SwiftUI

struct CreatePool: View {
    @Binding var result: String
    
    var body: some View {
        VStack {
            TextField("", text: $result , prompt: Text("Enter your menu...").foregroundColor(Color(red: 0.922, green: 0.756, blue: 0.712)), axis: .vertical).font(.system(size: 25)).frame(maxWidth: .infinity).foregroundColor(.orange).accentColor(.orange).padding().padding(.top, 20)
            Spacer()
        }
    }
}

