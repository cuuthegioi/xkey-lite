//
//  AdvancedSection.swift
//  XKey
//
//  Shared Advanced Settings Section
//

import SwiftUI
import UniformTypeIdentifiers

struct AdvancedSection: View {
    @ObservedObject var viewModel: PreferencesViewModel
    
    // State properties for dictionary section (moved from SpellCheckSection)
    @State private var isDownloading = false
    @State private var downloadError: String?
    @State private var showDownloadSuccess = false
    
    // State properties for user dictionary section
    @State private var newUserWord = ""
    @State private var userDictionaryWords: [String] = []
    @State private var showUserDictionaryList = false
    
    // Import/Export states for user dictionary
    @State private var showUserDictImportSheet = false
    @State private var showUserDictExportSheet = false
    @State private var showUserDictAlert = false
    @State private var userDictAlertMessage = ""
    @State private var userDictAlertIsError = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SettingsGroup(title: "Chính tả & Viết hoa") {
                    VStack(alignment: .leading, spacing: 10) {
                        Toggle("Tự động viết hoa chữ đầu câu", isOn: $viewModel.preferences.upperCaseFirstChar)

                        // Sub-option: only capitalize after sentence-ending punctuation when followed by a space
                        if viewModel.preferences.upperCaseFirstChar {
                            VStack(alignment: .leading, spacing: 4) {
                                Toggle("Chỉ viết hoa khi sau dấu câu có dấu cách", isOn: $viewModel.preferences.capitalizeOnlyAfterSpace)
                                    .padding(.leading, 20)

                                Text("Nếu bật: chỉ viết hoa sau \". ? !\" khi theo sau là dấu cách (vd \"google.com\", \"3.14\", \"file.txt\" không bị viết hoa). Xuống dòng vẫn luôn viết hoa. Nếu tắt: viết hoa ngay sau dấu câu kể cả khi không có dấu cách.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 20)
                            }
                        }

                        // Custom consonants toggle + chip editor
                        CustomConsonantChipEditor(isEnabled: $viewModel.preferences.customConsonantEnabled, customConsonants: $viewModel.preferences.customConsonants)

                        Toggle("Kiểm tra chính tả và tự động khôi phục (Thử nghiệm)", isOn: $viewModel.preferences.spellCheckEnabled)
                            .onChange(of: viewModel.preferences.spellCheckEnabled) { newValue in
                                if newValue {
                                    // Auto-load dictionary if available
                                    let style: VNDictionaryManager.DictionaryStyle = viewModel.preferences.modernStyle ? .dauMoi : .dauCu
                                    VNDictionaryManager.shared.loadIfAvailable(style: style)
                                } else {
                                    // Cascade disable: turn off child settings when spell check is disabled
                                    viewModel.preferences.restoreIfWrongSpelling = false
                                    viewModel.preferences.instantRestoreOnWrongSpelling = false
                                    
                                    // Clear dictionary cache to free memory (~2-5MB)
                                    VNDictionaryManager.shared.clearCache()
                                }
                            }
                        
                        Text("Cần xác nhận và tải về bộ từ điển Tiếng Việt bên dưới")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.leading, 20)
                        
                        // Sub-options for spell check (only visible when spell check is enabled)
                        if viewModel.preferences.spellCheckEnabled {
                            VStack(alignment: .leading, spacing: 8) {
                                Toggle("Khôi phục nếu sai chính tả", isOn: $viewModel.preferences.restoreIfWrongSpelling)
                                    .padding(.leading, 20)
                                    .onChange(of: viewModel.preferences.restoreIfWrongSpelling) { newValue in
                                        if !newValue {
                                            // Cascade disable: turn off instant restore when restore is disabled
                                            viewModel.preferences.instantRestoreOnWrongSpelling = false
                                        }
                                    }
                                
                                if viewModel.preferences.restoreIfWrongSpelling {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Toggle("Khôi phục ngay lập tức", isOn: $viewModel.preferences.instantRestoreOnWrongSpelling)
                                            .padding(.leading, 40)
                                        
                                        Text("Nếu bật: Restore ngay khi thêm dấu không hợp lệ, có thể sẽ gây lỗi từ Tiếng Việt hợp lệ không mong muốn. Nếu tắt: Chờ nhấn Space để restore sẽ chính xác hơn.")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .padding(.leading, 40)

                                        Toggle("Bỏ qua viết tắt IN HOA bắt đầu bằng chữ Việt có dấu", isOn: $viewModel.preferences.skipRestoreForUppercaseVietnameseAbbreviations)
                                            .padding(.leading, 40)

                                        Text("Nếu bật: các viết tắt như ÂT, ÔM, ỨH sẽ không bị khôi phục về phím gõ thô. Trường hợp ĐN/ĐL luôn được giữ kể cả khi tuỳ chọn này tắt.")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .padding(.leading, 40)
                                    }
                                }
                            }
                        }                    
                        
                        // Dictionary options (only shown when spell check is enabled)
                        if viewModel.preferences.spellCheckEnabled {
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 10) {
                                // Auto-select dictionary based on modernStyle
                                HStack(spacing: 4) {
                                    Image(systemName: "info.circle")
                                        .foregroundColor(.blue)
                                    let dictName = viewModel.preferences.modernStyle
                                        ? String(localized: "Dấu mới (xoà)")
                                        : String(localized: "Dấu cũ (xóa)")
                                    Text("Bộ từ điển: \(dictName)")
                                        .font(.caption)
                                    Text("- tự động theo kiểu gõ")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Divider()
                                
                                // Dictionary status
                                dictionaryStatusView
                                
                                // Success/Error messages (for both download and reload)
                                if let error = downloadError {
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.orange)
                                        // `error` is already a localized message produced where it was set.
                                        Text(error)
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                    }
                                }

                                if showDownloadSuccess {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text("Tải từ điển thành công!")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                    }
                                }
                                
