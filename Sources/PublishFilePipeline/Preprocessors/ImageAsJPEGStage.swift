//
//  ImageAsJPEGStage.swift
//
//
//  Created by Matthaus Woolard on 25/06/2024.
//


#if canImport(CoreImage)
import Foundation
import Publish
import Crypto
import Files
import CoreGraphics
import CoreImage
import UniformTypeIdentifiers


public struct ImageAsJPEGStage: SingleFilePipelineStage {
    enum ImageConvertError: Error {
        case failedToLoadImage
        case failedToSaveImage
    }
    
    public let tags: [String] = [ "asJPEG" ]
    public func run<Site>(
        input: any PipelineFile,
        on context: PublishingContext<Site>
    ) throws -> any PipelineFile where Site : Website {
        let fileData = try input.output.file.read()
        
        guard let image = CIImage(data: fileData) else {
            throw ImageConvertError.failedToLoadImage
        }
        
        let newName = "\(input.canonical.name).converted.jpg"
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
#endif
