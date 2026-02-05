//
//  ContactsImportService.swift
//  Care+
//
//  Import device contacts into ContactItem
//

import Foundation
import Contacts

enum ContactsImportService {

    /// Imports contacts from the device.
    /// - Parameters:
    ///   - existing: your current contacts (used to avoid duplicates)
    ///   - completion: returns imported contacts on main thread
    static func importFromDevice(
        existing: [ContactItem],
        completion: @escaping ([ContactItem]) -> Void
    ) {
        let store = CNContactStore()

        store.requestAccess(for: .contacts) { granted, _ in
            guard granted else {
                DispatchQueue.main.async { completion([]) }
                return
            }

            DispatchQueue.global(qos: .userInitiated).async {
                let keys: [CNKeyDescriptor] = [
                    CNContactGivenNameKey as CNKeyDescriptor,
                    CNContactFamilyNameKey as CNKeyDescriptor,
                    CNContactPhoneNumbersKey as CNKeyDescriptor,
                    CNContactEmailAddressesKey as CNKeyDescriptor,
                    CNContactImageDataAvailableKey as CNKeyDescriptor,
                    CNContactThumbnailImageDataKey as CNKeyDescriptor
                ]

                let request = CNContactFetchRequest(keysToFetch: keys)
                var imported: [ContactItem] = []

                do {
                    try store.enumerateContacts(with: request) { c, _ in
                        let fullName = [c.givenName, c.familyName].filter { !$0.isEmpty }.joined(separator: " ")
                        let phone = c.phoneNumbers.first?.value.stringValue
                        let email = c.emailAddresses.first.map { String($0.value) }
                        let photo = c.imageDataAvailable ? c.thumbnailImageData : nil

                        // Basic duplicate check by phone/email (same behavior as your current code)
                        let exists = existing.contains(where: { ex in
                            let pMatch = (phone != nil && ex.phone == phone)
                            let eMatch = (email != nil && ex.email?.lowercased() == email?.lowercased())
                            return pMatch || eMatch
                        })
                        if !exists {
                            imported.append(
                                ContactItem(
                                    name: fullName.isEmpty ? (phone ?? email ?? "Contact") : fullName,
                                    relation: nil,
                                    phone: phone,
                                    email: email,
                                    photoData: photo,
                                    audioNoteURL: nil
                                )
                            )
                        }
                    }
                } catch {
                    DispatchQueue.main.async { completion([]) }
                    return
                }

                DispatchQueue.main.async {
                    completion(imported)
                }
            }
        }
    }
}
