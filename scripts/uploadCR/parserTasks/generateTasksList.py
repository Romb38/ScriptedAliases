#!/usr/bin/env python3
import argparse
import os
import nf

def main():
    parser = argparse.ArgumentParser(description="Generate CSV and/or TXT files.")
    parser.add_argument(
        "-c", "--csv",
        action="store_true",
        help="Generate a CSV file."
    )
    parser.add_argument(
        "-t", "--txt",
        action="store_true",
        help="Generate a TXT file."
    )
    parser.add_argument(
        "-o", "--outputpath",
        type=str,
        default=os.getcwd(),
        help="Output path for the generated files (default: current directory)."
    )

    args = parser.parse_args()

    if not (args.csv or args.txt):
        parser.error("At least one of -c/--csv or -t/--txt must be provided.")

    output_path = args.outputpath
    if not os.path.exists(output_path):
        os.makedirs(output_path)

    lines = nf.getTexFile(output_path)
    toWrite = nf.parsing_texFile(lines)

    if args.csv:
        nf.toCSV(toWrite, output_path)
    if args.txt:
        nf.toTxt(toWrite, output_path)

if __name__ == "__main__":
    main()
