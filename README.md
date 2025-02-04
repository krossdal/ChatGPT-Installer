# 🚀 ChatGPT-Installer  
Ever tried installing ChatGPT on Windows without the Microsoft Store? Yeah, not fun. Since my system doesn't have the Microsoft Store, I needed a way to get ChatGPT up and running without jumping through unnecessary hoops. So, I built this **PowerShell script** to handle the entire process—download, install, update—without any manual hassle. And yes, this script was built with a little help from ChatGPT itself! 🤖✨

### 🔹 Features  
✅ Automatically downloads the latest ChatGPT version from the Microsoft Store.  
✅ Removes old installations from C:\Program Files\WindowsApps.  
✅ Handles permission issues with takeown and icacls.  
✅ No user prompts – fully automated installation and updates.  

### 📥 Installation & Usage  
1️⃣ Download the Script
Clone this repository or download the latest script.

2️⃣ Run the Script
Open PowerShell as Administrator and execute:
```
.\ChatGPT-Install.ps1
```
3️⃣ What Happens?  
- The script checks for the latest version.  
- If a new version is available, it closes ChatGPT, removes the old version, and installs the update.  
- If ChatGPT is up to date, the script exits without making changes.  

🔄 Updates  
Run the script periodically to ensure you’re always using the latest ChatGPT version.

### 🛠️ Tested on
- Windows Server 2022 Standard  
- PowerShell 5.1, Build 20348, Revision 2849  
- With administrator privileges  

### 📝 Notes  
- WindowsApps folder is protected, so the script takes ownership and grants permissions before removing old installations.  
- The script does not start ChatGPT after installation (you can launch it manually).

### ⚠️ Troubleshooting  
If you receive an error stating that running scripts is disabled, try running the following command before executing the script:  
```powershell
Set-ExecutionPolicy RemoteSigned -Scope Process
```
This will temporarily allow PowerShell to run the script for the current session without changing system-wide settings.  

### ⚖️ License
This project is licensed under the MIT License.
