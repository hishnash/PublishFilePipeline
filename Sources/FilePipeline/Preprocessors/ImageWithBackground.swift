//
//  ImageWithBackground.swift
//  PublishFilePipeline
//
//  Created by Matthaus Woolard on 14/01/2025.
//

import Foundation
import Crypto
import Files

public struct Color {
    let red: Int
    let green: Int
    let blue: Int
    
    public init(red: Int, green: Int, blue: Int) {
        self.red = red
        self.green = green
        self.blue = blue
    }
    
    var tag: String {
        "RGB(\(red),\(green),\(blue))"
    }
}

#if canImport(CoreImage)

import CoreGraphics
import CoreImage
import UniformTypeIdentifiers


public struct ImageWithBackground: SingleFilePipelineStage {
    
    enum ImageError: Error {
        case failedToLoadImage
        case failedToSaveImage
        case failedToSetBackground
    }
    
    let color: Color
    public init(background: Color) {
        self.color = background
    }
    
    public func run(
        input: any PipelineFile,
        on context: PipelineContext
    ) throws -> any PipelineFile {
        let fileData = try input.output.file.read()
        
        guard let image = CIImage(data: fileData) else {
            throw ImageError.failedToLoadImage
        }
        
        let newName = "\(input.canonical.nameExcludingExtension).filled.png"
        let file = try PipelineTemporaryStageFile(from: input, emptyNamed: newName)
        let context = CIContext()
        let backgroundImage = CIImage(
            color: CIColor(
                red: Double(color.red / 255),
                green: Double(color.green / 255),
                blue: Double(color.blue / 255))
        ).cropped(to: image.extent)
        
        // Apply compositing filter
        
        let compositingFilter = CIFilter(name: "CISourceOverCompositing")!
        compositingFilter.setValue(image, forKey: kCIInputImageKey)
        compositingFilter.setValue(backgroundImage, forKey: kCIInputBackgroundImageKey)
        
        guard let combinedImage = compositingFilter.outputImage else { throw ImageError.failedToSetBackground }
        
        guard let imageData = context.pngRepresentation(
            of: combinedImage,
            format: .rgbXf,
            colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!
        ) else {
            throw ImageError.failedToSaveImage
        }
                
        try file.file.file.write(imageData)
        return file
    }
}
#else
public struct ImageWithBackground: SingleFilePipelineStage {
    let color: Color
    public init(background: Color) {
        self.color = background
    }
    
    public func run(
        input: any PipelineFile,
        on context: PipelineContext
    ) throws -> any PipelineFile {
        throw FilePipelineErrors.notImplemented
    }
}
#endif

public extension ImageWithBackground {
    var tags: [String] {
        [ "withBackground-\(color.tag)" ]
    }
}
