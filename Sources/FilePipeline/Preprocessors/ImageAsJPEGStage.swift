//
//  ImageAsJPEGStage.swift
//
//
//  Created by Matthaus Woolard on 25/06/2024.
//


import Foundation
import Crypto
import Files

#if canImport(CoreImage)

import CoreGraphics
import CoreImage
import UniformTypeIdentifiers


public struct ImageAsJPEGStage: SingleFilePipelineStage {
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
        
        let newName = "\(input.canonical.nameExcludingExtension).converted.jpg"
        let file = try PipelineTemporaryStageFile(from: input, emptyNamed: newName)
        let context = CIContext()
        
        guard let imageData = context.jpegRepresentation(
            of: image,
            colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!
        ) else {
            throw ImageConvertError.failedToSaveImage
        }
                
        try file.file.file.write(imageData)
        return file
    }
}
#else
public struct ImageAsJPEGStage: SingleFilePipelineStage {
    public init() {}
    public func run(
        input: any PipelineFile,
        on context: PipelineContext
    ) throws -> any PipelineFile {
        throw FilePipelineErrors.notImplemented
    }
}
#endif

public extension ImageAsJPEGStage {
    var tags: [String] {
        [ "asJPEG" ]
    }
}
