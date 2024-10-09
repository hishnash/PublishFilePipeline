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

#if canImport(AppKit)

import CoreGraphics
import CoreImage
import UniformTypeIdentifiers
import ImageIO
import JxlCoder
import AppKit

public struct ImageAsJEPGXLStage: SingleFilePipelineStage {
    enum ImageConvertError: Error {
        case failedToLoadImage
        case failedToSaveImage
    }
        
    let quality: Int
    
    public init(quality: Int) {
        self.quality = quality
    }
    
    public func run<Site>(
        input: any PipelineFile,
        on context: PublishingContext<Site>
    ) throws -> any PipelineFile where Site : Website {
        let fileData = try input.output.file.read()
        
        guard let nsImage = NSImage(data: fileData) else {
            throw ImageConvertError.failedToLoadImage
        }
        
        let newName = "\(input.canonical.name).converted.jxl"
        let file = try PipelineTemporaryStageFile(from: input, emptyNamed: newName)
        let imageData = try JXLCoder.encode(image: nsImage, effort: 9, quality: quality, decodingSpeed: .medium)
        
        try file.file.file.write(imageData)
        return file
    }
}

#else
public struct ImageAsJEPGXLStage: SingleFilePipelineStage {
    let quality: Int
    
    public init(quality: Int) {
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

public extension ImageAsJEPGXLStage {
    var tags: [String] {
        ["asJPEGXL@\(quality)"]
    }
}
