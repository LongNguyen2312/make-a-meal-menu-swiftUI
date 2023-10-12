//
//  ProfilePopUp.swift
//  BepCuaMai
//
//  Created by Long Nguyễn văn on 06/10/2023.
//

import SwiftUI

struct ProfilePopUp: View {
    var body: some View {
        VStack {
            Text("Đây là ảnh của một người con gái xinh đẹp").font(.system(size: 30))
                .multilineTextAlignment(.center)
                .padding()
            Text("*Đừng tin").font(.system(size: 10))
            
            Image("avatar")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        }
    }
}

struct ProfilePopUp_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePopUp()
    }
}
