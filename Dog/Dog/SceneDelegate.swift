import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        let contentView = ContentView()
            .environment(\.managedObjectContext, DataController.shared.container.viewContext)
            .environmentObject(DataController.shared)
        
        window.rootViewController = UIHostingController(rootView: contentView)
        window.makeKeyAndVisible()
    }
} 