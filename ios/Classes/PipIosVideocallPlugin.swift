import UIKit
import Flutter
import Foundation

import AVKit
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    lazy var flutterEngine = FlutterEngine(name: "FlutterEngine")
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Runs the default Dart entrypoint with a default Flutter route.
        flutterEngine.run();
         
        let controller =
        FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil) 
       /*  let controller : FlutterViewController = window?.rootViewController as! FlutterViewController  */
        let nativeCallChannel = FlutterMethodChannel(name: "pip_ios_videocall",binaryMessenger: controller.binaryMessenger)
        
        nativeCallChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping  FlutterResult)  -> Void in
            switch (call.method) {
            case "createPiP":
                let arguments = call.arguments as? [String: Any] ?? [String: Any]()
                let remoteStreamId = arguments["remoteStreamId"] as? String ?? ""
                let peerConnectionId = arguments["peerConnectionId"] as? String ?? ""
                let isRemoteCameraEnable = arguments["isRemoteCameraEnable"] as? Bool ?? false
                let myAvatar = arguments["myAvatar"] as? String ?? ""
               
                
                RanaViewController.shared.configurationPictureInPicture(result: result, peerConnectionId: peerConnectionId, remoteStreamId: remoteStreamId, isRemoteCameraEnable: isRemoteCameraEnable, myAvatar: myAvatar)
                
                break
            case "disposePiP":
                RanaViewController.shared.disposePictureInPicture()
                result(true)
                break
            default:
                result(FlutterMethodNotImplemented)
                break
            }
        })
        
        
        GeneratedPluginRegistrant.register(with: self)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}



class RanaViewController: FlutterViewController {
    // MARK: Singleton
    static let shared = RanaViewController()
    
    // MARK: Public static variables
    static var pipController: AVPictureInPictureController? = nil
    static var pipContentSource: Any? = nil
    static var pipVideoCallViewController: Any? = nil
    
    // MARK: Private variables
    private var pictureInPictureView: PictureInPictureView = PictureInPictureView()
    
    open override func viewDidLoad() {
        // get the flutter engine for the view
        let flutterEngine: FlutterEngine! = (UIApplication.shared.delegate as! AppDelegate).flutterEngine
        
        // add flutter view
        addFlutterView(with: flutterEngine)
        
        preparePictureInPicture()
    }
    
