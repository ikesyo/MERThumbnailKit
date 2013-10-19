##Architecture
`METhumbnailManager` is the principal class. You would generally create and use instance of it within an application. You can also use the `sharedManager` instance for convenience.

The family of methods descending from `addThumbnailOperationForURL:size:page:time:completion:` create thumbnail operations that are owned and managed by the instance of `METhumbnailManager`.

The `fileCacheURLForMemoryCacheKey:` and `memoryCacheKeyForURL:size:page:time:` methods provide access to the file cache url and memory cache key respectively. For example, on older devices, memory caching should be disabled.

By default, the thumbnail manager will cache to disk and memory. To alter this behavior set the `cacheOptions` property appropriately.

The method that creates the thumbnails resides in [UIImage+METKExtensions.h](https://github.com/MaestroElearning/METhumbnailKit/blob/master/METhumbnailKit/UIImage%2BMETKExtensions.h). This can be used stand alone, provided you already have a reference to the image you want to create a thumbnail of.

Because the thumbnail generation method uses the Accelerate framework, which relies on correctly formatted image data to do its thing; thumbnails created from incorrectly formatted images will contain visual artifacts.
##Supported Formats

The library supports the following UTIs:

* kUTTypeImage (public.image)
* kUTTypeMovie (public.movie)
* kUTTypePDF (com.adobe.pdf)
* kUTTypeRTF (public.rtf)
* kUTTypeRTFD (com.apple.rtfd)
* kUTTypePlainText (public.plain-text)
* kUTTypeHTML (public.html)

Additionally it supports Microsoft Office documents:

* Word (.doc, .docx)
* Powerpoint (.ppt, .pptx)
* Excel (.xls, .xlsx)

##Demo

The demo will load up anything it finds in a directory named "Files" within the main bundle. It creates and displays the thumbnails within a `UICollectionView`.