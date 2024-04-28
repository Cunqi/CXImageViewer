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
    @Binding private var zoomLevel: CGFloat
    
    private var maxZoomLevel = CXImageViewerView.minZoomLevel
    
    // MARK: - Initializer
    
    public init(image: Binding<UIImage?>, zoomLevel: Binding<CGFloat>) {
        self._image = image
        self._zoomLevel = zoomLevel
    }
    
    // MARK: - Overrides
    
    public func makeUIView(context: Context) -> CXImageViewerView {
        CXImageViewerView()
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