    func preparePictureInPicture() {
        if #available(iOS 15.0, *) {
            RanaViewController.pipVideoCallViewController = AVPictureInPictureVideoCallViewController()
            (RanaViewController.pipVideoCallViewController as! AVPictureInPictureVideoCallViewController).preferredContentSize = CGSize(width: Sizer.WIDTH_OF_PIP, height: Sizer.HEIGHT_OF_PIP)
            (RanaViewController.pipVideoCallViewController as! AVPictureInPictureVideoCallViewController).view.clipsToBounds = true
            
            RanaViewController.pipContentSource = AVPictureInPictureController.ContentSource(
                activeVideoCallSourceView: self.view,
                contentViewController: (RanaViewController.pipVideoCallViewController as! AVPictureInPictureVideoCallViewController)
            )
        }
    }
    
    func configurationPictureInPicture(result: @escaping  FlutterResult, peerConnectionId: String, remoteStreamId: String, isRemoteCameraEnable: Bool, myAvatar: String) {
        if #available(iOS 15.0, *) {
            if (RanaViewController.pipContentSource != nil) {
                RanaViewController.pipController = AVPictureInPictureController(contentSource: RanaViewController.pipContentSource as! AVPictureInPictureController.ContentSource)
                RanaViewController.pipController?.canStartPictureInPictureAutomaticallyFromInline = true
                RanaViewController.pipController?.delegate = self
                
                // Add view
                let frameOfPiP = (RanaViewController.pipVideoCallViewController as! AVPictureInPictureVideoCallViewController).view.frame
                pictureInPictureView = PictureInPictureView(frame: frameOfPiP)
                pictureInPictureView.contentMode = .scaleAspectFit
                pictureInPictureView.initParameters(peerConnectionId: peerConnectionId, remoteStreamId: remoteStreamId, isRemoteCameraEnable: isRemoteCameraEnable, myAvatar: myAvatar)
                pictureInPictureView.configurationLayoutConstraintUserNameCard()
                (RanaViewController.pipVideoCallViewController as! AVPictureInPictureVideoCallViewController).view.addSubview(pictureInPictureView)
                
                addConstraintLayout()
            }
        }
        
        result(true)
    }
    
    func addConstraintLayout() {
        if #available(iOS 15.0, *) {
            pictureInPictureView.translatesAutoresizingMaskIntoConstraints = false
            let constraints = [
                pictureInPictureView.leadingAnchor.constraint(equalTo: (RanaViewController.pipVideoCallViewController as! AVPictureInPictureVideoCallViewController).view.leadingAnchor),
                pictureInPictureView.trailingAnchor.constraint(equalTo: (RanaViewController.pipVideoCallViewController as! AVPictureInPictureVideoCallViewController).view.trailingAnchor),
                pictureInPictureView.topAnchor.constraint(equalTo: (RanaViewController.pipVideoCallViewController as! AVPictureInPictureVideoCallViewController).view.topAnchor),
                pictureInPictureView.bottomAnchor.constraint(equalTo: (RanaViewController.pipVideoCallViewController as! AVPictureInPictureVideoCallViewController).view.bottomAnchor)
            ]
            (RanaViewController.pipVideoCallViewController as! AVPictureInPictureVideoCallViewController).view.addConstraints(constraints)
            pictureInPictureView.bounds = (RanaViewController.pipVideoCallViewController as! AVPictureInPictureVideoCallViewController).view.frame
        }
    }
    
    func updatePictureInPictureView(_ result: @escaping FlutterResult, isRemoteCameraEnable: Bool) {
        pictureInPictureView.updateStateValue(isRemoteCameraEnable: isRemoteCameraEnable)
        result(true)
    }
    
    func disposePictureInPicture() {
        // MARK: reset
        pictureInPictureView.disposeVideoView()
        
        if #available(iOS 15.0, *) {
            (RanaViewController.pipVideoCallViewController as! AVPictureInPictureVideoCallViewController).view.removeAllSubviews()
        }
        
        if (RanaViewController.pipController == nil) {
            return
        }
        
        RanaViewController.pipController = nil
    }
    
    func stopPictureInPicture() {
        if #available(iOS 15.0, *) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
               RanaViewController.pipController?.stopPictureInPicture()
            }
        }
    }
}

extension RanaViewController: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print(">> pictureInPictureControllerWillStopPictureInPicture")
        self.pictureInPictureView.stopPictureInPictureView()
    }
    
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print(">> pictureInPictureControllerWillStartPictureInPicture")
        self.pictureInPictureView.updateLayoutVideoVideo()
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print("Unable start pip error:", error.localizedDescription)
    }
}


// create an extension for all UIViewControllers
extension UIViewController {
    /**
     Add a flutter sub view to the UIViewController
     sets constraints to edge to edge, covering all components on the screen
     */
    func addFlutterView(with engine: FlutterEngine) {
        // create the flutter view controller
        let flutterViewController = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
        
        addChild(flutterViewController)
        
        guard let flutterView = flutterViewController.view else { return }
        
        // allows constraint manipulation
        flutterView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(flutterView)
        
        // set the constraints (edge-to-edge) to the flutter view
        let constraints = [
            flutterView.topAnchor.constraint(equalTo: view.topAnchor),
            flutterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            flutterView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            flutterView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        
        // apply (activate) the constraints
        NSLayoutConstraint.activate(constraints)
        
        flutterViewController.didMove(toParent: self)
        
        // updates the view with configured layout
        flutterView.layoutIfNeeded()
    }
}




enum Sizer {
    static let WIDTH_OF_PIP: CGFloat = 450
    static let HEIGHT_OF_PIP: CGFloat = 800
}


extension UIView {
    func setHeight(_ h:CGFloat, animateTime:TimeInterval?=nil) {

        if let c = self.constraints.first(where: { $0.firstAttribute == .height && $0.relation == .equal }) {
            c.constant = CGFloat(h)

            if let animateTime = animateTime {
                UIView.animate(withDuration: animateTime, animations:{
                    self.superview?.layoutIfNeeded()
                })
            }
            else {
                self.superview?.layoutIfNeeded()
            }
        }
    }
    
