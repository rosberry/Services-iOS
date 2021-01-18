//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import MediaPlayer

extension MPNowPlayingInfoCenter: NowPlayingInfoCenterService {

    public func update(title: String, duration: TimeInterval) {
        nowPlayingInfo = [
            MPMediaItemPropertyTitle: title,
            MPMediaItemPropertyPlaybackDuration: NSNumber(value: duration)
        ]
    }

    public func update(isPlaying: Bool, seconds: Double) {
        DispatchQueue.main.async {
            self.update(rate: isPlaying ? 1 : 0)
            self.update(playbackTime: seconds)
            if #available(iOS 13.0, *) {
                self.playbackState = isPlaying ? .playing : .paused
            }
        }
    }

    public func update(rate: Int) {
        nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = rate
    }

    public func update(playbackTime: Double) {
        nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playbackTime
    }

    public func resetPlaybackRateInfo() {
        update(rate: 0)
    }

    public func removeInfo() {
        nowPlayingInfo = nil
    }

    public func updateArtwork(with image: UIImage?) {
        guard let image = image else {
            return
        }

        let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in
            return image
        }
        update(artwork)
    }

    public func update(_ artwork: MPMediaItemArtwork) {
        nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
    }
}
