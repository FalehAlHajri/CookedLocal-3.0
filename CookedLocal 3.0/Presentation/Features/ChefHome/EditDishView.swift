//
//  EditDishView.swift
//  Cooked Local
//

import SwiftUI
import PhotosUI

struct EditDishView: View {
    @StateObject var viewModel: EditDishViewModel
    @State private var selectedPhotoItem: PhotosPickerItem?

    let sizeOptions = ["Small", "Medium", "Large"]

    private var categoryOptions: [String] {
        viewModel.categories.map { $0.name }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                    // Category Dropdown
                    DropdownField(
                        placeholder: "Select Category",
                        selection: $viewModel.selectedCategory,
                        options: categoryOptions
                    )

                    // Dish Title
                    AppTextField(
                        placeholder: "Enter Dish Title",
                        text: $viewModel.dishTitle
                    )

                    // Size & Price entries
                    ForEach(viewModel.sizes.indices, id: \.self) { index in
                        VStack(spacing: DesignTokens.Spacing.lg) {
                            DropdownField(
                                placeholder: "Select Size",
                                selection: $viewModel.sizes[index].size,
                                options: sizeOptions
                            )

                            AppTextField(
                                placeholder: "Enter Price",
                                text: $viewModel.sizes[index].price,
                                keyboardType: .decimalPad
                            )
                        }
                    }

                    // Add Another Size
                    Button(action: { viewModel.addAnotherSize() }) {
                        HStack(spacing: DesignTokens.Spacing.xs) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                            Text("Add Another Size")
                                .font(.system(size: DesignTokens.FontSize.body, weight: .semibold))
                        }
                        .foregroundColor(.brandOrange)
                    }

                    // Upload Food Image
                    uploadImageSection

                    // Error message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 13))
                            .foregroundColor(.red)
                    }

                    // Update Dish Button
                    PrimaryButton(title: viewModel.isLoading ? "Updating..." : "Update Dish", action: {
                        viewModel.updateDish()
                    })
                    .disabled(viewModel.isLoading)
                }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.vertical, DesignTokens.Spacing.lg)
            }
        }
        .background(Color.backgroundColor)
        .navigationBarHidden(true)
        .onChange(of: selectedPhotoItem) { newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    viewModel.selectedImage = uiImage
                }
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            Button(action: { viewModel.goBack() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.neutral900)
                    .frame(width: 40, height: 40)
                    .background(Color.white)
                    .clipShape(Circle())
            }

            Text("Edit Dish")
                .font(.anton(DesignTokens.FontSize.subheadline))
                .foregroundColor(.neutral900)

            Spacer()
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.sm)
        .background(Color.backgroundColor)
    }

    // MARK: - Upload Image Section
    private var uploadImageSection: some View {
        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
            VStack(spacing: DesignTokens.Spacing.sm) {
                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 150)
                        .clipped()
                        .cornerRadius(DesignTokens.CornerRadius.medium)
                } else if let thumbnail = viewModel.foodItem.imageURL, let url = URL(string: thumbnail) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 150)
                                .clipped()
                                .cornerRadius(DesignTokens.CornerRadius.medium)
                        default:
                            uploadPlaceholder
                        }
                    }
                } else {
                    uploadPlaceholder
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

    private var uploadPlaceholder: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            Text("Upload Food Image")
                .font(.system(size: DesignTokens.FontSize.body))
                .foregroundColor(.neutral600)
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 24))
                .foregroundColor(.neutral600)
        }
    }
}

// MARK: - Dropdown Field
struct DropdownField: View {
    let placeholder: String
    @Binding var selection: String
    let options: [String]
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Text(selection.isEmpty ? placeholder : selection)
                        .font(.anton(DesignTokens.FontSize.body))
                        .foregroundColor(selection.isEmpty ? .neutral600 : .neutral900)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.neutral600)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, DesignTokens.Spacing.md)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large)
                        .stroke(Color.neutral100, lineWidth: 1)
                )
            }

            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            selection = option
                            isExpanded = false
                        }) {
                            Text(option)
                                .font(.system(size: DesignTokens.FontSize.body))
                                .foregroundColor(.neutral900)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                                .padding(.vertical, DesignTokens.Spacing.sm)
                        }

                        if option != options.last {
                            Divider()
                                .padding(.horizontal, 20)
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(DesignTokens.CornerRadius.medium)
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                .padding(.top, 4)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
    }
}

#Preview {
    EditDishView(viewModel: EditDishViewModel(
        foodItem: FoodItem.samples[0],
        router: Router(),
        menuService: MenuService(),
        categoryService: CategoryService()
    ))
}
