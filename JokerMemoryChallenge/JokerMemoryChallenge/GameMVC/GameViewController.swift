//
//  GameViewController.swift
import UIKit
import AVFoundation
class GameViewController: UIViewController , ResultViewControllerDelegate  {
    
    
    func resultViewControllerDidTapRestart() {
        resetColorButton()
        generatRandomIndexes()
        startGame()
        currentOpenedIndexes.removeAll()
        checkGameWin()
    }
    
    //MARK: - Outlets
    @IBOutlet weak var levelController: LevelController!
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    
    
    //MARK: - Properties
    static let shared = GameViewController()
    var goalButtonCount: Int = 4
    var gamebuttons: [UIButton] = []
    var randomIndexes: [Int] = []
    var currentOpenedIndexes = [Int]()
    var row : Int = 3
    var column : Int = 3
    var currentProgress: Int = 0
    weak var timer: Timer?
    let blueImage = UIImage(named: "blue-card") as UIImage?
    let winImage = UIImage(named: "win-card") as UIImage?
    let showResult = "showResult"
    var isPaused = false
	var fix = false
    var score = 0 {
        didSet {
            scoreLabel.attributedText = String("Total \(score)").outlineAttributedText
        }
    }
    var time: Int = 0 {
        didSet {
            timeLabel.attributedText = String("Time \(String(format: "%02d", time / 60)):\(String(format: "%02d", time % 60))").outlineAttributedText
        }
    }
    private var flipsCount = 0
    
    weak var cardTimer: Timer?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        generateGameButtons()
        resetColorButton()
        generatRandomIndexes()
        randomColorButton()
        startGame()
        
		if AppSettings.configuration == .free {
			AdMobMnager.shared.addBanner(viewController: self, bannerPosition: .bottom)
		}
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        timer?.invalidate()
        cardTimer?.invalidate()
    }
    
    //MARK: - Timer methods
    enum GameState {
        case begin
        case normal
        case inactive
        case solved
    }
    func generatRandomIndexes() {
        randomIndexes.removeAll()
        var indexes = [Int](0..<gamebuttons.count)
        repeat {
            let randomIndex  = Int(arc4random_uniform(UInt32(indexes.count)))
            let index = indexes[randomIndex]
            indexes.remove(at: randomIndex)
            randomIndexes.append(index)
        } while randomIndexes.count <= goalButtonCount
        
    }
    
    func randomColorButton() {
        for index in randomIndexes {
            let gamebutton = gamebuttons[index]
            gamebutton.setImage(winImage, for: [])
        }
    }
    
    func checkGameWin() {
        if randomIndexes.count == currentOpenedIndexes.count {
            self.performSegue(withIdentifier: showResult, sender: nil)
        }
    }
    
    @objc func checkButton(button: UIButton) {
		fix = true
        let indexCheck =  gamebuttons.firstIndex(of: button)!
        var buttonfound = false
        for index in randomIndexes {
            if index == indexCheck {
                buttonfound = true
                currentOpenedIndexes.append(indexCheck)
                button.setImage(winImage, for: [])
                break
            }
        }
        if !buttonfound {
            looseViewControllerDidDismiss()
        } else {
            checkGameWin()
        }
    }
    
    func startGame() {
        randomColorButton()
        let seconds = 2.0
        gameView.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.resetColorButton()
            self.gameView.isUserInteractionEnabled = true
        }
    }
    func setupGameMode() {
       
        //goalButtonCount = randomIndexes.count
        if Options.shared.gameMode == 0 {
            row = 3
            column = 3
            goalButtonCount = 3
        } else if  Options.shared.gameMode == 1 {
            row = 4
            column = 4
            goalButtonCount = 5
        } else if  Options.shared.gameMode == 2 {
            row = 5
            column = 5
            goalButtonCount = 8
        }
    
    }
    
    func resetColorButton() {
        for gamebutton in gamebuttons {
            gamebutton.setImage(blueImage, for: [])
        }
    }
    
    func  generateGameButtons() {
        let widthView = Int(UIScreen.main.bounds.size.width) - 40
        let heightView = widthView
        setupGameMode()
        let widthButton = (Int(widthView) / row) - 20
        let heightButton = (Int(widthView) / column) - 20
        for  i in 0..<row {
            for j in 0..<column {
                let xCord = i * (Int(CGFloat(widthView) / CGFloat(row))) + 10
                let yCord = j * (Int(CGFloat(heightView) / CGFloat(column))) + 10
                let button = UIButton(frame: CGRect(x: xCord, y: yCord, width: widthButton, height: heightButton))
                gamebuttons.append(button)
                button.setImage(blueImage, for: [])
                //button.setTitle("", for: .normal)
                self.gameView.addSubview(button)
                button.addTarget(self,action:#selector(checkButton),
                                 for:.touchUpInside)
            }
        }
    }
    
    @IBAction func didTappedMenuButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
        // SKTAudio.sharedInstance().pauseBackgroundMusic()
    }
    
    @IBAction func didTappedPauseButton(_ sender: UIButton) {
        for sender in gamebuttons {
            sender.isUserInteractionEnabled = isPaused
        }
        pauseButton.isSelected = !sender.isSelected
        isPaused = !isPaused
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showResult {
        let vc = segue.destination as! ResultViewController
        vc.delegate = self
            }
        }
    }


//MARK: - Extensions
extension Int {
    var arc4Random: Int {
        switch self {
        case 1...Int.max:
            return Int(arc4random_uniform(UInt32(self)))
        case -Int.max..<0:
            return Int(arc4random_uniform(UInt32(self)))
        default:
            return 0
        }
        
    }
}
extension String {
    var outlineAttributedText: NSAttributedString {
        let _: [NSAttributedString.Key: Any] = [
            .strokeWidth: -4.0,
            .strokeColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        ]
        let attributedText = NSAttributedString(string: String(self), attributes: nil)
        return attributedText
    }
}
extension GameViewController: LooseViewControllerDelegate {
    func restartButton() {
        resultViewControllerDidTapRestart()
    }
    
    
    func looseViewControllerDidDismiss() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loseVC = storyboard.instantiateViewController(withIdentifier: String(describing: LooseViewController.classForCoder())) as? LooseViewController {
            loseVC.delegate = self
            loseVC.modalPresentationStyle = .overCurrentContext
            present(loseVC, animated: true, completion: nil)
        }
    }
}



