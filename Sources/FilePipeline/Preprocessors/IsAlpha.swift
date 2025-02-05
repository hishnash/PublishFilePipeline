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

public struct IsAlpha: If.PipelineCondition {
    public var tag: String { "isAlphaImage" }
    
    public init() {}
    
    public func evaluate(input: any PipelineFile, on context: any PipelineContext) throws -> Bool {
        let fileData = try input.output.file.read()
        
        guard let image = CIImage(data: fileData) else {
            throw ImageTestError.failedToLoadImage
        }
        return !image.isOpaque
    }
}

#else
public struct IsAlpha: If.PipelineCondition {
    static let tag: String = "isAlphaImage"
    
    public init() {}
    
    static func evaluate(input: any PipelineFile, on context: any PipelineContext) throws -> Bool {
        throw FilePipelineErrors.notImplemented
    }
}
#endif

public extension If.PipelineCondition where Self == IsAlpha {
    static var isAlpha: Self { .init() }
}
