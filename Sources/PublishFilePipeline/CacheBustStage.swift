//
//  File.swift
//  
//
//  Created by Matthaus Woolard on 04/04/2020.
//

import Foundation
import Publish
import Files
import Crypto

/**
 For every fie add its Base64 encoded sha into the file name `{oldfilename}.{sha}.{oldExtention}`
 */
public struct CacheBustStage: PipelineStage {
    public init () {}
    
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
        
        var sha = SHA256()
        sha.update(data: try wrappedFile.file.read())
        let digest = sha.finalize()
        let hash = Data(digest).base64EncodedString().replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "=", with: "")
        let name = "\(wrappedFile.file.nameExcludingExtension).\(hash).\(wrappedFile.file.extension ?? "bin")"
        
        return try PipelineTemporaryStageFile(from: wrappedFile, named: name)
    }
}
