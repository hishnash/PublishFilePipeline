//
//  ImageAsHEIC.swift
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

public struct ImageAsHEIFStage: SingleFilePipelineStage {
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
        
        guard let image = CIImage(data: fileData) else {
            throw ImageConvertError.failedToLoadImage
        }
        
        let newName = "\(input.canonical.name).converted.heif"
        let file = try PipelineTemporaryStageFile(from: input, emptyNamed: newName)
        let context = CIContext()
        
        
        
        guard let imageData = context.heifRepresentation(
            of: image,
            format: .RGB10,
            colorSpace: CGColorSpace(name: CGColorSpace.displayP3)!
        ) else {
            throw ImageConvertError.failedToSaveImage
        }
        
        try file.file.file.write(imageData)
        return file
    }
}
#else
public struct ImageAsHEIFStage: SingleFilePipelineStage {
    public init() {}
    
    public func run<Site>(
        input: any PipelineFile,
        on context: PublishingContext<Site>
    ) throws -> any PipelineFile where Site : Website {
        throw FilePipelineErrors.notImplemented
    }
}
#endif

public extension ImageAsHEIFStage {
    var tags: [String] {
        [ "asHEIF" ]
    }
}
