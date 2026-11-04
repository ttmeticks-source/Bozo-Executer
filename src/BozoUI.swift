import SwiftUI
import Network

@main
struct BozoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().frame(minWidth: 600, minHeight: 400).background(Color.white)
        }
    }
}

struct ContentView: View {
    @State private var script = "-- Bozo Executer\nprint(\"Made By C0oled!\")\n"
    @State private var status = "Ready"
    @State private var isOutOfDate = false
    let currentVersion = "1.0.0"

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Bozo Executer").font(.title2.bold()).foregroundColor(.black)
                Spacer()
                if isOutOfDate { Text("Out Of Date").font(.caption.bold()).foregroundColor(.red) }
            }
            if isOutOfDate {
                Text("Out Of Date, Please Install the new version In my discord Server!")
                    .font(.title3).foregroundColor(.red).frame(maxWidth: .infinity, maxHeight: .infinity)
                    .multilineTextAlignment(.center).border(Color.red.opacity(0.3))
            } else {
                TextEditor(text: $script).font(.system(.body, design: .monospaced))
                    .border(Color.gray.opacity(0.3)).frame(maxHeight: .infinity)
            }
            HStack {
                Text(status).foregroundColor(.gray).font(.caption)
                Spacer()
                if !isOutOfDate {
                    Button("Clear") { script = "" }
                    Button("Execute") { send() }.keyboardShortcut(.return, modifiers: .command)
                }
            }
        }
        .padding().background(Color.white).onAppear { checkVersion() }
    }

    func checkVersion() {
        guard let url = URL(string: "https://raw.githubusercontent.com/ttmeticks-source/Bozo-Executer/main/version.txt") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let latest = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                DispatchQueue.main.async { if latest != currentVersion { isOutOfDate = true } }
            }
        }.resume()
    }

    func send() {
        status = "Connecting..."
        let conn = NWConnection(host: "127.0.0.1", port: 5599, using: .tcp)
        conn.stateUpdateHandler = { st in
            if case .ready = st {
                conn.send(content: script.data(using: .utf8), completion: .contentProcessed { _ in
                    DispatchQueue.main.async { status = "Sent!" }
                    conn.cancel()
                })
            } else if case .failed = st { DispatchQueue.main.async { status = "Failed." } }
        }
        conn.start(queue: .global())
    }
}
