//
//  ImageAsAVIFStage.swift
//  PublishFilePipeline
//
//  Created by Matthaus Woolard on 10/10/2024.
//

import Foundation
import Crypto
import Files

#if canImport(CoreImage)

import CoreGraphics
import CoreImage
import UniformTypeIdentifiers
import ImageIO
import avif
import AppKit

public struct ImageAsAVIFStage: SingleFilePipelineStage {
    enum ImageConvertError: Error {
        case failedToLoadImage
        case failedToSaveImage
    }
    
    
    let quality: Double
    
    public init(quality: Double = 0.9) {
        self.quality = quality
    }
    
    public func run(
        input: any PipelineFile,
        on context: PipelineContext
    ) throws -> any PipelineFile {
        let fileData = try input.output.file.read()
        
        guard let image = NSImage(data: fileData) else {
            throw ImageConvertError.failedToLoadImage
        }
        
        let newName = "\(input.canonical.nameExcludingExtension).converted.avif"
        let file = try PipelineTemporaryStageFile(from: input, emptyNamed: newName)
        
        
        let imageData = try AVIFEncoder.encode(image: image, quality: quality)
        
        try file.file.file.write(imageData)
        return file
    }
}

#else
public struct ImageAsAVIFStage: SingleFilePipelineStage {
    
    let quality: Double
    
    public init(quality: Double = 0.9) {
        self.quality = quality
    }
        
    public func run(
        input: any PipelineFile,
        on context: PipelineContext
    ) throws -> any PipelineFile {
        throw FilePipelineErrors.notImplemented
    }
}
#endif

public extension ImageAsAVIFStage {
    
    var tags: [String] {
        ["asAVIF@\(quality)"]
    }
}
