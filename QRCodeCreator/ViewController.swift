//
//  ViewController.swift
//  QRCodeCreator
//
//  Created by Lucas on 2/1/24.
//

import UIKit

import AVFoundation

class ViewController: UIViewController, UITextFieldDelegate, AVCaptureMetadataOutputObjectsDelegate {

    var textField: UITextField!
    var qrCodeImageView: UIImageView!
    var generateButton: UIButton!
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

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
        setupCamera()

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
    
    func setupCamera() {
          captureSession = AVCaptureSession()

          guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
          let videoInput: AVCaptureDeviceInput

          do {
              videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
          } catch {
              return
          }

          if (captureSession.canAddInput(videoInput)) {
              captureSession.addInput(videoInput)
          } else {
              failed()
              return
          }

          let metadataOutput = AVCaptureMetadataOutput()

          if (captureSession.canAddOutput(metadataOutput)) {
              captureSession.addOutput(metadataOutput)

              metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
              metadataOutput.metadataObjectTypes = [.qr]
          } else {
              failed()
              return
          }

          previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
          previewLayer.frame = view.layer.bounds
          previewLayer.videoGravity = .resizeAspectFill
          view.layer.addSublayer(previewLayer)

          captureSession.startRunning()
      }

      func failed() {
          let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
          ac.addAction(UIAlertAction(title: "OK", style: .default))
          present(ac, animated: true)
          captureSession = nil
      }

      override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)

          if (captureSession?.isRunning == false) {
              captureSession.startRunning()
          }
      }

      override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)

          if (captureSession?.isRunning == true) {
              captureSession.stopRunning()
          }
      }

      func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
          captureSession.stopRunning()

          if let metadataObject = metadataObjects.first {
              guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
              guard let stringValue = readableObject.stringValue else { return }
              AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
              found(code: stringValue)
          }

          dismiss(animated: true)
      }

      func found(code: String) {
          // Open Notes app with scanned text
          if let url = URL(string: "mobilenotes://"),
             UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url, options: [:], completionHandler: nil)
          }
      }
}


