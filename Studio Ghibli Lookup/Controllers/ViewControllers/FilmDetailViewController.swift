//
//  FilmDetailViewController.swift
//  Studio Ghibli Lookup
//
//  Created by Andrew Saeyang on 9/7/21.
//

import UIKit

class FilmDetailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var filmImageView: UIImageView!
    @IBOutlet weak var filmTitleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var synopsisTextView: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    // MARK: - Properties
    var film: Film?
    var castMemebers: [Cast]?{
        didSet{
            updateViews()
        }
    }
    
    let defaultURL: URL = URL(string: "https://image.tmdb.org/t/p/w500/xi8z6MjzTovVDg8Rho6atJCcKjL.jpg")!
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        //blurr()
        tableView.delegate = self
        tableView.dataSource = self
        //updateViews()
        
        print("Number of cast members at ViewdidLoad is \(castMemebers?.count ?? 0)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize"{
            if let newValue = change?[.newKey]{
                let newSize = newValue as! CGSize
                tableViewHeight.constant = newSize.height
            }
        }
    }
    
    // MARK: - Helper Methods
    func updateViews(){
        
        guard let film = film else { return }
        
        DispatchQueue.main.async {
            
            self.title = film.title
            self.filmTitleLabel.text = film.title
            self.yearLabel.text = film.releaseDate
            self.synopsisTextView.text = film.filmDescription
            
            self.tableView.reloadData()
        }
            
        
        MovieAPIController.fetchMovies(with: film.originalTitle) { (result) in
            
            //dispatch has to do with the view. if in background thread CANNOT UPDATE VIEW. print statemetns are okay, code changes are okay.
            
            //mightn not need this to call the function.
            // DispatchQueue.main.async {
            
            switch result{
            
            case .success(let movie):
                self.fetchPoster(for: movie)
            //self.setCastMembers(for: movie)
            
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
            
        }
    }
    
    func fetchPoster(for movie: Movie){
        
        //move into own function (param of movie) pass in move[0]
        MovieAPIController.fetchMoviePoster(with: movie.posterPath ?? defaultURL) { [weak self]result in
            //print(movie.posterImage)
            DispatchQueue.main.async {
                switch result{
                
                case .success(let image):
                    // self?.view.backgroundColor = UIColor(patternImage: image)
                    self?.view.contentMode = .scaleAspectFill
                    
                    self?.filmImageView.image = image
                    self?.filmImageView.contentMode = .scaleAspectFill
                    self?.filmImageView.layer.cornerRadius = 8
                case .failure(let error):
                    print("Error IMAGE in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
    }
    
    func fetchCastMembers(for name: String){
        MovieAPIController.fetchMovies(with: name) { (result) in
            switch result{
            
            case .success(let movie):
                self.setCastMembers(for: movie)
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
    }
    
    func setCastMembers(for movie: Movie){
        
        MovieAPIController.fetchPeople(for: movie.id) { (result) in
            
            switch result{
            case .success(let cast):
                self.castMemebers = cast
                print("number of cast is \(cast.count)")
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
    }
    
    func blurr(){
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, at: 0)
    }
    
} // End of class

extension FilmDetailViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return castMemebers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "actorCell", for: indexPath) as? VoiceActorTableViewCell,
              let castMembers = castMemebers else { return UITableViewCell()}
        
        cell.nameLabel.text = castMembers[indexPath.row].name
        cell.roleLabel.text = castMembers[indexPath.row].character
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
