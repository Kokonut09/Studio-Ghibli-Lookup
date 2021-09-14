//
//  FilmCollectionViewCell.swift
//  Studio Ghibli Lookup
//
//  Created by Andrew Saeyang on 9/2/21.
//

import UIKit

class FilmCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var filmImageView: UIImageView!
    
    
    // MARK: - PROPERTIES
    var movie: Movie?
    var film: Film?{
        didSet{
            updateViews()
        }
    }
    
    // MARK: - Actions
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        
        print("Favorite Button tapped for \(film!.title)")
        film!.isFavorite.toggle()
        setFavoriteButton(for: film!)
    }
    
    
    // MARK: - Helper Methods
    func updateViews(){
        guard let film = film else { return }
        
        setFavoriteButton(for: film)
        
        //guard let movie = movie else { return }
        MovieAPIController.fetchMovies(with: film.originalTitle) { (result) in
            
            //dispatch has to do with the view. if in background thread CANNOT UPDATE VIEW. print statemetns are okay, code changes are okay.
            
            //mightn not need this to call the function.
            DispatchQueue.main.async {
                
                switch result{
                
                case .success(let movie):
                    self.fetchPoster(for: movie[0])
                    
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
    }
    
    func fetchPoster(for movie: Movie){
        
        //move into own function (param of movie) pass in move[0]
        MovieAPIController.fetchMoviePoster(with: movie.posterImage) { [weak self]result in
            
            DispatchQueue.main.async {
                switch result{
                
                case .success(let image):
                    
                    self?.filmImageView.image = image
                    self?.filmImageView.contentMode = .scaleAspectFill
                    self?.filmImageView.layer.cornerRadius = 8
                    
                case .failure(let error):
                    print("Error IMAGE in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
    }
    
    func setFavoriteButton(for film:Film){
        
        if film.isFavorite{
            favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }else{
            favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    }
    
}// End of class
