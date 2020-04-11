//
//  PublishPipeline.swift
//  
//
//  Created by Matthaus Woolard on 04/04/2020.
//

import Foundation
import Publish
import Files
import RegEx

public enum PublishPipelineFilter {
    case files(regex: RegEx, with: PublishPipeline)
    case any(with: PublishPipeline)
    
    func matches(_ path: Path) -> Bool {
        switch self {
        case .files(let regex, _):
            return regex.test(path.string)
        default:
            return true
        }
    }
}

public struct PublishPipeline {
    static var outputFiles: [PipelineFile] = []
    static var pendingFiles: Set<Path> = []
    
    var stages: [PipelineStage]
    
    func run<Site>(with files: [PipelineFile], on context: PublishingContext<Site>) throws ->  [PipelineFile] where Site: Website {
        var files = files
        for stage in stages {
            files = try stage.run(with: files, on: context)
        }
        return files
    }
    
    public init(_ stages: [PipelineStage]) {
        self.stages = stages
    }
}
