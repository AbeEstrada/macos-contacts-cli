import Contacts
import Foundation

class ContactsManager {
	let store = CNContactStore()

	func requestAccess() -> Bool {
		var authorized = false
		let semaphore = DispatchSemaphore(value: 0)
		store.requestAccess(for: .contacts) { granted, error in
			authorized = granted
			if let error = error {
				print("Error requesting access: \(error.localizedDescription)")
			}
			semaphore.signal()
		}
		semaphore.wait()
		return authorized
	}

	func fetchAllContacts() -> [CNContact] {
		var contacts = [CNContact]()
		let keysToFetch: [CNKeyDescriptor] = [
			CNContactGivenNameKey as CNKeyDescriptor,
			CNContactFamilyNameKey as CNKeyDescriptor,
			CNContactEmailAddressesKey as CNKeyDescriptor,
			CNContactPhoneNumbersKey as CNKeyDescriptor,
			CNContactBirthdayKey as CNKeyDescriptor,
		]
		let request = CNContactFetchRequest(keysToFetch: keysToFetch)
		do {
			try store.enumerateContacts(with: request) { contact, stop in
				contacts.append(contact)
			}
		} catch {
			print("Error fetching contacts: \(error.localizedDescription)")
		}
		return contacts
	}

	func searchContacts(query: String) -> [CNContact] {
		let predicate = CNContact.predicateForContacts(matchingName: query)
		let keysToFetch: [CNKeyDescriptor] = [
			CNContactGivenNameKey as CNKeyDescriptor,
			CNContactFamilyNameKey as CNKeyDescriptor,
			CNContactEmailAddressesKey as CNKeyDescriptor,
			CNContactPhoneNumbersKey as CNKeyDescriptor,
			CNContactBirthdayKey as CNKeyDescriptor,
		]
		do {
			return try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
		} catch {
			print("Error searching contacts: \(error.localizedDescription)")
			return []
		}
	}

	func printContacts(_ contacts: [CNContact], showBirthdays: Bool = false) {
		if contacts.isEmpty {
			print("No contacts found.")
			return
		}
		// print("Found \(contacts.count) contacts:\n")
		for contact in contacts {
			let fullName = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(
				in: .whitespaces)
			print("\(fullName)")
			if showBirthdays, let birthday = contact.birthday {
				print("\(birthdayFormatter(birthday: birthday))")
			} else {
				if !contact.phoneNumbers.isEmpty {
					for phone in contact.phoneNumbers {
						print(
							"\(phone.value.stringValue)"
						)
					}
				}
				if !contact.emailAddresses.isEmpty {
					for email in contact.emailAddresses {
						print(
							"\(email.value as String)"
						)
					}
				}
			}
			print("")
		}
	}

	func printContactsForAerc(_ contacts: [CNContact], query: String? = nil) {
		for contact in contacts {
			let fullName = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(
				in: .whitespaces)
			for email in contact.emailAddresses {
				let emailString = email.value as String
				if let query = query, !query.isEmpty {
					let lowercaseQuery = query.lowercased()
					let matchesName = fullName.lowercased().contains(lowercaseQuery)
					let matchesEmail = emailString.lowercased().contains(lowercaseQuery)

					if matchesName || matchesEmail {
						print("\(emailString)\t\(fullName)")
					}
				} else {
					print("\(emailString)\t\(fullName)")
				}
			}
		}
	}

	func fetchBirthdays() -> [CNContact] {
		let calendar = Calendar.current
		let today = Date()
		guard let thirtyDaysLater = calendar.date(byAdding: .day, value: 30, to: today) else {
			return []
		}

		let allContacts = fetchAllContacts()
		let contactsWithBirthdays = allContacts.compactMap {
			contact -> (contact: CNContact, month: Int, day: Int)? in
			guard let birthday = contact.birthday,
				let month = birthday.month,
				let day = birthday.day
			else {
				return nil
			}
			return (contact, month, day)
		}

		let currentMonth = calendar.component(.month, from: today)
		let currentDay = calendar.component(.day, from: today)
		// let currentYear = calendar.component(.year, from: today)

		let thirtyDaysLaterMonth = calendar.component(.month, from: thirtyDaysLater)
		let thirtyDaysLaterDay = calendar.component(.day, from: thirtyDaysLater)

		let filteredContacts = contactsWithBirthdays.filter { item in
			let month = item.month
			let day = item.day

			if month == currentMonth {
				return day >= currentDay
			}
			else if month > currentMonth && month < thirtyDaysLaterMonth {
				return true
			}
			else if month == thirtyDaysLaterMonth {
				return day <= thirtyDaysLaterDay
			}
			else if currentMonth == 12 && month <= thirtyDaysLaterMonth {
				return day <= thirtyDaysLaterDay
			}
			return false
		}

		let sortedContacts = filteredContacts.sorted {
			if $0.month != $1.month {
				return $0.month < $1.month
			}
			if $0.day != $1.day {
				return $0.day < $1.day
			}
			let name0 = "\($0.contact.givenName) \($0.contact.familyName)"
			let name1 = "\($1.contact.givenName) \($1.contact.familyName)"
			return name0 < name1
		}.map { $0.contact }

		return sortedContacts
	}

