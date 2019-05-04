//
//  StyleTransferViewController.swift
//  Prisma
//
//  Created by Konrad Em on 12/03/2019.
//  Copyright © 2019 Perpetuum. All rights reserved.
//

import UIKit
import AVFoundation

class StyleTransferViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    enum Error: Swift.Error {
        case noAvailableDevices
    }

    private lazy var styleTransferModel: StyleTransfer? = {
        return try? StyleTransfer.build()
    }()
    
    private let captureSession = AVCaptureSession()
    var captureDevice: AVCaptureDevice?
    var captureDeviceInput: AVCaptureDeviceInput?
    var captureVideoOutput: AVCaptureVideoDataOutput?
    let context = CIContext()
    
    private lazy var previewLayer: UIImageView = { UIImageView() }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            layoutView()
            try configureCaptureDevices()
            try configureDeviceInput()
            try configureCaptureOutput()
            captureSession.startRunning()
        } catch {
            return
        }
    }
    
    func layoutView() {
        view.addSubview(previewLayer)
        previewLayer.frame = view.frame
    }
    
    func configureCaptureDevices() throws {
        let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                       mediaType: .video,
                                                       position: .back)
        let devices = session.devices.compactMap { $0 }
        guard !devices.isEmpty else { throw Error.noAvailableDevices }
        try? devices.forEach {
            if $0.position == .back {
                self.captureDevice = $0
                try $0.lockForConfiguration()
                $0.focusMode = .continuousAutoFocus
                $0.unlockForConfiguration()
            }
        }
    }
    
    func configureDeviceInput() throws {
        guard let captureDevice = captureDevice else { throw Error.noAvailableDevices }
        captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
        if captureSession.canAddInput(captureDeviceInput!) { captureSession.addInput(captureDeviceInput!) }
    }
    
    func configureCaptureOutput() throws {
        captureVideoOutput = AVCaptureVideoDataOutput()
        captureVideoOutput!.setSampleBufferDelegate(self, queue: DispatchQueue(label: "buffer"))
        captureVideoOutput!.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA as UInt32]
        captureSession.sessionPreset = AVCaptureSession.Preset.vga640x480
        if captureSession.canAddOutput(captureVideoOutput!) { captureSession.addOutput(captureVideoOutput!)}
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.videoOrientation = .portrait
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        guard let prediction = try? styleTransferModel?.prediction(_0: imageBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: (prediction!._156))
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return  }
        let image = UIImage(cgImage: cgImage)
        DispatchQueue.main.async { [weak self] in
            self?.previewLayer.image = image
        }
    }
}
