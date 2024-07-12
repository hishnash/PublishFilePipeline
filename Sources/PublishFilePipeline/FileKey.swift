//
//  FileKey.swift
//  
//
//  Created by Matthaus Woolard on 22/06/2024.
//
import Foundation
import Publish
import Files

enum FileQuery: Equatable, Hashable, Codable {
    case file(path: Path, root: Path)
    case type(extension: String, root: Path)
    
    var asPath: Path {
        switch self {
        case .file(let path, let root):
            root.appendingComponent(path.string)
        case .type(let fileExtension, let root):
            root.appendingComponent("file.\(fileExtension)")
        }
    }
    
    var fileExtension: String {
        switch self {
        case .file(let path, _):
            return path.extension ?? ""
        case .type(let fileExtension, _):
            return fileExtension
        }
    }
}

public struct FileKey: Equatable, Hashable, Codable {
    let query: FileQuery
    let preprocessorTags: [String]
    
    init(_ query: FileQuery, preprocessor: SingleFilePipelineStage ) {
        self.query = query
        self.preprocessorTags = preprocessor.tags
    }
}
