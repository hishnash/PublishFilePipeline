//
//  ImageAsHEIC.swift
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

public struct ImageAsHEIFStage: SingleFilePipelineStage {
    enum ImageConvertError: Error {
        case failedToLoadImage
        case failedToSaveImage
        case imageHasAlphaChannel
    }
    
    public init() {}
    
    public func run(
        input: any PipelineFile,
        on context: PipelineContext
    ) throws -> any PipelineFile {
        let fileData = try input.output.file.read()
        
        guard let image = CIImage(data: fileData) else {
            throw ImageConvertError.failedToLoadImage
        }
        
        guard image.colorSpace?.numberOfComponents ?? 0 <= 3 else {
            throw ImageConvertError.imageHasAlphaChannel
        }
        
        let newName = "\(input.canonical.nameExcludingExtension).converted.heif"
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
    
    public func run(
        input: any PipelineFile,
        on context: PipelineContext
    ) throws -> any PipelineFile {
        throw FilePipelineErrors.notImplemented
    }
}
#endif

public extension ImageAsHEIFStage {
    var tags: [String] {
        [ "asHEIF" ]
    }
}
