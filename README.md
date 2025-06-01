# macOS Contacts

A read-only Swift command-line tool for listing, and searching macOS Contacts, with support for birthday listings and aerc integration.

```
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
```