    func setWidth(_ w:CGFloat, animateTime:TimeInterval?=nil) {

        if let c = self.constraints.first(where: { $0.firstAttribute == .width && $0.relation == .equal }) {
            c.constant = CGFloat(w)

            if let animateTime = animateTime {
                UIView.animate(withDuration: animateTime, animations:{
                    self.superview?.layoutIfNeeded()
                })
            }
            else {
                self.superview?.layoutIfNeeded()
            }
        }
    }
}

extension UIView {
    /// Remove all subview until has 1 view
    func removeSubviewsUntil1View() {
        for (index, element) in subviews.enumerated() {
            if (index < subviews.count - 1) {
                element.removeFromSuperview()
            }
        }
    }
    
    // Remove all subview
    func removeAllSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }

    /// Remove all subview with specific type
    func removeAllSubviews<T: UIView>(type: T.Type) {
        subviews
            .filter { $0.isMember(of: type) }
            .forEach { $0.removeFromSuperview() }
    }
}


class UserCardView: UIView {
    private var userName: UILabel = UILabel()
    private var avatar: UIImageView = UIImageView()
    
    
    // MARK: init
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUserName(userName: String) {
        self.userName.text = userName
    }
    
    func setAvatar(avatar: String) {
        if (!avatar.isEmpty) {
            let url = URL(string: avatar)
            if (url != nil) {
                self.downloadImage(from: url!)
            }
        }
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            // always update the UI from the main thread
            DispatchQueue.main.async() {
                self.avatar.image = UIImage(data: data)
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Text
        userName.font = .systemFont(ofSize: bounds.width / 14, weight: .heavy)
        
        // Avatar
        avatar.layer.borderWidth = avatar.frame.width / 180
        avatar.layer.masksToBounds = false
        avatar.layer.borderColor = UIColor.white.cgColor
        avatar.layer.cornerRadius = avatar.frame.width / 2
        avatar.clipsToBounds = true
    }
    
    // MARK: make view
    func setupView() {
        // MARK: username
        userName = UILabel()
        userName.numberOfLines = 1
        userName.adjustsFontSizeToFitWidth = true
        userName.minimumScaleFactor = 0.5
        userName.textAlignment = .left
        userName.textColor = .white
        
        // MARK: avatar
        avatar = UIImageView()
        avatar.contentMode = .scaleAspectFit
        avatar.image = UIImage(named: "avatar_default")
        
        addSubview(avatar)
        addSubview(userName)
        
        self.addLayoutConstraint()
    }
    
    func addLayoutConstraint() {
        avatar.translatesAutoresizingMaskIntoConstraints = false
        userName.translatesAutoresizingMaskIntoConstraints = false
        
        userName.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
        userName.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        userName.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.935).isActive = true
        userName.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.15).isActive = true
        
        avatar.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.28).isActive = true
        avatar.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.28).isActive = true
        addConstraint(NSLayoutConstraint(item: avatar, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: avatar, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }
}



class PictureInPictureView: UIView {
    // MARK: Private
    private var myUserNameCard: UserCardView = UserCardView()
    private var localView: UIView = UIView()
    private var peerConnectionId: String? = nil
    private var remoteStreamId: String? = nil
    private var isLocalCameraEnable: Bool = false
    private var isRemoteCameraEnable: Bool = false
    
    private var pictureInPictureIsRunning: Bool = false
    
    // MARK: Funcs
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        // MARK: Setup subviews
        localView = UIView()
        localView.clipsToBounds = true
        
        // MARK: add to parent view
        addSubview(localView)
        configurationLayoutConstrains()
        
