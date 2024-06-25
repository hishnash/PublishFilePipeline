import XCTest
import Publish
import Plot
@testable import PublishFilePipeline
import RegexBuilder

struct Site: Website {
    var url: URL = URL(string: "https://example.com")!
    
    enum SectionID: String, WebsiteSectionID {
        case blog
    }
    
    typealias ItemMetadata = Array<String>
    
    var name: String
    
    var description: String
    
    var language: Plot.Language  = .english
    
    var imagePath: Publish.Path?
}

final class PublishFilePipelineTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let p = PlainPipeline {
            DropCommentsStage(prefix: "//")
            StringReplaceStage()
            CacheBustStage()
        }
        print(p)
        
        @PipelineBuilder var builder: ReducingFilePipelineStage {
            DropCommentsStage(prefix: "//")
            StringReplaceStage()
            FileMergeStage(fileExtension: "bob")
            StringReplaceStage()
            CacheBustStage()
        }
        
        
        _ = Plugin<Site>.pipeline(forType: "css") {
            DropCommentsStage(prefix: "//")
            StringReplaceStage()
            FileMergeStage(fileExtension: "bob")
            CacheBustStage()
        }
        
        _ = Plugin<Site>.pipeline(
            for: Regex {
                ".png"
                Anchor.endOfLine
            }
        ) {
            ImageResizeStage(targetWidthInPoints: 300, scale: .three)
            ImageAsJPEGStage()
            CacheBustStage()
        }
        
        
        _ = Plugin<Site>.pipeline {
            CacheBustStage()
        }
        
        
        
        print(builder)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
