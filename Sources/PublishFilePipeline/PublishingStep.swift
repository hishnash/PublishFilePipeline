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
    static func copyResourcesThroughPipeline(
        with pipeline: PublishPipeline,
        at originPath: Path = "Resources",
        to targetFolderPath: Path? = nil,
        includingFolder includeFolder: Bool = false
    ) -> Self {
        step(named: "Copy '\(originPath)' files") { context in
            
            let files: [PipelineFile] = try context.site.files(at: originPath,  with: context).map { (file, path) in
                PipelineFileWrapper(file: file, path: path)
            }
            let outputFiles = try pipeline.run(with: files, on: context)
            PublishPipeline.state.set(outputs: outputFiles)
            
            for output in outputFiles {
                for wrappedFile in output.output {
                    try context.copyToOutput(
                        wrappedFile.file,
                        to: wrappedFile.canonical.deletingLastPathComponent()
                   )
                }
            }
        }
    }
}


extension PublishingContext {
    func copyToOutput(
        _ file: File,
        to path: Path
    ) throws {
        let targetFolder = try createOutputFolder(at: path)
        try file.copy(to: targetFolder)
    }
}
