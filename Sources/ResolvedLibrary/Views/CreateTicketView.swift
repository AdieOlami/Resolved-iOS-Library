//
//  CreateTicketView.swift
//  ResolvedLibrary
//
//  Created by Olami on 2025-07-13.
//

import SwiftUI
@_exported import Resolved

// MARK: - Create Ticket View

struct CreateTicketView: View {
    let configuration: HelpCenterConfiguration
    let userId: String
    let onBack: () -> Void
    
    @StateObject private var sdkManager = ResolvedSDKManager()
    @State private var formData = CreateTicketFormData()
    @State private var isSubmitting = false
    @State private var showingSuccess = false
    @State private var errorMessage: String?
    @State private var uploadedFiles: [UploadedFile] = []
    @State private var isDragOver = false
    @State private var showingFilePicker = false
    @State private var focusedField: FormField?
    
    enum FormField: CaseIterable {
        case title, category, priority, description
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Content
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Hero Section
                    heroSection
                    
                    // Form Card
                    formCard
                    
                    // File Upload Section
//                    fileUploadCard
                    
                    // Submit Section
                    submitSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .background(configuration.theme.backgroundColor)
        .navigationBarHidden(true)
        .onTapGesture {
            hideKeyboard()
        }
        .task {
            await setupSDK()
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Create Ticket")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(configuration.theme.textColor)
                
                Text("Get expert help from our support team")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(configuration.theme.secondaryColor)
            }
            
            Spacer()
            
