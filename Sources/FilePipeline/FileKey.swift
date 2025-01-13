//
//  FileKey.swift
//  
//
//  Created by Matthaus Woolard on 22/06/2024.
//
import Foundation
import Files

public enum FileQuery: Equatable, Hashable, Codable {
    case file(path: PipelinePath, root: PipelinePath)
    case type(extension: String, root: PipelinePath)
    
    public var asPath: PipelinePath {
        switch self {
        case .file(let path, let root):
            root.appendingComponent(path.string)
        case .type(let fileExtension, let root):
            root.appendingComponent("file.\(fileExtension)")
        }
    }
    
    public var fileExtension: String {
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
