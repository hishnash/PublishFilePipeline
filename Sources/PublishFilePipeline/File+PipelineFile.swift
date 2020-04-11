//
//  File.swift
//  
//
//  Created by Matthaus Woolard on 04/04/2020.
//

import Foundation
import Files
import Publish

public struct PipelineFileWrapper {
    public init(file: File, rootFolder: Folder) {
        self.file = file
        self.rootFolder = rootFolder
    }
    
    var file: File
    var rootFolder: Folder
    
    
}


extension PipelineFileWrapper: PipelineFile {
    public var source: [PipelineFileWrapper] {
        return [self]
    }
    
    public var output: [PipelineFileWrapper] {
        return [self]
    }
    
    public var canonical: Path {
        return Path(self.file.path(relativeTo: self.rootFolder))
    }
}
