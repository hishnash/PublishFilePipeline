//
//  ImageAsPNGStage.swift
//  PublishFilePipeline
//
//  Created by Matthaus Woolard on 14/01/2025.
//

import Foundation
import Crypto
import Files

#if canImport(CoreImage)

import CoreGraphics
import CoreImage
import UniformTypeIdentifiers


public struct ImageAsPNGStage: SingleFilePipelineStage {
    enum ImageConvertError: Error {
        case failedToLoadImage
        case failedToSaveImage
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
        
        let newName = "\(input.canonical.nameExcludingExtension).converted.png"
        let file = try PipelineTemporaryStageFile(from: input, emptyNamed: newName)
        let context = CIContext()
        
        guard let imageData = context.pngRepresentation(
            of: image,
            format: .RGBA8,
            colorSpace: image.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!
        ) else {
            throw ImageConvertError.failedToSaveImage
        }
                
        try file.file.file.write(imageData)
        return file
    }
}
#else
public struct ImageAsPNGStage: SingleFilePipelineStage {
    public init() {}
    public func run(
        input: any PipelineFile,
        on context: PipelineContext
    ) throws -> any PipelineFile {
        throw FilePipelineErrors.notImplemented
    }
}
#endif

public extension ImageAsPNGStage {
    var tags: [String] {
        [ "asPNG" ]
    }
}