        // MARK: add user card view to subviews
        self.addAvatarView()
        self.configurationLayoutConstraintUserNameCard()
    }
    
    func addAvatarView() {
        // Add local and remote avatar
        myUserNameCard = UserCardView()
        myUserNameCard.setUserName(userName: "You")
        myUserNameCard.contentMode = .scaleAspectFit
        localView.addSubview(myUserNameCard)
    }
    
    func initParameters(peerConnectionId: String, remoteStreamId: String, isRemoteCameraEnable: Bool, myAvatar: String) {
        self.peerConnectionId = peerConnectionId
        self.remoteStreamId = remoteStreamId
        self.isRemoteCameraEnable = isRemoteCameraEnable
        
        self.myUserNameCard.setAvatar(avatar: myAvatar)
    }
    
    func updateStateValue(isRemoteCameraEnable: Bool) {
        if (self.isRemoteCameraEnable != isRemoteCameraEnable) {
            self.isRemoteCameraEnable = isRemoteCameraEnable
            
            if (!self.pictureInPictureIsRunning) {
                return
            }
            
            if (self.isRemoteCameraEnable) {
                self.addRemoteRendererToView()
            } else {
            
            }
        }
    }
    
    func configurationLayoutConstrains() {
        // Enable Autolayout
        localView.translatesAutoresizingMaskIntoConstraints = false
        
        localView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        localView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
        localView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        localView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    }
    
    func configurationLayoutConstraintForRenderer() {
             
    }
    
    func configurationLayoutConstraintUserNameCard() {
        myUserNameCard.translatesAutoresizingMaskIntoConstraints = false
        
        let constraintsLocal = [
            self.myUserNameCard.leadingAnchor.constraint(equalTo: localView.leadingAnchor),
            self.myUserNameCard.trailingAnchor.constraint(equalTo: localView.trailingAnchor),
            self.myUserNameCard.topAnchor.constraint(equalTo: localView.topAnchor),
            self.myUserNameCard.bottomAnchor.constraint(equalTo: localView.bottomAnchor)
        ]
    
        self.localView.addConstraints(constraintsLocal)
        self.myUserNameCard.bounds = self.localView.frame
    }
    
    func configurationVideoView() {
        if (remoteStreamId == nil || peerConnectionId == nil) {
            return
        }
        
        if #available(iOS 15.0, *) {
            // Remote
            if (self.isRemoteCameraEnable) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    self.addRemoteRendererToView()
                }
            }
        }
    }
    
    func addRemoteRendererToView() {
     
    }
    
    func updateLayoutVideoVideo() {
        self.stopPictureInPictureView()
        
        self.pictureInPictureIsRunning = true
        self.myUserNameCard.isHidden = false
        
        // MARK: add video view
        self.configurationVideoView()
    }
    
    
    // MARK: release variables
    func disposeVideoView() {
        remoteStreamId = nil
        peerConnectionId = nil
    }
    
    func stopPictureInPictureView() {
        self.pictureInPictureIsRunning = false
        self.myUserNameCard.isHidden = true
       
    }
}


// import Flutter
// import UIKit
// import AVKit
// import Foundation

// public class PipIosVideocallPlugin: NSObject, FlutterPlugin {
//   public static func register(with registrar: FlutterPluginRegistrar) {
//     let channel = FlutterMethodChannel(name: "pip_ios_videocall", binaryMessenger: registrar.messenger())
//     let instance = PipIosVideocallPlugin()
//     registrar.addMethodCallDelegate(instance, channel: channel)
//   }

//   public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//     switch (call.method) {
//       case "createPiP":
//           let arguments = call.arguments as? [String: Any] ?? [String: Any]()
//           let remoteStreamId = arguments["remoteStreamId"] as? String ?? ""
//           let peerConnectionId = arguments["peerConnectionId"] as? String ?? ""
//           let isRemoteCameraEnable = arguments["isRemoteCameraEnable"] as? Bool ?? false
//           let myAvatar = arguments["myAvatar"] as? String ?? ""
          
          
//           RanaViewController.shared.configurationPictureInPicture(result: result, peerConnectionId: peerConnectionId, remoteStreamId: remoteStreamId, isRemoteCameraEnable: isRemoteCameraEnable, myAvatar: myAvatar)
          
