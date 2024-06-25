//
//  Path.swift
//  
//
//  Created by Matthaus Woolard on 23/06/2024.
//

import Publish
import Foundation

extension Path {
    func deletingLastPathComponent() -> Path {
        let path = self.string.split(separator: "/").dropLast().joined(separator: "/")
        return Path(path)
    }
    
    var fileExtension: String? {
        URL(filePath: self.string).pathExtension
    }
}
