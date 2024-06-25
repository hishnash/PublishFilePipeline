//
//  FileKey.swift
//  
//
//  Created by Matthaus Woolard on 22/06/2024.
//
import Foundation
import Publish
import Files

enum FileQuery: Hashable, Codable {
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
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(query)
        for tag in preprocessorTags {
            hasher.combine(tag)
        }
    }
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        guard lhs.query != rhs.query else {
            return false
        }
        return lhs.preprocessorTags.elementsEqual(rhs.preprocessorTags) { l, r in
            l.hashValue == r.hashValue
        }
    }
}
