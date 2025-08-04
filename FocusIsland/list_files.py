# import os

# path = '.'
# file_list = []

# for root, dirs, files in os.walk(path):
#     if 'node_modules' in dirs:
#         dirs.remove('node_modules')  # Exclude node_modules folder
#     if '.next' in dirs:
#         dirs.remove('.next')
#     if '.git' in dirs:
#         dirs.remove('.git')
#     if '.DS_Store' in files:
#         files.remove('.DS_Store')
#     for file in files:
#         file_list.append(os.path.relpath(os.path.join(root, file), path))

# print('\n'.join(file_list))




import os

def read_files_recursively(root_dir, skip_files=None, output_file='project_contents.txt'):
    if skip_files is None:
        skip_files = []
    with open(output_file, 'w', encoding='utf-8') as out_f:
        for dirpath, dirnames, filenames in os.walk(root_dir):
            # Skip directories in skip_files (e.g., 'node_modules', '.git')
            dirnames[:] = [d for d in dirnames if d not in skip_files]
            for filename in filenames:
                if filename in skip_files:
                    continue
                file_path = os.path.join(dirpath, filename)
                rel_path = os.path.relpath(file_path, root_dir)
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                    # Write relative file path and contents to output file
                    out_f.write(f"File: {rel_path}\n")
                    out_f.write("=" * 80 + "\n")
                    out_f.write(content)
                    out_f.write("\n\n" + "=" * 80 + "\n\n")
                except Exception as e:
                    # Could not read file (binary, encoding, or permission issues), skip
                    out_f.write(f"File: {rel_path}\n")
                    out_f.write("=" * 80 + "\n")
                    out_f.write(f"[Error reading file: {str(e)}]\n")
                    out_f.write("\n\n" + "=" * 80 + "\n\n")

# Example usage: customize this list as needed
skip_list = ['list_files.py', 'Assets.xcassets', '.git', 'README.md', '.DS_Store', '.env', 'package-lock.json', 'yarn.lock', 'package.json', '.next', '.env.local', 'public']

# Replace '/path/to/your/project' with your actual project path
project_root = '/Users/austin/Documents/CSProjs/FocusIsland-Mac/FocusIsland/FocusIsland'
read_files_recursively(project_root, skip_list)
