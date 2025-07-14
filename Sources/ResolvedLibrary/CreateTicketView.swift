//
//  File.swift
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
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                headerSection
                
                // Form
                formSection
                
                // File Upload
//                fileUploadSection
                
                // Submit Button
                submitButton
                
                // Success/Error Messages
                if showingSuccess {
                    successMessage
                } else if let error = errorMessage {
                    errorMessage(error)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .background(configuration.theme.backgroundColor)
        .onAppear {
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
            sdkManager.initialize(with: config)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            Text("Create Support Ticket")
                .font(.system(size: 42, weight: .black))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Get help from our expert support team. We're here to resolve your issues quickly and efficiently.")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
        }
        .padding(48)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(configuration.theme.primaryColor)
        )
    }
    
    // MARK: - Form Section
    private var formSection: some View {
        VStack(spacing: 24) {
            // Title and Category Row
            HStack(spacing: 16) {
                FormField(
                    title: "Subject",
                    isRequired: true,
                    configuration: configuration
                ) {
                    TextField("Briefly describe your issue", text: $formData.title)
                        .textFieldStyle(CustomTextFieldStyle(configuration: configuration))
                }
                
                FormField(
                    title: "Category",
                    isRequired: true,
                    configuration: configuration
                ) {
                    Picker("Select Category", selection: $formData.category) {
                        Text("Select Category").tag("")
                        Text("🔧 Technical Issue").tag("technical")
                        Text("💳 Billing Question").tag("billing")
                        Text("👤 Account Management").tag("account")
                        Text("✨ Feature Request").tag("feature")
                        Text("🔗 Integration Support").tag("integration")
                        Text("🐛 Bug Report").tag("bug")
                        Text("📝 Other").tag("other")
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(height: 48)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(fieldBackgroundColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(configuration.theme.borderColor.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
            }
            
            // Priority
            FormField(
                title: "Priority",
                isRequired: true,
                configuration: configuration
            ) {
                Picker("Select Priority", selection: $formData.priority) {
                    Text("Select Priority").tag("")
                    Text("🟢 Low - General inquiry").tag("low")
                    Text("🟡 Medium - Some impact").tag("medium")
                    Text("🟠 High - Significant impact").tag("high")
                    Text("🔴 Critical - Service down").tag("critical")
                }
                .pickerStyle(MenuPickerStyle())
                .frame(height: 48)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(fieldBackgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(configuration.theme.borderColor.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            
            // Description
            FormField(
                title: "Description",
                isRequired: true,
                configuration: configuration
            ) {
                ZStack(alignment: .topLeading) {
                    if formData.description.isEmpty {
                        Text("Please provide detailed information about your issue. Include steps to reproduce, error messages, and any relevant context that will help us assist you better.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(configuration.theme.secondaryColor)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                    }
                    
                    TextEditor(text: $formData.description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(configuration.theme.textColor)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .frame(minHeight: 120)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(fieldBackgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(configuration.theme.borderColor.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(formBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(configuration.theme.borderColor.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - File Upload Section
//    private var fileUploadSection: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            HStack {
//                Text("Attachments")
//                    .font(.system(size: 14, weight: .semibold))
//                    .foregroundColor(configuration.theme.textColor)
//                    .textCase(.uppercase)
//                
//                Text("(Optional - Images, PDFs, or text files)")
//                    .font(.system(size: 12, weight: .medium))
//                    .foregroundColor(configuration.theme.secondaryColor)
//                
//                Spacer()
//            }
//            
//            // Drop Zone
//            VStack(spacing: 16) {
//                ZStack {
//                    Circle()
//                        .fill(iconBackgroundColor)
//                        .frame(width: 64, height: 64)
//                    
//                    Image(systemName: "icloud.and.arrow.up.fill")
//                        .font(.system(size: 24))
//                        .foregroundColor(configuration.theme.primaryColor)
//                }
//                .scaleEffect(isDragOver ? 1.1 : 1.0)
//                .animation(.easeInOut(duration: 0.2), value: isDragOver)
//                
//                VStack(spacing: 8) {
//                    Text(isDragOver ? "Drop files here" : "Click to upload files")
//                        .font(.system(size: 18, weight: .bold))
//                        .foregroundColor(configuration.theme.textColor)
//                    
//                    Text("or drag and drop")
//                        .font(.system(size: 16, weight: .medium))
//                        .foregroundColor(configuration.theme.secondaryColor)
//                    
//                    Text("PNG, JPG, GIF, SVG, PDF, TXT up to 10MB each")
//                        .font(.system(size: 14, weight: .medium))
//                        .foregroundColor(configuration.theme.secondaryColor.opacity(0.8))
//                }
//            }
//            .padding(48)
//            .frame(maxWidth: .infinity)
//            .background(
//                RoundedRectangle(cornerRadius: 24)
//                    .fill(dropZoneBackgroundColor)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 24)
//                            .stroke(dropZoneBorderColor, lineWidth: 2, style: StrokeStyle(dash: [8, 4]))
//                    )
//            )
//            .onTapGesture {
//                // Handle file selection
//            }
//            .onDrop(of: [.fileURL], isTargeted: $isDragOver) { providers in
//                handleFileDrop(providers: providers)
//                return true
//            }
//            
//            // Uploaded Files List
//            if !uploadedFiles.isEmpty {
//                VStack(spacing: 8) {
//                    ForEach(uploadedFiles.indices, id: \.self) { index in
//                        FileItemView(
//                            file: uploadedFiles[index],
//                            configuration: configuration,
//                            onRemove: {
//                                uploadedFiles.remove(at: index)
//                            }
//                        )
//                    }
//                }
//            }
//        }
//        .padding(32)
//        .background(
//            RoundedRectangle(cornerRadius: 24)
//                .fill(formBackgroundColor)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 24)
//                        .stroke(configuration.theme.borderColor.opacity(0.2), lineWidth: 1)
//                )
//        )
//    }
    
    // MARK: - Submit Button
    private var submitButton: some View {
        Button(action: submitTicket) {
            HStack(spacing: 12) {
                if isSubmitting {
                    ProgressView()
                        .scaleEffect(0.9)
                } else {
                    Text("Create Ticket")
                        .font(.system(size: 16, weight: .bold))
                        .textCase(.uppercase)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(submitButtonBackgroundColor)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isSubmitting || !isFormValid)
        .scaleEffect(isSubmitting ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isSubmitting)
    }
    
    // MARK: - Messages
    private var successMessage: some View {
        MessageView(
            type: .success,
            title: "Success!",
            message: "Your ticket has been created successfully! Our support team will get back to you soon.",
            configuration: configuration
        )
    }
    
    private func errorMessage(_ message: String) -> some View {
        MessageView(
            type: .error,
            title: "Error",
            message: message,
            configuration: configuration
        )
    }
    
    // MARK: - Helper Methods
    private func submitTicket() {
        guard isFormValid else { return }
        
        isSubmitting = true
        errorMessage = nil
        
        let request = CreateTicketRequest(
            title: formData.title,
            description: formData.description,
            priority: formData.priority,
            category: formData.category,
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
    
    private func handleFileDrop(providers: [NSItemProvider]) -> Bool {
        // Handle file drop logic here
        return true
    }
    
    // MARK: - Computed Properties
    private var isFormValid: Bool {
        !formData.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !formData.category.isEmpty &&
        !formData.priority.isEmpty &&
        !formData.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var formBackgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray6).opacity(0.3)
            : Color.white.opacity(0.7)
    }
    
    private var fieldBackgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray5).opacity(0.3)
            : Color.white.opacity(0.9)
    }
    
    private var dropZoneBackgroundColor: Color {
        if isDragOver {
            return configuration.theme.primaryColor.opacity(0.1)
        }
        return configuration.theme.mode == .dark
            ? Color(.systemGray6).opacity(0.3)
            : Color.white.opacity(0.7)
    }
    
    private var dropZoneBorderColor: Color {
        isDragOver
            ? configuration.theme.primaryColor
            : configuration.theme.borderColor.opacity(0.4)
    }
    
    private var iconBackgroundColor: Color {
        configuration.theme.primaryColor.opacity(0.15)
    }
    
    private var submitButtonBackgroundColor: Color {
        if isSubmitting || !isFormValid {
            return Color(.systemGray4)
        }
        return configuration.theme.primaryColor
    }
}

// MARK: - Create Ticket Form Data
struct CreateTicketFormData {
    var title: String = ""
    var category: String = ""
    var priority: String = ""
    var description: String = ""
}

// MARK: - Form Field
struct FormField<Content: View>: View {
    let title: String
    let isRequired: Bool
    let configuration: HelpCenterConfiguration
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(configuration.theme.textColor)
                    .textCase(.uppercase)
                
                if isRequired {
                    Text("*")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.red)
                }
            }
            
            content
        }
    }
}

// MARK: - Custom Text Field Style
struct CustomTextFieldStyle: TextFieldStyle {
    let configuration: HelpCenterConfiguration
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(self.configuration.theme.textColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(fieldBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(self.configuration.theme.borderColor.opacity(0.3), lineWidth: 1)
                    )
            )
    }
    
    private var fieldBackgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray5).opacity(0.3)
            : Color.white.opacity(0.9)
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
        HStack(spacing: 12) {
            // File Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(iconBackgroundColor)
                    .frame(width: 40, height: 40)
                
                Image(systemName: fileIcon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(configuration.theme.primaryColor)
            }
            
            // File Info
            VStack(alignment: .leading, spacing: 2) {
                Text(file.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(configuration.theme.textColor)
                    .lineLimit(1)
                
                Text(formatFileSize(file.size))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(configuration.theme.secondaryColor)
            }
            
            Spacer()
            
            // Remove Button
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.red.opacity(0.7))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(fileItemBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(configuration.theme.borderColor.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var fileIcon: String {
        switch file.type.lowercased() {
        case "pdf":
            return "doc.fill"
        case "png", "jpg", "jpeg", "gif", "svg":
            return "photo.fill"
        case "txt":
            return "doc.text.fill"
        default:
            return "doc.fill"
        }
    }
    
    private var iconBackgroundColor: Color {
        configuration.theme.primaryColor.opacity(0.1)
    }
    
    private var fileItemBackgroundColor: Color {
        configuration.theme.mode == .dark
            ? Color(.systemGray5).opacity(0.3)
            : Color.white.opacity(0.8)
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

// MARK: - Message View
struct MessageView: View {
    enum MessageType {
        case success
        case error
    }
    
    let type: MessageType
    let title: String
    let message: String
    let configuration: HelpCenterConfiguration
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconBackgroundColor)
                    .frame(width: 40, height: 40)
                
                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(textColor)
                    .textCase(.uppercase)
                
                Text(message)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(textColor)
                    .lineLimit(nil)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(borderColor, lineWidth: 1)
                )
        )
    }
    
    private var colors: (icon: Color, text: Color, background: Color, border: Color) {
        switch type {
        case .success:
            let isDark = configuration.theme.mode == .dark
            return (
                icon: .green,
                text: isDark ? Color.green.opacity(0.9) : Color.green.opacity(0.8),
                background: isDark ? Color.green.opacity(0.1) : Color.green.opacity(0.05),
                border: Color.green.opacity(0.2)
            )
        case .error:
            let isDark = configuration.theme.mode == .dark
            return (
                icon: .red,
                text: isDark ? Color.red.opacity(0.9) : Color.red.opacity(0.8),
                background: isDark ? Color.red.opacity(0.1) : Color.red.opacity(0.05),
                border: Color.red.opacity(0.2)
            )
        }
    }
    
    private var iconName: String {
        switch type {
        case .success: return "checkmark.circle.fill"
        case .error: return "exclamationmark.triangle.fill"
        }
    }
    
    private var iconColor: Color { colors.icon }
    private var textColor: Color { colors.text }
    private var backgroundColor: Color { colors.background }
    private var borderColor: Color { colors.border }
    private var iconBackgroundColor: Color { backgroundColor }
}
