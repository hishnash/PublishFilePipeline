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
import RegexBuilder


public extension Plugin {
    static func pipeline(
        for pattern: Regex<Substring>,
        @PipelineBuilder with stages: @escaping () -> SingleFilePipelineStage
    ) -> Self {
        Plugin(name: "Pipeline") { context in
            PipelineState.shared.addPipeline(
                RegexPipeline(pattern: pattern, body: stages)
            )
        }
    }
    
    static func pipeline(
        forType: String,
        @PipelineBuilder with stages:  @escaping () -> ReducingFilePipelineStage
    ) -> Self {
        Plugin(name: "Pipeline") { context in
            PipelineState.shared.addPipeline(
                ReducingFileTypePipeline(fileType: forType, body: stages)
            )
        }
    }
    
    static func pipeline(
        @PipelineBuilder with stages:  @escaping () -> SingleFilePipelineStage
    ) -> Self {
        Plugin(name: "Pipeline") { context in
            PipelineState.shared.addPipeline(PlainPipeline(body: stages))
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
            let updatedHTML = html.replacing(htmLinkRegex) { match in
                let path = match[PATH]
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
    static func pipelineHTML<Site: Website>(with context: PublishingContext<Site>) -> Self {
        Modifier(target: .html) { html, markdown in
            
            let updatedHTML = html.replacing(htmLinkRegex) { match in
                let path = match[PATH]
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
    
}




fileprivate let PATH = Reference<Substring>()
fileprivate let htmLinkRegex = Regex {
    ChoiceOf {
        #"=""#
        Capture(as: PATH) {
            "/"
            CharacterClass.horizontalWhitespace.union(.anyOf(#"/"#)).inverted
            OneOrMore {
                CharacterClass.anyOf(#"""#).union(CharacterClass.horizontalWhitespace).inverted
            }
            "."
            OneOrMore {
                CharacterClass(.word)
            }
        }
        #"""#
    }
}
