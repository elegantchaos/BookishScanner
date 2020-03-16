// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/04/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import UIKit
import Actions
import ActionsKit

//import BookishModel

class AddBooksController: UIViewController, BarcodeScannerDelegate, DecodableWithContextViewController {
//    let scene: CollectionScene
    
    required init?(with context: ActionContext, coder: NSCoder) {
//        guard let scene = context[ActionContext.rootKey] as? CollectionScene else {
//            return nil
//        }
//        self.scene = scene
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        return nil
    }
    
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var candidatesTable: UITableView!
    @IBOutlet weak var barcodeView: UILabel!
    @IBOutlet weak var lookupSpinner: UIActivityIndicatorView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var overlayView: UIView!
    
    var scanner: BarcodeScanner? = nil
    var detected: String = ""
    var lookup: LookupSession? = nil
    var candidates: [LookupCandidate] = []
    var imageLayer: CALayer?
    var lookupManager: LookupManager? = nil
//    var collection: CollectionContainer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        barcodeView.text = "scanner.startup".localized
        lookupSpinner.isHidden = true
        candidatesTable.isHidden = true
        lookupManager = Application.shared.lookupManager
//        collection = scene.collection
        
        if let scanner = BarcodeScanner(delegate: self) {
            self.scanner = scanner
            scanner.run()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        candidatesTable.delegate = nil
        candidatesTable.dataSource = nil
        scanner?.shutdown()
        scanner = nil
        lookup = nil
        imageLayer = nil

        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageLayer?.frame = imageView.bounds
    }
    
    func detected(barcode value: String) {
        if detected != value {
            detected = value
            let valid = value.isISBN13
            if valid {
                lookup(text: value)
            }
            
            DispatchQueue.main.async {
                let key = valid ? "candidate.lookup.valid" : "candidate.lookup.invalid"
                self.searchField.text = value
                self.barcodeView.text = key.localized(with: ["search": value])
            }
        }
    }
    
    func attach(layer: CALayer) {
        layer.frame = view.bounds
        imageView.layer.addSublayer(layer)
        layer.anchorPoint = .zero
        layer.position = .zero
        imageLayer = layer
    }
    
    func lookup(text: String) {
        lookup?.cancel()
        if let manager = lookupManager /**, let collection = collection*/ {
            lookup = manager.lookup(query: text) { (session, state) in
                self.lookupUpdate(session: session, state: state)
            }
        }
    }
    
    func lookupUpdate(session: LookupSession, state: LookupSession.State) {
        switch state {
        case .starting:
            barcodeView.text = "candidate.lookup.start".localized(with: ["search": session.search])
            lookupSpinner.startAnimating()
            lookupSpinner.isHidden = false
            candidates.removeAll()
            candidatesTable.isHidden = true
            candidatesTable.reloadData()

        case .done:
            barcodeView.text = "candidate.found".localized(count: candidates.count)
            lookupSpinner.stopAnimating()
            lookupSpinner.isHidden = true

        case .foundCandidate(let candidate):
            let row = IndexPath(row: candidates.count, section: 0)
            candidates.append(candidate)
            candidatesTable.isHidden = false
            candidatesTable.insertRows(at: [row], with: .bottom)
            if candidatesTable.indexPathForSelectedRow == nil {
                candidatesTable.selectRow(at: row, animated: true, scrollPosition: .bottom)
            }

        default:
            break
        }
    }
    
        @IBAction func doSearch(_ sender: Any) {
        searchField.resignFirstResponder()
        if let search = searchField.text {
            switch search {
            case "test":
                detected(barcode: "9781408832240")
                lookup(text: "9781408832240")
            default:
                lookup(text: search)
            }
        }
    }
}


extension AddBooksController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return candidates.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "candidate", for: indexPath) as! CandidateRow
        let candidate = candidates[indexPath.row]
        cell.detailTextLabel?.text = candidate.title
        cell.setup(with: candidate)
        
        return cell
    }
}
