//
//  ImageResizeStage.swift
//
//
//  Created by Matthaus Woolard on 18/06/2024.
//

import Foundation
import Publish
import Crypto
import Files

#if canImport(CoreImage)

import CoreGraphics
import CoreImage

public struct ImageResizeStage: SingleFilePipelineStage {
    
    
    let targetWidthInPoints: Int
    let scale: Scale
    
    public init(targetWidthInPoints: Int, scale: Scale) {
        self.targetWidthInPoints = targetWidthInPoints
        self.scale = scale
    }
    
    /**
     
     Resize the image contained within the input file.
     
     It should be resized to be the width in Points based on the scale selected.
     
     If the file is not large enough to meet this scale it through throw an error.
     
     Should be able to handle PNG, JEPG etc, should output JEPG
     */
    public func run<Site>(
        input: any PipelineFile,
        on context: Publish.PublishingContext<Site>
    ) throws -> any PipelineFile where Site : Publish.Website {
        let fileData = try input.output.file.read()
        // Compute target width
        let targetWidth = targetWidthInPoints * scale.rawValue
        // load image from fileData
        guard let image = CIImage(data: fileData) else {
            throw ImageResizeError.failedToLoadImage
        }
        
        guard Int(image.extent.width) >= targetWidth else {
            throw ImageResizeError.imageToSmall
        }
        
        let scaleFactor = CGFloat(targetWidth) / image.extent.width
        let scaledImage = image.transformed(by: .init(scaleX: scaleFactor, y: scaleFactor), highQualityDownsample: true)
        let newName = "\(input.canonical.nameExcludingExtension)-w\(self.targetWidthInPoints)pt@\(scale.rawValue)x.png"
        let file = try PipelineTemporaryStageFile(from: input, emptyNamed: newName)
        let context = CIContext()
 
        guard let imageData = context.pngRepresentation(of: scaledImage, format: .rgbXf, colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!) else {
            throw ImageResizeError.failedToSaveImage
        }
        try file.file.file.write(imageData)
        return file
    }
}
#else
public struct ImageResizeStage: SingleFilePipelineStage {
    let targetWidthInPoints: Int
    let scale: Scale
    
    public init(targetWidthInPoints: Int, scale: Scale) {
        self.targetWidthInPoints = targetWidthInPoints
        self.scale = scale
    }
    
    public func run<Site>(
        input: any PipelineFile,
        on context: Publish.PublishingContext<Site>
    ) throws -> any PipelineFile where Site : Publish.Website {
        throw FilePipelineErrors.notImplemented
    }
}
#endif


public extension ImageResizeStage {
    enum Scale: Int, Codable {
        case one = 1
        case two = 2
        case three = 3
    }
    
    enum ImageResizeError: Error {
        case failedToLoadImage
        case failedToSaveImage
        case imageToSmall
    }
    
    var tags: [String] {
        ["ImageResizePreprocessor-\(targetWidthInPoints)@\(scale.rawValue)"]
    }
}
