import AppKit
import SwiftUI

struct MacContentView: View {
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
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    inputSection
                    resultSection
                    verifySection
                }
                .padding(24)
                .frame(maxWidth: 880)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Generate HMAC")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingSettings = true
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                MacSettingsView()
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Generate HMAC")
                .font(.system(size: 30, weight: .bold))

            Text("Enter plain text and a secret key to generate an HMAC-SHA256 hash. You can view the full website-compatible hash or a shortened 16-character grouped version.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(nsColor: .windowBackgroundColor), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Input")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("Plain Text")
                    .font(.subheadline.weight(.semibold))
                TextEditor(text: $plainText)
                    .font(.body)
                    .frame(minHeight: 130)
                    .padding(8)
                    .background(Color(nsColor: .textBackgroundColor), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Secret Key")
                    .font(.subheadline.weight(.semibold))
                SecureField("Enter your secret key", text: $hashKey)
                    .textFieldStyle(.roundedBorder)
            }

            Button("Generate Code", action: generateCode)
                .buttonStyle(.borderedProminent)
                .disabled(plainText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || hashKey.isEmpty)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(nsColor: .windowBackgroundColor), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var resultSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("Result")
                    .font(.headline)

                Spacer()

                Picker("Show", selection: $resultMode) {
                    ForEach(ResultMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 280)
            }

            Text(displayedResult)
                .font(.system(.title3, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(Color(nsColor: .textBackgroundColor), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            HStack(spacing: 12) {
                if !displayedResultPlaceholder {
                    Button("Copy to Clipboard", action: copyCode)
                        .buttonStyle(.bordered)
                }

                if !copyMessage.isEmpty {
                    Text(copyMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(nsColor: .windowBackgroundColor), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var verifySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Online Verification")
                .font(.headline)

            Link("Open Devglan HMAC-SHA256 Tool", destination: URL(string: "https://www.devglan.com/online-tools/hmac-sha256-online")!)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(nsColor: .windowBackgroundColor), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
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
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(displayedResult, forType: .string)
        copyMessage = "Copied to clipboard."
    }
}

#Preview {
    MacContentView()
}

private struct MacSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Algorithm Structure")
                        .font(.title2.bold())

                    MacEncryptionStructureCard()

                    Text("This app uses HMAC-SHA256. The full hash matches online tools when they use plain-text UTF-8 input, a plain-text UTF-8 secret key, and hex output.")
                        .foregroundStyle(.secondary)

                    Link("Open Devglan HMAC-SHA256 Website", destination: URL(string: "https://www.devglan.com/online-tools/hmac-sha256-online")!)
                        .font(.headline)
                }
                .padding(24)
                .frame(maxWidth: 760, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct MacEncryptionStructureCard: View {
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
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
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
        .background(Color(nsColor: .windowBackgroundColor), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
