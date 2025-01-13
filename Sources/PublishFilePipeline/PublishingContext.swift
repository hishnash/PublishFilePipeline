//
//  PublishingContext.swift
//  PublishFilePipeline
//
//  Created by Matthaus Woolard on 13/01/2025.
//


import Foundation
import Publish
import Files
import FilePipeline

extension PublishingContext: PipelineContext {
    public func resourcePath(for path: PipelinePath) throws -> PipelinePath {
        let path = try self.site.resourcePath(
            for: Path(path),
            with: self
        )
        return PipelinePath(path)
    }
    
    public func folder(
        at path: PipelinePath
    ) throws -> Files.Folder {
        try self.folder(at: Path(path))
    }
    
    public func createOutputFile(
        at path: PipelinePath
    ) throws -> Files.File {
        try self.createOutputFile(at: Path(path))
    }
}
