Here is the complete and properly formatted `README.md` content that you can **copy-paste directly** into your GitHub repository:

````markdown
# 🚀 BruteMaster

**BruteMaster** is a modular **Bash-based Brute-Force Framework** designed for **educational and ethical hacking** purposes.  
Inspired by tools like **Hydra** and **Metasploit**, it provides an extensible and interactive terminal interface for brute-forcing different services.

> 💡 Created by **CrazyCat**  
> 📚 Learn. Build. Break. Secure.

---

## 🔰 Pre-Requisites (Install Before Cloning)

Make sure the following packages are installed:

```bash
sudo apt update
sudo apt install python3 python3-pip python3-venv -y
````

---

## 📦 Installation Steps

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/sankalpvb/BruteMaster.git
cd BruteMaster
```

### 2️⃣ Setup Python Virtual Environment (Recommended)

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 3️⃣ Make Executable and Run

```bash
chmod +x brutemaster.sh
./brutemaster.sh
```

---

## 🌍 Install as Global Command (Optional)

```bash
chmod +x setup.sh
sudo ./setup.sh
```

Now you can run BruteMaster from anywhere:

```bash
brutemaster
```

---

## 🎮 Interface Usage

Once inside the BruteMaster terminal:

```text
use <module_name>        # Select a module (http_login, ssh, ftp_login, pdf_bruteforce)
set <option> <value>     # Configure module options
show options             # View required/optional options
run                      # Start the attack
exit                     # Quit BruteMaster
```

---

## ⚙️ Expert CLI Usage

Run a module directly without using the interface:

```bash
python3 modules/http_login.py -u "http://localhost/login.php" -U "admin" -w "/path/to/wordlist.txt" --verbose
```

---

## 🧰 Available Modules

| Module Name     | Description                 |
| --------------- | --------------------------- |
| http\_login     | Brute-force web login forms |
| ssh             | Brute-force SSH credentials |
| ftp\_login      | Brute-force FTP login       |
| pdf\_bruteforce | Crack encrypted PDF files   |

---

## 🧪 Example (Basic Usage)

```bash
use http_login
set url http://localhost/login.php
set username admin
set wordlist /usr/share/wordlists/rockyou.txt
set threads 5
set verbose true
run
```

---

## 🛠️ Troubleshooting

### ❌ `externally-managed-environment` Error?

If you see this error while running `pip` on Kali Linux:

```
error: externally-managed-environment
```

➡️ **Use a virtual environment**:

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

➡️ Or bypass it at your own risk:

```bash
pip install --break-system-packages -r requirements.txt
```

---

## 👨‍💻 Author

**Sankalp Bhosale** ([@sankalpvb](https://github.com/sankalpvb))

Inspired by real-world **Red Teaming** and **Ethical Hacking** techniques.

---

## ⚠️ Legal Disclaimer

> This tool is **for educational purposes only**.
> Do **NOT** use it on targets you do not own or do not have **explicit permission** to test.

---

## 📄 License

This project is licensed under the **MIT License**.

```

✅ **Ready to paste directly into `README.md`** on GitHub!  
Let me know if you also want a `requirements.txt` or `setup.sh` template.
```
