//
//  DropCommentsStage.swift
//  
//
//  Created by Matthaus Woolard on 8/04/22.
//

import Foundation
import Publish


public struct DropCommentsStage: PipelineStage {
    let prefix: String
    public init (prefix: String) {
        self.prefix = prefix
    }
    
    public func run<Site>(with files: [PipelineFile], on context: PublishingContext<Site>) throws -> [PipelineFile] where Site : Website {
        return try files.map { file in
            try self.handle(file)
        }
    }
    
    func handle(_ file: PipelineFile) throws -> PipelineFile {
        return PipelineFileContainer(
            children: try file.output.map({ outputFile in
                try self.handle(outputFile)
            }),
            parents: [file]
        )
    }
    
    func handle(_ wrappedFile: PipelineFileWrapper) throws -> PipelineFile {
        let name = "\(wrappedFile.file.nameExcludingExtension)-cleaned.\(wrappedFile.file.extension ?? "bin")"

        let result = try PipelineTemporaryStageFile(from: wrappedFile, emtpyName: name)
        var lastLine: String? = nil
        let fileAsString = try wrappedFile.file.readAsString()
        // Loop over lines
        for line in fileAsString.components(separatedBy: .newlines) {
            if line.starts(with: prefix) {
                continue
            } else {
                if !(line.isEmpty && (lastLine?.isEmpty ?? true)) {
                    // Dont add an extra new line at the start
                    if lastLine != nil {
                        try result.file.file.append("\n")
                    }
                    try result.file.file.append(line)
                    lastLine = line
                }
            }
        }
        
        return result
    }
}
