//
//  File.swift
//  
//
//  Created by Matthaus Woolard on 04/04/2020.
//

import Foundation
import Files
import Publish

public struct PipelineTemporaryStageFile: PipelineFile {
    public var source: [PipelineSourceFile]
    var file: PipelineFileWrapper
    public var canonical: Path
    
    public var output: any PipelineOutputFile {
        self.file
    }
    
    
    public init(
        from sourceFile: PipelineFile,
        with data: Data,
        named: String
    ) throws {
        let rootFolder = try Folder.temporary.createSubfolder(at: UUID().uuidString)
                
        let folderPath = sourceFile.canonical.deletingLastPathComponent()
        
        let folder: Folder
        
        if folderPath.string.isEmpty {
            folder = rootFolder
        } else {
            folder = try rootFolder.createSubfolder(at: folderPath.string)
        }
        
        let file = try folder.createFileIfNeeded(withName: named, contents: data)
        
        self.source  = sourceFile.source
        self.file = PipelineFileWrapper(file: file, path: Path(file.path(relativeTo: rootFolder)))
        self.canonical = sourceFile.canonical.replacing(name: named)
    }
    
    public init(
        from sourceFiles: [PipelineFile],
        with data: Data,
        named: String
    ) throws {
        let rootFolder = try Folder.temporary.createSubfolder(at: UUID().uuidString)
                
        let folderPath = sourceFiles.first!.canonical.deletingLastPathComponent()
        
        let folder: Folder
        
        if folderPath.string.isEmpty {
            folder = rootFolder
        } else {
            folder = try rootFolder.createSubfolder(at: folderPath.string)
        }
        
        let file = try folder.createFileIfNeeded(withName: named, contents: data)
        
        self.source = sourceFiles.flatMap { $0.source }
        self.file = PipelineFileWrapper(file: file, path: Path(file.path(relativeTo: rootFolder)))
        self.canonical = sourceFiles.first?.canonical.replacing(name: named) ?? Path(named)
    }
    
    public init(
        from sourceFiles: [PipelineFile],
        with data: Data,
        path: Path
    ) throws {
        let rootFolder = try Folder.temporary.createSubfolder(at: UUID().uuidString)
                
        let folderPath = sourceFiles.first!.canonical.deletingLastPathComponent()
        
        let folder: Folder
        
        if folderPath.string.isEmpty {
            folder = rootFolder
        } else {
            folder = try rootFolder.createSubfolder(at: folderPath.string)
        }
        
        let file = try folder.createFileIfNeeded(withName: path.name, contents: data)
        
        self.source = sourceFiles.flatMap { $0.source }
        self.file = PipelineFileWrapper(file: file, path: Path(file.path(relativeTo: rootFolder)))
        self.canonical = path
    }
    
    public init(from sourceFile: PipelineFile, named: String) throws {
        let rootFolder = try Folder.temporary.createSubfolder(at: UUID().uuidString)
        
        let folderPath = sourceFile.canonical.deletingLastPathComponent()
        
        let folder: Folder
        if folderPath.string.isEmpty {
            folder = rootFolder
        } else {
            folder = try rootFolder.createSubfolder(at: folderPath.string)
        }
        
        let file = try sourceFile.output.file.copy(to: folder)
        try file.rename(to: named)
        
        
        self.source = sourceFile.source
        self.file = PipelineFileWrapper(file: file, path: Path(file.path(relativeTo: rootFolder)))
        canonical = sourceFile.canonical.replacing(name: named)
    }
    
    public init(from sourceFile: PipelineFile, emptyNamed named: String) throws {
        let rootFolder = try Folder.temporary.createSubfolder(at: UUID().uuidString)
        
        let folderPath = sourceFile.canonical.deletingLastPathComponent()
        
        let folder: Folder
        if folderPath.string.isEmpty {
            folder = rootFolder
        } else {
            folder = try rootFolder.createSubfolder(at: folderPath.string)
        }
        
        let file = try folder.createFileIfNeeded(withName: named)
        
        self.source = sourceFile.source
        self.canonical = sourceFile.canonical.replacing(name: named)
        self.file = PipelineFileWrapper(file: file, path: Path(file.path(relativeTo: rootFolder)))
    }
}
