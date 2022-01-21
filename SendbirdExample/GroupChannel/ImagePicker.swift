//
//  ImagePicker.swift
//  SendbirdExample
//
//  Created by Ernest Hong on 2022/01/21.
//  https://www.hackingwithswift.com/books/ios-swiftui/importing-an-image-into-swiftui-using-phpickerviewcontroller

import PhotosUI
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    
    typealias DidPickImage = (UIImage) -> Void
    
    let didPickImage: DidPickImage
    
    init(didPickImage: @escaping DidPickImage) {
        self.didPickImage = didPickImage
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(didPickImage: didPickImage)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let didPickImage: DidPickImage

        init(didPickImage: @escaping DidPickImage) {
            self.didPickImage = didPickImage
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider else { return }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) {  [weak self] image, _ in
                    guard let image = image as? UIImage else { return }
                    
                    DispatchQueue.main.async {
                        self?.didPickImage(image)
                    }
                }
            }
        }
    }
}
