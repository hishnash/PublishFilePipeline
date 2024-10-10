//
//  ImageAsAVIFStage.swift
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
import avif
import AppKit

public struct ImageAsAVIFStage: SingleFilePipelineStage {
    enum ImageConvertError: Error {
        case failedToLoadImage
        case failedToSaveImage
    }
        

    public init() {}
    
    public func run<Site>(
        input: any PipelineFile,
        on context: PublishingContext<Site>
    ) throws -> any PipelineFile where Site : Website {
        let fileData = try input.output.file.read()
        
        guard let image = NSImage(data: fileData) else {
            throw ImageConvertError.failedToLoadImage
        }
        
        let newName = "\(input.canonical.name).converted.avif"
        let file = try PipelineTemporaryStageFile(from: input, emptyNamed: newName)
        
        let imageData = try AVIFEncoder.encode(image: image)
        
        try file.file.file.write(imageData)
        return file
    }
}

#else
public struct ImageAsAVIFStage: SingleFilePipelineStage {
    
    public init() {}
        
    public func run<Site>(
        input: any PipelineFile,
        on context: PublishingContext<Site>
    ) throws -> any PipelineFile where Site : Website {
        throw FilePipelineErrors.notImplemented
    }
}
#endif

public extension ImageAsAVIFStage {
    
    var tags: [String] {
        ["asAVIF"]
    }
}