//           break
//       case "disposePiP":
//           RanaViewController.shared.disposePictureInPicture()
//           result(true)
//           break
//       default:
//           result(FlutterMethodNotImplemented)
//           break
//       }
//   }
// }



// class RanaViewController: FlutterViewController {
//     // MARK: Singleton
//     static let shared = RanaViewController()
    
//     // MARK: Public static variables
//     static var pipController: AVPictureInPictureController? = nil
//     static var pipContentSource: Any? = nil
//     static var pipVideoCallViewController: Any? = nil
    
//     // MARK: Private variables
//     private var pictureInPictureView: PictureInPictureView = PictureInPictureView()
    
//     open override func viewDidLoad() {
//         // get the flutter engine for the view
//         let flutterEngine: FlutterEngine! = (UIApplication.shared.delegate as! AppDelegate).flutterEngine
        
//         // add flutter view
//         addFlutterView(with: flutterEngine)
        
//         preparePictureInPicture()
//     }
    
//     func preparePictureInPicture() {
//         if #available(iOS 15.0, *) {
//             RanaViewController.pipVideoCallViewController = AVPictureInPictureVideoCallViewController()
//             (RanaViewController.pipVideoCallViewController as! AVPictureInPictureVideoCallViewController).preferredContentSize = CGSize(width: Sizer.WIDTH_OF_PIP, height: Sizer.HEIGHT_OF_PIP)
//             (RanaViewController.pipVideoCallViewController as! AVPictureInPictureVideoCallViewController).view.clipsToBounds = true
            
//             RanaViewController.pipContentSource = AVPictureInPictureController.ContentSource(
//                 activeVideoCallSourceView: self.view,
//                 contentViewController: (RanaViewController.pipVideoCallViewController as! AVPictureInPictureVideoCallViewController)
//             )
//         }
//     }
    
//     func configurationPictureInPicture(result: @escaping  FlutterResult, peerConnectionId: String, remoteStreamId: String, isRemoteCameraEnable: Bool, myAvatar: String) {
//         if #available(iOS 15.0, *) {
//             if (RanaViewController.pipContentSource != nil) {
//                 RanaViewController.pipController = AVPictureInPictureController(contentSource: RanaViewController.pipContentSource as! AVPictureInPictureController.ContentSource)
//                 RanaViewController.pipController?.canStartPictureInPictureAutomaticallyFromInline = true
//                 RanaViewController.pipController?.delegate = self
                
//                 // Add view
//                 let frameOfPiP = (RanaViewController.pipVideoCallViewController as! AVPictureInPictureVideoCallViewController).view.frame
//                 pictureInPictureView = PictureInPictureView(frame: frameOfPiP)
//                 pictureInPictureView.contentMode = .scaleAspectFit
//                 pictureInPictureView.initParameters(peerConnectionId: peerConnectionId, remoteStreamId: remoteStreamId, isRemoteCameraEnable: isRemoteCameraEnable, myAvatar: myAvatar)
//                 pictureInPictureView.configurationLayoutConstraintUserNameCard()
//                 (RanaViewController.pipVideoCallViewController as! AVPictureInPictureVideoCallViewController).view.addSubview(pictureInPictureView)
                
//                 addConstraintLayout()
//             }
//         }
        
//         result(true)
//     }
    
