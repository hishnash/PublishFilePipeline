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
            let folder = try context.folder(at: originPath)
            
            let files: [PipelineFile] = Array(folder.files.recursive).map { file in
                PipelineFileWrapper(file: file, rootFolder: folder)
            }
            let outputFiles = try pipeline.run(with: files, on: context)
            PublishPipeline.outputFiles = outputFiles
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
