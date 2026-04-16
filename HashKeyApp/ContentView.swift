import SwiftUI
import UIKit

struct ContentView: View {
    private enum ResultMode: String, CaseIterable, Identifiable {
        case passwordHash = "Password Hash"
        case fullHash = "Full Hash"

        var id: String { rawValue }
    }

    @State private var plainText = ""
    @State private var hashKey = ""
    @State private var passwordHash = ""
    @State private var fullHash = ""
    @State private var copyMessage = ""
    @State private var resultMode: ResultMode = .passwordHash
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            Form {
                Section("About") {
                    Text("Enter plain text and a secret key to generate an HMAC-SHA256 hash. You can view the full website-compatible hash or a shortened 16-character grouped version.")
                        .foregroundStyle(.secondary)
                }

                Section("Input") {
                    TextField("Plain text", text: $plainText, axis: .vertical)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    SecureField("Hash key", text: $hashKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    Button("Generate Code", action: generateCode)
                        .disabled(plainText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || hashKey.isEmpty)
                }

                Section("Result") {
                    Picker("Show", selection: $resultMode) {
                        ForEach(ResultMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)

                    Text(displayedResult)
                        .font(.system(.title3, design: .monospaced))
                        .textSelection(.enabled)

                    if !displayedResultPlaceholder {
                        Button("Copy to Clipboard", action: copyCode)
                    }

                    if !copyMessage.isEmpty {
                        Text(copyMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Online Verification") {
                    Link("Open Devglan HMAC-SHA256 Tool", destination: URL(string: "https://www.devglan.com/online-tools/hmac-sha256-online")!)
                }
            }
            .navigationTitle("Generate HMAC")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }

    private var displayedResult: String {
        if fullHash.isEmpty {
            return "Your generated code will appear here."
        }

        switch resultMode {
        case .passwordHash:
            return passwordHash
        case .fullHash:
            return fullHash
        }
    }

    private var displayedResultPlaceholder: Bool {
        fullHash.isEmpty
    }

    private func generateCode() {
        let output = HashPasswordGenerator.generate(from: plainText, key: hashKey)
        passwordHash = output.shortGrouped
        fullHash = output.fullHex
        copyMessage = ""
    }

    private func copyCode() {
        UIPasteboard.general.string = displayedResult
        copyMessage = "Copied to clipboard."
    }
}

#Preview {
    ContentView()
}

private struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Algorithm Structure")
                        .font(.title2.bold())

                    EncryptionStructureCard()

                    Text("This app uses HMAC-SHA256. The full hash matches online tools when they use plain-text UTF-8 input, a plain-text UTF-8 secret key, and hex output.")
                        .foregroundStyle(.secondary)

                    Link("Open Devglan HMAC-SHA256 Website", destination: URL(string: "https://www.devglan.com/online-tools/hmac-sha256-online")!)
                        .font(.headline)
                }
                .padding()
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct EncryptionStructureCard: View {
    var body: some View {
        VStack(spacing: 12) {
            diagramRow(title: "Plain Text", value: "UTF-8 message")
            Image(systemName: "arrow.down")
                .foregroundStyle(.secondary)
            diagramRow(title: "Secret Key", value: "UTF-8 key")
            Image(systemName: "arrow.down")
                .foregroundStyle(.secondary)
            diagramRow(title: "HMAC-SHA256", value: "Cryptographic digest")
            Image(systemName: "arrow.down")
                .foregroundStyle(.secondary)
            HStack(spacing: 12) {
                diagramRow(title: "Full Hash", value: "64 hex chars")
                diagramRow(title: "Password Hash", value: "first 16 hex chars grouped")
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func diagramRow(title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.headline)
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
