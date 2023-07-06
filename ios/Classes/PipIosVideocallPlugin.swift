import Flutter
import UIKit
import AVKit
import Foundation

public class PipIosVideocallPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "pip_ios_videocall", binaryMessenger: registrar.messenger())
    let instance = PipIosVideocallPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch (call.method) {
        case "createPiP":
            // Configurar Picture in Picture
            let videoURLString = "http://example.arbiotica.com/assets/videos/OBRA-AMBIENTAL.mp4"
            if let videoURL = URL(string: videoURLString) {
                let player = AVPlayer(url: videoURL)
                
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                
                // Presentar el reproductor de video en el modo Picture in Picture
                if AVPictureInPictureController.isPictureInPictureSupported() {
                    let pictureInPictureController = AVPictureInPictureController(playerLayer: playerViewController.playerLayer)
                    pictureInPictureController.startPictureInPicture()
                }
            }
            
            result(true)
            break
        case "disposePiP":
            // Detener Picture in Picture si es necesario
            if AVPictureInPictureController.isPictureInPictureSupported() {
                AVPictureInPictureController.shared.stopPictureInPicture()
            }
            
            result(true)
            break
        default:
            result(FlutterMethodNotImplemented)
            break
        }
  }
}

class ViewController: UIViewController, AVPictureInPictureControllerDelegate {
    var playerViewController: AVPlayerViewController!
    var pictureInPictureController: AVPictureInPictureController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configurar el reproductor de video
        let videoURL = URL(string: "http://example.arbiotica.com/assets/videos/OBRA-AMBIENTAL.mp4")!
        let player = AVPlayer(url: videoURL)
        playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        // Configurar el controlador Picture in Picture
        pictureInPictureController = AVPictureInPictureController(playerLayer: playerViewController.playerLayer)
        pictureInPictureController.delegate = self
        
        // Presentar el reproductor de video
        present(playerViewController, animated: true) {
            self.playerViewController.player?.play()
        }
    }
    
    // Implementar el delegado de AVPictureInPictureController para controlar el estado de Picture in Picture
    func pictureInPictureControllerDidStartPictureInPicture(_ controller: AVPictureInPictureController) {
        // La reproducción entró en el modo Picture in Picture
        // Realizar acciones adicionales si es necesario
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ controller: AVPictureInPictureController) {
        // La reproducción salió del modo Picture in Picture
        // Realizar acciones adicionales si es necesario
    }
}