//
//  ChatLoading.swift
//  ChatApp
//
//  Created by 莊杰翰 on 2024/8/7.
//

import SwiftUI

// 加載動畫視窗
struct ChatLoading: View {
    @State private var isAnimating = false
    var bgColor: Color = Color(red: 40/255, green: 180/255, blue: 179/255) // 默認為透明色
                                     // ex: Color(red: 40/255, green: 180/255, blue: 179/255)
                                     // ex: Color.clear

    var body: some View {
        HStack(spacing: 15) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.white)
                    .frame(width: 10, height: 10)
                    .opacity(self.isAnimating ? 0.3 : 1)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                            .delay(0.2 * Double(index)), value: isAnimating
                    )
            }
        }
        .frame(width: 100, height: 40)
        .background(bgColor) // 默認透明
        .cornerRadius(10)
        .padding(.leading, 10)
        .onAppear {
            self.isAnimating = true
        }
    }
}
