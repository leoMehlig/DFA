//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  Provides supporting functions for setting up a live view.
//

import UIKit
import PlaygroundSupport

/// Instantiates a new instance of a live view.
///
/// By default, this loads an instance of `LiveViewController` from `LiveView.storyboard`.
public func instantiateLiveView() -> LiveViewController {
    let storyboard = UIStoryboard(name: "LiveView", bundle: nil)

    let viewController = storyboard.instantiateViewController(withIdentifier: "page1")

    guard let liveViewController = viewController as? LiveViewController else {
        fatalError("LiveView.storyboard's initial scene is not a LiveViewController; please either update the storyboard or this function")
    }

    return liveViewController
}

public func instantiatePage2LiveView() -> LiveViewController {
    let storyboard = UIStoryboard(name: "LiveView", bundle: nil)

   let viewController = storyboard.instantiateViewController(withIdentifier: "page2")

    guard let liveViewController = viewController as? LiveViewController else {
        fatalError("LiveView.storyboard's initial scene is not a LiveViewController; please either update the storyboard or this function")
    }

    return liveViewController
}

public func instantiatePage4LiveView() -> LiveViewController {
    let storyboard = UIStoryboard(name: "LiveView", bundle: nil)

    let viewController = storyboard.instantiateViewController(withIdentifier: "me")

    guard let liveViewController = viewController as? LiveViewController else {
        fatalError("LiveView.storyboard's initial scene is not a LiveViewController; please either update the storyboard or this function")
    }

    return liveViewController
}



public func instantiatePage3LiveView() -> MapViewController {
    let storyboard = UIStoryboard(name: "LiveView", bundle: nil)

//    let viewController = storyboard.instantiateViewController(withIdentifier: "page3")
    let viewController = storyboard.instantiateInitialViewController()!

    guard let liveViewController = viewController as? MapViewController else {
        fatalError("LiveView.storyboard's initial scene is not a MapViewController; please either update the storyboard or this function")
    }

    return liveViewController
}

