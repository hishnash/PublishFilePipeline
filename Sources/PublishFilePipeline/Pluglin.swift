//
//  File.swift
//  
//
//  Created by Matthaus Woolard on 05/04/2020.
//

import Foundation
import Publish
import Ink
import Plot
import RegEx


public extension Plugin {
    static func pipeline(for patern: RegEx, with stages: [PipelineStage]) -> Self {
        Plugin(name: "Pipeline") { context in
            installedPipelines.append(.files(regex: patern, with: PublishPipeline(stages)))
        }
    }
    static func pipeline(with stages: [PipelineStage]) -> Self {
        Plugin(name: "Pipeline") { context in
            installedPipelines.append(.any(with: PublishPipeline(stages)))
        }
    }
    
    static var markdownPipeline: Self {
        Plugin(name: "MarkdownPipeline") { context in
            context.markdownParser.addModifier(
                .pipelineImages
            )
            context.markdownParser.addModifier(
                .pipelineLinks(with: context)
            )
            context.markdownParser.addModifier(
                .pipelineHTML(with: context)
            )
        }
    }
}

public extension Modifier {
    static var pipelineImages: Self {
        return Modifier(target: .images) { html, markdown in
            var markdown = markdown.dropFirst("```".count)

            guard !markdown.hasPrefix("no-highlight") else {
                return html
            }

            markdown = markdown
                .drop(while: { !$0.isNewline })
                .dropFirst()
                .dropLast("\n```".count)

            return "abc"
        }
    }
    
    static func pipelineLinks<Site: Website>(with context: PublishingContext<Site>) -> Self {
        return Modifier(target: .links) { html, markdown in
            let result = Modifier.regex.replaceMatches(in: html)  { match in
               guard let path = match.values[1] else {
                   return ""
               }
               do {
                   let mappedPath = try context.site.resourcePath(for: Path(String(path)), with: context)
                   return mappedPath.string
               } catch {
                   return String(match.values[0] ?? "")
               }
               
           }
           return result
       }
   }
    static func pipelineHTML<Site: Website>(with context: PublishingContext<Site>) -> Self {
        Modifier(target: .html) { html, markdown in
            let updatedHTML = Modifier.regex.replaceMatches(in: html)  { match in
                guard let path = match.values[1] else {
                    return ""
                }
                do {
                    let mappedPath = try context.site.resourcePath(for: Path(String(path)), with: context)
                    return mappedPath.string
                } catch {
                    fatalError("Unable to find file for `\(String(path))`")
                }
                
            }
            return updatedHTML
       }
   }
    static let regex: RegEx = try! RegEx(pattern: #"(?<!https:/)(?<!http:/)(?<=["\s])(/[^/]{1}[^"\s]+\.[a-z]{1,})"#)
//    static let a = #"(?<!https:/)(?<!http:/)(/[^/]{1}[^"\s]+\.[a-z]{1,})"#
}


