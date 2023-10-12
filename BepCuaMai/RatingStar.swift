//
//  RatingStar.swift
//  BepCuaMai
//
//  Created by Long Nguyễn văn on 12/10/2023.
//

import SwiftUI

struct RatingStar: View {
    let rating: Int
    let callback: (Int) -> Void
    
    var body: some View {
        HStack {
            ForEach(1 ..< 6) { star in
                Button(action: {
                    callback(star)
                }) {
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .font(.title)
                        .foregroundColor(star <= rating ? .yellow : .white)
                }
            }
        }
    }
}
