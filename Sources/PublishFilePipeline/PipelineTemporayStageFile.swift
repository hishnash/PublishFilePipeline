//
//  File.swift
//  
//
//  Created by Matthaus Woolard on 04/04/2020.
//

import Foundation
import Files
import Publish

public struct PipelineTemporayStageFile {
    var sourceFiles: [PipelineFileWrapper]
    public var file: PipelineFileWrapper
    
    public init?(from sourceFiles: [PipelineFileWrapper], with data: Data, named: String) throws {
        let rootFolder = try Folder.temporary.createSubfolder(at: UUID().uuidString)
        
        guard let sourceFile = sourceFiles.first else { return nil }
        
        let folderPath = sourceFile.canonical.deletingLastPathComponent()
        
        let folder: Folder
        
        if folderPath.string.isEmpty {
            folder = rootFolder
        } else {
            folder = try rootFolder.createSubfolder(at: folderPath.string)
        }
        
        let file = try folder.createFileIfNeeded(withName: named, contents: data)
        
        self.sourceFiles  = sourceFiles
        self.file = PipelineFileWrapper(file: file, rootFolder: rootFolder)
    }
    
    public init(from sourceFile: PipelineFileWrapper, with data: Data, named: String) throws {
        let rootFolder = try Folder.temporary.createSubfolder(at: UUID().uuidString)
        
        let folderPath = sourceFile.canonical.deletingLastPathComponent()
        
        let folder: Folder
        if folderPath.string.isEmpty {
            folder = rootFolder
        } else {
            folder = try rootFolder.createSubfolder(at: folderPath.string)
        }
        
        let file = try folder.createFileIfNeeded(withName: named, contents: data)
        
        self.sourceFiles  = [sourceFile]
        self.file = PipelineFileWrapper(file: file, rootFolder: rootFolder)
    }
    
    public init(from sourceFile: PipelineFileWrapper, named: String) throws {
        let rootFolder = try Folder.temporary.createSubfolder(at: UUID().uuidString)
        
        let folderPath = sourceFile.canonical.deletingLastPathComponent()
        
        let folder: Folder
        if folderPath.string.isEmpty {
            folder = rootFolder
        } else {
            folder = try rootFolder.createSubfolder(at: folderPath.string)
        }
        
        let file = try sourceFile.file.copy(to: folder)
        try file.rename(to: named)
        
        
        self.sourceFiles  = [sourceFile]
        self.file = PipelineFileWrapper(file: file, rootFolder: rootFolder)
    }
    
    public init(from sourceFile: PipelineFileWrapper, emtpyName named: String) throws {
        let rootFolder = try Folder.temporary.createSubfolder(at: UUID().uuidString)
        
        let folderPath = sourceFile.canonical.deletingLastPathComponent()
        
        let folder: Folder
        if folderPath.string.isEmpty {
            folder = rootFolder
        } else {
            folder = try rootFolder.createSubfolder(at: folderPath.string)
        }
        
        let file = try folder.createFileIfNeeded(withName: named)
        
        self.sourceFiles  = [sourceFile]
        self.file = PipelineFileWrapper(file: file, rootFolder: rootFolder)
    }
}

extension PipelineTemporayStageFile: PipelineFile {
    public var source: [PipelineFileWrapper] {
        self.sourceFiles
    }
    
    public var output: [PipelineFileWrapper] {
        [self.file]
    }
    
    public var canonical: Path {
        return self.file.canonical
    }
}

public struct PipelineFileContainer {
    public init(children: [PipelineFile], parents: [PipelineFile]) {
        self.children = children
        self.parents = parents
    }
    
    var children: [PipelineFile]
    var parents: [PipelineFile]
}


extension PipelineFileContainer: PipelineFile {
    public var source: [PipelineFileWrapper] {
        return self.parents.flatMap { file in
            return file.source
        }
    }
    
    public var output: [PipelineFileWrapper] {
        return self.children.flatMap { file in
            return file.output
        }
    }
    
    public var canonical: Path {
        self.children.first!.canonical
    }
}


extension Path {
    func deletingLastPathComponent() -> Path {
        let path = self.string.split(separator: "/").dropLast().joined(separator: "/")
        return Path(path)
    }
}
