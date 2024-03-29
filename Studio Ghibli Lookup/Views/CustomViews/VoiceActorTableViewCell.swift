//
//  VoiceActorTableViewCell.swift
//  Studio Ghibli Lookup
//
//  Created by Andrew Saeyang on 9/16/21.
//

import UIKit

class VoiceActorTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var actorImageView: UIImageView!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    // MARK: - Properties
    var castMember: Cast?{
        didSet{
            updateViews()
        }
    }
    
    // MARK: - Helper Methods
    func updateViews(){
        guard let cast = castMember else {
            roleLabel.text = "Cat"
            nameLabel.text = "Billy Bob"
            return }
        
        // TODO: Add Photo
        //print("Cast member name is: \(cast.name) and role is: \(cast.character)")
        roleLabel.text = cast.character
        nameLabel.text = cast.name
        setCastImage(for: cast.profilePath)
    }
    
    func setCastImage(for url: URL?){
        if let url = url{
            
            MovieAPIController.fetchMoviePoster(with: url) { result in
                DispatchQueue.main.async {
                    
                    switch result{
                    
                    case .success(let image):
                        self.actorImageView.image = image
                    case .failure(let error):
                        print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    }
                }
            }
        } else {
            
            let defaultURL: URL = URL(string: "https://image.tmdb.org/t/p/w500/xi8z6MjzTovVDg8Rho6atJCcKjL.jpg")!
            let data = try? Data(contentsOf: defaultURL)
            
            if let imageData = data{
                let image = UIImage(data: imageData)
                actorImageView.image = image
                
            }
        }
    }
}// End of class
