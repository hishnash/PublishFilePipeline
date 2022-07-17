//
//  File.swift
//  
//
//  Created by Matthaus Woolard on 05/04/2020.
//

import Foundation
import RegEx
import Publish


public struct StringReplaceStage: PipelineStage {
    let regex: RegEx = try! RegEx(pattern: #""(/[^\"]+)""#)
    
    public init () {}
    
    public func run<Site>(with files: [PipelineFile], on context: PublishingContext<Site>) throws -> [PipelineFile] where Site : Website {
        return try files.map { file in
            try self.handle(file, on: context)
        }
    }
    
    func handle<Site>(_ file: PipelineFile, on context: PublishingContext<Site>) throws -> PipelineFile where Site : Website {
        return PipelineFileContainer(
            children: try file.output.map({ outputFile in
                try self.handle(outputFile, on: context)
            }),
            parents: [file]
        )
    }
    
    func handle<Site>(_ wrappedFile: PipelineFileWrapper, on context: PublishingContext<Site>) throws -> PipelineFile where Site : Website {
        var string: String
        do {
            string = try wrappedFile.file.readAsString()
        } catch {
            // files that we were unable to read should just be returned
            return wrappedFile
        }
        
        let result = regex.replaceMatches(in: string)  { match in
            guard let path = match.values[1] else {
                return ""
            }
            do {
                let replaced = try context.site.resourcePath(for: Path(String(path)), with: context)
                return "\"\(replaced.string)\""
            } catch {
                return String(match.values[0] ?? "")
            }
        }
        
        return try PipelineTemporaryStageFile(from: wrappedFile, with: result.data(using: .utf8)!, named: wrappedFile.file.name)
    }
}
