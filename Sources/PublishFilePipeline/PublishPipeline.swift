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
import Dispatch

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

class PipelineState {
    private var queue = DispatchQueue(label: "PipelineState")
    
    private var _outputFiles: [Path: PipelineFile] = [:]
    private var _additionalFiles: [Path: [Path: File]] = [:]
    private var _outputRefCount: [Path: Int] = [:]
    
    
    func reference(_ file: PipelineFile) {
        queue.async {
            self._outputRefCount[file.canonical, default: 0] += 1
        }
    }
    
    var references: [Path: Int] {
        queue.sync {
            self._outputRefCount
        }
    }
    
    var outputFiles: [PipelineFile] {
        queue.sync {
            Array(self._outputFiles.values)
        }
    }
    
    var additionalFiles: [Path: [Path: File]] {
        queue.sync {
            self._additionalFiles
        }
    }
    
    func outputFile(at path: Path) -> File? {
        queue.sync {
            self._outputFiles[path]?.output.first?.file
        }
    }
    
    func set<S: Sequence>(outputs: S) where S.Element == PipelineFileWrapper {
        queue.sync {
            self._outputFiles = [:]
            for output in outputs {
                self._outputFiles[output.canonical] = output
            }
        }
    }
    
    func additionalFiles(at originPath: Path = "Resources") -> [Path: File] {
        queue.sync {
            self._additionalFiles[originPath] ?? [:]
        }
    }
    
    func add<S: Sequence>(outputs: S) where S.Element == any PipelineFile {
        queue.sync {
            for output in outputs {
                self._outputFiles[output.canonical] = output
            }
        }
    }
    
    func set(file: File, for resource: Path, at originPath: Path) {
        queue.sync {
            _additionalFiles[originPath, default: [:]][resource] = file
        }
    }
}


public struct PublishPipeline {
    static var state = PipelineState()
    
//    static var outputFiles: [PipelineFile] = []
//    static var pendingFiles: Set<Path> = []
//
//    // originPath -> Path -> File
//    static var additionalFiles: [Path: [Path: File]] = [:]
    
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
