// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/04/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import UIKit
import Actions
import ActionsKit

class CaptureViewController: UIViewController, BarcodeScannerDelegate {
    
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
    var lookupQuery = ""
    var imageLayer: CALayer?
    var lookupManager: LookupManager? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lookupSpinner.isHidden = true
        imageView.isHidden = true
        lookupManager = Application.shared.lookupManager
        candidatesTable.dataSource = self
        candidatesTable.delegate = self
        updateCandidateTable(hidden: true, animated: false, label: "scanner.startup".localized)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let scanner = BarcodeScanner(delegate: self) {
            imageView.isHidden = false
            self.scanner = scanner
            scanner.run()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
        if let manager = lookupManager {
            lookupQuery = text
            lookup = manager.lookup(query: text) { (session, state) in
                self.lookupUpdate(session: session, state: state)
            }
        }
    }
    
    func lookupUpdate(session: LookupSession, state: LookupSession.State) {
        switch state {
            case .starting:
                lookupSpinner.startAnimating()
                lookupSpinner.isHidden = false
                candidates.removeAll()
                updateCandidateTable(hidden: true, animated: true, label: "candidate.lookup.start".localized(with: ["search": session.search]), reload: true)
            
            case .done:
                updateCandidateTable(hidden: false, animated: true, label: "candidate.found".localized(count: candidates.count))
                lookupSpinner.stopAnimating()
                lookupSpinner.isHidden = true
            
            case .foundCandidate(let candidate):
                let row = IndexPath(row: candidates.count, section: 0)
                candidates.append(candidate)
                print("found \(candidates.count)")
                updateCandidateTable(hidden: false, animated: true, label: "candidate.found".localized(count: candidates.count))
                candidatesTable.insertRows(at: [row], with: .bottom)
                if candidatesTable.indexPathForSelectedRow == nil {
                    candidatesTable.selectRow(at: row, animated: true, scrollPosition: .bottom)
            }
            
            case .cancelling:
                updateCandidateTable(hidden: true, animated: true)
            
            default:
                break
        }
    }
    
    func updateCandidateTable(hidden: Bool = false, animated: Bool = true, label: String? = nil, reload: Bool = false) {
        let tableView = candidatesTable!
        let labelView = barcodeView!

        labelView.text = label

        let labelHidden = label?.isEmpty ?? true
        let hiddenChanged = (tableView.isHidden != hidden) || (labelView.isHidden != labelHidden)
        let needChange = hiddenChanged || reload
        if needChange {
            let change = {

                if hiddenChanged {
                    labelView.isHidden = labelHidden
                    tableView.isHidden = hidden
                }
                if reload {
                    tableView.reloadData()
                }
            }
            if animated {
                UIView.animate(withDuration: 0.5, animations: change)
            } else {
                change()
            }
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
    
    @IBAction func textChanged(_ sender: Any) {
        lookup?.cancel()
        updateCandidateTable(hidden: lookupQuery.isEmpty || (lookupQuery != searchField.text), animated: true)
    }
}


extension CaptureViewController: UITableViewDelegate, UITableViewDataSource {
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
