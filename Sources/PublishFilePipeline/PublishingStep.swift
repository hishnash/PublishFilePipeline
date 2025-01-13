//
//  File.swift
//  
//
//  Created by Matthaus Woolard on 04/04/2020.
//

import Foundation
import Publish
import Files
import FilePipeline

public extension PublishingStep {
    static func copyPipelineFiles() -> Self {
        step(named: "Copy files") { context in
            try FilePipeline.copyPipelineFiles(with: context)
        }
    }
    
    
    static func loadPipelineManifest(_ file: @escaping () async throws -> StaticManifest ) -> Self {
        step(named: "Loading Pipeline Manifest") { context in
            let manifest = try await file()
            FilePipeline.load(manifest: manifest)
        }
    }
    
    static func writePipelineManifest(staticDomain: URL, filePath: Path = "/static/static-manifest.json") -> Self {
        step(named: "Write Pipeline Manifest") { context in
            try FilePipeline.writePipelineManifest(
                staticDomain: staticDomain,
                filePath: PipelinePath(filePath),
                with: context
            )
        }
    }
    
    static func resetPipeline() -> Self {
        step(named: "Resetting") { context in
            FilePipeline.reset()
        }
    }
}


extension PublishingContext {
    public func copyToOutput(
        _ file: File,
        to path: PipelinePath,
        with name: String
    ) throws {
        var file = file
        if file.name != name {
            let folder = try Folder.temporary.createSubfolder(named: UUID().uuidString)
            file = try file.copy(to: folder)
            try file.rename(to: name, keepExtension: false)
        }
        let targetFolder = try createOutputFolder(at: Path(path))
        try file.copy(to: targetFolder)
    }
}


extension Path {
    init(_ pipelinePath: PipelinePath) {
        self.init(pipelinePath.string)
    }
}
extension PipelinePath {
    init(_ path: Path) {
        self.init(path.string)
    }
}


