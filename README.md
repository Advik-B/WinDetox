# WinDetox
> A simple detox program for Windows that cleans up your system and makes it run faster.

## Contributing
1. Fork it
2. There is a folder called in `WinDetox/` called `Detoxes` where you can add your own detoxes.
3. Create a new folder with the name of your detox.
4. Add a `README.md` file with the instructions on how to use your detox. (optional)
5. Add a `detox.ps1` or `detox.py` file with the code for your detox. [see specifications below](#detoxes-specifications)
6. Commit your changes (`git commit -am 'Add some fooBar'`) and pull request.
7. After your pull request is merged, you can delete your branch.
8. Your detox will be available for everyone to use!

## Detoxes Specifications
- The detox must be a PowerShell script or a Python script.

### PowerShell (Not Recommended)
- The script must be named `detox.ps1`.
- The script will be executed with the command `powershell -ExecutionPolicy Bypass -File detox.ps1`.
- No additional parameters will be passed to the script.

### Python
- The script must be named `detox.py`.
- The script must have a variable called `__author__` with the following format:
```python
    __author__ = {
        'name': 'Your Name',
        'github': 'Your GitHub Username',
        'description': 'A short description of your detox'
    }
```
- The script must have a function called `detox` that follows the following format:
```python
    def detox(path: Path):
        # Your detox code here
```
> Note: The `path` parameter is the path to a single file that the detox will be applied to.

#### Example of a Python detox
```
WinDetox/
└── Detoxes/
    └── MyDetox/
        ├── README.md
        └── detox.py
```
```python
# detox.py

from pathlib import Path
__author__ = {
    'name': 'John Doe',
    'github': 'johndoe',
    'description': 'A simple detox that removes all the empty lines from a file'
}

def detox(path: Path):
    with open(path, 'r') as file:
        lines = file.readlines()
    with open(path, 'w') as file:
        for line in lines:
            if line.strip():
                file.write(line)
```

## License
This project is licensed under the MIT License - see the [LICENSE](./LICENSE.txt) file for details.
All detoxes are also licensed under the MIT License unless specified otherwise.

## Acknowledgments
- [Reddit Post by me](https://www.reddit.com/r/Windows11/comments/1crzkp9/psa_check_your_appdata_folder_for_bloating/)
- [Comment by u/FocusedWolf](https://www.reddit.com/r/Windows11/comments/1crzkp9/comment/l44ha9e/)