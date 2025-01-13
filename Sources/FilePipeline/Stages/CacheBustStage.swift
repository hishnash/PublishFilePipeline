//
//  File.swift
//  
//
//  Created by Matthaus Woolard on 04/04/2020.
//

import Foundation
import Files
import Crypto

/**
 For every fie add its Base64 encoded sha into the file name `{oldfilename}.{sha}.{oldExtention}`
 */
public struct CacheBustStage: SingleFilePipelineStage {
    public let tags: [String] = []
    
    public func run(
        input: any PipelineFile,
        on context: PipelineContext
    ) throws -> any PipelineFile {
        
        var sha = SHA256()
        sha.update(data: try input.output.file.read())
        let digest = sha.finalize()
        let hash = Data(digest).base64EncodedString().replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "=", with: "")
        
        
        let name = "\(input.canonical.nameExcludingExtension).\(hash).\(input.canonical.extension ?? "bin")"
                
        return RenamedPipelineFile(wrapped: input, name: name)
    }
    
    public init () {}
}
