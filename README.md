# CXImageViewer

An image viewer created for both plain swift and swiftUI use. 

It supports zoom in / out logic which mimics ios native photos app

* double tap to zoom in, the image viewer will try to track the tapped location as close as possible
* support pinch gesture recognizer to zoom in / out image
* allow customizing `maximumZoomScale`

To use the component, there are two scenarios:

### Swift

```Swift
let image = // prepare image
let imageViewer = CXImageViewer()
imageViewer.image = image
imageViewer.maximumZoomScale = 4.0
```

### SwiftUI

```Swift
CXImageViewer(image: $image, zoomLevel: .constant(1.0))
                    .maxZoomLevel(4.0)
```

### Screenshot

![Simulator Screen Recording - iPhone 15 - 2024-04-27 at 21 40 59](https://github.com/Cunqi/CXImageViewer/assets/8701790/ad3a6b94-cc2b-4fe1-9cce-bc16ff14ba3e)