                                // Download section (only when not loaded)
                                if !isDictionaryLoaded {
                                    downloadSection
                                }
                                
                                // License info (always visible)
                                dictionaryInfoView
                                
                                // Info text
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Từ điển chứa các từ đơn tiếng Việt.")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("XKey sẽ ưu tiên từ điển để xác định chính tả Tiếng Việt và tự động hoàn tác nếu từ đang gõ không tồn tại trong từ điển này. Bạn cũng có thể thêm các \"Từ điển cá nhân\" để bỏ qua việc kiểm tra chính tả đối với các từ mà bạn coi là hợp lệ.")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Divider()
                                
                                // User Dictionary section
                                userDictionarySection
                            }
                            .padding(.leading, 20)
                        }
                    }
                }

                SettingsGroup(title: "Smart Switch") {
                    VStack(alignment: .leading, spacing: 12) {
                        // Main Smart Switch toggle
                        VStack(alignment: .leading, spacing: 4) {
                            Toggle("Nhớ ngôn ngữ theo ứng dụng", isOn: $viewModel.preferences.smartSwitchEnabled)

                            Text("Tự động chuyển ngôn ngữ khi chuyển app")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }

    // MARK: - Dictionary Status View (moved from SpellCheckSection)
    
    private var dictionaryStatusView: some View {
        HStack(spacing: 8) {
            Image(systemName: isDictionaryLoaded ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isDictionaryLoaded ? .green : .secondary)

            if isDictionaryLoaded {
                Text("Đã tải từ điển (\(wordCount) từ)")
                    .font(.caption)
                
                // Reload button for updating dictionary
                Button(action: reloadDictionary) {
                    HStack(spacing: 4) {
                        if isDownloading {
                            ProgressView()
                                .controlSize(.small)
                                .scaleEffect(0.6)
                            Text("Đang tải...")
                        } else {
                            Image(systemName: "arrow.clockwise")
                            Text("Tải lại")
                        }
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .disabled(isDownloading)

                // Open dictionary folder button
                Button(action: openDictionaryFolder) {
                    Image(systemName: "folder")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .help("Mở thư mục chứa từ điển")
            } else if isDictionaryAvailable {
                Text("Từ điển đã tải về nhưng chưa được nạp")
                    .font(.caption)

                Button("Nạp") {
                    let style: VNDictionaryManager.DictionaryStyle = viewModel.preferences.modernStyle ? .dauMoi : .dauCu
                    VNDictionaryManager.shared.loadIfAvailable(style: style)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            } else {
                Text("Chưa tải từ điển")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Download Section (moved from SpellCheckSection)
    
    private var downloadSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Download button
            HStack(spacing: 8) {
                Button(action: downloadDictionary) {
                    HStack {
                        if isDownloading {
                            ProgressView()
                                .controlSize(.small)
                                .scaleEffect(0.7)
                            Text("Đang tải...")
                        } else {
                            Image(systemName: "arrow.down.circle")
                            Text("Tải từ điển (~200KB)")
                        }
                    }
                }
                .disabled(isDownloading)
                .buttonStyle(.borderedProminent)
            }
            
            Text("Bấm \"Tải từ điển\" đồng nghĩa bạn đồng ý với giấy phép GPL.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .italic()
        }
    }
    
    // MARK: - Dictionary Info View (always visible)
    
    private var dictionaryInfoView: some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: 6) {
                Text("• Nguồn: hunspell-vi by Minh Nguyen")
                Text("• License: GPL (GNU General Public License)")
                Text("• Một dự án mã nguồn mở")
                
                HStack(spacing: 4) {
                    Text("📎")
                    Link("github.com/1ec5/hunspell-vi", destination: URL(string: "https://github.com/1ec5/hunspell-vi")!)
                }
                .padding(.top, 4)
            }
            .font(.caption2)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
            .padding(.bottom, 4)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "doc.text")
                    .foregroundColor(.secondary)
                Text("Thông tin license từ điển")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 4)
    }
    
    // MARK: - User Dictionary Section
    
    private var userDictionarySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header with Import/Export buttons
            HStack(spacing: 4) {
                Image(systemName: "person.text.rectangle")
                    .foregroundColor(.blue)
                Text("Từ điển cá nhân")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Spacer()
                
                // Import/Export buttons
                HStack(spacing: 8) {
                    Button(action: { showUserDictImportSheet = true }) {
                        Label("Import", systemImage: "square.and.arrow.down")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    
                    Button(action: exportUserDictionary) {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .disabled(userDictionaryWords.isEmpty)
                }
            }
            
            Text("Thêm các từ bạn muốn bỏ qua kiểm tra chính tả")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            // Add new word form
            HStack(spacing: 8) {
                TextField("Nhập từ mới...", text: $newUserWord)
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
                    .frame(maxWidth: 200)
                    .onChange(of: newUserWord) { newValue in
                        // Remove spaces - only single words allowed
                        let filtered = newValue.replacingOccurrences(of: " ", with: "")
                        if filtered != newValue {
                            newUserWord = filtered
                        }
                    }
                    .onSubmit {
                        addUserWord()
                    }
                
                Button(action: addUserWord) {
                    Image(systemName: "plus.circle.fill")
                }
                .buttonStyle(.borderless)
                .disabled(newUserWord.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            // Hotkey: add the frontmost app's selected text after a confirm
            HStack {
                Text("Phím tắt thêm từ đã chọn:")
                    .font(.caption)
                Spacer()
                HotkeyRecorderView(hotkey: $viewModel.preferences.addToDictionaryHotkey, minimumModifiers: 2)
                    .frame(width: 150)
            }

            Text("Bôi đen text ở app bất kỳ rồi bấm phím tắt để thêm từng từ vào từ điển")
                .font(.caption2)
                .foregroundColor(.secondary)

            Text("Không thấy \"XKey: ...\" trong menu chuột phải? Bật tại System Settings → Keyboard → Keyboard Shortcuts → Services → Text")
                .font(.caption2)
                .foregroundColor(.secondary)

            Button("Mở Keyboard Settings") {
                openKeyboardServicesSettings()
            }
            .buttonStyle(.link)
            .font(.caption2)

            // Word count and toggle list
            HStack {
                Text("\(userDictionaryWords.count) từ")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !userDictionaryWords.isEmpty {
                    Button(showUserDictionaryList ? "Ẩn danh sách" : "Xem danh sách") {
                        withAnimation {
                            showUserDictionaryList.toggle()
                        }
                    }
                    .buttonStyle(.link)
                    .font(.caption)
                }
            }
            
            // Word list (expandable)
            if showUserDictionaryList && !userDictionaryWords.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(userDictionaryWords.sorted(), id: \.self) { word in
                        HStack {
                            Text(word)
                                .font(.caption)
                            
                            Spacer()
                            
                            Button(action: {
                                removeUserWord(word)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red.opacity(0.7))
                            }
                            .buttonStyle(.borderless)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(4)
                    }
                }
                .padding(.top, 4)
            }
        }
        .onAppear {
            loadUserDictionaryWords()
        }
        .fileImporter(
            isPresented: $showUserDictImportSheet,
            allowedContentTypes: [.plainText],
            allowsMultipleSelection: false
        ) { result in
            handleUserDictImportResult(result)
        }
        .fileExporter(
            isPresented: $showUserDictExportSheet,
            document: UserDictionaryDocument(words: userDictionaryWords),
            contentType: .plainText,
            defaultFilename: "xkey_user_dictionary.txt"
        ) { result in
            handleUserDictExportResult(result)
        }
        .alert(userDictAlertIsError
               ? String(localized: "Lỗi")
               : String(localized: "Thành công"),
               isPresented: $showUserDictAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            // `userDictAlertMessage` is set with String(localized:) at each assignment site.
            Text(userDictAlertMessage)
        }
    }

    // MARK: - Computed Properties (moved from SpellCheckSection)
    
    private var isDictionaryLoaded: Bool {
        VNDictionaryManager.shared.isDictionaryLoaded(
            style: viewModel.preferences.modernStyle ? .dauMoi : .dauCu
        )
    }

    private var isDictionaryAvailable: Bool {
        VNDictionaryManager.shared.isDictionaryAvailable(
            style: viewModel.preferences.modernStyle ? .dauMoi : .dauCu
        )
    }

    private var wordCount: Int {
        let stats = VNDictionaryManager.shared.getDictionaryStats()
        let key = viewModel.preferences.modernStyle ? "DauMoi" : "DauCu"
        return stats[key] ?? 0
    }

    // MARK: - Actions (moved from SpellCheckSection)
    
    private func downloadDictionary() {
        isDownloading = true
        downloadError = nil
        showDownloadSuccess = false

        let style: VNDictionaryManager.DictionaryStyle = viewModel.preferences.modernStyle ? .dauMoi : .dauCu

        VNDictionaryManager.shared.downloadAndLoad(style: style) { result in
            DispatchQueue.main.async {
                isDownloading = false

                switch result {
                case .success:
                    showDownloadSuccess = true
                    // Hide success message after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        showDownloadSuccess = false
                    }
                case .failure(let error):
                    downloadError = error.localizedDescription
                }
            }
        }
    }
    
    private func reloadDictionary() {
        isDownloading = true
        downloadError = nil
        showDownloadSuccess = false

        let style: VNDictionaryManager.DictionaryStyle = viewModel.preferences.modernStyle ? .dauMoi : .dauCu

        VNDictionaryManager.shared.downloadAndLoad(style: style) { result in
            DispatchQueue.main.async {
                isDownloading = false

                switch result {
                case .success:
                    showDownloadSuccess = true
                    // Hide success message after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        showDownloadSuccess = false
                    }
                case .failure(let error):
                    downloadError = String(localized: "Lỗi khi tải lại: \(error.localizedDescription)")
                }
            }
        }
    }

    private func openDictionaryFolder() {
        let url = VNDictionaryManager.shared.getDictionaryDirectoryURL()
        NSWorkspace.shared.open(url)
    }

    private func openKeyboardServicesSettings() {
        // macOS 13+ uses the Settings extension ID; macOS 12 (deployment
        // target) still answers to the old preference-pane ID.
        for raw in [
            "x-apple.systempreferences:com.apple.Keyboard-Settings.extension",
            "x-apple.systempreferences:com.apple.preference.keyboard",
        ] {
            if let url = URL(string: raw), NSWorkspace.shared.open(url) { return }
        }
    }
    
    // MARK: - User Dictionary Actions
    
    private func loadUserDictionaryWords() {
        userDictionaryWords = Array(SharedSettings.shared.getUserDictionaryWords())
    }
    
    private func addUserWord() {
        let word = newUserWord.trimmingCharacters(in: .whitespaces).lowercased()
        guard !word.isEmpty else { return }
        
        SharedSettings.shared.addUserDictionaryWord(word)
        loadUserDictionaryWords()
        newUserWord = ""
    }
    
    private func removeUserWord(_ word: String) {
        SharedSettings.shared.removeUserDictionaryWord(word)
        loadUserDictionaryWords()
    }
    
    // MARK: - User Dictionary Import/Export
    
    private func exportUserDictionary() {
        guard !userDictionaryWords.isEmpty else { return }
        showUserDictExportSheet = true
    }
    
    private func handleUserDictExportResult(_ result: Result<URL, Error>) {
        switch result {
        case .success(_):
            userDictAlertMessage = String(localized: "Đã xuất \(userDictionaryWords.count) từ thành công")
            userDictAlertIsError = false
            showUserDictAlert = true
        case .failure(let error):
            // User cancelled - don't show error
            if (error as NSError).code == NSUserCancelledError {
                return
            }
            userDictAlertMessage = String(localized: "Lỗi khi lưu file: \(error.localizedDescription)")
            userDictAlertIsError = true
            showUserDictAlert = true
        }
    }

    private func handleUserDictImportResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            importUserDictionary(from: url)
        case .failure(let error):
            userDictAlertMessage = String(localized: "Lỗi khi chọn file: \(error.localizedDescription)")
            userDictAlertIsError = true
            showUserDictAlert = true
        }
    }

    private func importUserDictionary(from url: URL) {
        do {
            // Start accessing security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                userDictAlertMessage = String(localized: "Không có quyền truy cập file")
                userDictAlertIsError = true
                showUserDictAlert = true
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }

            let content = try String(contentsOf: url, encoding: .utf8)

            // Split by newlines and filter out empty lines
            let lines = content.components(separatedBy: .newlines)
            let importedWords = lines
                .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
                .filter { !$0.isEmpty }

            guard !importedWords.isEmpty else {
                userDictAlertMessage = String(localized: "File không chứa từ nào")
                userDictAlertIsError = true
                showUserDictAlert = true
                return
            }

            // Add imported words
            var importedCount = 0
            for word in importedWords {
                // Skip words with spaces (only single words allowed)
                if !word.contains(" ") {
                    SharedSettings.shared.addUserDictionaryWord(word)
                    importedCount += 1
                }
            }

            loadUserDictionaryWords()

            userDictAlertMessage = String(localized: "Đã import \(importedCount) từ thành công")
            userDictAlertIsError = false
            showUserDictAlert = true

        } catch {
            userDictAlertMessage = String(localized: "Lỗi: \(error.localizedDescription)")
            userDictAlertIsError = true
            showUserDictAlert = true
        }
    }
}

// MARK: - User Dictionary Document for FileExporter

struct UserDictionaryDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText] }
    
    var words: [String]
    
    init(words: [String]) {
        self.words = words
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let content = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        words = content.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
            .filter { !$0.isEmpty }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let content = words.sorted().joined(separator: "\n")
        guard let data = content.data(using: .utf8) else {
            throw CocoaError(.fileWriteUnknown)
        }
        return .init(regularFileWithContents: data)
    }
}
