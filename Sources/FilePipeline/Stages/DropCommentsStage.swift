//
//  DropCommentsStage.swift
//  
//
//  Created by Matthaus Woolard on 8/04/22.
//

import Foundation


public struct DropCommentsStage: SingleFilePipelineStage {
    public let tags: [String] = []
    
    let prefix: String
    public init (prefix: String) {
        self.prefix = prefix
    }
    
    public func run(
        input: any PipelineFile,
        on context: PipelineContext
    ) throws -> any PipelineFile {
        let name = "\(input.canonical.nameExcludingExtension)-cleaned.\(input.canonical.extension ?? "bin")"
        let result = try PipelineTemporaryStageFile(from: input, emptyNamed: name)
        var lastLine: String? = nil
        let fileAsString = try input.output.file.readAsString()
        for line in fileAsString.components(separatedBy: .newlines) {
            if line.starts(with: prefix) {
                continue
            } else {
                if !(line.isEmpty && (lastLine?.isEmpty ?? true)) {
                    // Don't add an extra new line at the start
                    if lastLine != nil {
                        try result.output.file.append("\n")
                    }
                    try result.output.file.append(line)
                    lastLine = line
                }
            }
        }
        return result
    }
}
