//
//  File.swift
//  
//
//  Created by Matthaus Woolard on 02/03/2020.
//

import Foundation
import Crypto
import Files



public protocol MultiFilePipelineStage  {
    func run(inputs: [PipelineFile], on context: PipelineContext) throws -> [PipelineFile]
    var tags: [String] { get }
}

public protocol SingleFilePipelineStage: MultiFilePipelineStage {
    func run(input: PipelineFile, on context: PipelineContext) throws -> PipelineFile
    var tags: [String] { get }
}

public extension SingleFilePipelineStage {
    func run(inputs: [PipelineFile], on context: PipelineContext) throws -> [PipelineFile] {
        try inputs.map { file in
            try self.run(input: file, on: context)
        }
    }
}

public protocol ExpandingFilePipelineStage: MultiFilePipelineStage {
    func run(input: PipelineFile, on context: PipelineContext) throws -> [PipelineFile]
    var tags: [String] { get }
}

public extension ExpandingFilePipelineStage {
    func run(inputs: [PipelineFile], on context: PipelineContext) throws -> [PipelineFile] {
        try inputs.flatMap { file in
            try self.run(input: file, on: context)
        }
    }
}

public protocol ReducingFilePipelineStage {
    func run(inputs: [PipelineFile], on context: PipelineContext) throws -> PipelineFile
    var tags: [String] { get }
}


//public extension ReducingFilePipelineStage {
//    func run<Site: Website>(input: PipelineFile, on context: PublishingContext<Site>) throws -> PipelineFile {
//        try self.run(inputs: [input], on: context)
//    }
//}


public struct EmptySingleFilePipelineStage: SingleFilePipelineStage {
    public func run(
        input: any PipelineFile,
        on context: PipelineContext
    ) throws -> any PipelineFile {
        input
    }
    
    public var tags: [String] { [] }
    
    public init() {}
}
