import re
import os
import csv

def extract_r_code_from_rmd(file_path):
    """
    Extract R code blocks from an Rmd file.

    :param file_path: Path to the .Rmd file.
    :return: A list of R code strings.
    """
    with open(file_path, "r", encoding="utf-8") as file:
        content = file.read()

    # Match R code blocks: ```{r} ... ```
    code_blocks = re.findall(r"```{r.*?}\n(.*?)```", content, re.DOTALL)
    return code_blocks

def extract_functions_and_packages(r_code):
    """
    Extract functions and their packages from R code.

    :param r_code: R code as a string.
    :return: A dictionary of functions and their packages.
    """
    functions = set()
    packages = {}

    # Match library(package) or require(package)
    for match in re.findall(r"(library|require)\((.*?)\)", r_code):
        package = match[1]
        packages[package] = []

    # Match :: operator for package-specific function calls
    for match in re.findall(r"([a-zA-Z0-9_]+)::([a-zA-Z0-9_]+)", r_code):
        package, function = match
        packages.setdefault(package, []).append(function)
        functions.add(function)

    # Match standalone function calls
    for match in re.findall(r"\b([a-zA-Z0-9_]+)\s*\(", r_code):
        functions.add(match)

    return functions, packages

def process_rmd_file(file_path):
    """
    Process an Rmd file to extract functions and packages.

    :param file_path: Path to the .Rmd file.
    :return: A list of (function, package) tuples.
    """
    code_blocks = extract_r_code_from_rmd(file_path)
    all_functions = set()
    all_packages = {}

    for code in code_blocks:
        functions, packages = extract_functions_and_packages(code)
        all_functions.update(functions)
        for pkg, funcs in packages.items():
            all_packages.setdefault(pkg, set()).update(funcs)

    results = []
    for function in all_functions:
        # Try to find the package for the function, if any
        package = None
        for pkg, funcs in all_packages.items():
            if function in funcs:
                package = pkg
                break
        results.append((function, package))

    return results

def process_rmd_folder(folder_path, output_csv):
    """
    Process all Rmd files in a folder to extract functions and packages.

    :param folder_path: Path to the folder containing Rmd files.
    :param output_csv: Path to the output CSV file.
    """
    results = []
    for root, _, files in os.walk(folder_path):
        for file in files:
            if file.endswith(".Rmd"):
                file_path = os.path.join(root, file)
                print(f"Processing: {file_path}")
                file_results = process_rmd_file(file_path)
                for function, package in file_results:
                    results.append({"Filename": file, "Function": function, "Package": package})

    # Write results to CSV
    with open(output_csv, "w", newline="", encoding="utf-8") as csvfile:
        fieldnames = ["Filename", "Function", "Package"]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(results)

if __name__ == "__main__":
    # Example usage
    folder_path = "./"  # Replace with the path to your Rmd folder
    output_csv = "./rmd_functions_packages.csv"
    process_rmd_folder(folder_path, output_csv)
    print(f"Results saved to {output_csv}")