//     func addConstraintLayout() {
//         if #available(iOS 15.0, *) {
//             pictureInPictureView.translatesAutoresizingMaskIntoConstraints = false
//             let constraints = [
//                 pictureInPictureView.leadingAnchor.constraint(equalTo: (RanaViewController.pipVideoCallViewController as! AVPictureInPictureVideoCallViewController).view.leadingAnchor),
//                 pictureInPictureView.trailingAnchor.constraint(equalTo: (RanaViewController.pipVideoCallViewController as! AVPictureInPictureVideoCallViewController).view.trailingAnchor),
//                 pictureInPictureView.topAnchor.constraint(equalTo: (RanaViewController.pipVideoCallViewController as! AVPictureInPictureVideoCallViewController).view.topAnchor),
//                 pictureInPictureView.bottomAnchor.constraint(equalTo: (RanaViewController.pipVideoCallViewController as! AVPictureInPictureVideoCallViewController).view.bottomAnchor)
//             ]
//             (RanaViewController.pipVideoCallViewController as! AVPictureInPictureVideoCallViewController).view.addConstraints(constraints)
//             pictureInPictureView.bounds = (RanaViewController.pipVideoCallViewController as! AVPictureInPictureVideoCallViewController).view.frame
//         }
//     }
    
//     func updatePictureInPictureView(_ result: @escaping FlutterResult, isRemoteCameraEnable: Bool) {
//         pictureInPictureView.updateStateValue(isRemoteCameraEnable: isRemoteCameraEnable)
//         result(true)
//     }
    
//     func disposePictureInPicture() {
//         // MARK: reset
//         pictureInPictureView.disposeVideoView()
        
//         if #available(iOS 15.0, *) {
//             (RanaViewController.pipVideoCallViewController as! AVPictureInPictureVideoCallViewController).view.removeAllSubviews()
//         }
        
//         if (RanaViewController.pipController == nil) {
//             return
//         }
        
//         RanaViewController.pipController = nil
//     }
    
//     func stopPictureInPicture() {
//         if #available(iOS 15.0, *) {
//             DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
//                RanaViewController.pipController?.stopPictureInPicture()
//             }
//         }
//     }
// }

// extension RanaViewController: AVPictureInPictureControllerDelegate {
//     func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
//         print(">> pictureInPictureControllerWillStopPictureInPicture")
//         self.pictureInPictureView.stopPictureInPictureView()
//     }
    
//     func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
//         print(">> pictureInPictureControllerWillStartPictureInPicture")
//         self.pictureInPictureView.updateLayoutVideoVideo()
//     }
    
//     func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
//         print("Unable start pip error:", error.localizedDescription)
//     }
// }


// // create an extension for all UIViewControllers
// extension UIViewController {
//     /**
//      Add a flutter sub view to the UIViewController
//      sets constraints to edge to edge, covering all components on the screen
//      */
//     func addFlutterView(with engine: FlutterEngine) {
//         // create the flutter view controller
//         let flutterViewController = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
        
//         addChild(flutterViewController)
        
//         guard let flutterView = flutterViewController.view else { return }
        
//         // allows constraint manipulation
//         flutterView.translatesAutoresizingMaskIntoConstraints = false
        
//         view.addSubview(flutterView)
        
//         // set the constraints (edge-to-edge) to the flutter view
//         let constraints = [
//             flutterView.topAnchor.constraint(equalTo: view.topAnchor),
//             flutterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//             flutterView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//             flutterView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//         ]
        
//         // apply (activate) the constraints
//         NSLayoutConstraint.activate(constraints)
        
//         flutterViewController.didMove(toParent: self)
        
//         // updates the view with configured layout
//         flutterView.layoutIfNeeded()
//     }
// }




// enum Sizer {
//     static let WIDTH_OF_PIP: CGFloat = 450
//     static let HEIGHT_OF_PIP: CGFloat = 800
// }


// extension UIView {
//     func setHeight(_ h:CGFloat, animateTime:TimeInterval?=nil) {

//         if let c = self.constraints.first(where: { $0.firstAttribute == .height && $0.relation == .equal }) {
//             c.constant = CGFloat(h)

//             if let animateTime = animateTime {
//                 UIView.animate(withDuration: animateTime, animations:{
//                     self.superview?.layoutIfNeeded()
//                 })
//             }
//             else {
//                 self.superview?.layoutIfNeeded()
//             }
//         }
//     }
    
//     func setWidth(_ w:CGFloat, animateTime:TimeInterval?=nil) {

