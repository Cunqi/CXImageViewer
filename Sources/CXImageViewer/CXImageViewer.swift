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
    
    /// Combine using with index, this will be used to handle reset zoom
    /// after the index switched
    @Binding private var currentIndex: Int?
    @Binding private var isZooming: Bool
    
    private var maxZoomLevel = CXImageViewerView.minZoomLevel
    private var index: Int
    
    // MARK: - Initializer
    
    public init(image: Binding<UIImage?>, at index: Int = 0) {
        self._image = image
        self.index = index
        self._currentIndex = .constant(0)
        self._isZooming = .constant(false)
    }
    
    // MARK: - Overrides
    
    public func makeUIView(context: Context) -> CXImageViewerView {
        let viewer = CXImageViewerView()
        viewer.viewerDelegate = context.coordinator
        return viewer
    }
    
    public func updateUIView(_ uiView: CXImageViewerView, context: Context) {
        uiView.image = image
        uiView.maximumZoomScale = maxZoomLevel
        zoomOutIfNeeded(viewer: uiView)
    }
    
    public static func dismantleUIView(_ uiView: CXImageViewerView, coordinator: ()) {
        uiView.resetZoom(animated: false)
        uiView.image = nil
    }
    
    // MARK: - Private methods
    
    private func zoomOutIfNeeded(viewer: CXImageViewerView) {
        guard index != currentIndex,
              viewer.zoomScale > CXImageViewerView.minZoomLevel else {
            return
        }
        viewer.resetZoom(animated: false)
    }
}

extension CXImageViewer {
    public class Coordinator: NSObject, CXImageViewerViewDelegate {
        
        // MARK: - Internal properties
        
        var parent: CXImageViewer
        
        // MARK: - Initializer
        
        init(parent: CXImageViewer) {
            self.parent = parent
        }
        
        // MARK: - CXImageViewerViewDelegate
        
        public func imageViewer(didZoom view: CXImageViewerView, isZooming: Bool) {
            parent.isZooming = isZooming
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

extension CXImageViewer {
    public func maxZoomLevel(_ maxZoomLevel: CGFloat) -> Self {
        var imageViewer = self
        imageViewer.maxZoomLevel = maxZoomLevel
        return imageViewer
    }
    
    public func index(_ index: Int) -> Self {
        var imageViewer = self
        imageViewer.index = index
        return imageViewer
    }
    
    public func currentIndex(_ currentIndex: Binding<Int?>) -> Self {
        var imageViewer = self
        imageViewer._currentIndex = currentIndex
        return imageViewer
    }
    
    public func isZooming(_ isZooming: Binding<Bool>) -> Self {
        var imageViewer = self
        imageViewer._isZooming = isZooming
        return imageViewer
    }
}
