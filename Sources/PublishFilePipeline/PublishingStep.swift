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
    
    static func processThroughPipeline(
        at originPath: Path = "Resources"
    ) -> Self {
        step(named: "Copy '\(originPath)' files") { context in
            
            for (_, path) in try context.site.files(at: originPath, with: context) {
                try context.site.processPath(for: path, with: context)
            }
        }
    }
    
    static func copyPipelineFiles() -> Self {
        step(named: "Copy files") { context in
            let refs = PublishPipeline.state.references
            for output in PublishPipeline.state.outputFiles {
                for wrappedFile in output.output {
                    if refs[wrappedFile.canonical, default: 0] >= 1 {
                        try context.copyToOutput(
                            wrappedFile.file,
                            to: wrappedFile.canonical.deletingLastPathComponent()
                        )
                    }
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
