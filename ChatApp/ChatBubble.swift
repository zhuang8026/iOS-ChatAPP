//
//  ChatBubble.swift
//  ChatApp
//
//  Created by 莊杰翰 on 2024/8/7.
//

import SwiftUI

// 聊天視窗
struct ChatBubble: View {
    var message: String
    var isSentByUser: Bool
    var time: String
    var status: Bool

    var body: some View {
        HStack {
            if !isSentByUser {
                // 機器人對話框（左邊）
                HStack(alignment: .bottom) {
                    Text(message)
                        .padding()
                        .background(status ?
                                    Color(red: 1.0, green: 108.0 / 255.0, blue: 108.0 / 255.0) :
                                    Color(red: 40/255, green: 180/255, blue: 179/255))
                        .cornerRadius(10)
                        .foregroundColor(.white) // 設置文字顏色為白色
                    Text(time)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.leading, 5)
                }
                Spacer()
            } else {
                Spacer()
                // 用戶對話框（右邊）
                HStack(alignment: .bottom) {
                    Text(time)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.trailing, 5)
                    Text(message)
                        .padding()
                        .background(.white)
                        .cornerRadius(10)
                        .foregroundColor(Color.PrimaryColor) // 設置文字顏色為白色
                    
                }
            }
        }
    }
}
