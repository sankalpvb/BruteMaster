import pikepdf
import argparse
from tabulate import tabulate

def crack_pdf(pdf_file, wordlist_file, verbose):
    with open(wordlist_file, 'r', errors='ignore') as f:
        passwords = [line.strip() for line in f if line.strip()]

    print(f"[+] Loaded {len(passwords)} passwords.\n")

    for i, password in enumerate(passwords, 1):
        try:
            with pikepdf.open(pdf_file, password=password):
                print("\n[✔] PDF Decrypted Successfully!\n")
                table = [["PDF Path", pdf_file], ["Password Found", password]]
                print(tabulate(table, headers=["Field", "Value"], tablefmt="fancy_grid"))
                return
        except pikepdf.PasswordError:
            if verbose:
                print(f"[-] {i}/{len(passwords)} Tried: {password}")
        except Exception as e:
            print(f"[!] Error: {e}")
            return

    print("[×] Password not found in given wordlist.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="PDF Password Cracker")
    parser.add_argument("-f", "--file", required=True, help="Path to encrypted PDF")
    parser.add_argument("-w", "--wordlist", required=True, help="Path to wordlist file")
    parser.add_argument("--verbose", action="store_true", help="Enable verbose output")
    args = parser.parse_args()

    crack_pdf(args.file, args.wordlist, args.verbose)