	private func birthdayFormatter(birthday: DateComponents) -> String {
		var parts = [String]()
		if let month = birthday.month, let day = birthday.day {
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "MMMM"
			let monthName = dateFormatter.monthSymbols[month - 1]
			parts.append("\(day) \(monthName)")
		}
		if let year = birthday.year {
			parts.append("\(year)")
		}
		return parts.joined(separator: " ")
	}
}

func parseArguments() -> (
	listAll: Bool, searchQuery: String?, birthdaysThisMonth: Bool, aercMode: Bool,
	aercQuery: String?
) {
	var listAll = false
	var searchQuery: String? = nil
	var birthdaysThisMonth = false
	var aercMode = false
	var aercQuery: String? = nil

	var i = 1
	while i < CommandLine.arguments.count {
		let argument = CommandLine.arguments[i]

		if argument == "--list" || argument == "-l" {
			listAll = true
		} else if argument == "--search" || argument == "-s" {
			if i + 1 < CommandLine.arguments.count {
				searchQuery = CommandLine.arguments[i + 1]
				i += 1
			}
		} else if argument.hasPrefix("--search=") {
			searchQuery = String(argument.dropFirst("--search=".count))
		} else if argument.hasPrefix("-s=") {
			searchQuery = String(argument.dropFirst("-s=".count))
		} else if argument == "--birthdays" || argument == "-b" {
			birthdaysThisMonth = true
		} else if argument == "--aerc" || argument == "-a" {
			aercMode = true
			if i + 1 < CommandLine.arguments.count {
				aercQuery = CommandLine.arguments[i + 1]
				i += 1
			}
		}
		i += 1
	}
	return (listAll, searchQuery, birthdaysThisMonth, aercMode, aercQuery)
}

func printUsage() {
	print(
		"""
		Contacts

		Usage:
		  contacts --list             List all contacts
		  contacts --search <query>   Search contacts by name
		  contacts --birthdays        List contacts with birthdays this month
		  contacts --aerc [query]     List contacts in aerc format, optionally filtered by query
		  contacts -l                 Short form for --list
		  contacts -s <query>         Short form for --search
		  contacts -b                 Short form for --birthdays
		  contacts -a [query]         Short form for --aerc

		Examples:
		  contacts --list
		  contacts --birthdays
		  contacts --search "John"
		  contacts -s "john@example.com"
		  contacts --aerc
		  contacts --aerc "john"
		""")
}

let manager = ContactsManager()

guard manager.requestAccess() else {
	print("Access to contacts was denied.")
	exit(1)
}

let args = parseArguments()

if args.aercMode {
	let contacts = manager.fetchAllContacts()
	manager.printContactsForAerc(contacts, query: args.aercQuery)
} else if args.birthdaysThisMonth {
	let contacts = manager.fetchBirthdays()
	let now = Date()
	let currentMonth = Calendar.current.component(.month, from: now)
	let currentYear = Calendar.current.component(.year, from: now)
	let dateFormatter = DateFormatter()
	dateFormatter.dateFormat = "MMMM"
	let monthName = dateFormatter.monthSymbols[currentMonth - 1]
	print("Birthdays - \(monthName) \(currentYear)\n")
	manager.printContacts(contacts, showBirthdays: true)
} else if args.listAll {
	let contacts = manager.fetchAllContacts()
	manager.printContacts(contacts)
} else if let query = args.searchQuery {
	let contacts = manager.searchContacts(query: query)
	manager.printContacts(contacts)
} else {
	printUsage()
}
