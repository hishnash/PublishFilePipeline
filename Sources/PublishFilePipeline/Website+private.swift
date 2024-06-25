//
//  Website+private.swift
//  
//
//  Created by Matthaus Woolard on 22/06/2024.
//

import Publish
import Files


extension Website {
    /**
     Get all files with respective paths.
     */
//    func files(
//        at originPath: Path = "Resources",
//        with context: PublishingContext<Self>
//    ) throws -> [(file: File, path: Path)] {
//        let files = PublishPipeline.state.additionalFiles[originPath, default: [:]].map { (path, file) in
//            return (file: file, path: path)
//        }
//        
//        let folder = try context.folder(at: originPath)
//        let realFiles = Array(folder.files.recursive).map { file in
//            let path = Path(file.path(relativeTo: folder))
//            return (file: file, path: path)
//        }
//        
//        return files + realFiles
//    }
    
    
//    /**
//     Get file (before mutation)
//     */
//    func file(
//        for resource: Path,
//        at originPath: Path = "Resources",
//        with context: PublishingContext<Self>
//    ) throws -> File {
//        if let file = PublishPipeline.state.additionalFiles[originPath]?[resource] {
//            return file
//        }
//        let folder = try context.folder(at: originPath)
//        return try folder.file(at: resource.string)
//    }
}
