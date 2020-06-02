//
//  ViewController.swift
//  AudioRecorder
//
//  Created by Paul Solt on 10/1/19.
//  Copyright © 2019 Lambda, Inc. All rights reserved.
//

import UIKit
import AVFoundation
class AudioRecorderController: UIViewController {
    
    private var timer: Timer?
    
    @IBOutlet var playButton: UIButton!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var timeElapsedLabel: UILabel!
    @IBOutlet var timeRemainingLabel: UILabel!
    @IBOutlet var timeSlider: UISlider!
    @IBOutlet var audioVisualizer: AudioVisualizer!
    
    private lazy var timeIntervalFormatter: DateComponentsFormatter = {
        // NOTE: DateComponentFormatter is good for minutes/hours/seconds
        // DateComponentsFormatter is not good for milliseconds, use DateFormatter instead)
        
        let formatting = DateComponentsFormatter()
        formatting.unitsStyle = .positional // 00:00  mm:ss
        formatting.zeroFormattingBehavior = .pad
        formatting.allowedUnits = [.minute, .second]
        return formatting
    }()
    
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use a font that won't jump around as values change
        timeElapsedLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeElapsedLabel.font.pointSize,
                                                          weight: .regular)
        timeRemainingLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeRemainingLabel.font.pointSize,
                                                                   weight: .regular)
        
        loadAudio()
    }
    
    deinit {
//        stop all timers if this screen is not visible.
        cancelTimer()
    }
    
    
    // MARK: - Timer
    
    func startTimer() {
        timer?.invalidate() // import to invalidate the timer to start a new one to prevent multiple timers.
        timer = Timer.scheduledTimer(withTimeInterval: 0.030, repeats: true) { [weak self] (_) in
            guard let self = self else { return }
            self.updateViews()
    //            if let audioRecorder = self.audioRecorder,
    //                self.isRecording == true {
    //
    //                audioRecorder.updateMeters()
    //                self.audioVisualizer.addValue(decibelValue: audioRecorder.averagePower(forChannel: 0))
    //
    //            }
    //
    //            if let audioPlayer = self.audioPlayer,
    //                self.isPlaying == true {
    //
    //                audioPlayer.updateMeters()
    //                self.audioVisualizer.addValue(decibelValue: audioPlayer.averagePower(forChannel: 0))
    //            }
        }
    }
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateViews() {
        playButton.isSelected = isPlaying // here we will know if the player is being selected and played.
        
        // we also want to update the timer & slider
//        TODO: Extract into helper computed properties.
        let elapsedTime = audioPlayer?.currentTime ?? 0 // use these values if it hasn't changed
        let duration = audioPlayer?.duration ?? 0
        //        TODO: -BUG That needs to be fixed is that the labels are not updating on time. fixed!
        let timeRemaining: TimeInterval = round(duration) - elapsedTime // assign to timeinterval to change the meaning
        // timer interval means seconds
        timeElapsedLabel.text = timeIntervalFormatter.string(from: elapsedTime)
        timeRemainingLabel.text = timeIntervalFormatter.string(from: timeRemaining)

        // fixing the timeslider
        timeSlider.minimumValue = 0
        timeSlider.maximumValue = Float(duration)
        timeSlider.value = Float(elapsedTime)

    }
    
    // MARK: - Playback
    
    var audioPlayer: AVAudioPlayer? {
        didSet {
            audioPlayer?.delegate = self // tell me when it finishes playing/ errors
        }
    }
    
    var isPlaying: Bool { // business app logic
        return audioPlayer?.isPlaying ?? false // if it is not player turn it to false as default value
    }
    
    
    func loadAudio() {
        let songURL = Bundle.main.url(forResource: "piano", withExtension: "mp3")!
        
        //FUTURE: Do more error checking and fail early if perogrammer error, or present a message to user.
        audioPlayer = try? AVAudioPlayer(contentsOf: songURL) // wil be nil if this fails
        
        
    }
    
    /*
    func prepareAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
        try session.setActive(true, options: []) // can fail if on a phone call, for instance
    }
    */
    func togglePlayback() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    
    func play() {
        audioPlayer?.play() // don't crash if player is nil, if nothing to play, just don't do anything.
        startTimer()
        updateViews()
    }
    
    func pause() {
        audioPlayer?.pause()
        cancelTimer()
        updateViews()
    }
    
 
    
    // MARK: - Recording
    
    var recordingURL: URL?
    
    
    
    func createNewRecordingURL() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
        let file = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")
        
//        print("recording URL: \(file)")
        
        return file
    }
    
    /*
    func requestPermissionOrStartRecording() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                guard granted == true else {
                    print("We need microphone access")
                    return
                }
                
                print("Recording permission has been granted!")
                // NOTE: Invite the user to tap record again, since we just interrupted them, and they may not have been ready to record
            }
        case .denied:
            print("Microphone access has been blocked.")
            
            let alertController = UIAlertController(title: "Microphone Access Denied", message: "Please allow this app to access your Microphone.", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Open Settings", style: .default) { (_) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            })
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            
            present(alertController, animated: true, completion: nil)
        case .granted:
            startRecording()
        @unknown default:
            break
        }
    }
    */
    
    func startRecording() {
        
    }
    
    func stopRecording() {
        
    }
    
    // MARK: - Actions
    
    @IBAction func togglePlayback(_ sender: Any) {
        togglePlayback()
    }
    
    @IBAction func updateCurrentTime(_ sender: UISlider) {
        
    }
    
    @IBAction func toggleRecording(_ sender: Any) {
        
    }
}
//Delegate
//Asking someone else to do something fopr you
//1. action pick up a coffee- starbucks
extension AudioRecorderController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.updateViews()
        }
        
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print(error)
        }
      DispatchQueue.main.async {
            self.updateViews()
        }
    }
}
