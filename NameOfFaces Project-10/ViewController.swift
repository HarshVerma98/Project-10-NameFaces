//
//  ViewController.swift
//  NameOfFaces Project-10
//
//  Created by Harsh Verma on 14/08/21.
//

import UIKit

class ViewController: UICollectionViewController {
    
    var people = [Person]()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Name Faces"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didAddPerson))
        // Do any additional setup after loading the view.
    }
    
    func getDocumentPath() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }
    
    func deletePerson(indexPath: IndexPath) {
        DispatchQueue.global().async { [weak self] in
            guard let selectedImage = self?.people[indexPath.item].image else {
                self?.showRemoveError()
                return
            }
            
            guard let selectedPath = self?.getDocumentPath().appendingPathComponent(selectedImage) else {
                self?.showRemoveError()
                return
            }
            
            do {
                try FileManager.default.removeItem(at: selectedPath)
            }
            catch {
                self?.showRemoveError()
                return
            }
            
            self?.people.remove(at: indexPath.item)
            
            // Reload View From Main Thread
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
    
    //Challenge 1
    
    func personTapped(indexPath: IndexPath) {
        let alert = UIAlertController(title: "Remove?", message: "Delete Person \"\(people[indexPath.item].name)\"?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { _ in
            self.deletePerson(indexPath: indexPath)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    
    func showRemoveError() {
        // Called from Main Thread
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: "Error", message: "Failed to remove this person", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func didAddPerson() {

        //Challenge 2
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let alert = UIAlertController(title: "Source", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
                self.showPicker(camera: false)
            }))
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                self.showPicker(camera: true)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }else {
            showPicker(camera: false)
        }
    }
    
    func showPicker(camera: Bool) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? PersonCell else {
            return UICollectionViewCell()
        }
        cell.nameLabel.text = people[indexPath.item].name
        
        let obtainedPath = getDocumentPath().appendingPathComponent(people[indexPath.item].image)
        cell.personPic.image = UIImage(contentsOfFile: obtainedPath.path)
        cell.personPic.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.personPic.layer.borderWidth = 2
        cell.personPic.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let indexing = people[indexPath.item]
        let alert = UIAlertController(title: "Rename Person", message: nil, preferredStyle: .alert)
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak self, weak alert] _ in
            guard let renamed = alert?.textFields?[0].text else {
                return
            }
            indexing.name = renamed
            self?.collectionView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Delete a Person", style: .destructive, handler: { _ in
            self.personTapped(indexPath: indexPath)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let picutre = info[.editedImage] as? UIImage else {
            return
        }
        let picName = UUID().uuidString
        let picPath = getDocumentPath().appendingPathComponent(picName)
        
        if let jpegData = picutre.jpegData(compressionQuality: 0.3) {
            try? jpegData.write(to: picPath)
        }
        let person = Person(name: "Unknown", image: picName)
        people.append(person)
        collectionView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
