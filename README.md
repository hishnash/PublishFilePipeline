# PublishFilePipeline

This package aims to provide a simple way to add file prossing pipelines to the Resources when using [Publish](https://github.com/johnsundell/publish).

common usage is to add a hash to the resources filenames. This package supports doing this, and ensures that the links throughout your blog that link to these hased files are correct.

## Usage

```swift
// This will generate your website using the built-in Foundation theme:
try MyWebSite().pipelinePublish(
    withTheme: .container,
    plugins: [
        .pipeline(forType: "css") {                  // Run on all CSS files combining them into a single output file
            DropCommentsStage(prefix: "//")          // Drop any comments from the CSS file
            StringReplaceStage()                     // Resolve any urls within the css file that are not absolute
            FileMergeStage("/static/merged.css")     // Merge all CSS files into a single file
            CacheBustStage()                         //  Cache bust the merged result
        },
        .pipeline(
            for: Regex {
                ".png"
                Anchor.endOfLine
            }  // For each PNG file separately 
        ) {
            ImageAsJEPGStage()
            CacheBustStage()
        },
        .pipeline {
            CacheBustStage()                          // For all other files inject hash into file name to bust cache
        },
        .markdownPipeline
    ]
)
```

This includes 3 differnt plugins.

### Merging all txt based `Resources` that link to other `Resources`

When adding the hash of a file to its filename it is important that all links to this file are updated, this includes links to this file that exist from within your ``Resources`` such as ``CSS`` that might sometimes like the background images.

```swift
.pipeline(forType: "css") {                  // Run on all CSS files
    DropCommentsStage(prefix: "//")          // Drop any comments from the CSS file (run on each file separately)
    StringReplaceStage()                     // Resolve any urls within the css file that are not absolute 
    FileMergeStage("/static/merged.css")     // Merge all CSS files into a single file located at "/static/merged.css"
    CacheBustStage()                         // Cache bust the merged result
}
```

This will setup a filter to match all files ending in `.css`, so that first the file has any refrences to other `Resources`` replaced with the final output filename then it is hashed. This means that if a background image is changed (and thus its hashed filename changes) any css that points at this image will also be changed and its hash will be updated so that browser cache issues to not impact your users.  This merges all `css` files into a single file.

### Handling files by regex match individually 

```swift
.pipeline(
    for: Regex {
        ".png"
        Anchor.endOfLine
    }  // For each PNG file separately 
) {
    ImageAsJPEGStage()
    CacheBustStage()
}
```

This will apply to all files individually that match the regex. In this case it will convert the file to a JPEG and then cache bust it. 

### Handling all other file types

```swift
.pipeline {
    CacheBustStage()
}
```


This should be the last ``.pipeline`` plugin you define it will catch any files that are not matched by the above filters. In this case it will then hash them and copy the file with the hash in the filename.


### Handling links to your files

```swift
.markdownPipeline
```

This will attempt to match any links you have to files in your Resousre folder and change them to point to the new filenames (that include the hash).


In your theme template you might also need to refrences files (such as css etc). You can ask for the output (hashed) filename:

```swift
site.resourcePath(for: "/static/red-moa.svg", with: context)
```


### Refrencing files with mutations

Sometimes when you reference an image you might want a resized or converted version of the image.

```swift
site.resourcePath(for: "/static/red-moa.png", with: context) {
    ImageResizeStage(targetWidthInPoints: 300, scale: .three)
    ImageAsJPEGStage()
}
```

This will return the path for the `red-moa` image resized to be `3x at 300pt` converted to JPEG and then run through the standard pipeline (likely cache busting).  

You can use this to have the build process resize your image to allow you to have a single image in your project but have it sized to fit the use cases it is used in. 


### How does it work


* When refrencing a file if it is not yet refrences it runs it through a pipeline and adds it to the set of pipelined files.
* When refrecing a file if that file is alreayd pipelined then it just returns the canonical URL.


