//
//  TapRecorderViewController.swift
//  TapRecorder
//
//  Created by Dongwoo Pae on 9/20/19.
//  Copyright © 2019 Dongwoo Pae. All rights reserved.
//

import UIKit
import AVFoundation

class TapRecorderViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {

    private var sampleAudioURL: URL? = Bundle.main.url(forResource: "piano", withExtension: "mp3")
    
    //MARK: outlets
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    private var player: AVAudioPlayer?
    private var recorder: AVAudioRecorder?
    
    //to store recorded file
    private var recordingURL: URL?
    
    private var isPlaying: Bool {
        return player?.isPlaying ?? false
    }
    
    private var isRecording: Bool {
        return recorder?.isRecording ?? false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    //MARK: IBAction
    @IBAction func recordButtonTapped(_ sender: Any) {
        defer{updateButtons()}  //as last this will get called
        
        guard !isRecording else {
            recorder?.stop()
            return
        }
        
        do {
            let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2)! //based on the recording quality and stereo/ mono? - cd audio quality and stereo
            recorder = try AVAudioRecorder(url: self.newRecordingURL(), format: format)
            recorder?.delegate = self
            recorder?.record()
        } catch {
            NSLog("Unable to start recording: \(error)")
        }
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        defer{updateButtons()}
        
        guard let url = self.recordingURL else {return}
        
        guard !isPlaying else {
            player?.stop()
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.play()
        } catch {
            NSLog("Unable to star playing: \(error)")
        }
    }
    
    //MARK: private methods
    
    private func updateButtons() {
        //for play button update
        let playButtonString = self.isPlaying ? "Stop Playing" : "Play" //ternary  operator
        self.playButton.setTitle(playButtonString, for: .normal)
        
        //for recording button update
        let recordButtonString = self.isRecording ? "Stop" : "Record"
        self.recordButton.setTitle(recordButtonString, for: .normal)
    }
    
    private func newRecordingURL() -> URL {
        let fm = FileManager.default
        let documentsDirectory = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        return documentsDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("caf")  //similar to mp3 caf is lighter way
    }
    
    //MARK: avaudioplayer/recorder delegate methods
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player = nil //we are creating a new instance later
        self.updateButtons()
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        self.recordingURL = recorder.url  //we need to know where the recorder was stored
        self.recorder = nil
        self.updateButtons()
    }
}

