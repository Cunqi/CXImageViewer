//
//  CXImageViewer.swift
//
//
//  Created by Cunqi Xiao on 4/27/24.
//

import SwiftUI
import Combine

public struct CXImageViewer: UIViewRepresentable {
    public typealias UIViewType = CXImageViewerView
    
    // MARK: - Private properties
    
    @Binding private var image: UIImage?
    
    private var maxZoomLevel = CXImageViewerView.minZoomLevel
    
    private var zoomOutPublisher: AnyPublisher<Void, Never>?
    @State var cancellable: AnyCancellable?

    
    // MARK: - Initializer
    
    public init(image: Binding<UIImage?>,
                zoomOutPublisher: AnyPublisher<Void, Never>? = nil) {
        self._image = image
        self.zoomOutPublisher = zoomOutPublisher
    }
    
    // MARK: - Overrides
    
    public func makeUIView(context: Context) -> CXImageViewerView {
        let imageViewer = CXImageViewerView()
        
        if let publisher = zoomOutPublisher {
            cancellable = publisher.sink { _ in
                imageViewer.resetZoom()
            }
        }
        
        return imageViewer
    }
    
    public func updateUIView(_ uiView: CXImageViewerView, context: Context) {
        uiView.image = image
        uiView.maximumZoomScale = maxZoomLevel
    }
    
    public static func dismantleUIView(_ uiView: CXImageViewerView, coordinator: ()) {
        uiView.resetZoom()
        uiView.image = nil
    }
}

extension CXImageViewer {
    public func maxZoomLevel(_ maxZoomLevel: CGFloat) -> CXImageViewer {
        var imageViewer = self
        imageViewer.maxZoomLevel = maxZoomLevel
        return imageViewer
    }
}
