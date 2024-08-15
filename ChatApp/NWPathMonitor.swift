import Network
import UIKit

struct NetworkMonitor {
    private var monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private var wasDisconnected: Bool = false // 網路正常狀態
    
    // 初始化時啟動監控
    init() {
        monitor = NWPathMonitor()
        startMonitoring()
    }

    // 開始監控網絡狀態
    mutating func startMonitoring() {
        monitor.pathUpdateHandler = { [self] path in
            var networkMonitor = self
            print("監控網絡狀況:\(path), 狀態：\(path.status)")
            if path.status == .unsatisfied {
                // networkMonitor
                if !networkMonitor.wasDisconnected {
                    networkMonitor.wasDisconnected = true  // 網路已經斷線
                    
                    // [提示窗] 在主線程顯示
                    DispatchQueue.main.async {
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                            if let topViewController = windowScene.windows.first?.rootViewController {
                                let alert = UIAlertController(title: "網路狀態", message: "網絡訊號不穩，請檢查網路", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "確定", style: .default))
                                topViewController.present(alert, animated: true, completion: nil)
                            }
                        }
                    }

                }
            } else {
                // 處理網絡重新連接
                if networkMonitor.wasDisconnected {
                    networkMonitor.wasDisconnected = false  // 網路正常狀態
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    // 停止監控網絡狀態
    mutating func stopMonitoring() {
        monitor.cancel()
    }
}

