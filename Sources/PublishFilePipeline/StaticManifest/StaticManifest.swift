//
//  StaticManifest.swift
//  
//
//  Created by Matthaus Woolard on 24/06/2024.
//
import Foundation
import Publish

public struct StaticManifest: Codable {
    public var staticDomain: URL
    
    public var files: [FileKey: Path]
    
    init(staticDomain: URL, files: [FileKey : Path]) {
        self.staticDomain = staticDomain
        self.files = files
    }
    
    public struct StaticManifestPipelineFile: PipelineFile {
        public var source: [any PipelineSourceFile] = []
        
        public var output: any PipelineOutputFile {
            fatalError("Un-abled to access underlying file located at \(self.canonical)")
        }
        
        public var canonical: Publish.Path
    }
    
    public var asPipelineFiles: [FileKey: PipelineFile] {
        self.files.mapValues { path in
            return StaticManifestPipelineFile(canonical: path)
        }
    }
}

