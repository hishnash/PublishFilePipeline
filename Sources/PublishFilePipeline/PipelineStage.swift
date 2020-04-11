//
//  File.swift
//  
//
//  Created by Matthaus Woolard on 02/03/2020.
//

import Foundation
import Publish
import Crypto
import Files



public protocol PipelineStage {
    func run<Site>(with files: [PipelineFile], on context: PublishingContext<Site>) throws -> [PipelineFile] where Site: Website
}
