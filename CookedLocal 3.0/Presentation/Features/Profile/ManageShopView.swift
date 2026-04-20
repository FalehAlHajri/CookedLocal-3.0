//
//  ManageShopView.swift
//  Cooked Local
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct ManageShopView: View {
    @StateObject var viewModel: ManageShopViewModel
    @State private var profilePhotoItem: PhotosPickerItem?
    @State private var bannerPhotoItem: PhotosPickerItem?
    @State private var showDocumentPicker = false

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            ScrollView(showsIndicators: false) {
                VStack(spacing: DesignTokens.Spacing.lg) {
                    profileImageSection

                    formSection

                    shortBioSection

                    uploadSection

                    socialSection

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.system(size: DesignTokens.FontSize.caption))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, DesignTokens.Spacing.md)
                    }

                    if let success = viewModel.successMessage {
                        Text(success)
                            .font(.system(size: DesignTokens.FontSize.caption))
                            .foregroundColor(.green)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, DesignTokens.Spacing.md)
                    }

                    updateButton
                }
                .padding(.top, DesignTokens.Spacing.md)
                .padding(.bottom, DesignTokens.Spacing.xl)
            }
        }
        .background(Color.backgroundColor)
        .navigationBarHidden(true)
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPickerView { data, fileName in
                viewModel.selectedQualificationData = data
                viewModel.qualificationFileName = fileName
            }
        }
        .onChange(of: profilePhotoItem) { newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    viewModel.selectedProfileImage = uiImage
                }
            }
        }
        .onChange(of: bannerPhotoItem) { newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    viewModel.selectedBannerImage = uiImage
                }
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Button(action: { viewModel.goBack() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.neutral900)
                    .frame(width: 44, height: 44)
                    .background(Color.neutral100.opacity(0.5))
                    .clipShape(Circle())
            }

            Text("Manage Shop")
                .font(.anton(DesignTokens.FontSize.subheadline))
                .foregroundColor(.neutral900)

            Spacer()
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.md)
    }

    // MARK: - Profile Image
    private var profileImageSection: some View {
        PhotosPicker(selection: $profilePhotoItem, matching: .images) {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if let selected = viewModel.selectedProfileImage {
                        Image(uiImage: selected)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else if let urlString = viewModel.profileImageURL, let url = URL(string: urlString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let img):
                                img.resizable().aspectRatio(contentMode: .fill)
                            default:
                                Image(systemName: "person.circle.fill").resizable().foregroundColor(.neutral600)
                            }
                        }
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundColor(.neutral600)
                    }
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())

                Image(systemName: "camera.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .frame(width: 30, height: 30)
                    .background(Color.neutral600.opacity(0.7))
                    .clipShape(Circle())
            }
        }
    }

    // MARK: - Form Section
    private var formSection: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            IconTextField(
                icon: "person",
                placeholder: "Shop Name",
                text: $viewModel.shopName
            )

            IconTextField(
                icon: "envelope",
                placeholder: "Enter your Email",
                text: $viewModel.email,
                keyboardType: .emailAddress
            )
            .disabled(true)
            .opacity(0.6)

            IconTextField(
                icon: "phone",
                placeholder: "Phone Number",
                text: $viewModel.phoneNumber,
                keyboardType: .phonePad
            )

            IconTextField(
                icon: "mappin.and.ellipse",
                placeholder: "Shop Location",
                text: $viewModel.shopLocation
            )
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
    }

    // MARK: - Short Bio Section
    private var shortBioSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.shortBio)
                    .font(.system(size: DesignTokens.FontSize.body))
                    .foregroundColor(.neutral900)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 100)
                    .padding(DesignTokens.Spacing.sm)

                if viewModel.shortBio.isEmpty {
                    Text("Short Bio")
                        .font(.system(size: DesignTokens.FontSize.body))
                        .foregroundColor(.neutral600)
                        .padding(.horizontal, DesignTokens.Spacing.md)
                        .padding(.vertical, DesignTokens.Spacing.md)
                        .allowsHitTesting(false)
                }
            }
            .background(Color.white)
            .cornerRadius(DesignTokens.CornerRadius.large)
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large)
                    .stroke(Color.neutral100, lineWidth: 1)
            )
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
    }

    // MARK: - Upload Section
    private var uploadSection: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            // Qualification PDF
            Button(action: { showDocumentPicker = true }) {
                VStack(spacing: DesignTokens.Spacing.sm) {
                    if let fileName = viewModel.qualificationFileName {
                        Image(systemName: "doc.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.brandOrange)
                        Text(fileName)
                            .font(.system(size: DesignTokens.FontSize.caption))
                            .foregroundColor(.neutral900)
                            .lineLimit(1)
                    } else {
                        Text("Upload Qualification (PDF)")
                            .font(.system(size: DesignTokens.FontSize.body))
                            .foregroundColor(.neutral600)
                        Image(systemName: "doc.badge.plus")
                            .font(.system(size: 24))
                            .foregroundColor(.neutral600)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignTokens.Spacing.xl)
                .background(Color.white)
                .cornerRadius(DesignTokens.CornerRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium)
                        .stroke(Color.neutral100, lineWidth: 1)
                )
            }

            // Shop Banner
            PhotosPicker(selection: $bannerPhotoItem, matching: .images) {
                VStack(spacing: DesignTokens.Spacing.sm) {
                    if let banner = viewModel.selectedBannerImage {
                        Image(uiImage: banner)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                            .clipped()
                            .cornerRadius(DesignTokens.CornerRadius.medium)
                    } else {
                        Text("Upload Shop Banner")
                            .font(.system(size: DesignTokens.FontSize.body))
                            .foregroundColor(.neutral600)
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 24))
                            .foregroundColor(.neutral600)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignTokens.Spacing.xl)
                .background(Color.white)
                .cornerRadius(DesignTokens.CornerRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium)
                        .stroke(Color.neutral100, lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
    }

    // MARK: - Social Section
    private var socialSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            socialField(label: "Facebook Profile", placeholder: "facebook Page URL", text: $viewModel.facebookURL)
            socialField(label: "Instagram Profile", placeholder: "Instagram Page URL", text: $viewModel.instagramURL)
            socialField(label: "Whats'app Number", placeholder: "Enter what's app Number", text: $viewModel.whatsappNumber, keyboardType: .phonePad)
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
    }

    private func socialField(label: String, placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(label)
                .font(.anton(DesignTokens.FontSize.body))
                .foregroundColor(.neutral900)

            TextField("", text: text, prompt: Text(placeholder).foregroundColor(.neutral600))
                .font(.system(size: DesignTokens.FontSize.body))
                .foregroundColor(.neutral900)
                .tint(.neutral900)
                .keyboardType(keyboardType)
                .padding(.horizontal, 20)
                .padding(.vertical, DesignTokens.Spacing.md)
                .background(Color.white)
                .cornerRadius(DesignTokens.CornerRadius.large)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large)
                        .stroke(Color.neutral100, lineWidth: 1)
                )
        }
    }

    // MARK: - Update Button
    private var updateButton: some View {
        Button(action: {
            Task { await viewModel.updateShop() }
        }) {
            if viewModel.isLoading {
                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignTokens.Spacing.sm)
            } else {
                Text("Update Shop Details")
                    .font(.anton(DesignTokens.FontSize.body))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignTokens.Spacing.sm)
            }
        }
        .background(Color.brandOrange)
        .cornerRadius(DesignTokens.CornerRadius.pill)
        .padding(.horizontal, DesignTokens.Spacing.md)
        .disabled(viewModel.isLoading)
    }
}

// MARK: - Document Picker
struct DocumentPickerView: UIViewControllerRepresentable {
    let onPick: (Data, String) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf])
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (Data, String) -> Void

        init(onPick: @escaping (Data, String) -> Void) {
            self.onPick = onPick
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            if let data = try? Data(contentsOf: url) {
                onPick(data, url.lastPathComponent)
            }
        }
    }
}

#Preview {
    ManageShopView(viewModel: ManageShopViewModel(router: Router(), userService: UserService()))
}
