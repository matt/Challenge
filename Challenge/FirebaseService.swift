//
//  FirebaseService.swift
//  Challenge
//
//  Created by Matthew Mohrman on 8/8/18.
//  Copyright © 2018 Matthew Mohrman. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage

enum CollectionName: String {
    case profiles
}

enum SerializationError: Error {
    case unsuccessful
}

class FirebaseService {

    static func configure() {
        FirebaseApp.configure()
    }

    static func reference(toCollection collectionName: CollectionName) -> CollectionReference {
        return Firestore.firestore().collection(collectionName.rawValue)
    }
    
    static func reference(toCollection collectionName: CollectionName, documentId: String) -> DocumentReference {
        return Firestore.firestore().collection(collectionName.rawValue).document(documentId)
    }

    static func create<T: Encodable>(_ encodableObject: T, in collectionReference: CollectionReference, completion: @escaping (Error?) -> Void) {
        guard let encodedObject = try? JSONEncoder().encode(encodableObject), let jsonObject = try? JSONSerialization.jsonObject(with: encodedObject), let data = jsonObject as? [String: Any] else {
            completion(SerializationError.unsuccessful)
            return
        }
        collectionReference.addDocument(data: data, completion: completion)
    }

    static func read<T: Decodable>(fromQuery query: Query, returning objectType: T.Type, completion: @escaping ([T]) -> Void) -> ListenerRegistration {
        
        let listener = query.addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot else {
                return
            }
            
            do {
                var objects = [T]()
                for document in snapshot.documents {
                    var documentData = document.data()
                    documentData["documentId"] = document.documentID
                    
                    let jsonData = try JSONSerialization.data(withJSONObject: documentData)
                    let model = try JSONDecoder().decode(T.self, from: jsonData)
                    objects.append(model)
                }
                
                completion(objects)
            } catch {
                print(error)
            }
        }

        return listener
    }
    
    static func read<T: Decodable>(fromDocument document: DocumentReference, returning objectType: T.Type, completion: @escaping (T?) -> Void) -> ListenerRegistration {
        
        let listener = document.addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot, var documentData = snapshot.data() else {
                completion(nil)
                return
            }
            
            documentData["documentId"] = snapshot.documentID
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: documentData)
                let object = try JSONDecoder().decode(T.self, from: jsonData)
                completion(object)
            } catch {
                print(error)
            }
        }
        
        return listener
    }

    static func update(data: [AnyHashable: Any], in documentReference: DocumentReference) {
        documentReference.updateData(data) { error in
            print(error)
        }
    }

    static func delete(_ documentReference: DocumentReference) {
        documentReference.delete { error in
            print(error)
        }
    }

    static func uploadImage(_ image: UIImage, completionBlock: @escaping (_ url: URL?, _ errorMessage: String?) -> Void) {
        let storageReference = Storage.storage().reference()
        let imageReference = storageReference.child("images").child("\(Date().timeIntervalSince1970).jpg")
        
        if let imageData = UIImageJPEGRepresentation(image, 0.85) {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            _ = imageReference.putData(imageData, metadata: metadata, completion: { (metadata, error) in
                guard error == nil else {
                    completionBlock(nil, error?.localizedDescription)
                    return
                }
                
                imageReference.downloadURL(completion: { (url, error) in
                    guard error == nil else {
                        completionBlock(nil, error?.localizedDescription)
                        return
                    }
                    
                    completionBlock(url, nil)
                })
            })
        } else {
            completionBlock(nil, "Image couldn't be converted to Data.")
        }
    }
    
    static func deleteImage(fileName: String) {
        let storageReference = Storage.storage().reference()
        let imageReference = storageReference.child("images").child(fileName)
        imageReference.delete()
    }
}