            // Back button
            Button(action: onBack) {
                ZStack {
                    Circle()
                        .fill(configuration.theme.primaryColor.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(configuration.theme.primaryColor)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
        .background(headerBackgroundColor)
        .overlay(
            Rectangle()
                .fill(configuration.theme.borderColor.opacity(0.2))
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    // MARK: - Hero Section
    private var heroSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(iconBackgroundGradient)
                    .frame(width: 80, height: 80)
                    .shadow(color: configuration.theme.primaryColor.opacity(0.3), radius: 12, x: 0, y: 6)
                
                Image(systemName: "headphones.circle.fill")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 12) {
                Text("How can we help you?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(configuration.theme.textColor)
                    .multilineTextAlignment(.center)
                
                Text("Describe your issue and we'll get back to you as soon as possible. Our support team is standing by to help.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(configuration.theme.secondaryColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 30)
    }
    
    // MARK: - Form Card
    private var formCard: some View {
        VStack(spacing: 24) {
            // Progress Indicator
            progressIndicator
            
            // Form Fields
            VStack(spacing: 20) {
                // Subject Field
                FormFieldView(
                    title: "Subject",
                    isRequired: true,
                    configuration: configuration,
                    isFocused: focusedField == .title
                ) {
                    TextField("Briefly describe your issue", text: $formData.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(configuration.theme.textColor)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(fieldBackgroundColor)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(focusedField == .title ? configuration.theme.primaryColor : configuration.theme.borderColor.opacity(0.2), lineWidth: focusedField == .title ? 2 : 1)
                                )
                        )
                        .onTapGesture {
                            focusedField = .title
                        }
                }
                
                // Category and Priority Row
                HStack(spacing: 16) {
                    FormFieldView(
                        title: "Category",
                        isRequired: true,
                        configuration: configuration,
                        isFocused: focusedField == .category
                    ) {
                        categoryPicker
                    }
                    
                    FormFieldView(
                        title: "Priority",
                        isRequired: true,
                        configuration: configuration,
                        isFocused: focusedField == .priority
                    ) {
                        priorityPicker
                    }
                }
                
                // Description Field
                FormFieldView(
                    title: "Description",
                    isRequired: true,
                    configuration: configuration,
                    isFocused: focusedField == .description
                ) {
                    ZStack(alignment: .topLeading) {
                        if formData.description.isEmpty {
                            Text("Please provide detailed information about your issue. Include steps to reproduce, error messages, and any relevant context...")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(configuration.theme.secondaryColor.opacity(0.7))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                        }
                        
                        TextEditor(text: $formData.description)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(configuration.theme.textColor)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .frame(minHeight: 120)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .onTapGesture {
                                focusedField = .description
                            }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(fieldBackgroundColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(focusedField == .description ? configuration.theme.primaryColor : configuration.theme.borderColor.opacity(0.2), lineWidth: focusedField == .description ? 2 : 1)
                            )
                    )
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(cardBackgroundColor)
                .shadow(color: shadowColor, radius: 12, x: 0, y: 6)
        )
    }
    
    // MARK: - Progress Indicator
    private var progressIndicator: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Progress")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(configuration.theme.secondaryColor)
                    .textCase(.uppercase)
                
                Spacer()
                
                Text("\(formCompletionPercentage)% Complete")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(configuration.theme.primaryColor)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(configuration.theme.borderColor.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [configuration.theme.primaryColor, configuration.theme.primaryColor.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(formCompletionPercentage) / 100, height: 8)
                        .animation(.easeInOut(duration: 0.3), value: formCompletionPercentage)
                }
            }
            .frame(height: 8)
        }
    }
    
    // MARK: - Category Picker
    private var categoryPicker: some View {
        Menu {
            Button("🔧 Technical Issue") { formData.category = "technical" }
            Button("💳 Billing Question") { formData.category = "billing" }
            Button("👤 Account Management") { formData.category = "account" }
            Button("✨ Feature Request") { formData.category = "feature" }
            Button("🔗 Integration Support") { formData.category = "integration" }
            Button("🐛 Bug Report") { formData.category = "bug" }
            Button("📝 Other") { formData.category = "other" }
        } label: {
            HStack {
                Text(categoryDisplayText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(formData.category.isEmpty ? configuration.theme.secondaryColor.opacity(0.7) : configuration.theme.textColor)
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(configuration.theme.secondaryColor)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(fieldBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(configuration.theme.borderColor.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Priority Picker
    private var priorityPicker: some View {
        Menu {
            Button("🟢 Low") { formData.priority = "low" }
            Button("🟡 Medium") { formData.priority = "medium" }
            Button("🟠 High") { formData.priority = "high" }
            Button("🔴 Critical") { formData.priority = "critical" }
        } label: {
            HStack {
                Text(priorityDisplayText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(formData.priority.isEmpty ? configuration.theme.secondaryColor.opacity(0.7) : configuration.theme.textColor)
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(configuration.theme.secondaryColor)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(fieldBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(configuration.theme.borderColor.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - File Upload Card
    private var fileUploadCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Attachments")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(configuration.theme.textColor)
                
                Text("Add screenshots, logs, or other files to help us understand your issue better")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(configuration.theme.secondaryColor)
                    .lineLimit(nil)
            }
            
            // Upload Area
            Button(action: { showingFilePicker = true }) {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(uploadIconBackgroundGradient)
                            .frame(width: 64, height: 64)
                            .shadow(color: configuration.theme.primaryColor.opacity(0.2), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: "icloud.and.arrow.up.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(isDragOver ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragOver)
                    
                    VStack(spacing: 8) {
                        Text(isDragOver ? "Drop files here" : "Upload Files")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(configuration.theme.textColor)
                        
                        Text("PNG, JPG, PDF, TXT up to 10MB each")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(configuration.theme.secondaryColor)
                    }
                }
                .padding(32)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(uploadBackgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(uploadBorderColor, style: StrokeStyle(lineWidth: 2, dash: isDragOver ? [] : [8, 4]))
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Uploaded Files
            if !uploadedFiles.isEmpty {
                VStack(spacing: 12) {
                    ForEach(uploadedFiles) { file in
                        FileItemView(
                            file: file,
                            configuration: configuration,
                            onRemove: {
                                uploadedFiles.removeAll { $0.id == file.id }
                            }
                        )
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(cardBackgroundColor)
                .shadow(color: shadowColor, radius: 12, x: 0, y: 6)
        )
    }
    
    // MARK: - Submit Section
    private var submitSection: some View {
        VStack(spacing: 16) {
            if showingSuccess {
                SuccessMessageView(configuration: configuration)
                    .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
            }
            
            if let error = errorMessage {
                ErrorMessageView(message: error, configuration: configuration)
                    .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
            }
            
            Button(action: submitTicket) {
                HStack(spacing: 12) {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.9)
                    } else {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 16, weight: .bold))
                        
                        Text("Create Ticket")
                            .font(.system(size: 18, weight: .bold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(submitButtonGradient)
                        .shadow(color: submitButtonShadowColor, radius: 12, x: 0, y: 6)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isSubmitting || !isFormValid)
            .scaleEffect(isSubmitting ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSubmitting)
        }
    }
    
    // MARK: - Helper Methods
    private func setupSDK() async {
        var config = configuration
        config = HelpCenterConfiguration(
            apiKey: configuration.apiKey,
            baseURL: configuration.baseURL,
            customerId: userId,
            customerEmail: configuration.customerEmail,
            customerName: configuration.customerName,
            customerMetadata: configuration.customerMetadata,
            includeKnowledgeBase: configuration.includeKnowledgeBase,
            includeTickets: configuration.includeTickets,
            includeCreateTicket: configuration.includeCreateTicket,
            includeFAQs: configuration.includeFAQs,
            theme: configuration.theme,
            timeoutInterval: configuration.timeoutInterval,
            shouldRetry: configuration.shouldRetry,
            maxRetries: configuration.maxRetries,
            enableOfflineQueue: configuration.enableOfflineQueue,
            loggingEnabled: configuration.loggingEnabled
        )
        
        await sdkManager.initialize(with: config)
    }
    
    private func submitTicket() {
        guard isFormValid else { return }
        
        hideKeyboard()
        isSubmitting = true
        errorMessage = nil
        
        let request = CreateTicketRequest(
            title: formData.title,
            description: formData.description,
            priority: formData.priority.uppercased(),
            category: formData.category.uppercased(),
            customerId: userId,
            customerEmail: configuration.customerEmail,
            customerName: configuration.customerName,
            customerMetadata: configuration.customerMetadata?.compactMapValues { AnyCodable($0) },
            channel: "SDK_MOBILE"
        )
        
        Task {
            do {
                _ = try await sdkManager.createTicket(request: request)
                
                await MainActor.run {
                    isSubmitting = false
                    showingSuccess = true
                    formData = CreateTicketFormData()
                    uploadedFiles = []
                    
                    // Auto-hide success message after 5 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        showingSuccess = false
                    }
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        focusedField = nil
    }
    
    // MARK: - Computed Properties
    private var isFormValid: Bool {
        !formData.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !formData.category.isEmpty &&
        !formData.priority.isEmpty &&
        !formData.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var formCompletionPercentage: Int {
        var completed = 0
        let totalFields = 4
        
        if !formData.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { completed += 1 }
        if !formData.category.isEmpty { completed += 1 }
        if !formData.priority.isEmpty { completed += 1 }
        if !formData.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { completed += 1 }
        
        return Int((Double(completed) / Double(totalFields)) * 100)
    }
    
    private var categoryDisplayText: String {
        switch formData.category {
        case "technical": return "🔧 Technical Issue"
        case "billing": return "💳 Billing Question"
        case "account": return "👤 Account Management"
        case "feature": return "✨ Feature Request"
        case "integration": return "🔗 Integration Support"
        case "bug": return "🐛 Bug Report"
        case "other": return "📝 Other"
        default: return "Select Category"
        }
    }
    
    private var priorityDisplayText: String {
        switch formData.priority {
        case "low": return "🟢 Low"
        case "medium": return "🟡 Medium"
        case "high": return "🟠 High"
        case "critical": return "🔴 Critical"
        default: return "Select Priority"
        }
    }
    
    // MARK: - Color Properties
    private var headerBackgroundColor: Color {
        configuration.theme.mode == .dark
        ? Color(.systemBackground)
        : Color(.systemBackground)
    }
    
    private var cardBackgroundColor: Color {
        configuration.theme.mode == .dark
        ? Color(.systemGray6).opacity(0.3)
        : Color.white
    }
    
    private var fieldBackgroundColor: Color {
        configuration.theme.mode == .dark
        ? Color(.systemGray5).opacity(0.3)
        : Color(.systemGray6).opacity(0.3)
    }
    
    private var shadowColor: Color {
        configuration.theme.mode == .dark
        ? Color.black.opacity(0.3)
        : Color.black.opacity(0.1)
    }
    
    private var iconBackgroundGradient: LinearGradient {
        LinearGradient(
            colors: [configuration.theme.primaryColor, configuration.theme.primaryColor.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var uploadIconBackgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color.blue, Color.blue.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var uploadBackgroundColor: Color {
        if isDragOver {
            return Color.blue.opacity(0.1)
        }
        return configuration.theme.mode == .dark
        ? Color(.systemGray6).opacity(0.2)
        : Color(.systemGray6).opacity(0.3)
    }
    
    private var uploadBorderColor: Color {
        isDragOver ? Color.blue : Color.blue.opacity(0.3)
    }
    
    private var submitButtonGradient: LinearGradient {
        if isSubmitting || !isFormValid {
            return LinearGradient(colors: [Color.gray, Color.gray], startPoint: .leading, endPoint: .trailing)
        }
        return LinearGradient(
            colors: [configuration.theme.primaryColor, configuration.theme.primaryColor.opacity(0.8)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var submitButtonShadowColor: Color {
        if isSubmitting || !isFormValid {
            return Color.clear
        }
        return configuration.theme.primaryColor.opacity(0.3)
    }
}

// MARK: - Create Ticket Form Data
struct CreateTicketFormData {
    var title: String = ""
    var category: String = ""
    var priority: String = ""
    var description: String = ""
}

// MARK: - Form Field View
struct FormFieldView<Content: View>: View {
    let title: String
    let isRequired: Bool
    let configuration: HelpCenterConfiguration
    let isFocused: Bool
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(configuration.theme.textColor)
                
                if isRequired {
                    Text("*")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.red)
                }
                
                Spacer()
            }
            
            content
        }
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - Uploaded File Model
struct UploadedFile: Identifiable {
    let id = UUID()
    let name: String
    let size: Int64
    let type: String
}

// MARK: - File Item View
struct FileItemView: View {
    let file: UploadedFile
    let configuration: HelpCenterConfiguration
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // File Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(fileIconGradient)
                    .frame(width: 48, height: 48)
                    .shadow(color: fileIconColor.opacity(0.3), radius: 4, x: 0, y: 2)
                
                Image(systemName: fileIcon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // File Info
            VStack(alignment: .leading, spacing: 4) {
                Text(file.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(configuration.theme.textColor)
                    .lineLimit(1)
                
                Text(formatFileSize(file.size))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(configuration.theme.secondaryColor)
            }
            
            Spacer()
            
            // Remove Button
            Button(action: onRemove) {
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.1))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.red)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(fileItemBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(configuration.theme.borderColor.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var fileIcon: String {
        switch file.type.lowercased() {
        case "pdf": return "doc.fill"
        case "png", "jpg", "jpeg", "gif", "svg": return "photo.fill"
        case "txt": return "doc.text.fill"
        default: return "doc.fill"
        }
    }
    
    private var fileIconColor: Color {
        switch file.type.lowercased() {
        case "pdf": return .red
        case "png", "jpg", "jpeg", "gif", "svg": return .green
        case "txt": return .blue
        default: return .gray
        }
    }
    
    private var fileIconGradient: LinearGradient {
        LinearGradient(
            colors: [fileIconColor, fileIconColor.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var fileItemBackgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray6).opacity(0.2)
            : Color(.systemGray6).opacity(0.3)
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

// MARK: - Error Message View
struct ErrorMessageView: View {
    let message: String
    let configuration: HelpCenterConfiguration
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(errorGradient)
                    .frame(width: 48, height: 48)
                    .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Error")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.red)
                
                Text(message)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(configuration.theme.textColor)
                    .lineLimit(nil)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(errorBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var errorGradient: LinearGradient {
        LinearGradient(
            colors: [Color.red, Color.red.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var errorBackgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color.red.opacity(0.1)
            : Color.red.opacity(0.05)
    }
}

// MARK: - Success Message View

struct SuccessMessageView: View {
    let configuration: HelpCenterConfiguration
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(successGradient)
                    .frame(width: 48, height: 48)
                    .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Success!")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.green)
                
                Text("Your ticket has been created successfully! We'll get back to you soon.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(configuration.theme.textColor)
                    .lineLimit(nil)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(successBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var successGradient: LinearGradient {
        LinearGradient(
            colors: [Color.green, Color.green.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var successBackgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color.green.opacity(0.1)
            : Color.green.opacity(0.05)
    }
}
