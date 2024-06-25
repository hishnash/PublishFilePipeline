//
//  PublishPipelineFilter.swift
//  
//
//  Created by Matthaus Woolard on 23/06/2024.
//

import Foundation
import Publish
import Files




//public enum PublishPipelineFilter {
//    case allFiles(ofTypes: Set<String>, with: PublishPipeline)
//    case files(regex: RegEx, with: PublishPipeline)
//    case any(with: PublishPipeline)
//    
//    internal func matches(_ query: Query) -> Bool {
//        switch self {
//        case .allFiles(let types, _):
//            types.contains(query.fileExtension)
//        case .files(let regex, _):
//            regex.test(query.asPath.string)
//        default:
//            true
//        }
//    }
//}
//
//internal extension Path {
//    var fileType: String? {
//        guard let fileExtension = self.string.split(separator: ".", omittingEmptySubsequences: true).last else { return nil }
//        return String(fileExtension)
//    }
//}
//
//
//internal extension Array<PublishPipelineFilter> {
//    func first(matching path: PublishPipelineFilter.Query) throws -> PublishPipeline  {
//        let pipelineFilter = self.first { (filter) -> Bool in
//            filter.matches(path)
//        }
//        
//        guard let pipelineFilter else {
//            throw FilePipelineErrors.missingPipeline
//        }
//        
//        switch pipelineFilter {
//        case .any(let pipeline):
//            return pipeline
//        case .files(_, let pipeline):
//            return pipeline
//        case .allFiles(_, let pipeline):
//            return pipeline
//        }
//    }
//}
