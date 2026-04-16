import SwiftUI

@main
struct HashKeyMacApp: App {
    var body: some Scene {
        WindowGroup {
            MacContentView()
                .frame(minWidth: 760, minHeight: 620)
        }
        .windowResizability(.contentSize)
    }
}
