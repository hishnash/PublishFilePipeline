//
//  ImageResizeStage.swift
//
//
//  Created by Matthaus Woolard on 18/06/2024.
//

#if canImport(CoreImage)
import Foundation
import Publish
import Crypto
import Files
import CoreGraphics
import CoreImage

public struct ImageResizeStage: SingleFilePipelineStage {
    public enum Scale: Int, Codable {
        case one = 1
        case two = 2
        case three = 3
    }
    
    let targetWidthInPoints: Int
    let scale: Scale
    
    public init(targetWidthInPoints: Int, scale: Scale) {
        self.targetWidthInPoints = targetWidthInPoints
        self.scale = scale
    }
    
    enum ImageResizeError: Error {
        case failedToLoadImage
        case failedToSaveImage
        case imageToSmall
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
        let newName = "\(input.canonical.name)-w\(self.targetWidthInPoints)pt@\(scale.rawValue)x.png"
        let file = try PipelineTemporaryStageFile(from: input, emptyNamed: newName)
        let context = CIContext()
        guard let imageData = context.pngRepresentation(of: scaledImage, format: .RGBA8, colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!) else {
            throw ImageResizeError.failedToSaveImage
        }
        try file.file.file.write(imageData)
        return file
    }
    
    public var tags: [String] {
        ["ImageResizePreprocessor-\(targetWidthInPoints)@\(scale.rawValue)"]
    }    
}
#endif
