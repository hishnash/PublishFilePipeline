//
//  File.swift
//  
//
//  Created by Matthaus Woolard on 05/04/2020.
//

import Foundation
import Publish
import RegexBuilder
import Dispatch

fileprivate let path = Reference<Substring>()

fileprivate var stack: Set<Path> = []
fileprivate var stackQueue = DispatchQueue(label: "recursive-lookup")

public struct StringReplaceStage: SingleFilePipelineStage {
    
    public let tags: [String] = []
    
    let regex = Regex {
        #"""#
        Capture(as: path) {
            "/"
            OneOrMore {
                CharacterClass.anyOf(#"""#).inverted
            }
        }
        #"""#
    }
    
    let urlRegex = Regex {
        "URL("
        ZeroOrMore(.horizontalWhitespace)
        Capture(as: path) {
            "/"
            OneOrMore {
                CharacterClass.anyOf(#")"#).inverted
            }
        }
        ZeroOrMore(.horizontalWhitespace)
        ")"
    }.ignoresCase()
    
    public init () {}
    
    public func run<Site>(
        input: any PipelineFile,
        on context: Publish.PublishingContext<Site>
    ) throws -> any PipelineFile where Site : Publish.Website {
        try stackQueue.sync {
            if stack.contains(input.canonical) {
                throw FilePipelineErrors.recursiveLookup(for: input.canonical)
            }
            stack.insert(input.canonical)
        }
        
        defer {
            _ = stackQueue.sync {
                stack.remove(input.canonical)
            }
        }
        
        
        var string: String
        do {
            string = try input.output.file.readAsString()
        } catch {
            // files that we were unable to read should just be returned
            return input
        }
        
        var didMatch = false
        string.replace(self.regex) { match in
            let pathString = match[path]
            do {
                let replaced = try context.site.resourcePath(for: Path(String(pathString)), with: context)
                didMatch = true
                return "\"\(replaced.absoluteString)\""
            } catch {
                return "\"\(pathString)\""
            }
        }
        
        string.replace(self.urlRegex) { match in
            let pathString = match[path]
            do {
                let replaced = try context.site.resourcePath(for: Path(String(pathString)), with: context)
                didMatch = true
                return "URL(\(replaced.absoluteString))"
            } catch {
                return "URL(\(pathString))"
            }
        }

        guard didMatch else { return input }
        return try PipelineTemporaryStageFile(from: input, with: string.data(using: .utf8)!, named: input.canonical.name)
    }
}
