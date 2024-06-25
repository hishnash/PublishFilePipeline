//
//  File.swift
//  
//
//  Created by Matthaus Woolard on 04/04/2020.
//

import Foundation
import Publish
import Files

public extension PublishingStep {
    static func copyPipelineFiles() -> Self {
        step(named: "Copy files") { context in
            for pipelineFile in PipelineState.shared.getAllOutputs() {
                let outputFile = pipelineFile.output.file
                try context.copyToOutput(
                    outputFile,
                    to: pipelineFile.canonical.deletingLastPathComponent(),
                    with: pipelineFile.canonical.name
                )
            }
        }
    }
    
    
    static func loadPipelineManifest(_ file: @escaping () async throws -> StaticManifest ) -> Self {
        step(named: "Loading Pipeline Manifest") { context in
            let manifest = try await file()
            PipelineState.shared.load(manifest: manifest)
        }
    }
    
    static func writePipelineManifest(staticDomain: URL, filePath: Path = "/static/static-manifest.json") -> Self {
        step(named: "Write Pipeline Manifest") { context in
            let outputs = PipelineState.shared.getStaticOutputs()
            let manifest = StaticManifest(staticDomain: staticDomain, files: outputs)
            let encoder = try JSONEncoder().encode(manifest)
            let file = try context.createOutputFile(at: filePath)
            try file.write(encoder)
        }
    }
    
    static func resetPipeline() -> Self {
        step(named: "Resetting") { context in
            PipelineState.shared = PipelineState()
        }
    }
}


extension PublishingContext {
    func copyToOutput(
        _ file: File,
        to path: Path,
        with name: String
    ) throws {
        var file = file
        if file.name != name {
            let folder = try Folder.temporary.createSubfolder(named: UUID().uuidString)
            file = try file.copy(to: folder)
            try file.rename(to: name, keepExtension: false)
        }
        let targetFolder = try createOutputFolder(at: path)
        try file.copy(to: targetFolder)
    }
}
