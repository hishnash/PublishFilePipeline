//
//  File.swift
//  
//
//  Created by Matthaus Woolard on 02/03/2020.
//

import Foundation
import Publish
import Crypto
import Files



public protocol MultiFilePipelineStage  {
    func run<Site: Website>(inputs: [PipelineFile], on context: PublishingContext<Site>) throws -> [PipelineFile]
    var tags: [String] { get }
}

public protocol SingleFilePipelineStage: MultiFilePipelineStage {
    func run<Site: Website>(input: PipelineFile, on context: PublishingContext<Site>) throws -> PipelineFile
    var tags: [String] { get }
}

public extension SingleFilePipelineStage {
    func run<Site: Website>(inputs: [PipelineFile], on context: PublishingContext<Site>) throws -> [PipelineFile] {
        try inputs.map { file in
            try self.run(input: file, on: context)
        }
    }
}

public protocol ExpandingFilePipelineStage: MultiFilePipelineStage {
    func run<Site: Website>(input: PipelineFile, on context: PublishingContext<Site>) throws -> [PipelineFile]
    var tags: [String] { get }
}

public extension ExpandingFilePipelineStage {
    func run<Site: Website>(inputs: [PipelineFile], on context: PublishingContext<Site>) throws -> [PipelineFile] {
        try inputs.flatMap { file in
            try self.run(input: file, on: context)
        }
    }
}

public protocol ReducingFilePipelineStage {
    func run<Site: Website>(inputs: [PipelineFile], on context: PublishingContext<Site>) throws -> PipelineFile
    var tags: [String] { get }
}


//public extension ReducingFilePipelineStage {
//    func run<Site: Website>(input: PipelineFile, on context: PublishingContext<Site>) throws -> PipelineFile {
//        try self.run(inputs: [input], on: context)
//    }
//}


struct EmptySingleFilePipelineStage: SingleFilePipelineStage {
    func run<Site>(
        input: any PipelineFile,
        on context: Publish.PublishingContext<Site>
    ) throws -> any PipelineFile where Site : Publish.Website {
        input
    }
    
    var tags: [String] { [] }
    
    init() {}
}
