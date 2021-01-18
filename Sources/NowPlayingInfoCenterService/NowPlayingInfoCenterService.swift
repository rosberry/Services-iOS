//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

public protocol HasNowPlayingInfoCenterService {

    var nowPlayingInfoCenterService: NowPlayingInfoCenterService { get }
}

public protocol NowPlayingInfoCenterService: class {

    func update(title: String, duration: TimeInterval)
    func update(isPlaying: Bool, seconds: Double)
    func update(playbackTime: Double)
    func resetPlaybackRateInfo()
    func removeInfo()
    func updateArtwork(with image: UIImage?)
}
