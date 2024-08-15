//
//  Models.swift
//  ChatApp
//
//  Created by 莊杰翰 on 2024/8/7.
//

import SwiftUI

struct Message: Identifiable {
    var id = UUID() // Unique identifier
    var content: String
    var isSentByUser: Bool
    var time: String
    var date: String
    var status: Bool = false
}

extension Color {
    static let PrimaryColor = Color(red: 50.0 / 255.0, green: 53.0 / 255.0, blue: 98.0 / 255.0) // 深藍色 全域文字顏色
    static let ChatColor = Color(red: 40/255, green: 180/255, blue: 179/255)  // 綠松石色 聊天視窗
    static let GradientStart = Color(red: 9.0 / 255.0, green: 225.0 / 255.0, blue: 165.0 / 255.0) // 漸變色 深綠
    static let GradientEnd = Color(red: 40.0 / 255.0, green: 180.0 / 255.0, blue: 179.0 / 255.0) // 漸變色 淺綠
    static let background = Color(red: 238.0 / 255.0, green: 241.0 / 255.0, blue: 251.0 / 255.0) // 灰色
}

struct ButtonData {
    let name: String
    let value: String
    let prompt: String
}

