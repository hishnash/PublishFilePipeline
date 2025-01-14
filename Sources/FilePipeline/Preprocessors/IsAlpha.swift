//
//  IsAlpha.swift
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
import ImageIO
import avif
import AppKit

enum ImageTestError: Error {
    case failedToLoadImage
}

public enum IsAlpha: IfElse.PipelineCondition {
    public static let tag: String = "isAlphaImage"
    
    public static func evaluate(input: any PipelineFile, on context: any PipelineContext) throws -> Bool {
        let fileData = try input.output.file.read()
        
        guard let image = CIImage(data: fileData) else {
            throw ImageTestError.failedToLoadImage
        }
        return image.colorSpace?.numberOfComponents == 4
    }
}

#else
enum IsAlpha: IfElse.PipelineCondition {
    static let tag: String = "isAlphaImage"
    
    static func evaluate(input: any PipelineFile, on context: any PipelineContext) throws -> Bool {
        throw FilePipelineErrors.notImplemented
    }
}
#endif

public extension IfElse.PipelineCondition {
    static var isAlpha: IsAlpha.Type { IsAlpha.self }
}

