//
//  ImageAsWEBPStage.swift
//  PublishFilePipeline
//
//  Created by Matthaus Woolard on 10/10/2024.
//

import Foundation
import Publish
import Crypto
import Files

#if canImport(CoreImage)

import CoreGraphics
import CoreImage
import UniformTypeIdentifiers
import ImageIO
import WebP

public struct ImageAsWEBPStage: SingleFilePipelineStage {
    enum ImageConvertError: Error {
        case failedToLoadImage
        case failedToSaveImage
    }
        
    let quality: Float
    let preset: Preset
    
    public init(preset: Preset, quality: Float = 95) {
        self.preset = preset
        self.quality = quality
    }
    
    public func run<Site>(
        input: any PipelineFile,
        on context: PublishingContext<Site>
    ) throws -> any PipelineFile where Site : Website {
        let fileData = try input.output.file.read()
        
        guard let image = CIImage(data: fileData), let cgImage = image.cgImage else {
            throw ImageConvertError.failedToLoadImage
        }
        
        let newName = "\(input.canonical.name).converted.webp"
        let file = try PipelineTemporaryStageFile(from: input, emptyNamed: newName)
        
        let encoder = WebPEncoder()
        let imageData = try encoder.encode(BGRA: cgImage, config: .preset(preset.webPPreset, quality: quality))
        
        try file.file.file.write(imageData)
        return file
    }
}

extension ImageAsWEBPStage.Preset {
    var webPPreset: WebPEncoderConfig.Preset {
        switch self {
        case .default: return .default
        case .picture: return .picture
        case .photo: return .photo
        case .drawing: return .drawing
        case .icon: return .icon
        case .text: return .text
        }
    }
}
#else
public struct ImageAsWEBPStage: SingleFilePipelineStage {
    
    let quality: Float
    let preset: Preset
    
    public init(preset: Preset, quality: Float = 95) {
        self.preset = preset
        self.quality = quality
    }
        
    public func run<Site>(
        input: any PipelineFile,
        on context: PublishingContext<Site>
    ) throws -> any PipelineFile where Site : Website {
        throw FilePipelineErrors.notImplemented
    }
}
#endif

public extension ImageAsWEBPStage {
    enum Preset: String {
        case `default`, picture, photo, drawing, icon, text
    }
    
    var tags: [String] {
        ["asWEBP.\(preset.rawValue)@\(quality)"]
    }
}