//         if let c = self.constraints.first(where: { $0.firstAttribute == .width && $0.relation == .equal }) {
//             c.constant = CGFloat(w)

//             if let animateTime = animateTime {
//                 UIView.animate(withDuration: animateTime, animations:{
//                     self.superview?.layoutIfNeeded()
//                 })
//             }
//             else {
//                 self.superview?.layoutIfNeeded()
//             }
//         }
//     }
// }

// extension UIView {
//     /// Remove all subview until has 1 view
//     func removeSubviewsUntil1View() {
//         for (index, element) in subviews.enumerated() {
//             if (index < subviews.count - 1) {
//                 element.removeFromSuperview()
//             }
//         }
//     }
    
//     // Remove all subview
//     func removeAllSubviews() {
//         subviews.forEach { $0.removeFromSuperview() }
//     }

//     /// Remove all subview with specific type
//     func removeAllSubviews<T: UIView>(type: T.Type) {
//         subviews
//             .filter { $0.isMember(of: type) }
//             .forEach { $0.removeFromSuperview() }
//     }
// }


// class UserCardView: UIView {
//     private var userName: UILabel = UILabel()
//     private var avatar: UIImageView = UIImageView()
    
    
//     // MARK: init
//     override init(frame: CGRect) {
//         super.init(frame: frame)
//         clipsToBounds = true
//         setupView()
//     }
    
//     required init?(coder: NSCoder) {
//         fatalError("init(coder:) has not been implemented")
//     }
    
//     func setUserName(userName: String) {
//         self.userName.text = userName
//     }
    
//     func setAvatar(avatar: String) {
//         if (!avatar.isEmpty) {
//             let url = URL(string: avatar)
//             if (url != nil) {
//                 self.downloadImage(from: url!)
//             }
//         }
//     }
    
//     func downloadImage(from url: URL) {
//         print("Download Started")
//         getData(from: url) { data, response, error in
//             guard let data = data, error == nil else { return }
//             print(response?.suggestedFilename ?? url.lastPathComponent)
//             print("Download Finished")
//             // always update the UI from the main thread
//             DispatchQueue.main.async() {
//                 self.avatar.image = UIImage(data: data)
//             }
//         }
//     }
    
//     func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
//         URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
//     }
    
//     override func layoutSubviews() {
//         super.layoutSubviews()
//         // Text
//         userName.font = .systemFont(ofSize: bounds.width / 14, weight: .heavy)
        
//         // Avatar
//         avatar.layer.borderWidth = avatar.frame.width / 180
//         avatar.layer.masksToBounds = false
//         avatar.layer.borderColor = UIColor.white.cgColor
//         avatar.layer.cornerRadius = avatar.frame.width / 2
//         avatar.clipsToBounds = true
//     }
    
//     // MARK: make view
//     func setupView() {
//         // MARK: username
//         userName = UILabel()
//         userName.numberOfLines = 1
//         userName.adjustsFontSizeToFitWidth = true
//         userName.minimumScaleFactor = 0.5
//         userName.textAlignment = .left
//         userName.textColor = .white
        
//         // MARK: avatar
//         avatar = UIImageView()
//         avatar.contentMode = .scaleAspectFit
//         avatar.image = UIImage(named: "avatar_default")
        
//         addSubview(avatar)
//         addSubview(userName)
        
//         self.addLayoutConstraint()
//     }
    
//     func addLayoutConstraint() {
//         avatar.translatesAutoresizingMaskIntoConstraints = false
//         userName.translatesAutoresizingMaskIntoConstraints = false
        
//         userName.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
//         userName.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
//         userName.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.935).isActive = true
//         userName.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.15).isActive = true
        
//         avatar.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.28).isActive = true
//         avatar.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.28).isActive = true
//         addConstraint(NSLayoutConstraint(item: avatar, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
//         addConstraint(NSLayoutConstraint(item: avatar, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
//     }
// }



