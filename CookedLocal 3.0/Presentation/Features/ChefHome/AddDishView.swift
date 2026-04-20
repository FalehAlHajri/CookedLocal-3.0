//
//  AddDishView.swift
//  Cooked Local
//

import SwiftUI
import PhotosUI

struct AddDishView: View {
    @StateObject var viewModel: AddDishViewModel
    @State private var showPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?

    let sizeOptions = ["Small", "Medium", "Large"]

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                    // Category Dropdown
                    DropdownField(
                        placeholder: "Select Category",
                        selection: $viewModel.selectedCategory,
                        options: viewModel.categoryNames
                    )

                    // Dish Title
                    AppTextField(
                        placeholder: "Enter Dish Title",
                        text: $viewModel.dishTitle
                    )

                    // Description
                    AppTextField(
                        placeholder: "Enter Description",
                        text: $viewModel.dishDescription
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

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.system(size: DesignTokens.FontSize.caption))
                            .foregroundColor(.red)
                    }

                    // Submit Dish Button
                    PrimaryButton(title: viewModel.isLoading ? "Submitting..." : "Submit Dish", action: {
                        viewModel.submitDish()
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

            Text("Add Dish")
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
                } else {
                    Text("Upload Food Image")
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
}

#Preview {
    AddDishView(viewModel: AddDishViewModel(router: Router(), menuService: MenuService(), categoryService: CategoryService()))
}
