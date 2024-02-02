//
//  ViewController.swift
//  QRCodeCreator
//
//  Created by Lucas on 2/1/24.
//

import UIKit

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    var textField: UITextField!
    var qrCodeImageView: UIImageView!
    var generateButton: UIButton!

    override func loadView() {
        super.loadView()

        // Create UITextField
        textField = UITextField()
        textField.placeholder = "Enter text"
        textField.borderStyle = .roundedRect
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)

        // Create UIImageView
        qrCodeImageView = UIImageView()
        qrCodeImageView.contentMode = .scaleAspectFit
        qrCodeImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(qrCodeImageView)

        // Create UIButton
        generateButton = UIButton(type: .system)
        generateButton.setTitle("Generate QR Code", for: .normal)
        generateButton.addTarget(self, action: #selector(generateButtonTapped), for: .touchUpInside)
        generateButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(generateButton)

        // Set up constraints
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            qrCodeImageView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            qrCodeImageView.widthAnchor.constraint(equalToConstant: 200),
            qrCodeImageView.heightAnchor.constraint(equalToConstant: 200),
            qrCodeImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            generateButton.topAnchor.constraint(equalTo: qrCodeImageView.bottomAnchor, constant: 20),
            generateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set background color
        view.backgroundColor = .white
    }

    // Called when the user presses the Return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Close the keyboard
        textField.resignFirstResponder()
        // Generate QR Code and update ImageView
        generateQRCode()
        return true
    }

    // Generate QR Code and update ImageView
    func generateQRCode() {
        guard let inputText = textField.text else { return }

        if let qrCodeImage = generateQRCode(from: inputText) {
            qrCodeImageView.image = qrCodeImage
        }
    }

    // Helper function to generate QR Code
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            guard let qrCodeImage = filter.outputImage else { return nil }

            let scaleX = qrCodeImageView.frame.size.width / qrCodeImage.extent.size.width
            let scaleY = qrCodeImageView.frame.size.height / qrCodeImage.extent.size.height

            let transformedImage = qrCodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

            return UIImage(ciImage: transformedImage)
        }

        return nil
    }

    // Button tap event
    @objc func generateButtonTapped() {
        // Generate QR Code and update ImageView
        generateQRCode()
    }
}