// class PictureInPictureView: UIView {
//     // MARK: Private
//     private var myUserNameCard: UserCardView = UserCardView()
//     private var localView: UIView = UIView()
//     private var peerConnectionId: String? = nil
//     private var remoteStreamId: String? = nil
//     private var isLocalCameraEnable: Bool = false
//     private var isRemoteCameraEnable: Bool = false
    
//     private var pictureInPictureIsRunning: Bool = false
    
//     // MARK: Funcs
//     override init(frame: CGRect) {
//         super.init(frame: frame)
//         setupView()
//     }
    
//     required init?(coder: NSCoder) {
//         fatalError("init(coder:) has not been implemented")
//     }
    
//     func setupView() {
//         // MARK: Setup subviews
//         localView = UIView()
//         localView.clipsToBounds = true
        
//         // MARK: add to parent view
//         addSubview(localView)
//         configurationLayoutConstrains()
        
//         // MARK: add user card view to subviews
//         self.addAvatarView()
//         self.configurationLayoutConstraintUserNameCard()
//     }
    
//     func addAvatarView() {
//         // Add local and remote avatar
//         myUserNameCard = UserCardView()
//         myUserNameCard.setUserName(userName: "You")
//         myUserNameCard.contentMode = .scaleAspectFit
//         localView.addSubview(myUserNameCard)
//     }
    
//     func initParameters(peerConnectionId: String, remoteStreamId: String, isRemoteCameraEnable: Bool, myAvatar: String) {
//         self.peerConnectionId = peerConnectionId
//         self.remoteStreamId = remoteStreamId
//         self.isRemoteCameraEnable = isRemoteCameraEnable
        
//         self.myUserNameCard.setAvatar(avatar: myAvatar)
//     }
    
//     func updateStateValue(isRemoteCameraEnable: Bool) {
//         if (self.isRemoteCameraEnable != isRemoteCameraEnable) {
//             self.isRemoteCameraEnable = isRemoteCameraEnable
            
//             if (!self.pictureInPictureIsRunning) {
//                 return
//             }
            
//             if (self.isRemoteCameraEnable) {
//                 self.addRemoteRendererToView()
//             } else {
            
//             }
//         }
//     }
    
//     func configurationLayoutConstrains() {
//         // Enable Autolayout
//         localView.translatesAutoresizingMaskIntoConstraints = false
        
//         localView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
//         localView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
//         localView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
//         localView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
//     }
    
//     func configurationLayoutConstraintForRenderer() {
             
//     }
    
//     func configurationLayoutConstraintUserNameCard() {
//         myUserNameCard.translatesAutoresizingMaskIntoConstraints = false
        
//         let constraintsLocal = [
//             self.myUserNameCard.leadingAnchor.constraint(equalTo: localView.leadingAnchor),
//             self.myUserNameCard.trailingAnchor.constraint(equalTo: localView.trailingAnchor),
//             self.myUserNameCard.topAnchor.constraint(equalTo: localView.topAnchor),
//             self.myUserNameCard.bottomAnchor.constraint(equalTo: localView.bottomAnchor)
//         ]
    
//         self.localView.addConstraints(constraintsLocal)
//         self.myUserNameCard.bounds = self.localView.frame
//     }
    
//     func configurationVideoView() {
//         if (remoteStreamId == nil || peerConnectionId == nil) {
//             return
//         }
        
//         if #available(iOS 15.0, *) {
//             // Remote
//             if (self.isRemoteCameraEnable) {
//                 DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
//                     self.addRemoteRendererToView()
//                 }
//             }
//         }
//     }
    
//     func addRemoteRendererToView() {
     
//     }
    
//     func updateLayoutVideoVideo() {
//         self.stopPictureInPictureView()
        
//         self.pictureInPictureIsRunning = true
//         self.myUserNameCard.isHidden = false
        
//         // MARK: add video view
//         self.configurationVideoView()
//     }
    
    
//     // MARK: release variables
//     func disposeVideoView() {
//         remoteStreamId = nil
//         peerConnectionId = nil
//     }
    
//     func stopPictureInPictureView() {
//         self.pictureInPictureIsRunning = false
//         self.myUserNameCard.isHidden = true
       
//     }
// }
