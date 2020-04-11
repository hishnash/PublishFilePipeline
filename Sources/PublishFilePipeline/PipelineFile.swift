//
//  File.swift
//  
//
//  Created by Matthaus Woolard on 04/04/2020.
//

import Foundation
import Files
import Publish


public protocol PipelineFile {
    
    var source: [PipelineFileWrapper] { get }
    var output: [PipelineFileWrapper] { get }
    
    // URL for the primiary file
    var canonical: Path { get }
}
